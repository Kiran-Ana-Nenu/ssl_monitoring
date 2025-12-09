<!DOCTYPE html>
<html>
<head>
<title>Trivy Scan Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
table { border-collapse: collapse; width: 100%; margin-top: 15px; }
th, td { padding: 8px 12px; border: 1px solid #ddd; font-size: 14px; }
th { background: #4a5568; color: white; }
.sev-critical { background: #ff4d4f; color: white; font-weight: bold; padding: 5px 8px; border-radius: 4px; }
.sev-high { background: #ff9800; color: black; font-weight: bold; padding: 5px 8px; border-radius: 4px; }
.sev-medium { background: #ffc107; color: black; padding: 5px 8px; border-radius: 4px; }
.sev-low { background: #03a9f4; color: white; padding: 5px 8px; border-radius: 4px; }
.sev-unknown { background: #9e9e9e; color: white; padding: 5px 8px; border-radius: 4px; }
.summary-box { margin-bottom: 15px; padding: 10px; background: #f8f9fa; border-left: 6px solid #4a5568; }
.summary-item { font-size: 16px; }
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
  <p class="summary-item"> 🔥 <span class="sev-critical">Critical:</span> {{ $crit }}</p>
  <p class="summary-item"> ⚠  <span class="sev-high">High:</span> {{ $high }}</p>
  <p class="summary-item"> 🟡 <span class="sev-medium">Medium:</span> {{ $med }}</p>
  <p class="summary-item"> 🔹 <span class="sev-low">Low:</span> {{ $low }}</p>
  <p class="summary-item"> ❔ <span class="sev-unknown">Unknown:</span> {{ $unk }}</p>
</div>

<hr/>

{{ range . }}
  <h3>🧱 Target: {{ .Target }}</h3>
  {{ if .Vulnerabilities }}
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
      <td><a href="{{ .PrimaryURL }}" target="_blank">Reference Link</a></td>
    </tr>
    {{ end }}
  </table>
  {{ else }}
    <p style="color:green;"><b>✔ No vulnerabilities found</b></p>
  {{ end }}
{{ end }}

</body>
</html>
