<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Trivy Full Vulnerability Report</title>
  <style>
    body { font-family: Arial; font-size: 14px; }
    h1, h2, h3 { color: #2c3e50; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
    th, td { border: 1px solid #ddd; padding: 6px; vertical-align: top; }
    th { background-color: #f4f4f4; }
    .CRITICAL { background: #ffb3b3; }
    .HIGH { background: #ffd6b3; }
    .MEDIUM { background: #fff0b3; }
    .LOW { background: #e6f2ff; }
    .UNKNOWN { background: #eeeeee; }
    .meta { background: #f9f9f9; font-size: 13px; }
    .desc { white-space: pre-wrap; }
  </style>
</head>

<body>
<h1>Trivy – Full Vulnerability Report</h1>

<h2>Scan Metadata</h2>
<table class="meta">
<tr><th>Target</th><td>{{ .ArtifactName }}</td></tr>
<tr><th>Artifact Type</th><td>{{ .ArtifactType }}</td></tr>
<tr><th>Trivy Version</th><td>{{ .Scanner.Name }}</td></tr>
<tr><th>Scan Time</th><td>{{ .CreatedAt }}</td></tr>
</table>

{{ range .Results }}
<h2>Target: {{ .Target }}</h2>
<h3>Type: {{ .Type }}</h3>

{{ if .Vulnerabilities }}
<table>
<tr>
  <th>Package</th>
  <th>Installed</th>
  <th>Fixed</th>
  <th>CVE</th>
  <th>Severity</th>
  <th>CVSS</th>
  <th>Status</th>
  <th>Published</th>
  <th>URL</th>
  <th>Description</th>
</tr>

{{ range .Vulnerabilities }}
<tr class="{{ .Severity }}">
  <td>{{ .PkgName }}</td>
  <td>{{ .InstalledVersion }}</td>
  <td>{{ .FixedVersion }}</td>
  <td>{{ .VulnerabilityID }}</td>
  <td>{{ .Severity }}</td>
  <td>
    {{ range $k, $v := .CVSS }}
      {{ $k }}: {{ $v.V3Score }}<br/>
    {{ end }}
  </td>
  <td>{{ .Status }}</td>
  <td>{{ .PublishedDate }}</td>
  <td><a href="{{ .PrimaryURL }}">{{ .PrimaryURL }}</a></td>
  <td class="desc">{{ .Description }}</td>
</tr>
{{ end }}
</table>
{{ else }}
<p>✅ No vulnerabilities found</p>
{{ end }}

{{ end }}

</body>
</html>
