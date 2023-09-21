{{- define "helm-library.ingress.apiVersion" -}}
{{- if and ($.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) }}
{{- print "networking.k8s.io/v1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}

{{- define "helm-library.common.required" -}}
{{- "No value found for '%s' in the template" -}}
{{- end -}}

{{- define "helm-library.common.labels" -}}
{{- $message := include "helm-library.required" . -}}
app.kubernetes.io/name: {{ required (printf $message "name") .Values.name | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}
helm.sh/chart-version: {{ .Chart.Version | quote }}
{{- end -}}