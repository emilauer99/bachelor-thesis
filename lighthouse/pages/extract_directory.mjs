// lh-flow-extract-batch.mjs
import fs from 'node:fs';
import path from 'node:path';

// ---------- IO ----------
function readFile(p) {
    try { return fs.readFileSync(p, 'utf8'); }
    catch (e) { console.error('Konnte Datei nicht lesen:', p); return null; }
}
function writeUtf8WithBOM(p, s) {
    const BOM = '\uFEFF';
    fs.writeFileSync(p, BOM + s, 'utf8');
}

// ---------- Helpers ----------
const pick = (o, k, d = undefined) => (o && o[k] !== undefined ? o[k] : d);
const round = (v, d = 2) => (v === undefined || v === null) ? v : +Number(v).toFixed(d);
const normalizeDisplay = (s) => {
    if (s == null) return '';
    return String(s).replace(/[\u00A0\u202F\u2007\u2009]/g, ' ').trim();
};
const msToSecDisp = (ms) => ms == null ? '' : `${(ms/1000).toFixed(1)} s`;
const msDisp = (ms) => ms == null ? '' : `${Math.round(ms)} ms`;
function toCsv(rows) {
    if (!rows.length) return 'sep=;\n';
    const header = Object.keys(rows[0]);
    const esc = (v) => {
        if (v === null || v === undefined) return '';
        const s = String(v);
        return /[",;\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
    };
    return ['sep=;', header.join(';'), ...rows.map(r => header.map(k => esc(r[k])).join(';'))].join('\n');
}
function getArg(name, def=null){
    const m = process.argv.find(x=>x.startsWith(name+'='));
    return m ? m.split('=')[1] : def;
}

// ---------- Extractors ----------
function extractFlowJson(html) {
    const re = /window\.__LIGHTHOUSE_FLOW_JSON__\s*=\s*({[\s\S]*?})\s*;?\s*<\/script>/i;
    const m = html.match(re);
    if (!m) return null;
    try { return JSON.parse(m[1]); } catch { return null; }
}
function extractSingleJson(html){
    const m1 = html.match(/<script[^>]*id=["']__LIGHTHOUSE_JSON__["'][^>]*>([\s\S]*?)<\/script>/i);
    if (m1) { try { return JSON.parse(m1[1]); } catch {} }
    const m2 = html.match(/window\.__LIGHTHOUSE_JSON__\s*=\s*({[\s\S]*?})\s*;?\s*<\/script>/i);
    if (m2) { try { return JSON.parse(m2[1]); } catch {} }
    return null;
}

// ---------- Metrics ----------
function getPerfScore(lhr) {
    const perf = pick(pick(lhr, 'categories', {}), 'performance', {});
    if (typeof perf.score === 'number') return Math.round(perf.score * 100);
    const audits = pick(lhr, 'audits', {});
    const weights = {};
    for (const ref of (perf.auditRefs || [])) weights[ref.id] = ref.weight || 0;
    let num = 0, den = 0;
    for (const id of Object.keys(weights)) {
        const w = weights[id]; if (!w) continue;
        const s = audits[id]?.score;
        if (typeof s === 'number') { num += s * w; den += w; }
    }
    return den ? Math.round((num/den)*100) : null;
}
function getCoreMetrics(lhr) {
    const a = lhr.audits || {};
    const get = id => a[id] || {};
    const val = x => x?.numericValue;
    const _fcp = get('first-contentful-paint');
    const _lcp = get('largest-contentful-paint');
    const _tbt = get('total-blocking-time');
    const _cls = get('cumulative-layout-shift');
    const _si  = get('speed-index');
    return {
        fcp_ms: round(val(_fcp), 1),
        lcp_ms: round(val(_lcp), 1),
        tbt_ms: round(val(_tbt), 1),
        cls_value: round(val(_cls), 4),
        speed_index_ms: round(val(_si), 1),
        fcp: normalizeDisplay(_fcp?.displayValue),
        lcp: normalizeDisplay(_lcp?.displayValue),
        tbt: normalizeDisplay(_tbt?.displayValue),
        cls: normalizeDisplay(_cls?.displayValue ?? String(val(_cls) ?? '')),
        speed_index: normalizeDisplay(_si?.displayValue),
    };
}
function getReportDetails(lhr) {
    const env = lhr.environment || {};
    const cfg = lhr.configSettings || {};
    return {
        captured_at: lhr.fetchTime,
        lighthouse_version: lhr.lighthouseVersion,
        requested_url: lhr.requestedUrl,
        final_url: lhr.finalUrl,
        user_agent: env.hostUserAgent || lhr.userAgent,
        form_factor: cfg.formFactor,
        throttling_method: cfg.throttlingMethod,
        throttling: cfg.throttling,
        screen_emulation: cfg.screenEmulation,
        emulated_user_agent: cfg.emulatedUserAgent,
        channel: cfg.channel,
        gather_mode: lhr.gatherMode,
        run_warnings: lhr.runWarnings || [],
        metrics_debug: lhr.audits?.metrics?.details?.items?.[0] ?? null,
    };
}

// ---------- Main ----------
(async function main() {
    const dir = process.argv[2];
    if (!dir) {
        console.error('Usage: node lh-flow-extract-batch.mjs <folder> [--from=1 --to=10]');
        process.exit(1);
    }
    const from = parseInt(getArg('--from', '1'), 10);
    const to   = parseInt(getArg('--to',   '10'), 10);

    const rows = [];          // CSV rows (inkl. numeric)
    const details = [];       // JSON details
    const perStepNumeric = new Map(); // step_index -> array of numeric objects for averaging
    const perStepName = new Map();    // step_index -> most recent name (für die AVG-Zeile)

    let filesProcessed = 0, stepsTotal = 0;

    for (let i = from; i <= to; i++) {
        const file = path.join(dir, `${i}_report.html`);
        if (!fs.existsSync(file)) { console.warn(`⚠️  ${i}.html nicht gefunden – übersprungen.`); continue; }

        const html = readFile(file); if (!html) continue;

        let steps = [];
        let stepMeta = [];
        const flow = extractFlowJson(html);
        if (flow?.steps?.length) {
            steps = flow.steps.map(s => s.lhr || s);
            stepMeta = flow.steps;
        } else {
            const lhr = extractSingleJson(html);
            if (lhr) { steps = [lhr]; stepMeta = [{ name: 'Page load' }]; }
        }
        if (!steps.length) { console.warn(`⚠️  Keine Steps in ${i}_report.html gefunden.`); continue; }

        steps.forEach((lhr, idx) => {
            const meta = stepMeta[idx] || {};
            const stepName = meta.name || meta.stepName || meta.mode || `Step ${idx+1}`;
            const perf = getPerfScore(lhr);
            const m = getCoreMetrics(lhr);
            const d = getReportDetails(lhr);

            rows.push({
                report: i,
                step_index: idx + 1,
                step_name: stepName,
                url: lhr.requestedUrl || lhr.finalUrl || '',
                performance: perf,
                FCP: m.fcp,
                LCP: m.lcp,
                TBT: m.tbt,
                CLS: m.cls,
                SpeedIndex: m.speed_index,
                // numerisch für Auswertungen:
                FCP_ms: m.fcp_ms,
                LCP_ms: m.lcp_ms,
                TBT_ms: m.tbt_ms,
                CLS_value: m.cls_value,
                SpeedIndex_ms: m.speed_index_ms,
            });

            details.push({
                report: i,
                step_index: idx + 1,
                step_name: stepName,
                url: lhr.requestedUrl || lhr.finalUrl || '',
                performance_score: perf,
                core_metrics: m,
                report_details: d,
            });

            const key = idx + 1;
            if (!perStepNumeric.has(key)) perStepNumeric.set(key, []);
            perStepNumeric.get(key).push({
                performance: perf,
                FCP_ms: m.fcp_ms,
                LCP_ms: m.lcp_ms,
                TBT_ms: m.tbt_ms,
                CLS_value: m.cls_value,
                SpeedIndex_ms: m.speed_index_ms,
            });
            perStepName.set(key, stepName);
        });

        filesProcessed++;
        stepsTotal += steps.length;
        console.log(`✓ ${i}_report.html → ${steps.length} Step(s)`);
    }

    // ---- AVG-Zeilen pro Step anhängen ----
    const avgRows = [];
    const avgOf = (arr, key) => {
        const vals = arr.map(o => o[key]).filter(v => typeof v === 'number' && !isNaN(v));
        if (!vals.length) return null;
        return vals.reduce((a,b)=>a+b,0) / vals.length;
    };

    for (const [stepIdx, arr] of Array.from(perStepNumeric.entries()).sort((a,b)=>a[0]-b[0])) {
        const name = perStepName.get(stepIdx) || `Step ${stepIdx}`;
        const avgPerf = avgOf(arr, 'performance');
        const fcp = avgOf(arr, 'FCP_ms');
        const lcp = avgOf(arr, 'LCP_ms');
        const tbt = avgOf(arr, 'TBT_ms');
        const cls = avgOf(arr, 'CLS_value');
        const si  = avgOf(arr, 'SpeedIndex_ms');

        avgRows.push({
            report: 'AVG',
            step_index: stepIdx,
            step_name: `${name} (avg)`,
            url: '',
            performance: avgPerf == null ? '' : Math.round(avgPerf),
            FCP: msToSecDisp(fcp),
            LCP: msToSecDisp(lcp),
            TBT: msDisp(tbt),
            CLS: cls == null ? '' : String(+cls.toFixed(3)),
            SpeedIndex: msToSecDisp(si),
            FCP_ms: fcp == null ? '' : +fcp.toFixed(1),
            LCP_ms: lcp == null ? '' : +lcp.toFixed(1),
            TBT_ms: tbt == null ? '' : +tbt.toFixed(1),
            CLS_value: cls == null ? '' : +cls.toFixed(4),
            SpeedIndex_ms: si == null ? '' : +si.toFixed(1),
        });
    }

    const outDir = path.resolve(dir);
    const csvPath = path.join(outDir, 'combined_summary.csv');
    const jsonPath = path.join(outDir, 'combined_details.json');

    // CSV: erst alle Einzel-Zeilen, dann die AVG-Zeilen
    writeUtf8WithBOM(csvPath, toCsv([...rows, ...avgRows]));
    fs.writeFileSync(jsonPath, JSON.stringify({ steps: details }, null, 2), 'utf8');

    console.log(`\n✅ Fertig. Dateien verarbeitet: ${filesProcessed}, Steps gesamt: ${stepsTotal}`);
    console.log(`CSV:  ${csvPath}`);
    console.log(`JSON: ${jsonPath}`);
})();
