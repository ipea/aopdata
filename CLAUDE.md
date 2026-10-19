# CLAUDE.md — aopdata

**aopdata** is an R package to download data from Ipea's *Access to
Opportunities Project* (AOP): accessibility estimates by transport mode,
population/socioeconomic data and land use (jobs, schools, health, CRAS), all
aggregated on an H3 hexagonal grid (resolution 9) for the 20 largest Brazilian
cities, years 2017–2019. Published on CRAN; developed by Ipea (ipea).
Maintainer: Rafael H. M. Pereira. License MIT. Docs:
<https://ipea.github.io/aopdata/>.

**The package lives in the `r-package/` subfolder**, not at the repo root. Run
R tooling against `"r-package"` (or from inside it); git commands run from the
repo root.

---

## Core principles

- **Fail gracefully, never error on the network.** CRAN policy: when a data
  server is unreachable, functions print an informative `cli` message and return
  `invisible(NULL)`; the `NULL` must propagate through every calling level
  (`read_access()` → `read_landuse()` → `read_population()`).
- **CRAN-ready at all times.** `R CMD check --as-cran`: 0 errors, 0 warnings.
  Examples, tests and vignettes that download data never run on CRAN.
- **Docs stay in sync with the data.** City lists, years, modes and the data
  dictionary are repeated in several roxygen blocks and two dictionary
  vignettes; change one, change all.
- **Plan first.** Enter plan mode before non-trivial tasks. Every plan must be
  reviewed by two adversarial agents that improve it and make it simpler, with
  as little code intervention as possible. Present the plan only when both
  agents reach consensus (max 3 rounds, then escalate the disagreement). Plans
  live in `quality_reports/plans/`.
- **Verify after.** Every task ends with the gates below, not with "should work".
- **Learn from corrections.** Log `[LEARN:category] wrong → right` in
  `MEMORY.md`.
- **Code style.** Always use the convention `package::function()`. Exceptions
  are functions from ggplot2 and special data.table operators such as `:=`.

Conventions are in [`.claude/rules/r-package-conventions.md`](.claude/rules/r-package-conventions.md);
gates are in [`.claude/rules/quality-gates.md`](.claude/rules/quality-gates.md).

---

## Repository map

```
aopdata/                          # git root
├── README.md                     # GitHub landing page (hand-written; differs from r-package/README.md)
├── .github/workflows/            # R-CMD-CHECK, R-CMD-check-CRAN, pkgdown, test-coverage (trigger on r-package/**)
├── papers/                       # Ipea technical reports (not part of the package)
└── r-package/                    # THE PACKAGE
    ├── DESCRIPTION, NAMESPACE    # NAMESPACE is roxygen-generated; never hand-edit
    ├── R/
    │   ├── aopdata.R             # package doc, @importFrom, utils::globalVariables()
    │   ├── read_access.R         # read_access(): access + land use (+ grid if geometry = TRUE)
    │   ├── read_landuse.R        # read_landuse(): land use + population
    │   ├── read_population.R     # read_population()
    │   ├── read_grid.R           # read_grid(): H3 sf grid
    │   ├── aopdata_dictionary.R  # opens the dictionary vignette in a browser
    │   ├── download_metadata.R   # metadata.csv → tempdir (session cache)
    │   └── utils.R               # select_*_input, select_metadata, download_data, load_data,
    │                             # aop_merge, aop_spatial_join, check_connection, check_downloaded_obj
    ├── man/roxygen/templates/    # @template city / year / geometry / showProgress
    ├── tests/testthat/           # test_<function>.R (underscore); every file skip_on_cran(); needs internet
    ├── tests/tests_rafa/         # maintainer scratch (Rbuildignored) — don't touch
    ├── vignettes/                # aopdata, access_maps, access_inequality, landuse_maps,
    │                             # population_maps, data_dic_en, data_dic_pt
    ├── pkgdown/_pkgdown.yml      # minimal config (no reference index)
    ├── prep_data/                # data-prep scripts for the hosted files (Rbuildignored)
    ├── NEWS.md, cran-comments.md
    └── README.md                 # CRAN README (plain .md, no .Rmd)
```

Data flow: `select_metadata(t, c, y, m)` reads `metadata.csv` (GitHub release
`v1.0.0` first, Ipea server fallback) and returns the file URLs →
`download_data()` downloads each file with httr2 (`aop_fetch()`, parallel) from
the Ipea server, retries failed files from the GitHub release, and saves them
to `tempdir()` (session cache, `.part` then rename) → `load_data()` reads
`.csv` with `data.table::fread()` or `.gpkg` with `sf::st_read()`.

Local-only workflow files (gitignored): `MEMORY.md`, `quality_reports/`,
`templates/`, and everything in `.claude/` except `rules/`. They sit at the
repo root, outside `r-package/`, so they never reach the package tarball.

---

## Commands

Run from the repo root (or `cd r-package` and drop the path argument).

```r
devtools::load_all("r-package")
devtools::document("r-package")                       # regenerate man/ + NAMESPACE
devtools::test("r-package")                           # full suite (NOT_CRAN=true; needs internet)
devtools::test("r-package", filter = "read_access")
devtools::check("r-package", args = "--as-cran")      # long; run in background
devtools::build_vignettes("r-package")
pkgdown::build_site("r-package")
covr::package_coverage("r-package")
```

- Tests, examples (`@examplesIf NOT_CRAN`) and vignettes (`eval = NOT_CRAN`
  plus `eval = !is.null(df)` guards) all download real data. Offline, they
  should skip or degrade, never error.
- No `.lintr` in the repo; `lintr` is advisory only on new code.

---

## Quality gates (summary)

| Checkpoint | Must hold |
|---|---|
| Commit | `document()` produces no content drift (`git diff`); tests for touched functions pass; `NEWS.md` entry for user-facing changes; docs tables/vignettes in sync if data facts changed |
| PR | Full `test()` passes; `check(--as-cran)` gives 0 errors / 0 warnings, NOTEs triaged; offline behaviour still graceful; review loop converged; `r-package-reviewer` 0 CRITICAL/MAJOR |
| Release | `/aop-package-check`; win-builder + rhub; `cran-comments.md` updated |

Details: `.claude/rules/quality-gates.md`.

---

## Skills and agents

These are local to the maintainer's Claude setup and are not in git. In a fresh
clone, follow the rules in `.claude/rules/` directly.

Project skills carry an `aop-` prefix so user-level skills with the same base
name can't shadow them. **In this repo, always use the `aop-` version:** use
`/aop-commit`, never a generic `/commit`. Where user-level rules conflict with
`.claude/rules/`, the project rules win.

- `/aop-package-check`: document, test, check `--as-cran`, triage, reviewer
  report.
- `/aop-commit`: Gate 1, then branch and commit. Push and PR only when asked,
  after Gate 2. **Merging to `main` only on explicit request.**
- `/aop-diagnose`: root-cause a failing test or wrong result.
- `/aop-checkpoint`, `/aop-compress-session`, `/context-status`: session state.
- `/aop-learn`: turn a session discovery into a reusable skill.
- Agent `r-package-reviewer`: read-only CRAN and convention review of
  package source.

---

## Working mode

1. **Plan:** for non-trivial tasks, enter plan mode, explore, ask only about
   real decisions, pass the adversarial plan review, and get approval.
2. **Execute (contractor mode):** after approval, work autonomously through
   implement → verify → parallel review → fix, looping until reviews come
   back dry (see `.claude/rules/orchestrator-protocol.md`). Come back only for
   ambiguity or a decision that belongs to the user.
3. **Report:** summarise what changed, gate results, open questions; log the
   session.

No commits, pushes, PRs, merges, version bumps, CRAN submissions, changes to
the hosted data files / `metadata.csv`, or `.github/workflows/` changes without
an explicit request. Never hand-edit generated files (`r-package/NAMESPACE`,
`r-package/man/*.Rd`).
