{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "%%% APPLICATION_NAME %%%.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "%%% APPLICATION_NAME %%%.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" $name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "%%% APPLICATION_NAME %%%.labels" -}}
app.kubernetes.io/name: {{ include "%%% APPLICATION_NAME %%%.name" . }}
helm.sh/chart: {{ include "%%% APPLICATION_NAME %%%.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "%%% APPLICATION_NAME %%%.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "organization-host" -}}
{{- if eq .Values.environment "prod" -}}
{{- printf "%s.organization.org" .Chart.Name -}}
{{- else -}}
{{- printf "%s-%s.organization.org" .Chart.Name .Values.environment -}}
{{- end -}}
{{- end -}}

{{- define "define-organization-host" -}}
{{- $organizationHost := "" -}}
{{- if eq .Values.environment "prod" -}}
{{- $organizationHost = printf "%s.organization.org" .Chart.Name -}}
{{- else -}}
{{- $organizationHost = printf "%s-%s.organization.org" .Chart.Name .Values.environment -}}
{{- end -}}
{{- end -}}

{{- define "%%% APPLICATION_NAME %%%.strategy" -}}
{{- if .Values.strategy }}
{{ .Values.strategy }}
{{- else }}
rollingUpdate:
  maxUnavailable: 1
  maxSurge: 2
type: RollingUpdate
{{- end }}
{{- end -}}

{{- define "%%% APPLICATION_NAME %%%.namespace" -}}
{{- if .Values.namespace }}
{{ .Values.namespace }}
{{- else -}}
organization-spinnaker
{{- end -}}
{{- end }}
