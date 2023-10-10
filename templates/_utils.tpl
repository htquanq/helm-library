{{/*
Input:
  testMerge:
    - a: 1
    - b: 2
      c: 3
Output:
  - a: 1
    b: 2
    c: 3
Note: result will be a structed string so use fromYamlArray to transform from string into list of map
*/}}
{{- define "helm-library.util.merge-list" }}
{{- $final := (index . 0) }}
{{- range (index . 1) }}
{{- $final = append $final . }}
{{- end }}
{{- compact $final | toYaml | nindent 0 }}
{{- end }}