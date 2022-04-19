{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "continuous-delivery.name" -}}
{{- include "common.names.name" . -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "continuous-delivery.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "continuous-delivery.chart" -}}
{{- include "common.names.chart" . -}}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "continuous-delivery.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "continuous-delivery.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
