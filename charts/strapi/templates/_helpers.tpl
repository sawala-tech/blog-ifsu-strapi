{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Sets extra ingress annotations
*/}}
{{- define "chart.ingress.annotations" -}}
  {{- if .Values.ingress.annotations }}
  annotations:
    {{- $tp := typeOf .Values.ingress.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.ingress.annotations . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.ingress.annotations | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra pod annotations
*/}}
{{- define "chart.podAnnotations" -}}
  {{- if .Values.podAnnotations }}
        {{- $tp := typeOf .Values.podAnnotations }}
        {{- if eq $tp "string" }}
          {{- toYaml .Values.podAnnotations| substr 2 -1 | nindent 6 }}
        {{- else }}
          {{- toYaml .Values.podAnnotations | nindent 6 }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra args for vault
*/}}
{{- define "chart.extraArgs" -}}
  {{- if .Values.vault.extraArgs }}
          args:
            {{- $tp := typeOf .Values.vault.extraArgs }}
            {{- if eq $tp "string" }}
              {{- toYaml .Values.vault.extraArgs | substr 2 -1 | nindent 12 }}
            {{- else }}
              {{- toYaml .Values.vault.extraArgs | nindent 12 }}
            {{- end }}
  {{- end }}
{{- end -}}

{{/*
Set helper for vault agent basic annotations
*/}}
{{- define "chart.vaultSecret" }}
  {{- if .Values.vault.secret  }}
    {{- print .Values.vault.secret }}
  {{- else }}
    {{- printf "secret/%s" (include "chart.fullname" .) -}}
  {{- end }}
{{- end }}

{{- define "chart.vault.database.secret" }}
  {{- if .Values.vault.database.secret  }}
    {{- print .Values.vault.database.secret }}
  {{- else }}
    {{- printf "database/creds/%s" (include "chart.fullname" .) -}}
  {{- end }}
{{- end }}

{{- define "chart.vault.aws.secret" }}
  {{- if .Values.vault.aws.secret  }}
    {{- print .Values.vault.aws.secret }}
  {{- else }}
    {{- printf "aws/creds/%s" (include "chart.fullname" .) -}}
  {{- end }}
{{- end }}

{{- define "chart.vault" -}}
  {{- if .Values.vault.enabled }}
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/agent-cache-enable: 'true'
        vault.hashicorp.com/role: {{- default (include "chart.fullname" .) .Values.vault.role | indent 1 }}
        vault.hashicorp.com/agent-inject-secret-config.env: {{- include "chart.vaultSecret" . | indent 1 }}
        {{- toYaml .Values.vault.template | replace "secret/template" (include "chart.vaultSecret" .) | nindent 8 }}

        {{-  if .Values.vault.database.enabled }}
        vault.hashicorp.com/agent-inject-secret-database.env: {{- include "chart.vault.database.secret" . | indent 1 }}
        {{- toYaml .Values.vault.database.template | replace "database/creds/strapi-helm-template" ( include "chart.vault.database.secret" .) | nindent 8 }}
        {{- end }}

        {{- if .Values.vault.aws.enabled }}
        vault.hashicorp.com/agent-inject-secret-aws.env: {{- include "chart.vault.aws.secret" . | indent 1 }}
        {{- toYaml .Values.vault.aws.template | replace "aws/creds/strapi-helm-template" ( include "chart.vault.aws.secret" .) | nindent 8 }}
        {{- end }}

        {{- if .Values.vault.extraTemplates }}
          {{- $tp := typeOf .Values.vault.extraTemplates }}
          {{- if eq $tp "string" }}
            {{- toYaml .Values.vault.extraTemplates | substr 2 -1 | nindent 6 }}
          {{- else }}
            {{- toYaml .Values.vault.extraTemplates | nindent 6 }}
          {{- end }}
        {{- end }}
  {{- end }}
{{- end -}}