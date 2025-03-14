# Define the submission URL
cran_submission_url <- "https://xmpalantir.wu.ac.at/cransubmit/index2.php"

# Function to extract CRAN error message from HTML response
extract_cran_msg <- function(content) {
  # Very simple extraction - in reality would need better HTML parsing
  msg_pattern <- "<p>\\s*(.+?)\\s*</p>"
  m <- regmatches(content, regexpr(msg_pattern, content, perl = TRUE))
  if (length(m) > 0) {
    # Strip HTML tags
    gsub("<[^>]+>", "", m)
  } else {
    "Unknown error occurred"
  }
}

# Function to read CRAN comments
read_cran_comments <- function(pkg_dir) {
  comments_path <- file.path(pkg_dir, "cran-comments.md")
  if (file.exists(comments_path)) {
    readLines(comments_path, warn = FALSE)
  } else {
    "* This submission was automatically generated by the R Package CRAN Submission GitHub Action."
  }
}

# Main upload function
upload_cran <- function(pkg_dir, pkg_file, pkg_name, pkg_version, maint_name, maint_email) {
  cat("Starting CRAN submission process...\n")

  # Make sure required packages are available
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("Package 'httr' is required for CRAN submission")
  }

  # Validate required metadata
  if (is.null(pkg_name) || is.null(pkg_version) || is.null(maint_name) || is.null(maint_email)) {
    stop("Required package metadata is missing. Ensure pkg_name, pkg_version, maint_name, and maint_email are provided.")
  }

  # Create metadata list
  metadata <- list(
    package = pkg_name,
    version = pkg_version,
    name = maint_name,
    email = maint_email
  )

  cat("Package:", metadata$package, "Version:", metadata$version, "\n")
  cat("Maintainer:", metadata$name, "<", metadata$email, ">\n")

  # Get CRAN comments
  comments <- paste(read_cran_comments(pkg_dir), collapse = "\n")

  # Check if package file exists
  if (!file.exists(pkg_file)) {
    stop("Package file not found: ", pkg_file)
  }

  cat("Uploading package and comments to CRAN...\n")

  # Prepare request body
  body <- list(
    pkg_id = "",
    name = metadata$name,
    email = metadata$email,
    uploaded_file = httr::upload_file(pkg_file, "application/x-gzip"),
    comment = comments,
    upload = "Upload package"
  )

  # Submit package
  r <- httr::POST(cran_submission_url, body = body)

  # Handle 404 errors
  if (httr::status_code(r) == 404) {
    msg <- ""
    try({
      r2 <- httr::GET(sub("index2", "index", cran_submission_url))
      msg <- extract_cran_msg(httr::content(r2, "text"))
    })
    stop("Submission failed: ", msg)
  }

  # Check for other errors
  httr::stop_for_status(r)

  # Parse the URL to get pkg_id
  new_url <- httr::parse_url(r$url)

  cat("Confirming submission...\n")

  # Confirm submission
  body <- list(
    pkg_id = new_url$query$pkg_id,
    name = metadata$name,
    email = metadata$email,
    policy_check = "1/",
    submit = "Submit package"
  )

  r <- httr::POST(cran_submission_url, body = body)
  httr::stop_for_status(r)

  # Check if submission was successful
  new_url <- httr::parse_url(r$url)
  if (new_url$query$submit == "1") {
    cat("Package submission successful\n")
    cat("Check your email for confirmation link.\n")
  } else {
    stop("Package failed to upload")
  }

  return(TRUE)
}

# Use when called directly from command line
if (!interactive()) {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)

  # Get required package file path
  if (length(args) >= 1) {
    pkg_file <- args[1]
  } else {
    pkg_file <- Sys.getenv("SUBMISSION_PKG", "")
    if (pkg_file == "") {
      cat("Error: No package file specified. Provide as first argument or set SUBMISSION_PKG environment variable.\n")
      quit(status = 1)
    }
  }

  # Get package directory
  pkg_dir <- if (length(args) >= 2) args[2] else "."

  # Get package metadata - prioritize command line arguments, then environment variables
  pkg_name <- if (length(args) >= 3) args[3] else Sys.getenv("PKGNAME", NA)
  pkg_version <- if (length(args) >= 4) args[4] else Sys.getenv("VERSION", NA)
  maint_name <- if (length(args) >= 5) args[5] else Sys.getenv("MAINTAINER_NAME", NA)
  maint_email <- if (length(args) >= 6) args[6] else Sys.getenv("MAINTAINER_EMAIL", NA)

  # Check if we have all required metadata
  missing_metadata <- c()
  if (is.na(pkg_name)) missing_metadata <- c(missing_metadata, "PKGNAME")
  if (is.na(pkg_version)) missing_metadata <- c(missing_metadata, "VERSION")
  if (is.na(maint_name)) missing_metadata <- c(missing_metadata, "MAINTAINER_NAME")
  if (is.na(maint_email)) missing_metadata <- c(missing_metadata, "MAINTAINER_EMAIL")

  if (length(missing_metadata) > 0) {
    cat("Error: Missing required metadata:", paste(missing_metadata, collapse=", "), "\n")
    cat("Provide as command line arguments or set environment variables.\n")
    cat("Usage: Rscript submit_to_cran.R <package_file> [package_dir] [pkg_name] [pkg_version] [maint_name] [maint_email]\n")
    quit(status = 1)
  }

  # Execute submission
  result <- tryCatch({
    upload_cran(pkg_dir, pkg_file, pkg_name, pkg_version, maint_name, maint_email)
  }, error = function(e) {
    cat("Error during CRAN submission:", conditionMessage(e), "\n")
    return(FALSE)
  })

  # Exit with appropriate status code
  if (!result) {
    quit(save="no", status = 1)
  }
}