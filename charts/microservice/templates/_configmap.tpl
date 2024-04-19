{{- define "project.configmap" }}
{{- if .configuration}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "project.name" . }}-{{ .name }}-config
  labels:
    service: {{ include "project.name" . }}-{{ .name }}
    app: {{ include "project.name" . }}-{{ .name }}
    component: {{ include "project.name" . }}-{{ .name }}-config
data:
  {{- range $key, $value := .configuration }}
  {{ $key }}:
  {{- tpl (toYaml $value) $ | indent 2 }}
  {{- end}}
{{- end}}
{{- end}}
