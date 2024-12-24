{{- define "project.service" }}
{{- if or .ports .service }}
{{- $service := .service | default dict }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "project.name" . }}-{{ .name }}
  labels:
    {{- include "project.labels" . | nindent 4 }}
  {{- with $service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ $service.type | default "ClusterIP" }}
  {{- if $service.loadBalancerIP }}
  loadBalancerIP: {{ $service.loadBalancerIP }}
  {{- end }}
  {{- if $service.externalIPs }}
  externalIPs:
    {{- range $ip := $service.externalIPs }}
    - {{ $ip }}
    {{- end }}
  {{- end }}
  {{- if .clusterIP }}
  clusterIP: {{ .clusterIP }}
  {{- end }}
  ports:
    {{- if .ports }}
    {{- range $port := .ports }}
    - port: {{ $port.value }}
      name: {{ $port.name }}
      protocol: {{ default "TCP" $port.protocol }}
      targetPort: {{ $port.value }}
    {{- end }}
    {{- end }}

    {{- if $service.port }}
    - port: {{ $service.port}}
      name: tcp-service
      targetPort: {{ $service.port }}
      {{- if $service.nodePort }}
      nodePort: {{ $service.nodePort }}
      {{- end }}
    {{- end }}
  selector:
    {{- include "project.selectorLabels" . | nindent 4 }}
{{- end}}
{{- end}}
