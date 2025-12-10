<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Trivy Vulnerability Report</title>
<style>
  body { font-family: Arial, sans-serif; margin: 18px; background: #fafafa; color:#222; }
  h1 { margin-bottom: 6px; }
  .meta { margin-bottom:16px; color:#444; }
  .summary-box { display:flex; gap:12px; margin-bottom:18px; flex-wrap:wrap; }
  .badge { padding:10px 12px; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,0.06); min-width:120px; text-align:center; }
  .crit { background:#ffecec; color:#b22222; font-weight:700; }   /* red-ish */
  .high { background:#fff4e6; color:#b35a00; font-weight:700; }   /* orange */
  .med  { background:#fffbe6; color:#8a6b00; font-weight:700; }   /* yellow */
  .low  { background:#eefaf0; color:#1b6b2c; font-weight:700; }   /* green */
  .unk  { background:#f0f0f0; color:#666; font-weight:700; }     /* gray */

  .chart-row { display:flex; gap:18px; flex-wrap:wrap; margin-bottom:24px; }
  canvas { background: #fff; border-radius:6px; padding:8px; box-shadow:0 1px 4px rgba(0,0,0,0.04); }

  table { border-collapse: collapse; width: 100%; margin-top: 14px; background:#fff; }
  th, td { padding:10px 8px; border:1px solid #e6e6e6; font-size:13px; vertical-align:top; }
  th { background:#f3f6f9; color:#333; text-align:left; }
  .sev-CRITICAL { background:#ff4d4f; color:white; padding:4px 8px; border-radius:4px; font-weight:700; }
  .sev-HIGH     { background:#ff9800; color:#222; padding:4px 8px; border-radius:4px; font-weight:700; }
  .sev-MEDIUM   { background:#ffc107; color:#222; padding:4px 8px; border-radius:4px; font-weight:700; }
  .sev-LOW      { background:#8bc34a; color:white; padding:4px 8px; border-radius:4px; font-weight:700; }
  .sev-UNKNOWN  { background:#9e9e9e; color:white; padding:4px 8px; border-radius:4px; font-weight:700; }

  .small { font-size:12px; color:#666; }
  .mono { font-family:monospace; font-size:12px; color:#333; }
  .layer-cell { font-size:12px; color:#444; background:#fbfbfb; padding:6px; border-radius:4px; }
</style>
</head>
<body>

<h1>🔐 Trivy Vulnerability Report</h1>

<div class="meta">
  <span class="small">Image: <b>{{ getenv "TRIVY_IMAGE" }}</b></span> &nbsp; • &nbsp;
  <span class="small">Build: <b>{{ getenv "TRIVY_BUILD_NUMBER" }}</b></span> &nbsp; • &nbsp;
  <span class="small">Run: <b>{{ getenv "TRIVY_TIMESTAMP" }}</b></span>
</div>

{{/* ===== compute counters ===== */}}
{{ $crit := 0 }} {{ $high := 0 }} {{ $med := 0 }} {{ $low := 0 }} {{ $unk := 0 }}

{{ range . }}
  {{ range .Vulnerabilities }}
    {{ if eq .Severity "CRITICAL" }}{{ $crit = add $crit 1 }}{{ end }}
    {{ if eq .Severity "HIGH" }}{{ $high = add $high 1 }}{{ end }}
    {{ if eq .Severity "MEDIUM" }}{{ $med = add $med 1 }}{{ end }}
    {{ if eq .Severity "LOW" }}{{ $low = add $low 1 }}{{ end }}
    {{ if eq .Severity "UNKNOWN" }}{{ $unk = add $unk 1 }}{{ end }}
  {{ end }}
{{ end }}

<div class="summary-box">
  <div class="badge crit">Critical<br><span style="font-size:18px">{{ $crit }}</span></div>
  <div class="badge high">High<br><span style="font-size:18px">{{ $high }}</span></div>
  <div class="badge med">Medium<br><span style="font-size:18px">{{ $med }}</span></div>
  <div class="badge low">Low<br><span style="font-size:18px">{{ $low }}</span></div>
  <div class="badge unk">Unknown<br><span style="font-size:18px">{{ $unk }}</span></div>
</div>

<div class="chart-row">
  <div style="flex:1; min-width:280px;">
    <canvas id="pieChart" width="380" height="260"></canvas>
  </div>
  <div style="flex:1; min-width:320px;">
    <canvas id="barChart" width="480" height="260"></canvas>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
  const counts = {
    critical: {{ $crit }},
    high: {{ $high }},
    medium: {{ $med }},
    low: {{ $low }},
    unknown: {{ $unk }}
  };

  // Pie
  new Chart(document.getElementById('pieChart'), {
    type: 'pie',
    data: {
      labels: ['Critical','High','Medium','Low','Unknown'],
      datasets: [{
        data: [counts.critical, counts.high, counts.medium, counts.low, counts.unknown],
        backgroundColor: ['#ff4d4f','#ff9800','#ffc107','#8bc34a','#9e9e9e']
      }]
    },
    options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
  });

  // Bar
  new Chart(document.getElementById('barChart'), {
    type: 'bar',
    data: {
      labels: ['Critical','High','Medium','Low','Unknown'],
      datasets: [{
        label: 'Vulnerabilities',
        data: [counts.critical, counts.high, counts.medium, counts.low, counts.unknown],
        backgroundColor: ['#ff4d4f','#ff9800','#ffc107','#8bc34a','#9e9e9e']
      }]
    },
    options: { responsive: true, scales: { y: { beginAtZero: true } }, plugins: { legend: { display: false } } }
  });
</script>

<hr/>

<h2>🔥 Top Critical & High Vulnerabilities</h2>
<table>
  <thead>
    <tr>
      <th style="width:90px">Severity</th>
      <th>ID</th>
      <th>Package</th>
      <th>Installed</th>
      <th>Fixed</th>
      <th>Layer</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
  {{ range . }}
    {{ range .Vulnerabilities }}
      {{ if or (eq .Severity "CRITICAL") (eq .Severity "HIGH") }}
        <tr>
          <td>
            {{ if eq .Severity "CRITICAL" }}<span class="sev-CRITICAL">CRITICAL</span>{{ end }}
            {{ if eq .Severity "HIGH" }}<span class="sev-HIGH">HIGH</span>{{ end }}
          </td>
          <td class="mono">{{ .VulnerabilityID }}</td>
          <td>{{ .PkgName }}</td>
          <td class="mono">{{ .InstalledVersion }}</td>
          <td class="mono">{{ .FixedVersion }}</td>
          <td class="layer-cell">
            {{ with .Layer }}{{ if .Digest }}{{ .Digest }}{{ else }}{{ . }}{{ end }}{{ else }}-{{ end }}
          </td>
          <td style="max-width:420px">{{ .Title }}{{ if .PrimaryURL }} (<a href="{{ .PrimaryURL }}" target="_blank">ref</a>){{ end }}</td>
        </tr>
      {{ end }}
    {{ end }}
  {{ end }}
  </tbody>
</table>

<hr/>

<h2>📋 Full Vulnerability Table (with Layer details)</h2>
<table>
  <thead>
    <tr>
      <th>Severity</th><th>ID</th><th>Package</th><th>Installed</th><th>Fixed</th><th>Layer Digest</th><th>Layer Path</th><th>Target</th><th>Reference</th>
    </tr>
  </thead>
  <tbody>
  {{ range . }}
    {{ $target := .Target }}
    {{ range .Vulnerabilities }}
      <tr>
        <td>
          {{ if eq .Severity "CRITICAL" }}<span class="sev-CRITICAL">CRITICAL</span>{{ end }}
          {{ if eq .Severity "HIGH" }}<span class="sev-HIGH">HIGH</span>{{ end }}
          {{ if eq .Severity "MEDIUM" }}<span class="sev-MEDIUM">MEDIUM</span>{{ end }}
          {{ if eq .Severity "LOW" }}<span class="sev-LOW">LOW</span>{{ end }}
          {{ if eq .Severity "UNKNOWN" }}<span class="sev-UNKNOWN">UNKNOWN</span>{{ end }}
        </td>
        <td class="mono">{{ .VulnerabilityID }}</td>
        <td>{{ .PkgName }}</td>
        <td class="mono">{{ .InstalledVersion }}</td>
        <td class="mono">{{ .FixedVersion }}</td>
        <td class="mono">
          {{ with .Layer }}
            {{ if .Digest }}{{ .Digest }}{{ else }}{{ . }}{{ end }}
          {{ else }}
            -
          {{ end }}
        </td>
        <td>
          {{ with .Layer }}
            {{ if .Path }}{{ .Path }}{{ else if .Details }}{{ .Details }}{{ else }}-{{ end }}
          {{ else }}
            -
          {{ end }}
        </td>
        <td class="mono">{{ $target }}</td>
        <td>
          {{ if .PrimaryURL }}<a href="{{ .PrimaryURL }}" target="_blank">Link</a>{{ else }}-{{ end }}
        </td>
      </tr>
    {{ end }}
  {{ end }}
  </tbody>
</table>

</body>
</html>
