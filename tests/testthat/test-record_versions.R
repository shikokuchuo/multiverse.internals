test_that("record_versions() in a mock repo", {
  # Temporary files used in the mock test.
  manifest <- tempfile()
  # First update to the manifest.
  contents <- data.frame(
    package = c(
      "package_unmodified",
      "version_decremented",
      "version_incremented",
      "version_unmodified"
    ),
    version_current = rep("1.0.0", 4L),
    hash_current = rep("hash_1.0.0", 4L)
  )
  record_versions(
    manifest = manifest,
    current = contents
  )
  written <- jsonlite::read_json(manifest)
  expected <- list(
    list(
      package = "package_unmodified",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0"
    ),
    list(
      package = "version_decremented",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0"
    ),
    list(
      package = "version_incremented",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0"
    ),
    list(
      package = "version_unmodified",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0"
    )
  )
  expect_true(identical(written, expected))
  # Update the manifest after no changes to packages or versions.
  suppressMessages(
    record_versions(
      manifest = manifest,
      current = contents
    )
  )
  written <- jsonlite::read_json(manifest)
  expected <- list(
    list(
      package = "package_unmodified",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0",
      version_highest = "1.0.0",
      hash_highest = "hash_1.0.0"
    ),
    list(
      package = "version_decremented",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0",
      version_highest = "1.0.0",
      hash_highest = "hash_1.0.0"
    ),
    list(
      package = "version_incremented",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0",
      version_highest = "1.0.0",
      hash_highest = "hash_1.0.0"
    ),
    list(
      package = "version_unmodified",
      version_current = "1.0.0",
      hash_current = "hash_1.0.0",
      version_highest = "1.0.0",
      hash_highest = "hash_1.0.0"
    )
  )
  expect_true(identical(written, expected))
  # Update the packages in all the ways indicated above.
  index <- contents$package == "version_decremented"
  contents$version_current[index] <- "0.0.1"
  contents$hash_current[index] <- "hash_0.0.1"
  index <- contents$package == "version_incremented"
  contents$version_current[index] <- "2.0.0"
  contents$hash_current[index] <- "hash_2.0.0"
  index <- contents$package == "version_unmodified"
  contents$version_current[index] <- "1.0.0"
  contents$hash_current[index] <- "hash_1.0.0-modified"
  for (index in seq_len(2L)) {
    record_versions(
      manifest = manifest,
      current = contents
    )
    written <- jsonlite::read_json(manifest)
    expected <- list(
      list(
        package = "package_unmodified",
        version_current = "1.0.0",
        hash_current = "hash_1.0.0",
        version_highest = "1.0.0",
        hash_highest = "hash_1.0.0"
      ),
      list(
        package = "version_decremented",
        version_current = "0.0.1",
        hash_current = "hash_0.0.1",
        version_highest = "1.0.0",
        hash_highest = "hash_1.0.0"
      ),
      list(
        package = "version_incremented",
        version_current = "2.0.0",
        hash_current = "hash_2.0.0",
        version_highest = "2.0.0",
        hash_highest = "hash_2.0.0"
      ),
      list(
        package = "version_unmodified",
        version_current = "1.0.0",
        hash_current = "hash_1.0.0-modified",
        version_highest = "1.0.0",
        hash_highest = "hash_1.0.0"
      )
    )
    expect_true(identical(written, expected))
  }
  # Remove temporary files
  unlink(manifest)
})

test_that("manifest can be created and updated from an actual repo", {
  manifest <- tempfile()
  temp <- utils::capture.output(
    suppressMessages(
      record_versions(
        manifest = manifest,
        repo = "https://wlandau.r-universe.dev"
      )
    )
  )
  expect_true(file.exists(manifest))
  contents <- do.call(vctrs::vec_rbind, jsonlite::read_json(manifest))
  contents <- lapply(contents, as.character)
  lapply(contents, function(x) expect_true(!anyNA(x)))
  temp <- utils::capture.output(
    suppressMessages(
      record_versions(
        manifest = manifest,
        repo = "https://wlandau.r-universe.dev"
      )
    )
  )
  contents <- jsonlite::read_json(manifest)
  expect_true(is.character(contents[[1L]]$package))
  expect_true(length(contents[[1L]]$package) == 1L)
  expect_true(file.exists(manifest))
  unlink(manifest)
})
