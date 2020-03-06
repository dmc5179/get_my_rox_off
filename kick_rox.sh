#!/bin/bash
###################################
# edit vars
###################################
set -e
password="p@ssw0rd"
stackrox_lic=mylicense.lic
registry_prefix="10.0.1.5:5000/stackrox/"
main_image="${registry_prefix}main:3.0.36.0"
monitoring_image="${registry_prefix}monitoring:3.0.36.0"
scanner_image="${registry_prefix}scanner:2.0.2"
scanner_db_image="${registry_prefix}scanner-db:2.0.2"

function rox () {
  echo -n " setting up stackrox "
  roxctl central generate openshift none \
    --offline \
    --lb-type route \
    --monitoring-lb-type route \
    --main-image $main_image \
    --scanner-image $scanner_image \
    --scanner-db-image $scanner_db_image \
    --license $stackrox_lic \
    --password $password > /dev/null 2>&1

}

case "$1" in
	rox) rox;;
	*) echo "Usage: $0 {rox}"; exit 1
esac
