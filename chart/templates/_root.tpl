{{- define "project.root" -}}
{{- range $name, $config := .Values.components }}
    {{- $config := set . "Capabilities" $.Capabilities }}
    {{- $config := set . "Template" $.Template }}
    {{- $config := set . "name" ($name | lower) }}
    {{- $config := set . "Release" $.Release }}
    {{- $config := set . "Chart" $.Chart }}
    {{- $config := set . "serviceAccount" $.Values.serviceAccount }}
    {{- $config := set . "observability" $.Values.observability }}
    {{- $config := set . "defaultValues" $.Values.default }}

    {{- if eq false $config.enabled | not -}}
        {{- include "project.deployment" $config -}}
        {{- include "project.service" $config -}}
        {{- include "project.ingress" $config -}}
        {{- include "project.configmap" $config -}}
        {{- include "project.volumes" $config -}}
    {{ end }}
{{- end }}

{{- if .Values.serviceAccount.create -}}
{{- $config := set . "serviceAccount" .Values.serviceAccount }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "project.serviceAccountName" . }}
  labels:
    {{- include "project.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
