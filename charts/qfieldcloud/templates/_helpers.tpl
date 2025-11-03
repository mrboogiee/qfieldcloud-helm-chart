{{/*
Expand the name of the chart.
*/}}
{{- define "qfieldcloud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "qfieldcloud.fullname" -}}
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
{{- define "qfieldcloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "qfieldcloud.labels" -}}
helm.sh/chart: {{ include "qfieldcloud.chart" . }}
{{ include "qfieldcloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "qfieldcloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qfieldcloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "qfieldcloud.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "qfieldcloud.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build storage configuration with conditional region_name
*/}}
{{- define "qfieldcloud.storageConfig" -}}
{{- $storages := dict -}}
{{- if eq .Values.django.storage.type "s3" -}}
{{- $options := dict 
  "bucket_name" .Values.django.storage.bucketName
  "endpoint_url" .Values.django.storage.endpointUrl
  "custom_domain" (default nil .Values.django.storage.customDomain)
  "file_overwrite" false
  "object_parameters" (dict)
  "default_acl" "private"
-}}
{{- if .Values.django.storage.regionName -}}
{{- $_ := set $options "region_name" .Values.django.storage.regionName -}}
{{- end -}}
{{- $defaultStorage := dict 
  "BACKEND" "qfieldcloud.filestorage.backend.QfcS3Boto3Storage"
  "OPTIONS" $options
  "QFC_IS_LEGACY" false
-}}
{{- $_ := set $storages "default" $defaultStorage -}}
{{- else if .Values.django.storage.storagesConfig -}}
{{- $storages = deepCopy .Values.django.storage.storagesConfig -}}
{{- range $key, $storage := $storages -}}
{{- if hasKey $storage "OPTIONS" -}}
{{- $options := $storage.OPTIONS -}}
{{- if and (hasKey $options "region_name") (eq $options.region_name "") -}}
{{- $_ := unset $options "region_name" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $storages | toJson -}}
{{- end }}

{{/*
Get the domain from global.domain or first ingress host as fallback
*/}}
{{- define "qfieldcloud.domain" -}}
{{- if .Values.global.domain -}}
{{- .Values.global.domain -}}
{{- else if .Values.ingress.hosts -}}
{{- (index .Values.ingress.hosts 0).host -}}
{{- else -}}
{{- "localhost" -}}
{{- end -}}
{{- end }} 