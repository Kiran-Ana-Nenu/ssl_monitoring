{{- define "output template" -}}
<!DOCTYPE html>
<html>
<head>
    <title>Trivy Scan Report</title>
    <meta charset="UTF-8"/>
</head>
<body>
<h2>Trivy Scan Report</h2>
<p><strong>Image:</strong> {{ .Report.Metadata.RepoDigests }}</p>
<p><strong>Scan Type:</strong> {{ .Report.Type }}</p>
<hr/>

{{ range .Results }}
  <h3>Target: {{ .Target }}</h3>
  <table border="1" cellspacing="0" cellpadding="4">
    <tr>
      <th>ID</th>
      <th>Severity</th>
      <th>Package</th>
      <th>Installed Version</th>
      <th>Fixed Version</th>
      <th>Title</th>
    </tr>
    {{ range .Vulnerabilities }}
      <tr>
        <td>{{ .VulnerabilityID }}</td>
        <td>{{ .Severity }}</td>
        <td>{{ .PkgName }}</td>
        <td>{{ .InstalledVersion }}</td>
        <td>{{ .FixedVersion }}</td>
        <td>{{ .Title }}</td>
      </tr>
    {{ end }}
  </table>
  <br/>
{{ end }}
</body>
</html>
{{- end -}}
