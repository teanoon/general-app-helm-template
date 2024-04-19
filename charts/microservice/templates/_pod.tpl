{{- define "project.pod.env" -}}
{{- if eq false (.useDefault).env | not }}
{{-   $allEnvs := default list .env }}
{{-   $names := list }}
{{-   range $env := $allEnvs }}
{{-     $names = append $names $env.name }}
{{-   end }}
{{-   range $defaultEnv := .defaultValues.env }}
{{-     if not (has $defaultEnv.name $names) }}
{{-       $allEnvs = append $allEnvs $defaultEnv }}
{{-     end }}
{{-   end }}
{{-   tpl (toYaml $allEnvs) . }}
{{- else }}
{{-   tpl (toYaml .defaultValues.env) . }}
{{- end }}
{{- end }}

{{- define "project.pod.ports" -}}
{{- range $port := .ports }}
- containerPort: {{ $port.value }}
  name: {{ $port.name}}
  protocol: {{ default "TCP" $port.protocol }}
{{- end }}
{{- if (.service).port -}}
- containerPort: {{ .service.port }}
  name: service
{{- end }}
{{- end }}
