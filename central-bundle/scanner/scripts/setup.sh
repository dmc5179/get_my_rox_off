#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

KUBE_COMMAND=${KUBE_COMMAND:-oc}

${KUBE_COMMAND} get namespace stackrox &>/dev/null || ${KUBE_COMMAND} create namespace stackrox
${KUBE_COMMAND} -n stackrox annotate namespace/stackrox --overwrite openshift.io/node-selector=""



${KUBE_COMMAND} get scc/scanner &>/dev/null || ${KUBE_COMMAND} create -f "$DIR/scanner-scc.yaml.txt"
while ! ${KUBE_COMMAND} get scc/scanner &>/dev/null; do
    sleep 1
done

if ! ${KUBE_COMMAND} get secret/stackrox -n stackrox > /dev/null; then
  registry_auth="$("${DIR}/../../docker-auth.sh" -m k8s "https://10.3.62.83:5000")"
  [[ -n "$registry_auth" ]] || { echo >&2 "Unable to get registry auth info." ; exit 1 ; }
  ${KUBE_COMMAND} create --namespace "stackrox" -f - <<EOF
apiVersion: v1
data:
  .dockerconfigjson: ${registry_auth}
kind: Secret
metadata:
  name: stackrox
  namespace: stackrox
  labels:
    app.kubernetes.io/name: stackrox
type: kubernetes.io/dockerconfigjson
EOF
fi
