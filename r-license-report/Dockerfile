FROM rocker/tidyverse:4.1.0

# Install the checkpoint package
RUN R -e "install.packages(c('checkpoint'), repos='http://cran.us.r-project.org')"

# Copy scripts
COPY license-report.R /license-report.R
COPY entrypoint.sh /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
