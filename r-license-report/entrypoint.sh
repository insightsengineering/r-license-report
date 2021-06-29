#!/usr/bin/env bash

ARGS=""

if [[ "${INPUT_FAIL}" == "true" || "${INPUT_FAIL}" == "1" ]]
then {
    ARGS="${ARGS} -f"
}
fi

if [[ -z "${INPUT_PATH}" ]]
then {
    ARGS="${ARGS} -p ${INPUT_PATH}"
}
fi

if [[ -z "${INPUT_REGEX}" ]]
then {
    ARGS="${ARGS} -r ${INPUT_REGEX}"
}
fi

if [[ -z "${INPUT_MRAN_SNAPSHOT_DATE}" ]]
then {
    ARGS="${ARGS} -s ${INPUT_MRAN_SNAPSHOT_DATE}"
}
fi

if [[ -z "${INPUT_BIOC_RELEASE}" ]]
then {
    ARGS="${ARGS} -b ${INPUT_BIOC_RELEASE}"
}
fi

Rscript /main.R "${ARGS}"
