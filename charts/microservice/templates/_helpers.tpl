{{- define "project.name" -}}
{{- default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "project.labels" -}}
helm.sh/chart: {{ include "project.chart" . }}
{{ include "project.selectorLabels" . }}
{{ include "project.workloadLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: opentelemetry-demo
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "project.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "project.selectorLabels" -}}
{{- if .name -}}
opentelemetry.io/name: {{ include "project.name" . }}-{{ .name }}
{{- else -}}
opentelemetry.io/name: {{ include "project.name" . }}
{{- end }}
{{- end }}

{{- define "project.workloadLabels" -}}
app.kubernetes.io/platform: {{ .Release.Name }}
app.kubernetes.io/cluster: {{ .Release.Namespace }}
{{- if .name }}
app.kubernetes.io/component: {{ .name }}
app.kubernetes.io/name: {{ include "project.name" . }}-{{ .name }}
{{- else }}
app.kubernetes.io/name: {{ include "project.name" . }}
{{- end }}
{{- end }}

{{- define "project.envOverriden" -}}
{{- $mergedEnvs := list }}
{{- $envOverrides := default (list) .envOverrides }}

{{- range .env }}
{{-   $currentEnv := . }}
{{-   $hasOverride := false }}
{{-   range $envOverrides }}
{{-     if eq $currentEnv.name .name }}
{{-       $mergedEnvs = append $mergedEnvs . }}
{{-       $envOverrides = without $envOverrides . }}
{{-       $hasOverride = true }}
{{-     end }}
{{-   end }}
{{-   if not $hasOverride }}
{{-     $mergedEnvs = append $mergedEnvs $currentEnv }}
{{-   end }}
{{- end }}
{{- $mergedEnvs = concat $mergedEnvs $envOverrides }}
{{- mustToJson $mergedEnvs }}
{{- end }}

{{- define "project.serviceAccountName" -}}
{{- if .serviceAccount.create }}
{{- default (include "project.name" $) .serviceAccount.name }}
{{- else }}
{{- default "default" .serviceAccount.name }}
{{- end }}
{{- end }}
