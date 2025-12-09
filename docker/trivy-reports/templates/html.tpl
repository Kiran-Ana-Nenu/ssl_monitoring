<!DOCTYPE html>
<html>
<head>
<title>Trivy Scan Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin-top: 15px; }
th, td { padding: 10px 14px; border: 1px solid #bbb; font-size: 15px; }
th { background: #2d3748; color: white; text-transform: uppercase; }
tr:nth-child(even) { background: #f6f8fa; }
tr:hover { background: #e2e8f0; }

.sev-critical { background: #ff4d4f; color: white; font-weight: bold; padding: 5px 10px; border-radius: 4px; }
.sev-high { background: #ff9800; color: black; font-weight: bold; padding: 5px 10px; border-radius: 4px; }
.sev-medium { background: #ffc107; color: black; padding: 5px 10px; border-radius: 4px; }
.sev-low { background: #03a9f4; color: white; padding: 5px 10px; border-radius: 4px; }
.sev-unknown { background: #9e9e9e; color: white; padding: 5px 10px; border-radius: 4px; }

.summary-box { margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-left: 6px solid #2d3748; }
.summary-item { font-size: 18px; font-weight: 600; line-height: 1.4; }

.chart-container { width: 100%; max-width: 850px; margin: 35px auto; }
</style>
</head>
<body>

<h2>🔐 Trivy Vulnerability Scan Report</h2>

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

<!-- ===== Charts Section ===== -->
<div class="chart-container">
  <canvas id="pieChart"></canvas>
</div>
<div class="chart-container">
  <canvas id="barChart"></canvas>
</div>

<!-- Embedded Chart.js (offline) -->
<script>
!function(e,r){"object"==typeof exports&&"undefined"!=typeof module?r():"function"==typeof define&&define.amd?define(r):r()}(0,function() {
{{/* Chart.js v4 (minified) stored as an embedded base64 string */}}
var script=document.createElement("script");
script.src="data:text/javascript;base64,{{ chartJS }}";
document.head.appendChild(script);
});
</script>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const data = {
      labels: ["CRITICAL", "HIGH", "MEDIUM", "LOW", "UNKNOWN"],
      values: [{{ $crit }}, {{ $high }}, {{ $med }}, {{ $low }}, {{ $unk }}]
    };

    // Pie Chart
    new Chart(document.getElementById("pieChart"), {
      type: "pie",
      data: {
        labels: data.labels,
        datasets: [{
          data: data.values,
          backgroundColor: ["#ff4d4f", "#ff9800", "#ffc107", "#03a9f4", "#9e9e9e"]
        }]
      }
    });

    // Bar Chart
    new Chart(document.getElementById("barChart"), {
      type: "bar",
      data: {
        labels: data.labels,
        datasets: [{
          label: "Count",
          data: data.values,
          backgroundColor: ["#ff4d4f", "#ff9800", "#ffc107", "#03a9f4", "#9e9e9e"]
        }]
      },
      options: {
        plugins: { legend: { display: false }},
        scales: { y: { beginAtZero: true } }
      }
    });
});
</script>

<hr/>

{{ range . }}
  <h3>🧱 Target: {{ .Target }}</h3>
  {{ if .Vulnerabilities }}

  {{ $sorted := sort .Vulnerabilities "Severity" "desc" }}

  <table>
    <tr>
      <th>ID</th>
      <th>Title</th>
      <th>Severity</th>
      <th>Package</th>
      <th>Installed Version</th>
      <th>Fixed Version</th>
      <th>URL</th>
    </tr>
    {{ range $sorted }}
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
      <td><a href="{{ .PrimaryURL }}" target="_blank">Reference Link</a></td>
    </tr>
    {{ end }}
  </table>

  {{ else }}
    <p style="color:green; font-size: 16px;"><b>✔ No vulnerabilities found</b></p>
  {{ end }}
{{ end }}

</body>
</html>
