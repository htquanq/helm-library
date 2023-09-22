{{- define "helm-library.probe.builder" }}
initialDelaySeconds: {{ .initialDelaySeconds | default 30 }}
periodSeconds: {{ .periodSeconds | default 10 }}
failureThreshold: {{ .failureThreshold | default 3 }}
successThreshold: {{ .successThreshold | default 3 }}
{{- if or .tcp.port .tcp.host .exec .httpGet.livenessPath .httpGet.livenessPort .grpc.service .grpc.port }}
{{- if or .tcp.port .tcp.host }}
tcpSocket:
  host: {{ .tcp.host }}
  port: {{ .tcp.port }}
{{- end }}
{{- if .exec }}
command: {{ .exec }}
{{- end }}
{{- if or .grpc.service .grpc.port }}
grpc:
  service: {{ .grpc.service }}
  port: {{ .grpc.port }}
{{- end }}
{{- if or .livenessPath .livenessPort }}
httpGet:
  path: {{ .livenessPath | default "/" }}
  port: {{ .livenessPort }}
{{- end }}
{{- else }}
httpGet:
  path: "/"
  port: 80
{{- end }}
{{- end }}

{{- define "helm-library.volumemount.builder" }}
- name: {{ required "Specify name of a volume" .name | quote }}
  mountPath: {{ required "Specify mountPath, must not contain ':'" .mountPath | quote }}
  readOnly: {{ .readOnly | default false }}
  subPath: {{ .subPath | default "" }}
  subPathExpr: {{ .subPathExpr | default "" }}
{{- end }}

{{- define "helm-library.container.env.builder" }}
{{- range . }}
{{- range $key,$val := . }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helm-library.container.template" }}
{{- range . }}
- name: {{ .name }}
  image: {{ .image }}
  imagePullPolicy: {{ .imagePullPolicy | default "IfNotPresent" }}
  {{- if .volumeMounts }}
  {{- range .volumeMounts }}
  {{- include "helm-library.volumemount.builder" . | indent 2}}
  {{- end }}
  {{- end }}
  startupProbe:
    {{- include "helm-library.probe.builder" .startupProbe | indent 4 }}
  readinessProbe:
    {{- include "helm-library.probe.builder" .readinessProbe | indent 4 }}
  livenessProbe:
    {{- include "helm-library.probe.builder" .livenessProbe | indent 4 }}
  {{- if .workingDir }}
  workingDir: {{ .workingDir }}
  {{- end }}
  {{- if .lifecycle }}
  postStart: {{ .lifecycle.postStart }}
  preStop: {{ .lifecyle.preStop }}
  {{- end }}
  {{- if .envFrom }}
  envFrom:
  {{ toYaml .envFrom | indent 2 }}
  {{- end }}
  {{- if .env }}
  env:
  {{ include "helm-library.container.env.builder" .env | indent 2 }}
  {{- end }}
  {{- if .command }}
  command:
    {{ toYaml .command }}
  {{- end }}
  {{- if .args }}
  args:
  {{ toYaml .args | indent 2 }}
  {{- end }}
  {{- if or .limits .requests }}
  resources:
    {{- if .limits }}
    limits:
    {{- if .limits.memory }}
      memory: {{ .limits.memory | quote }}
    {{- end }}
    {{- if .limits.cpu }}
      cpu: {{ .limits.cpu | quote }}
    {{- end }}
    {{- end }}
    {{- if .requests }}
    requests:
    {{- if .requests.memory }}
      memory: {{ .requests.memory | quote }}
    {{- end }}
    {{- if .requests.cpu }}
      cpu: {{ .requests.cpu | quote }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- if .ports }}
  ports:
  {{- range .ports }}
    - containerPort: {{ .containerPort }}
      protocol: {{ .protocol | upper }}
      name: {{ .name }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}