#!/usr/bin/env bash

set -e

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

# Generate the report
Rscript /main.R \
    $FAIL_ARG \
    -p "${INPUT_PATH:-.}" \
    ${REGEX_ARG} \
    -s "${INPUT_RSPM_SNAPSHOT_DATE:-$(date "+%Y-%m-%d")}" \
    -b "${INPUT_BIOC_RELEASE}" 2>&1 | tee output.raw

# Convert to HTML, if requested
TERMINAL_TO_HTML_VERSION="3.6.1"
if [[ "${INPUT_OUTPUT_TYPE}" == "html" ]]
then {
    echo "⏬ Downloading terminal-to-html"
    wget -q \
        -O t2html.gz \
        "https://github.com/buildkite/terminal-to-html/releases/download/v${TERMINAL_TO_HTML_VERSION}/terminal-to-html-${TERMINAL_TO_HTML_VERSION}-linux-amd64.gz"
    gunzip t2html.gz && chmod +x t2html
    echo "📄 Saving output as HTML"
    ./t2html --preview < output.raw > license-report.html
    echo "💾 HTML report saved at: $(pwd)/license-report.html"
}
fi

# Convert to PDF, if requested
if [[ "${INPUT_OUTPUT_TYPE}" == "pdf" ]]
then {
    echo "📄 Saving output as PDF"
    pandoc output.raw -o license-report.pdf
    echo "💾 PDF report saved at: $(pwd)/license-report.pdf"
}
fi
