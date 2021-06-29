#!/usr/bin/env bash

FAIL_ARG=""
if [[ "${INPUT_FAIL}" == "true" || "${INPUT_FAIL}" == "1" ]]
then {
    FAIL_ARG="-f"
}
fi

REGEX_ARG=""
if [[ "${INPUT_REGEX}" != "" ]]
then {
    REGEX_ARG="-r ${INPUT_REGEX}"
}
fi

Rscript /main.R \
    $FAIL_ARG \
    -p "${INPUT_PATH:-"."}" \
    ${REGEX_ARG} \
    -s "${INPUT_MRAN_SNAPSHOT_DATE:-$(date "+%Y-%m-%d")}" \
    -b "${INPUT_BIOC_RELEASE}"
