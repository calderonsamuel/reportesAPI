
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reportesAPI

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/reportesAPI)](https://CRAN.R-project.org/package=reportesAPI)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/calderonsamuel/reportesAPI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/calderonsamuel/reportesAPI/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/calderonsamuel/reportesAPI/branch/main/graph/badge.svg)](https://app.codecov.io/gh/calderonsamuel/reportesAPI?branch=main)
<!-- badges: end -->

The goal of reportesAPI is to be able to get data from a Reportes
instance for use in the app or in analysis.

The user should also have an `.Renviron` file containing the following
variables:

-   `DB_HOST`
-   `DB_NAME`
-   `DB_USER`
-   `DB_SECRET`
-   `DB_PORT`
-   `REPORTES_EMAIL` (Optional)

The package asumes you are using RMariaDB for data storage.

## Installation

You can install the development version of reportesAPI from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("calderonsamuel/reportesAPI")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(reportesAPI)

man <- DBManager$new()
#> ℹ Connected to DB
```

When fetching data, instead of returning a data.frame, by default we get
a tibble.

``` r
man$db_get_query("SELECT user_id, time_last_modified FROM users")
#> # A tibble: 7 × 2
#>   user_id                          time_last_modified 
#>   <chr>                            <dttm>             
#> 1 84f82757d27e55f7f781865524a7d0ae 2022-11-11 20:42:58
#> 2 81d8169fc25c672e452775ba5eec4cd8 2022-11-11 20:42:58
#> 3 243caa4a7de6f9212adbdc2f50ea97ec 2022-11-11 20:42:58
#> 4 d618dc956854bc12fa8084ae7f543dbd 2022-11-11 20:42:58
#> 5 3fd4eafdffff29d0f131304e35091549 2022-11-11 20:42:58
#> 6 2b4cd2e9a4a8f6f995e2a4ae0de7331e 2022-11-11 20:42:58
#> 7 25ec41daa87947b1d326d5515dc7b9a9 2022-11-11 20:42:58
```

To start an instance of `AppData` is necessary to provide an email. This
will not be done here for security reasons.
