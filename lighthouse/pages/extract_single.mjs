// extract_single.mjs
import fs from 'node:fs';
import path from 'node:path';

// ---------- IO ----------
function readFile(p) {
    try { return fs.readFileSync(p, 'utf8'); }
    catch (e) { console.error('Konnte Datei nicht lesen:', p); process.exit(1); }
}
function writeUtf8WithBOM(p, s) {
    const BOM = '\uFEFF';
    fs.writeFileSync(p, BOM + s, 'utf8');
}

// ---------- Helpers ----------
const pick = (o, k, d = undefined) => (o && o[k] !== undefined ? o[k] : d);
const round = (v, d = 2) => (v === undefined || v === null) ? v : +v.toFixed(d);
const normalizeDisplay = (s) => {
    if (s == null) return '';
    return String(s)
        // NBSP / thin spaces / figure spaces -> normales Leerzeichen
        .replace(/[\u00A0\u202F\u2007\u2009]/g, ' ')
        .trim();
};

// Robust den JSON-Blob aus dem HTML holen
function extractFlowJson(html) {
    const marker = 'window.__LIGHTHOUSE_FLOW_JSON__';
    const re = new RegExp(
        String.raw`${marker}\s*=\s*({[\s\S]*?})\s*;?\s*<\/script>`,
        'i'
    );
    const m = html.match(re);
    if (!m) throw new Error('FLOW JSON nicht gefunden (window.__LIGHTHOUSE_FLOW_JSON__)');
    return JSON.parse(m[1]);
}

// Performance-Score (oder gewichtet berechnen)
function getPerfScore(lhr) {
    const perf = pick(pick(lhr, 'categories', {}), 'performance', {});
    if (typeof perf.score === 'number') return Math.round(perf.score * 100);
    const audits = pick(lhr, 'audits', {});
    const weights = {};
    for (const ref of (perf.auditRefs || [])) weights[ref.id] = ref.weight || 0;
    let num = 0, den = 0;
    for (const id of Object.keys(weights)) {
        const w = weights[id];
        if (!w) continue;
        const s = pick(audits[id] || {}, 'score', null);
        if (typeof s === 'number') { num += s * w; den += w; }
    }
    return den ? Math.round((num / den) * 100) : null;
}

// Kernmetriken aus Audits
function getCoreMetrics(lhr) {
    const a = lhr.audits || {};
    const get = (id) => a[id] || {};
    const val = (x) => x?.numericValue;

    const _fcp = get('first-contentful-paint');
    const _lcp = get('largest-contentful-paint');
    const _tbt = get('total-blocking-time');
    const _cls = get('cumulative-layout-shift');
    const _si  = get('speed-index');

    return {
        // numerisch (ms bzw. CLS als unitless)
        fcp_ms: round(val(_fcp), 1),
        lcp_ms: round(val(_lcp), 1),
        tbt_ms: round(val(_tbt), 1),
        cls_value: round(val(_cls), 4),
        speed_index_ms: round(val(_si), 1),
        // display strings (bereinigt -> keine "Â")
        fcp: normalizeDisplay(_fcp?.displayValue),
        lcp: normalizeDisplay(_lcp?.displayValue),
        tbt: normalizeDisplay(_tbt?.displayValue),
        cls: normalizeDisplay(_cls?.displayValue ?? String(val(_cls) ?? '')),
        speed_index: normalizeDisplay(_si?.displayValue),
    };
}

// Report-/Footer-Details (entsprechen Bild 3/4)
function getReportDetails(lhr) {
    const env = lhr.environment || {};
    const cfg = lhr.configSettings || {};
    const metricsDebug = pick(lhr.audits?.metrics?.details || {}, 'items', [])[0] || null;
    return {
        captured_at: lhr.fetchTime,
        lighthouse_version: lhr.lighthouseVersion,
        requested_url: lhr.requestedUrl,
        final_url: lhr.finalUrl,
        user_agent: env.hostUserAgent || lhr.userAgent,
        network_user_agent: env.networkUserAgent,
        benchmark_index: env.benchmarkIndex,
        form_factor: cfg.formFactor,
        throttling_method: cfg.throttlingMethod,
        throttling: cfg.throttling,
        screen_emulation: cfg.screenEmulation,
        emulated_user_agent: cfg.emulatedUserAgent,
        channel: cfg.channel,
        gather_mode: lhr.gatherMode,        // z.B. "navigation"
        run_warnings: lhr.runWarnings || [],
        metrics_debug: metricsDebug          // TTI, FMP, etc. (wenn vorhanden)
    };
}

// CSV
function toCsv(rows) {
    if (!rows.length) return '';
    const header = Object.keys(rows[0]);
    const esc = (v) => {
        if (v === null || v === undefined) return '';
        const s = String(v);
        return /[",;\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
    };
    const lines = [
        'sep=;',                              // Excel Hint
        header.join(';'),
        ...rows.map(r => header.map(k => esc(r[k])).join(';'))
    ];
    return lines.join('\n');
}

// ---------- Main ----------
function main() {
    const file = process.argv[2];
    if (!file) {
        console.error('Usage: node lh-flow-extract_single.mjs /path/to/1_report.html');
        process.exit(1);
    }

    const html = readFile(file);
    const flow = extractFlowJson(html);
    const steps = flow.steps || [];

    const summaryRows = [];
    const all = [];

    steps.forEach((step, i) => {
        const lhr = step.lhr || step;
        const name = step.name || step.stepName || step.mode || `Step ${i + 1}`;
        const perfScore = getPerfScore(lhr);
        const m = getCoreMetrics(lhr);
        const d = getReportDetails(lhr);

        summaryRows.push({
            step_index: i + 1,
            step_name: name,
            url: lhr.requestedUrl || lhr.finalUrl || '',
            performance: perfScore,
            FCP: m.fcp,
            LCP: m.lcp,
            TBT: m.tbt,
            CLS: m.cls,
            SpeedIndex: m.speed_index,
        });

        all.push({
            step_index: i + 1,
            step_name: name,
            url: lhr.requestedUrl || lhr.finalUrl || '',
            performance_score: perfScore,
            core_metrics: m,
            report_details: d,
        });
    });

    const outDir = path.dirname(path.resolve(file));
    const csvPath = path.join(outDir, 'flow_summary.csv');
    const jsonPath = path.join(outDir, 'flow_details.json');

    writeUtf8WithBOM(csvPath, toCsv(summaryRows));               // CSV (Excel-freundlich)
    fs.writeFileSync(jsonPath, JSON.stringify({ steps: all }, null, 2), 'utf8'); // JSON

    console.log(`✅ Extracted ${all.length} step(s).`);
    console.log(`CSV:  ${csvPath}`);
    console.log(`JSON: ${jsonPath}`);
}

main();
