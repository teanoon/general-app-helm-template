{{- define "project.volumes" }}
---
{{- $projectName := include "project.name" . }}
{{- $name := .name }}
{{- range $volume := .volumes }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $projectName }}-{{ $name }}-{{ $volume.name }}-pv-claim
  labels:
    service: {{ $projectName }}-{{ $name }}
    app: {{ $projectName }}-{{ $name }}
    component: {{ $projectName }}-{{ $name }}-volume
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ $volume.size }}
{{- end}}
{{- end}}
