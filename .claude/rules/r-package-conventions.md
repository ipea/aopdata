---
paths:
  - "r-package/R/**/*.R"
  - "r-package/tests/**/*.R"
  - "r-package/man/**"
  - "r-package/vignettes/**"
  - "r-package/DESCRIPTION"
  - "r-package/NAMESPACE"
  - "r-package/NEWS.md"
  - "r-package/README.md"
  - "r-package/pkgdown/**"
---

# aopdata package conventions

**Standard:** a CRAN-ready data-access package that never errors because a
server is down. `R CMD check --as-cran` returns 0 errors, 0 warnings, and only
explained notes. New code reads like the code around it.

Part A describes how aopdata is written today (verified against the source,
2026-10-12). Items tagged **[NEW]** are decisions for new or modified code only;
never apply them to untouched code as drive-bys. Part B is the general CRAN
standard. When they conflict, Part A wins; flag the conflict in the plan.

All paths below are relative to `r-package/`.

---

# Part A: aopdata house style

## A1. Namespacing

- **Always call `package::function()`**: `data.table::`, `checkmate::`,
  `curl::`, `sf::`, `cli::`, `utils::`.
- **Exceptions:** the `@importFrom` set in `R/aopdata.R` — `data.table`
  `setDT`, `:=`, `%like%`; `utils` `globalVariables`, `head`, `tail`;
  `methods` `is`. Base `subset()` is used throughout the read functions; keep it
  where it is.
- ggplot2 functions in vignettes and README, after `library(ggplot2)`.
- Never use `library()`/`require()` in `R/`. Suggested packages are guarded
  with `requireNamespace("pkg", quietly = TRUE)`.
- Column names used with non-standard evaluation go into the
  `utils::globalVariables(c(...))` block in `R/aopdata.R`. Append new names
  at the end and check for duplicates first.

## A2. The `read_*()` skeleton

Every exported reader follows the same pipeline. New readers copy it; changes
to one reader are checked against the others.

```r
read_something <- function(city = NULL, year = 2019, geometry = FALSE,
                           showProgress = TRUE) {

  # checks
  checkmate::assert_logical(geometry)

  # Get metadata with data url addresses
  temp_meta <- select_metadata(t = 'something', c = city, y = year)

  # check if download failed
  check_downloaded_obj(temp_meta) # nocov
  if (is.null(temp_meta)) { return(invisible(NULL)) }

  # download files
  file_url <- as.character(temp_meta$download_path2)
  aop <- download_data(url = file_url, progress_bar = showProgress)

  # check if download failed
  check_downloaded_obj(aop) # nocov
  if (is.null(aop)) { return(invisible(NULL)) }

  # geometry = TRUE: read_grid() + aop_spatial_join()
  ...
}
```

- **Inputs:** `city`, `year`, `mode` are validated by `select_city_input()`,
  `select_year_input()`, `select_mode_input()` in `R/utils.R` against the
  metadata, which is the source of truth for what exists. Other arguments use
  `checkmate::assert_*`. City input accepts names or 3-letter abbreviations,
  case- and accent-insensitive (`tolower()` + `iconv(to = "ASCII//TRANSLIT")`),
  and `"all"`.
- **Composition:** `read_access()` calls `read_landuse()`, which calls
  `read_population()`; `geometry = TRUE` adds `read_grid()`. A change in a
  lower reader changes every reader above it.
- **Return types:** `data.table`/`data.frame` when `geometry = FALSE`; `sf`
  (`aop_spatial_join()`) when `TRUE`. `read_grid()` always returns `sf`.

## A3. Network and graceful failure (CRAN policy)

This is the package's most important invariant.

- Network failures **never raise an error**. They print a `cli` alert
  (`cli::cli_alert_danger()`) and return `invisible(NULL)`. Input errors (bad
  city/year/mode, wrong type) do raise, with `cli::cli_abort()`.
- **Every call site** that receives the result of `select_metadata()`,
  `download_data()` or another reader checks `is.null()` and returns
  `invisible(NULL)` immediately. A missing check turns a graceful failure into
  an obscure error further down (e.g. `subset()` on `NULL`).
- `check_connection()` is the only place that probes a URL; it is silenced with
  `silent = TRUE` in internal calls so the user sees one message, not several
  (NEWS 1.1.2).
- **Mirrors:** `metadata.csv` comes from the GitHub release `v1.0.0` first and
  the Ipea server (`www.ipea.gov.br/geobr/aopdata/`) as fallback. Data files
  come from the Ipea URL in `metadata$download_path2` first, with the GitHub
  release `v1.0.0` as fallback. Keep both mirrors working; never hardcode a
  single server.
- **Cache:** downloads go to `tempdir()` only (session cache, `resume = TRUE`).
  Nothing is written outside `tempdir()`. **[NEW]** a persistent cache
  (`tools::R_user_dir()`) would be a user-facing change and needs a plan.
- Network code is wrapped in `# nocov start` / `# nocov end` or `# nocov`.

## A4. data.table and sf

- `aop_merge()` and `aop_spatial_join()` call `setDT()` on objects the package
  just downloaded, so in-place conversion is fine there. Never `setDT()` or
  `:=` on an object the **user** passed in.
- Join keys are `id_hex`, `abbrev_muni`, `name_muni`, `code_muni` (+ `year`
  for access/land use). Joins are keyed `merge.data.table(..., all = TRUE)` or
  `on =` joins; no row loops.
- The H3 grid geometry column comes in as `geom` and is joined into
  `geometry`. Spatial outputs keep the CRS of the hosted `.gpkg` files; don't
  transform it.

## A5. Messages and errors (cli)

- Errors: `cli::cli_abort()` with glue interpolation (`"... in {year} are:
  {cities_available}."`). Network problems: `cli::cli_alert_danger()`.
- Legacy: `message(paste0("Downloading ... for the year ", year))` in the
  readers. **[NEW]** new or modified progress messages use
  `cli::cli_inform()` / `cli::cli_progress_*`, and respect `showProgress`
  where relevant. Migrating the existing `message()` calls is its own planned
  step, never a drive-by.

## A6. Style

- 2-space indent, `<-`, snake_case, comments are short lowercase labels above
  each step (`# checks`, `# download files`), explicit `return()`.
- Existing argument names stay as they are (`showProgress` is camelCase for
  back-compatibility; don't rename exported arguments without a deprecation
  plan).
- The existing code is loosely formatted (`=` spacing, `T` in `load_data()`).
  Don't reformat untouched lines. **[NEW]** new lines use `TRUE`/`FALSE`, spaces
  around `=` and `<-`, and ≤ 80 columns.

## A7. Documentation (roxygen2, markdown)

- Use the templates in `man/roxygen/templates/`: `@template city`,
  `@template year`, `@template geometry`, `@template showProgress`.
- Use `@family` (`accessibility data functions`, `land use data functions`,
  `population data functions`, `spatial data functions`, `Data dictionary`).
  Internal helpers use `@keywords internal`.
- **Data dictionary tables** live in `@details` of each reader and are
  duplicated in `vignettes/data_dic_en.Rmd` and `vignettes/data_dic_pt.Rmd`.
  The **city table** (name, abbreviation, modes) is repeated in four readers.
  Any change to a column, city, year or mode updates every copy (see
  `summary-parity.md`), plus the public-transport city lists hardcoded per year
  in `read_access()`.
- **Examples** download data, so they use
  `@examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")` and
  `showProgress = FALSE`. Never `\dontrun{}` on an export.
- `pkgdown/_pkgdown.yml` has no `reference:` index, so new exports appear
  automatically. Add one only through a plan.
- Never hand-edit `NAMESPACE` or `man/*.Rd`; run `devtools::document()`.

## A8. Tests (testthat, 2nd edition)

- Files are `tests/testthat/test_<function>.R` (underscore). Each starts with
  `context("<function>")` and `testthat::skip_on_cran()` because every test
  downloads data. `DESCRIPTION` has no `Config/testthat/edition`; don't switch
  to 3e as a drive-by.
- Existing style: `expect_true(is(read_x(...), 'data.frame'))` /
  `'sf'` for expected behaviour; `expect_error()` for bad inputs; blocks under
  `### expected behavior` / `### expected errors` headers. Use small cities
  (`'nat'`) for speed.
- **New or modified readers need at least:**
  - expected class with `geometry = FALSE` and `TRUE`
  - errors for invalid `city`, `year`, `mode` and argument types
  - **graceful offline failure**: mock the network and expect `NULL`, e.g.
    `testthat::local_mocked_bindings(check_connection = function(...) FALSE)`
    then `expect_null(read_x(...))` (needs testthat ≥ 3.1.7; check that the
    mock reaches the code path — a cached `metadata.csv` in `tempdir()` can
    bypass it)
- Real-network tests also need `testthat::skip_if_offline()` when added.
- `tests/tests_rafa/` is the maintainer's scratch; leave it alone.

## A9. NEWS.md

Version headers are `# aopdata vX.Y.Z`. Sections are bold lines, not `##`:
`**Major changes**`, `**Minor changes**`, `**Bug fixes**` (add
`**New features**` only if needed). Bullets are plain sentences; packages as
`{pkg}`, functions in backticks.

## A10. Figures (vignettes, README, pkgdown)

- **Existing convention:** vignettes use ggplot2 + sf maps with
  `scale_fill_viridis_c()`-style continuous scales. The setup chunk sets
  `eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true")`; chunks after a
  download use `eval = !is.null(df)` so an offline build skips the plots
  instead of failing.
- **[NEW] Publication-ready standard for new or modified figures:**
  - one consistent theme (`theme_void()` for maps, `theme_minimal()` otherwise)
  - a colour-blind-safe palette (viridis / Okabe-Ito)
  - labelled legends/axes with units (minutes, number of jobs, R$)
  - fixed `fig.width`, `fig.height` and `dpi` in chunk options

  Existing figures are restyled only through a plan.

---

# Part B: general CRAN standard

- **DESCRIPTION:** `Imports` for code in `R/`, `Suggests` for
  tests/vignettes/optional paths, `Depends` only for the R version. Version
  floors only when a feature requires them. `Authors@R` with roles.
- **Docs:** every export documents all `@param`s, `@return`, and examples.
- **Internet resources (CRAN policy):** packages that use internet resources
  must fail gracefully with an informative message if the resource is not
  available or has changed, and must not cause check errors. See A3.
- **Red flags:**

| Red flag | Do instead |
|---|---|
| `library()`/`require()` in `R/` | `pkg::fun()` |
| Writing outside `tempdir()` | Write only to `tempdir()` or user-supplied paths |
| `stop()` / uncaught error on a network failure | `cli::cli_alert_danger()` + `return(invisible(NULL))` |
| Reader result used without `is.null()` check | `check_downloaded_obj()` + early return |
| A single hardcoded server URL | Ipea + GitHub-release mirrors (A3) |
| Example/test/vignette downloading on CRAN | `@examplesIf NOT_CRAN`, `skip_on_cran()`, `eval = NOT_CRAN` |
| `<<-` to global env | Return values |
| `print()`/`cat()` in functions | `cli::cli_inform()` |
| `options()` changed, not restored | `on.exit(..., add = TRUE)` |
| `T`/`F` in new code | `TRUE`/`FALSE` |
| `==` on doubles | `abs(x - y) < tol` or `all.equal()` |

- **Versioning:** the maintainer bumps versions (dev versions have used
  `x.y.z.999`); Claude never does.

## Checklist (new or modified code)

```
[ ] pkg::fun() everywhere (except the @importFrom set / ggplot2 in docs)
[ ] reader follows the A2 skeleton; NULL propagates at every call site
[ ] no error on network failure; one informative cli message; tested offline with a mock
[ ] downloads only to tempdir(); both mirrors still used
[ ] user-supplied objects never modified by reference
[ ] cli::cli_* for new messages
[ ] roxygen: templates, @family, @return, @examplesIf NOT_CRAN
[ ] dictionary/city tables updated in every reader + data_dic_en/pt vignettes
[ ] devtools::document() run; no hand-edited generated files
[ ] NEWS.md bullet for user-facing changes
```

## Cross-references

- [`quality-gates.md`](quality-gates.md): when each check must pass.
- `.claude/agents/r-package-reviewer.md` enforces this rule. It is local to the
  maintainer's setup and may be absent in a fresh clone; if so, apply the
  checklist manually.
