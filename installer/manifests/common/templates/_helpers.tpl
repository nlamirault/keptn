{{/* vim: set filetype=mustache: */}}

{{/*
Kubernetes standard labels
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "common.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "control-plane.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "control-plane.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "control-plane.gracePeriod" -}}
      terminationGracePeriodSeconds: 50
{{- end }}

{{- define "control-plane.dist.livenessProbe" -}}
livenessProbe:
  httpGet:
    path: /health
    port: {{.port | default 8080}}
  initialDelaySeconds: {{.initialDelaySeconds | default 10}}
  periodSeconds: 5
{{- end }}

{{- define "control-plane.dist.readinessProbe" -}}
readinessProbe:
  httpGet:
    path: /health
    port: {{.port | default 8080}}
  initialDelaySeconds: {{.initialDelaySeconds | default 5}}
  periodSeconds: 5
{{- end }}

{{- define "control-plane.dist.prestop" -}}
lifecycle:
   preStop:
      exec:
       command: ["/bin/sleep", "20"]
{{- end }}

{{- define "control-plane.dist.common.env.vars" -}}
- name: PUBSUB_URL
  value: 'nats://keptn-nats'
- name: VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['app.kubernetes.io/version']
- name: DISTRIBUTOR_VERSION
{{- if .Values.distributor.image.tag }}
  value: {{ .Values.distributor.image.tag }}
{{- else }}
  value: {{ .Chart.AppVersion }}
{{- end }}
- name: LOCATION
  valueFrom:
   fieldRef:
      fieldPath: metadata.labels['app.kubernetes.io/component']
- name: K8S_DEPLOYMENT_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['app.kubernetes.io/name']
- name: K8S_POD_NAME
  valueFrom:
    fieldRef:
     fieldPath: metadata.name
- name: K8S_NAMESPACE
{{- if .Values.distributor.metadata.namespace }}
  value: {{ .Values.distributor.metadata.namespace }}
{{- else }}
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}
- name: K8S_NODE_NAME
{{- if .Values.distributor.metadata.hostname }}
  value: {{ .Values.distributor.metadata.hostname }}
{{- else }}
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
{{- end }}
{{- if .Values.distributor.config.queueGroup.enabled }}
- name: PUBSUB_GROUP
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['app.kubernetes.io/name']
{{- end }}
- name: OAUTH_CLIENT_ID
  value: "{{ (((.Values.distributor).config).oauth).clientID }}"
- name: OAUTH_CLIENT_SECRET
  value: "{{ (((.Values.distributor).config).oauth).clientSecret }}"
- name: OAUTH_DISCOVERY
  value: "{{ (((.Values.distributor).config).oauth).discovery }}"
- name: OAUTH_TOKEN_URL
  value: "{{ (((.Values.distributor).config).oauth).tokenURL }}"
- name: OAUTH_SCOPES
  value: "{{ (((.Values.distributor).config).oauth).scopes }}"
{{- end }}

{{- define "control-plane.common.security-context-seccomp" -}}
{{- if ge .Capabilities.KubeVersion.Minor "21" }}
  seccompProfile:
    type: RuntimeDefault
{{- end -}}
{{- end -}}

{{- define "control-plane.bridge.pod-security-context" -}}
{{- if .Values.bridge.podSecurityContext -}}
{{- if .Values.bridge.podSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.bridge.podSecurityContext "enabled" "defaultSeccompProfile" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- if not .Values.bridge.podSecurityContext.seccompProfile }}
{{- if .Values.bridge.podSecurityContext.defaultSeccompProfile -}}
{{- include "control-plane.common.security-context-seccomp" . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  fsGroup: 65532
{{- include "control-plane.common.security-context-seccomp" . }}
{{- end -}}
{{- end -}}

{{- define "control-plane.bridge.container-security-context" -}}
{{- if .Values.bridge.containerSecurityContext -}}
{{- if .Values.bridge.containerSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.bridge.containerSecurityContext "enabled" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  runAsNonRoot: true
  runAsUser: 65532
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  privileged: false
{{- end -}}
{{- end -}}

{{- define "control-plane.apiGatewayNginx.pod-security-context" -}}
{{- if .Values.apiGatewayNginx.podSecurityContext -}}
{{- if .Values.apiGatewayNginx.podSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.apiGatewayNginx.podSecurityContext "enabled" "defaultSeccompProfile" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- if not .Values.apiGatewayNginx.podSecurityContext.seccompProfile -}}
{{- if .Values.apiGatewayNginx.podSecurityContext.defaultSeccompProfile -}}
{{- include "control-plane.common.security-context-seccomp" . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  fsGroup: 101
{{- include "control-plane.common.security-context-seccomp" . }}
{{- end -}}
{{- end -}}

{{- define "control-plane.apiGatewayNginx.container-security-context" -}}
{{- if .Values.apiGatewayNginx.containerSecurityContext -}}
{{- if .Values.apiGatewayNginx.containerSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.apiGatewayNginx.containerSecurityContext "enabled" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  runAsNonRoot: true
  runAsUser: 101
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  privileged: false
{{- end -}}
{{- end -}}

{{- define "control-plane.common.pod-security-context" -}}
{{- if (.Values.common).podSecurityContext -}}
{{- if .Values.common.podSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.common.podSecurityContext "enabled" "defaultSeccompProfile" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- if not .Values.common.podSecurityContext.seccompProfile -}}
{{- if .Values.apiGatewayNginx.podSecurityContext.defaultSeccompProfile -}}
{{- include "control-plane.common.security-context-seccomp" . -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  fsGroup: 65532
{{- include "control-plane.common.security-context-seccomp" . }}
{{- end -}}
{{- end -}}

{{- define "control-plane.common.container-security-context" -}}
{{- if (.Values.common).containerSecurityContext -}}
{{- if .Values.common.containerSecurityContext.enabled -}}
securityContext:
{{- range $key, $value := omit .Values.common.containerSecurityContext "enabled" }}
  {{ $key }}: {{- toYaml $value | nindent 4 }}
{{- end -}}
{{- end -}}
{{- else -}}
securityContext:
  runAsNonRoot: true
  runAsUser: 65532
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  privileged: false
{{- end -}}
{{- end -}}


{{/***********************************************************************/}}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/***********************************************************************/}}

{{/*
Create the name of the service account to use
*/}}
{{- define "jmeter-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jmeter-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
