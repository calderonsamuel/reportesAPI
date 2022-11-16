
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reportesAPI

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/reportesAPI)](https://CRAN.R-project.org/package=reportesAPI)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of reportesAPI is to be able to get data from a Reportes
instance for use in the app or in analysis.

The user should also have an `.Renviron` file containing the following
variables:

- `DB_HOST`
- `DB_NAME`
- `DB_USER`
- `DB_SECRET`
- `DB_PORT`
- `REPORTES_EMAIL` (Optional)

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

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
