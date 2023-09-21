{{- define "helm-library.ingress.builder" }}
{{- range $key, $value := . }}
{{- range $v := $value }}
{{- if ne "networking" $key }}
- path: {{ $v.path }}
  backend:
    serviceName: {{ $v.serviceName }}
    servicePort: {{ $v.servicePort }}
{{- else }}
- path: {{ $v.path }}
  pathType: {{ default "Prefix" $v.pathType }}
  backend:
    service:
      name: {{ $v.serviceName }}
      port:
      {{- if (kindIs "string" $v.servicePort) }}
        name: {{ $v.servicePort }}
      {{- else }}
        number: {{ $v.servicePort }}
      {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}