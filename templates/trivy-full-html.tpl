<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Trivy Full Vulnerability Report</title>
  <style>
    body { font-family: Arial, sans-serif; font-size: 14px; }
    h1, h2, h3 { color: #2c3e50; }
    table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
    th, td { border: 1px solid #ddd; padding: 6px; vertical-align: top; }
    th { background-color: #f4f4f4; }
    .CRITICAL { background-color: #ffb3b3; }
    .HIGH { background-color: #ffd6b3; }
    .MEDIUM { background-color: #fff0b3; }
    .LOW { background-color: #e6f2ff; }
    .UNKNOWN { background-color: #eeeeee; }
    .desc { white-space: pre-wrap; }
  </style>
</head>

<body>
<h1>Trivy Vulnerability Report</h1>

{{ range . }}
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
      <td>
        {{ if .PrimaryURL }}
          <a href="{{ .PrimaryURL }}">{{ .PrimaryURL }}</a>
        {{ end }}
      </td>
      <td class="desc">{{ .Description }}</td>
    </tr>
    {{ end }}

  </table>
  {{ else }}
    <p>✅ No vulnerabilities found for this target</p>
  {{ end }}
{{ end }}

</body>
</html>
