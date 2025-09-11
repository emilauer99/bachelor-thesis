// lighthouse-flow-runner.mjs
import {writeFileSync} from 'fs';
import puppeteer from 'puppeteer';
import {startFlow, desktopConfig as lhDesktopConfig} from 'lighthouse';

function usageAndExit(msg) {
    if (msg) console.error(`\nError: ${msg}\n`);
    console.log(
        `Usage: node lighthouse-flow-runner.mjs --mode=<angular|flutter|flutter_wasm> --subpath=<path> --desktopConfig=<true|false> --runs=<n>

Example:
  node lighthouse-flow-runner.mjs --mode=angular --subpath=/login --desktopConfig=true --runs=3`
    );
    process.exit(1);
}

function parseArgs(argv) {
    const args = {};
    for (const arg of argv) {
        if (arg.startsWith('--')) {
            const [key, value] = arg.slice(2).split('=');
            args[key] = value;
        }
    }
    return args;
}

function parseBool(v) {
    const s = (v ?? '').toLowerCase().trim();
    if (s === 'true') return true;
    if (s === 'false') return false;
    usageAndExit(`desktopConfig must be 'true' or 'false', got '${v}'`);
}

function baseUrlFor(mode) {
    switch (mode) {
        case 'angular':
            return 'http://localhost:4000';
        case 'flutter':
            return 'http://localhost:5000/#';
        case 'flutter_wasm':
            return 'http://localhost:5200/#';
        default:
            usageAndExit(`Unknown mode '${mode}'`);
    }
}

function normalizeSubpath(p) {
    if (!p) return '/';
    return p.startsWith('/') ? p : `/${p}`;
}

async function main() {
    const args = parseArgs(process.argv.slice(2));

    const mode = args.mode || usageAndExit('Missing --mode');
    const subpath = normalizeSubpath(args.subpath || usageAndExit('Missing --subpath'));
    const useDesktopConfig = parseBool(args.desktopConfig ?? usageAndExit('Missing --desktopConfig'));
    const runs = Number.parseInt(args.runs ?? usageAndExit('Missing --runs'), 10);
    if (!Number.isFinite(runs) || runs < 1) usageAndExit(`--runs must be an integer >= 1, got '${args.runs}'`);

    const base = baseUrlFor(mode);
    const url = `${base}${subpath}`;

    for (let i = 1; i <= runs; i++) {
        const browser = await puppeteer.launch({
            args: [
                '--disable-background-timer-throttling',
                '--disable-backgrounding-occluded-windows',
                '--disable-renderer-backgrounding',
                '--no-sandbox',
                '--disable-dev-shm-usage',
                '--window-size=1280,900',
                '--disable-service-worker',
            ],
            defaultViewport: {width: 1280, height: 900, deviceScaleFactor: 1},
        });
        const page = await browser.newPage();
        const startFlowOptions = useDesktopConfig
            ? {config: lhDesktopConfig, name: 'Cold and warm navigations'}
            : undefined;

        const flow = await startFlow(page, startFlowOptions);

        await flow.navigate(url, {
            name: 'Cold navigation'
        });
        if (mode == 'flutter_wasm' || mode == 'flutter') {
            // await waitForFlutterPaint();
            await page.waitForSelector('pierce/canvas', {timeout: 30000});
            await flow.startNavigation({
                configContext: {
                    settingsOverrides: {disableStorageReset: true},
                },
                name: 'Warm navigation'
            });
                await page.reload();
            await flow.endNavigation();
        } else {
            await flow.navigate(url, {
                configContext: {
                    settingsOverrides: {disableStorageReset: true},
                },
                name: 'Warm navigation'
            });
        }
        const reportHtml = await flow.generateReport();
        const filename = `${i}_report.html`;
        writeFileSync(filename, reportHtml);
        console.log(`Saved ${filename}`);
        await browser.close();
    }
}

main().catch((err) => {
    console.error('Unhandled error:', err);
    process.exit(1);
});
