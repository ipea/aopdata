---
paths:
  - "r-package/R/**"
  - "r-package/tests/**"
  - "r-package/vignettes/**"
  - "r-package/man/roxygen/**"
  - "r-package/DESCRIPTION"
  - "r-package/NEWS.md"
  - "r-package/README.md"
  - "README.md"
---

# Quality gates (aopdata)

Gates are **pass/fail checks**, not scores. A task is "done" only when the gate
for its checkpoint passes and the output has actually been seen; "should work"
doesn't count. Commands run from the repo root; the package is `r-package/`.

## Gate 1: Task done / commit

All must hold for the files touched:

| Check | Command | Pass |
|---|---|---|
| Docs regenerated | `Rscript -e "devtools::document('r-package')"` then `git diff --stat r-package/man/ r-package/NAMESPACE` | No unexpected content drift (use `git diff`, not `git status`: `core.autocrlf=true` can make EOL-only noise); intended changes staged with the source |
| Targeted tests | `Rscript -e "devtools::test('r-package', filter = '<fn>')"` for every touched function | 0 failures, 0 errors, 0 new warnings (needs internet) |
| Offline behaviour | for any change to a reader or `utils.R` network code: the mocked-offline test for that path | Returns `NULL` with one message, no error |
| Docs parity | if a column, city, year or mode changed | Every reader's `@details` table, `read_access()` PT city lists, `data_dic_en.Rmd` and `data_dic_pt.Rmd` agree |
| READMEs | if user-facing usage changed | Both `README.md` (root) and `r-package/README.md` updated where relevant |
| NEWS | user-facing change | Bullet in `r-package/NEWS.md` under the right bold section |
| Staging hygiene | `git diff --cached --name-only` | No `.rds`/`.RData`/`.Rhistory`/downloaded data; no workflow files except `CLAUDE.md` and `.claude/rules/` |
| Conventions | `.claude/rules/r-package-conventions.md` checklist | All items hold |

## Gate 2: Pull request

Gate 1, plus:

| Check | Command | Pass |
|---|---|---|
| Full suite | `Rscript -e "devtools::test('r-package')"` | 0 failures, 0 errors |
| CRAN check | `Rscript -e "devtools::check('r-package', args = '--as-cran')"` (background; several minutes) | 0 errors, 0 warnings; each NOTE triaged (pre-existing vs new) |
| Vignettes | built by `check()`; or `devtools::build_vignettes('r-package')` | Build with and without network (offline: chunks skip via `!is.null(df)`) |
| Review loop | parallel review lenses (`orchestrator-protocol.md`) | Converged: 0 open CRITICAL/MAJOR |
| Package review | `r-package-reviewer` agent on changed files (local; if absent, apply the conventions checklist manually) | 0 CRITICAL/MAJOR |

## Gate 3: Release (maintainer-driven)

Gate 2, plus `/aop-package-check` (full report), `devtools::check_win_devel('r-package')`
and/or R-hub, URL check (`urlchecker::url_check('r-package')`) since the
package depends on external servers, and `cran-comments.md` updated. Claude
prepares; the maintainer bumps the version and submits.

## Overrides

A gate may be skipped only on an explicit user instruction ("commit anyway"),
and the reason is recorded in the commit body and the session log. Never use
`git commit --no-verify`.

## Pre-existing failures

If a gate fails for reasons unrelated to the change (e.g. a data server is
down, an upstream package changed), don't fix it as a drive-by. Report it,
confirm it also fails on `main`, and add it to the backlog
(`quality_reports/specs/`).
