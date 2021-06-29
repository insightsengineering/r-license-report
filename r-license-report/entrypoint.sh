#!/usr/bin/env bash

FAIL_ARG=""
if [[ "${INPUT_FAIL}" == "true" || "${INPUT_FAIL}" == "1" ]]
then {
    FAIL_ARG="-f"
}
fi

Rscript /main.R \
    -p "${INPUT_PATH}" \
    -r "${INPUT_REGEX}" \
    ${FAIL_ARG} \
    -s "${INPUT_MRAN_SNAPSHOT_DATE}" \
    -b "${INPUT_BIOC_RELEASE}"
