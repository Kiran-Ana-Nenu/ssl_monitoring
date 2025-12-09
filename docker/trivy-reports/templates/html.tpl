<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Trivy Vulnerability Scan Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f5f6fa; }
h1,h2,h3 { color: #2d3748; }
table { border-collapse: collapse; width: 100%; margin-top: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);}
th,td { padding: 10px 14px; border: 1px solid #bbb; font-size: 14px; text-align: left; }
th { background: #2d3748; color: white; text-transform: uppercase; }
tr:nth-child(even) { background: #f6f8fa; }
tr:hover { background: #e2e8f0; }
.sev-critical { background: #ff4d4f; color: white; font-weight: bold; padding: 5px 10px; border-radius: 4px; }
.sev-high { background: #ff9800; color: black; font-weight: bold; padding: 5px 10px; border-radius: 4px; }
.sev-medium { background: #ffc107; color: black; padding: 5px 10px; border-radius: 4px; }
.sev-low { background: #03a9f4; color: white; padding: 5px 10px; border-radius: 4px; }
.sev-unknown { background: #9e9e9e; color: white; padding: 5px 10px; border-radius: 4px; }
.summary-box { margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-left: 6px solid #2d3748; }
.summary-item { font-size: 16px; font-weight: 600; line-height: 1.4; }
.chart-container { width: 100%; max-width: 850px; margin: 35px auto; }
.report-info { margin-bottom: 25px; padding: 15px; background: #eef2f7; border-left: 6px solid #2d3748; }
</style>
</head>
<body>

<div class="report-info">
<h2>Report Info</h2>
<p><b>Generated On:</b> {{ getenv "TRIVY_TS" }}</p>
<p><b>Build Number:</b> {{ getenv "TRIVY_BUILD_NUMBER" }}</p>
<p><b>Scanned Image:</b> {{ getenv "TRIVY_IMAGE" }}</p>
</div>

<h1>🔐 Trivy Consolidated Vulnerability Scan</h1>

{{/* ===== Summary counters ===== */}}
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
<p class="summary-item">🔥 <span class="sev-critical">Critical:</span> {{ $crit }}</p>
<p class="summary-item">⚠ <span class="sev-high">High:</span> {{ $high }}</p>
<p class="summary-item">🟡 <span class="sev-medium">Medium:</span> {{ $med }}</p>
<p class="summary-item">🔹 <span class="sev-low">Low:</span> {{ $low }}</p>
<p class="summary-item">❔ <span class="sev-unknown">Unknown:</span> {{ $unk }}</p>
</div>

<div class="chart-container"><canvas id="pieChart"></canvas></div>
<div class="chart-container"><canvas id="barChart"></canvas></div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
const data = { labels: ["CRITICAL","HIGH","MEDIUM","LOW","UNKNOWN"], values: [{{ $crit }},{{ $high }},{{ $med }},{{ $low }},{{ $unk }}] };
new Chart(document.getElementById("pieChart"),{ type:"pie", data:{ labels:data.labels,datasets:[{ data:data.values, backgroundColor:["#ff4d4f","#ff9800","#ffc107","#03a9f4","#9e9e9e"] }] } });
new Chart(document.getElementById("barChart"),{ type:"bar", data:{ labels:data.labels,datasets:[{ label:"Count", data:data.values, backgroundColor:["#ff4d4f","#ff9800","#ffc107","#03a9f4","#9e9e9e"] }] }, options:{ plugins:{ legend:{ display:false } }, scales:{ y:{ beginAtZero:true } } } });
});
</script>

<hr/>

<h3>Top Critical & High Vulnerabilities</h3>
<table>
<tr><th>ID</th><th>Severity</th><th>Title</th><th>Package</th><th>Installed Version</th><th>Fixed Version</th><th>Target</th></tr>
{{ range . }}
  {{ range .Vulnerabilities }}
    {{ if or (eq .Severity "CRITICAL") (eq .Severity "HIGH") }}
    <tr>
    <td>{{ .VulnerabilityID }}</td>
    <td>{{ .Severity }}</td>
    <td>{{ .Title }}</td>
    <td>{{ .PkgName }}</td>
    <td>{{ .InstalledVersion }}</td>
    <td>{{ .FixedVersion }}</td>
    <td>{{ $.Target }}</td>
    </tr>
    {{ end }}
  {{ end }}
{{ end }}
</table>

<hr/>

{{/* Full table per target */}}
{{ range . }}
<h3>🧱 Target: {{ .Target }}</h3>
{{ if .Vulnerabilities }}
<table>
<tr><th>ID</th><th>Title</th><th>Severity</th><th>Package</th><th>Installed Version</th><th>Fixed Version</th><th>URL</th></tr>
{{ range .Vulnerabilities }}
<tr>
<td>{{ .VulnerabilityID }}</td>
<td>{{ .Title }}</td>
<td>
{{ if eq .Severity "CRITICAL" }}<span class="sev-critical">CRITICAL</span>{{ end }}
{{ if eq .Severity "HIGH" }}<span class="sev-high">HIGH</span>{{ end }}
{{ if eq .Severity "MEDIUM" }}<span class="sev-medium">MEDIUM</span>{{ end }}
{{ if eq .Severity "LOW" }}<span class="sev-low">LOW</span>{{ end }}
{{ if eq .Severity "UNKNOWN" }}<span class="sev-unknown">UNKNOWN</span>{{ end }}
</td>
<td>{{ .PkgName }}</td>
<td>{{ .InstalledVersion }}</td>
<td>{{ .FixedVersion }}</td>
<td><a href="{{ .PrimaryURL }}" target="_blank">Link</a></td>
</tr>
{{ end }}
</table>
{{ else }}
<p style="color:green; font-size: 16px;"><b>✔ No vulnerabilities found</b></p>
{{ end }}
{{ end }}

</body>
</html>
