#!/bin/sh

# Port Forward to StackRox Monitoring
#
# Usage:
#   ./port-forward.sh 8443
#
# Using a different command:
#     The KUBE_COMMAND environment variable will override the default of kubectl
#
# Examples:
# To use the default command to create resources:
#     $ ./port-forward.sh 8443
# To use another command instead:
#     $ export KUBE_COMMAND='kubectl --context prod-cluster'
#     $ ./port-forward.sh 8443

if [ -z "$1" ]; then
	echo "usage: $0 8443"
	echo "The above would forward localhost:8443 to monitoring:8443."
	exit 1
fi

KUBE_COMMAND=${KUBE_COMMAND:-oc}

while true; do
    pod="$(${KUBE_COMMAND} get pod -n 'stackrox' --selector 'app=monitoring' --field-selector 'status.phase=Running' --output 'jsonpath={.items..metadata.name}' 2>/dev/null)"
    [ -z  "$pod" ] || break
    printf '.'
    sleep 1
done
echo

nohup ${KUBE_COMMAND} port-forward -n 'stackrox' svc/monitoring "$1:8443" 1>/dev/null 2>&1 &
echo "Access monitoring on https://localhost:$1"
