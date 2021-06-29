#!/usr/bin/env bash

set -x

FAIL_ARG=""
if [[ "${INPUT_FAIL}" == "true" || "${INPUT_FAIL}" == "1" ]]
then {
    FAIL_ARG="-f"
}
fi

Rscript /main.R \
    $FAIL_ARG \
    -p "${INPUT_PATH:-"."}" \
    -r "${INPUT_REGEX:-""}" \
    -s "${INPUT_MRAN_SNAPSHOT_DATE:-$(date "+%Y-%m-%d")}" \
    -b "${INPUT_BIOC_RELEASE}:-release"
