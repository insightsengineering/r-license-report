FROM rocker/tidyverse:4.1.2

# Copy scripts
COPY license-report.R /main.R
COPY entrypoint.sh /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
