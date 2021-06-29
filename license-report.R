#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("jsonlite"))
suppressPackageStartupMessages(library("curl"))
suppressPackageStartupMessages(library("purrr"))
library("stringr")
library("docopt")
library("cli")
library("glue")
library("tools")

options(warn = -1)

## Check if file exists and get path of downloaded file if URL is specified
check_file_exists <- function(dir, fname, url = NA) {
  fpath <- file.path(dir, fname)
  if (!file.exists(fpath)) {
    if (!is.na(url)) {
      download.file(url, fpath, quiet = TRUE)
    } else {
      stop(fpath, " - File not found", call. = FALSE)
    }
  }
  return(fpath)
}

## Cleans and converts field to vector
clean_description_field <- function(field) {
  field <- str_split(field, ",")[[1]]
  field <- str_squish(field)
  pkgs <- str_remove(field, " .*")
  return(pkgs)
}

## Gets direct dependencies for package
pkg_deps <- function(pkg) {
  dep <- package_dependencies(pkg,
                              which = c("Depends", "Imports", "LinkingTo"),
                              recursive = TRUE)
  dep <- unlist(dep)
  return(unique(c(pkg, dep)))
}

## Get comprehensive list of transitive dependencies for package
## TODO: Add support for renv
get_licenses <- function(dir = ".",
                         fields = c("Depends", "Imports"),
                         snapshot = format(Sys.time(), '%Y-%m-%d'),
                         bioc_release = "release") {
  # Set values
  fields_to_read <- c("Package", "Version", "License")
  mran_url <-
    glue("https://mran.microsoft.com/snapshot/{snapshot}/src/contrib")
  bioc_home <-
    glue("https://www.bioconductor.org/packages/{bioc_release}/")
  bioc_packages_path <- "/src/contrib/PACKAGES"
  bioc_categories <- c("bioc", "data/experiment", "data/annotation")
  # Get a vector of all dependencies from the DESCRIPTION
  fname <- check_file_exists(dir, "DESCRIPTION")
  des <- read.dcf(fname)
  out <- des[, intersect(colnames(des), fields)]
  out <- as.list(out)
  names(out) <- NULL
  pkgs <- purrr::map(out, clean_description_field)
  all_deps <- unlist(purrr::map(pkgs, pkg_deps))
  all_deps <- sort(unique(all_deps))
  
  if (is.null(all_deps)) {
    cli_alert_info(glue("No dependencies found in package's {toString(fields)}"))
    quit(status = 0)
  }
  
  # Packages versions and licenses for a given MRAN snapshot
  avail_pkgs <- available.packages(contrib_url = mran_url)
  avail_pkgs <-
    avail_pkgs[rownames(avail_pkgs) %in% all_deps, fields_to_read]
  
  # Packages licenses and versions from R core
  installed_pkgs <- installed.packages()
  full_r_version <-
    paste(R.Version()$major, R.Version()$minor, sep = ".")
  core_packages <-
    installed_pkgs[installed_pkgs[, "License"] == paste0("Part of R ", full_r_version), ]
  core_packages <-
    core_packages[rownames(core_packages) %in% all_deps, fields_to_read]
  
  # Packages versions and licenses from BioC
  cache_dir <- tempdir()
  bioc_metadata <- data.frame()
  for (category in bioc_categories) {
    metadata_url <- paste0(bioc_home, category, bioc_packages_path)
    metadata_cache <-
      check_file_exists(cache_dir, gsub("/", "_", category), metadata_url)
    metadata <- read.dcf(metadata_cache, fields = fields_to_read)
    bioc_metadata <-
      rbind(bioc_metadata, metadata, stringsAsFactors = FALSE)
  }
  bioc_pkgs <-
    bioc_metadata[bioc_metadata$Package %in% all_deps, fields_to_read]
  
  known_licences <- rbind(avail_pkgs, core_packages, bioc_pkgs)
  unknown_deps <- all_deps[!(all_deps %in% known_licences$Package)]
  
  unknown_licenses <- data.frame(
    Package  = unknown_deps,
    Version = rep(NA, length(unknown_deps)),
    License = rep("Package not in BioC/CRAN", length(unknown_deps))
  )
  
  return(rbind(known_licences, unknown_licenses))
}

parse_arguments <- function() {
  'License Report.

Usage:
  license-report.R [-p dir] [-r regex] [-f] [-s snapshot] [-b release]
  license-report.R -h | --help

Options:
  -r regex     If a license matches this regular expression, it will be flagged. [default: ""]
  -p path      Path to directory containing the DESCRIPTION file. [default: "."]
  -f           Yield a non-zero exit status for any flagged licenses that match the regular expression. [default: FALSE]
  -s snapshot  MRAN snapshot date for package metadata retrieval. Format: YYYY-MM-DD. Defaults to current date. [default: ""]
  -b release   BioConductor release version for package metadata retrieval. [default: release]
' -> doc
  
  return(docopt(doc))
}

## Get licenses for all dependencies
main <- function() {
  # Parse args
  args <- parse_arguments()
  # Set snapshot
  if (args$s == "") {
    args$s <- format(Sys.time(), '%Y-%m-%d')
  }
  # Fetch deps
  cli_alert("Gathering license information for dependencies...")
  deps <-
    get_licenses(dir = args$p,
                 snapshot = args$s,
                 bioc_release = args$b)
  cli_alert("Analyzing license information...")
  # Set fail counter
  fail_counter <- 0
  # Loop through deps
  ## TODO: Export report as CSV, XLSX, PDF
  for (d in 1:nrow(deps)) {
    # Package name and version
    pkg_name <- deps[d, "Package"]
    pkg_version <- deps[d, "Version"]
    # Get license
    license <- deps[d, "License"]
    # Flag if regex is matched, otherwise do not
    if (stringr::str_detect(license, args$r)) {
      fail_counter <- fail_counter + 1
      cli_alert_warning(glue("{pkg_name} | {pkg_version} | {license}"))
    } else {
      cli_alert_info(glue("{pkg_name} | {pkg_version} | {license}"))
    }
  }
  # Force fail if set
  if (args$f) {
    if (fail_counter > 0) {
      cli_alert_danger(glue("{fail_counter} licenses flagged for review"))
    }
    quit(status = fail_counter)
  }
}

# Execute main
main()
