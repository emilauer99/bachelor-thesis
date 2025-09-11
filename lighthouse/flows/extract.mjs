// lh-timespan-extract.mjs
import fs from 'node:fs';
import path from 'node:path';

// ---------- IO ----------
const read = p => fs.readFileSync(p, 'utf8');
function writeUtf8WithBOM(p, s) { fs.writeFileSync(p, '\uFEFF' + s, 'utf8'); }

// ---------- Helpers ----------
const normalizeDisplay = s => s == null ? '' : String(s).replace(/[\u00A0\u202F\u2009]/g, ' ').trim();
const round = (v, d = 1) => v == null ? null : +Number(v).toFixed(d);
const pick = (o, k, d=undefined) => (o && o[k] !== undefined ? o[k] : d);
const msToSecDisp = ms => ms == null ? '' : `${(ms/1000).toFixed(1)} s`;
const msDisp = ms => ms == null ? '' : `${Math.round(ms)} ms`;
const getArg = (name, def=null) => {
    const m = process.argv.find(x => x.startsWith(name + '=')); return m ? m.split('=')[1] : def;
};
function toCsv(rows) {
    if (!rows.length) return 'sep=;\n';
    const header = Object.keys(rows[0]);
    const esc = v => v == null ? '' : (/[",;\n]/.test(String(v)) ? `"${String(v).replace(/"/g,'""')}"` : String(v));
    return ['sep=;', header.join(';'), ...rows.map(r => header.map(k => esc(r[k])).join(';'))].join('\n');
}

// ---------- Parse LHR from Timespan HTML ----------
function extractLhrFromHtml(html) {
    const re = /window\.__LIGHTHOUSE_JSON__\s*=\s*({[\s\S]*?})\s*;?\s*<\/script>/i;
    const m = html.match(re);
    if (!m) throw new Error('LIGHTHOUSE_JSON not found');
    return JSON.parse(m[1]);
}
function filesFromArg(inputPath, from=1, to=10) {
    const p = path.resolve(inputPath);
    const st = fs.statSync(p);
    if (st.isDirectory()) {
        const out = [];
        for (let i = from; i <= to; i++) {
            const f = path.join(p, `${i}.html`);
            if (fs.existsSync(f)) out.push(f);
        }
        return out;
    }
    return [p];
}

// ---------- Metrics ----------
const audit = (lhr, id) => (lhr?.audits && lhr.audits[id]) || {};
const metricsItem = lhr => lhr?.audits?.metrics?.details?.items?.[0] || {};

function getTimespanMetrics(lhr) {
    // TBT
    const aTbt = audit(lhr, 'total-blocking-time');
    const tbtMs = aTbt.numericValue ?? metricsItem(lhr).totalBlockingTime;
    const tbt = normalizeDisplay(aTbt.displayValue) || (tbtMs != null ? (tbtMs >= 1000 ? msToSecDisp(tbtMs) : msDisp(tbtMs)) : '');

    // CLS
    const aCls = audit(lhr, 'cumulative-layout-shift');
    const clsNum = aCls.numericValue ?? metricsItem(lhr).cumulativeLayoutShift ?? metricsItem(lhr).observedCumulativeLayoutShift;
    const cls = normalizeDisplay(aCls.displayValue) || (clsNum != null ? String(clsNum) : '');

    // INP (verschiedene IDs + Fallbacks)
    const aInp = audit(lhr, 'interaction-to-next-paint') || audit(lhr, 'experimental-interaction-to-next-paint');
    let inpMs = aInp?.numericValue;
    if (inpMs == null) {
        const m = metricsItem(lhr);
        const cand = [
            'observedInteractionToNextPaint',
            'observedExperimentalInteractionToNextPaint',
            'interactionToNextPaint',
            'experimentalInteractionToNextPaint'
        ];
        for (const k of cand) if (typeof m?.[k] === 'number') { inpMs = m[k]; break; }
    }
    const inp = normalizeDisplay(aInp?.displayValue) || (inpMs != null ? (inpMs >= 1000 ? msToSecDisp(inpMs) : msDisp(inpMs)) : '');

    return {
        tbt_ms: round(tbtMs, 1),
        tbt,
        cls_value: clsNum == null ? null : +clsNum,
        cls,
        inp_ms: round(inpMs, 1),
        inp
    };
}

function getReportDetails(lhr) {
    return {
        fetchTime: lhr.fetchTime,
        lighthouseVersion: lhr.lighthouseVersion,
        gatherMode: lhr.gatherMode, // "timespan"
        formFactor: lhr.configSettings?.formFactor,
        throttlingMethod: lhr.configSettings?.throttlingMethod,
        screenEmulation: lhr.configSettings?.screenEmulation,
        channel: lhr.configSettings?.channel,
        userAgent: lhr.environment?.hostUserAgent || lhr.userAgent
    };
}

// ---------- Main ----------
(function main() {
    const arg = process.argv[2];
    if (!arg) {
        console.error('Usage: node lh-timespan-extract.mjs <file.html | folder> [--from=1 --to=10]');
        process.exit(1);
    }
    const from = parseInt(getArg('--from', '1'), 10);
    const to   = parseInt(getArg('--to',   '10'), 10);

    const files = filesFromArg(arg, from, to);
    const rows = [];
    const details = [];

    for (const file of files) {
        try {
            const html = read(file);
            const lhr = extractLhrFromHtml(html);
            const m = getTimespanMetrics(lhr);
            const d = getReportDetails(lhr);

            rows.push({
                file: path.basename(file),
                url: lhr.finalDisplayedUrl || lhr.finalUrl || lhr.requestedUrl || '',
                TBT: m.tbt,
                CLS: m.cls,
                INP: m.inp,
                // numerisch:
                TBT_ms: m.tbt_ms,
                CLS_value: m.cls_value,
                INP_ms: m.inp_ms,
                captured_at: d.fetchTime,
                lighthouse: d.lighthouseVersion,
                gatherMode: d.gatherMode,
                formFactor: d.formFactor,
                throttlingMethod: d.throttlingMethod,
                channel: d.channel
            });

            details.push({
                file: path.basename(file),
                url: lhr.finalDisplayedUrl || lhr.finalUrl || lhr.requestedUrl || '',
                metrics: m,
                report_details: d
            });
        } catch (e) {
            console.error(`⚠️  ${path.basename(file)}: ${e.message}`);
        }
    }

    // ---- Durchschnittszeile (AVG) über alle Reports ----
    const avg = (key) => {
        const vals = rows.map(r => r[key]).filter(v => typeof v === 'number' && !isNaN(v));
        if (!vals.length) return null;
        return vals.reduce((a,b)=>a+b,0) / vals.length;
    };
    const avgTbt = avg('TBT_ms');
    const avgCls = avg('CLS_value');
    const avgInp = avg('INP_ms');

    rows.push({
        file: 'AVG',
        url: '',
        TBT: avgTbt == null ? '' : (avgTbt >= 1000 ? msToSecDisp(avgTbt) : msDisp(avgTbt)),
        CLS: avgCls == null ? '' : String(+avgCls.toFixed(3)),
        INP: avgInp == null ? '' : (avgInp >= 1000 ? msToSecDisp(avgInp) : msDisp(avgInp)),
        TBT_ms: avgTbt == null ? '' : +avgTbt.toFixed(1),
        CLS_value: avgCls == null ? '' : +avgCls.toFixed(4),
        INP_ms: avgInp == null ? '' : +avgInp.toFixed(1),
        captured_at: '',
        lighthouse: '',
        gatherMode: '',
        formFactor: '',
        throttlingMethod: '',
        channel: ''
    });

    const outDir = path.dirname(path.resolve(files[0] || arg));
    const csvPath = path.join(outDir, 'timespan_summary.csv');
    const jsonPath = path.join(outDir, 'timespan_details.json');

    writeUtf8WithBOM(csvPath, toCsv(rows));
    fs.writeFileSync(jsonPath, JSON.stringify({ reports: details }, null, 2), 'utf8');

    console.log(`✅ Extracted ${details.length} report(s).`);
    console.log(`CSV:  ${csvPath}`);
    console.log(`JSON: ${jsonPath}`);
})();
