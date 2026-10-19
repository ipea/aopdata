---
paths:
  - "r-package/NEWS.md"
  - "r-package/README.md"
  - "README.md"
  - "r-package/vignettes/**"
  - "r-package/DESCRIPTION"
  - "r-package/cran-comments.md"
  - "r-package/R/**/*.R"
---

# Summary–body parity

**When editing a summary, re-check the whole summary against what it
summarises.** Don't patch just the flagged word. Summaries drift when the body
changes and the summary isn't re-verified.

**Summaries in this repo:**
- the `Description:` field in `DESCRIPTION`
- both READMEs (root `README.md` and `r-package/README.md`): intro, years,
  number of cities, modes
- vignette introductions
- the opening of each `NEWS.md` version entry
- `cran-comments.md`
- PR titles and `## Summary` blocks
- roxygen `@description` / title lines

**Duplicated facts (aopdata-specific drift magnets):** the city table (4
readers), the data dictionary (`@details` of each reader +
`data_dic_en.Rmd` + `data_dic_pt.Rmd`), the public-transport cities per
year in the docs, and "years available" / "number of cities"
claims in the READMEs and `DESCRIPTION`. The hosted `metadata.csv` is the
source of truth for what exists.

## Protocol

1. Read the full body (the function's actual behaviour, the metadata, the full
   NEWS section, the vignette).
2. List every claim in the summary: counts, years, cities, modes, function
   names, "now supports X", "no longer Y".
3. Check each claim against the code, metadata or body.
4. Rewrite the paragraph as a whole when any claim fails, and update every
   duplicated copy.
5. If the same summary is flagged twice in a row, rewrite it structurally and
   prefer fewer enumerative claims. A summary with no counts can't drift.
