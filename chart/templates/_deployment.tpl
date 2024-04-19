{{- define "project.deployment" }}
{{- $name := .name }}
{{- $imagePullSecrets := default .defaultValues.image.pullSecrets (.image).pullSecrets }}
{{- $nodeSelector := default .defaultValues.schedulingRules.nodeSelector (.schedulingRules).nodeSelector }}
{{- $affinity := default .defaultValues.schedulingRules.affinity (.schedulingRules).affinity }}
{{- $tolerations := default .defaultValues.schedulingRules.tolerations (.schedulingRules).tolerations }}
{{- $specs := dict "imagePullSecrets" $imagePullSecrets "nodeSelector" $nodeSelector "affinity" $affinity "tolerations" $tolerations }}

{{- $imageRepository := default .defaultValues.image.repository (.image).repository }}
{{- $imageTag := (.image).tag | default (printf "%s-%s" (default .Chart.AppVersion .defaultValues.image.tag) (replace "-" "" .name)) }}
{{- $imagePullPolicy := default .defaultValues.image.pullPolicy (.image).pullPolicy }}
{{- $securityContext := default .defaultValues.securityContext .securityContext }}
{{- $containerSpecs := dict "resources" .resources "securityContext" $securityContext "livenessProbe" .livenessProbe }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "project.name" . }}-{{ .name }}
  labels:
    {{- include "project.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "project.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "project.selectorLabels" . | nindent 8 }}
        {{- include "project.workloadLabels" . | nindent 8 }}
      {{- if .annotations }}
      annotations:
        {{- toYaml .annotations | nindent 8 }}
      {{- end }}
    spec:
      serviceAccountName: {{ include "project.serviceAccountName" . }}
      {{- range $key, $value := $specs }}
      {{- if $value }}
      {{ $key }}:
        {{- toYaml $value | nindent 8 }}
      {{- end }}
      {{- end }}
      containers:
        - name: {{ .name }}
          image: {{ $imageRepository }}:{{ $imageTag }}
          imagePullPolicy: {{ $imagePullPolicy }}
          {{- if .command }}
          command:
            {{- .command | toYaml | nindent 12 }}
          {{- end }}
          {{- if or .ports .service }}
          ports:
            {{- include "project.pod.ports" . | nindent 12 }}
          {{- end }}
          env:
            {{- include "project.pod.env" . | nindent 12 }}
          {{- range $key, $value := $containerSpecs }}
          {{- if $value }}
          {{ $key }}:
            {{- toYaml $value | nindent 12 }}
          {{- end }}
          {{- end }}
        {{- if or .configuration .volumes }}
          volumeMounts:
          {{- if .configuration }}
          - name: config
            mountPath: /etc/config
          {{- end }}
          {{- if .volumes }}
          {{- range $volume := .volumes }}
          - name: {{ $volume.name }}
            mountPath: {{ $volume.mountPath }}
          {{- end }}
          {{- end }}
      volumes:
        {{- if .configuration }}
        - name: config
          configMap:
            name: {{ include "project.name" . }}-{{ .name }}-config
        {{- end }}
        {{- range $volume := .volumes }}
        - name: {{ $volume.name }}
          persistentVolumeClaim:
            claimName: {{ include "project.name" $ }}-{{ $name }}-{{ $volume.name }}-pv-claim
        {{- end }}
        {{- end }}
      {{- if .initContainers }}
      initContainers:
        {{- tpl (toYaml .initContainers) . | nindent 8 }}
      {{- end }}
{{- end }}
