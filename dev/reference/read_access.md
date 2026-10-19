# Download accessibility estimates with population and land use data

Download estimates of access to employment, health, education and social
assistance services by transport mode and time of the day for the cities
included in the AOP project. See the documentation 'Details' for the
data dictionary. The data set reports information for each heaxgon in a
H3 spatial grid at resolution 9, with a side of 174 meters and an area
of 0.10 km2. More information about H3 at
<https://h3geo.org/docs/core-library/restable/>.

## Usage

``` r
read_access(
  city = NULL,
  mode = "walk",
  peak = TRUE,
  year = 2019,
  geometry = FALSE,
  showProgress = TRUE
)
```

## Arguments

- city:

  Character. A city name or three-letter abbreviation. If `city="all"`,
  the function returns data for all cities.

- mode:

  Character. A transport mode. Modes available include
  'public_transport', 'bicycle', or 'walk' (the default).

- peak:

  Logical. If `TRUE` (the default), returns accessibility estimates
  during peak time, between 6am and 8am. If `FALSE`, returns
  accessibility during off-peak, between 2pm and 4am. This argument only
  takes effect when `mode` is either `car` or `public_transport`.

- year:

  Numeric. A year number in YYYY format. Defaults to 2019.

- geometry:

  Logical. If `FALSE` (the default), returns a regular data.table of aop
  data. If `TRUE`, returns an `sf data.frame` with simple feature
  geometry of spatial hexagonal grid H3. See details in
  [read_grid](https://ipea.github.io/aopdata/dev/reference/read_grid.md).

- showProgress:

  Logical. Defaults to `TRUE` display progress bar.

## Value

A `data.frame` object

## Data dictionary:

|  |  |  |  |
|----|----|----|----|
| **data_type** | **column** | **description** | **values** |
| temporal | year | Year of reference |  |
| transport | mode | Transport mode | walk; bicycle; public_transport; car |
| transport | peak | Peak and off-peak | 1 (peak); 0 (off-peak) |

The name of the columns with accessibility estimates are the junction of
three components: 1) Type of accessibility indicator 2) Type of
opportunity / population 3) Time threshold

### 1) Type of accessibility indicator

|  |  |  |
|----|----|----|
| **Indicator** | **Description** | **Observation** |
| CMA | Cumulative opportunity measure (active) |  |
| CMP | Cumulative opportunity measure (passive) |  |
| TMI | Travel time to closest opportunity | Value = Inf when travel time is longer than 2h (public transport or car) or 1,5h (walking or bicycle) |

### 2) Type of opportunity / population

|  |  |  |
|----|----|----|
| **Type of opportunity** | **Description** | **Observation: available in combination with** |
| TT | All jobs | CMA indicator |
| TB | Jobs with primary education | CMA indicator |
| TM | Jobs with secondary education | CMA indicator |
| TA | Jobs with tertiary education | CMA indicator |
| ST | All healthcare facilities | CMA and TMI indicators |
| SB | Healthcare facilities - Low complexity | CMA and TMI indicators |
| SM | Healthcare facilities - Medium complexity | CMA and TMI indicators |
| SA | Healthcare facilities - High complexity | CMA and TMI indicators |
| ET | All public schools | CMA and TMI indicators |
| EI | Public schools - early childhood | CMA and TMI indicators |
| EF | Public schools - elementary schools | CMA and TMI indicators |
| EM | Public schools - high schools | CMA and TMI indicators |
| MT | All school enrollments | CMA and TMI indicators |
| MI | School enrollments - early childhood | CMA and TMI indicators |
| MF | School enrollments - elementary schools | CMA and TMI indicators |
| MM | School enrollments - high schools | CMA and TMI indicators |
| CT | All Social Assistance Reference Centers (CRAS) | CMA and TMI indicators |

|  |  |  |
|----|----|----|
| **People** | **Description** | **Observation: available in combination with** |
| PT | All population | CMP indicator |
| PH | Men | CMP indicator |
| PM | Women | CMP indicator |
| PB | White population | CMP indicator |
| PA | Asian-descendent population | CMP indicator |
| PI | Indigenous population | CMP indicator |
| PN | Back population | CMP indicator |
| P0005I | Population between 0 and 5 years old | CMP indicator |
| P0614I | Population between 6 and 14 years old | CMP indicator |
| P1518I | Population between 15 and 18 years old | CMP indicator |
| P1924I | Population between 19 and 24 years old | CMP indicator |
| P2539I | Population between 25 and 39 years old | CMP indicator |
| P4069I | Population between 40 and 69 years old | CMP indicator |
| P70I | Population with 70 years old or more | CMP indicator |

### 3) Time threshold (only applicable to CMA and CMP estimates)

|  |  |  |
|----|----|----|
| **Time threshold** | \*\*Description \*\* | **Observation: only applicable to** |
| 15 | Opportunities accessible within 15 min. | Active transport modes |
| 30 | Opportunities accessible within 30 min. | All transport modes |
| 45 | Opportunities accessible within 45 min. | Active transport modes |
| 60 | Opportunities accessible within 60 min. | All transport modes |
| 90 | Opportunities accessible within 90 min. | Public transport and car |
| 120 | Opportunities accessible within 120 min. | Public transport and car |

### 4) Cities available

|                 |                               |                     |
|-----------------|-------------------------------|---------------------|
| **City name**   | **Three-letter abbreviation** | **Transport modes** |
| Belem           | `bel`                         | Active              |
| Belo Horizonte  | `bho`                         | All                 |
| Brasilia        | `bsb`                         | Active              |
| Campinas        | `cam`                         | All                 |
| Campo Grande    | `cgr`                         | Active              |
| Curitiba        | `cur`                         | Active              |
| Duque de Caxias | `duq`                         | Active              |
| Fortaleza       | `for`                         | All                 |
| Goiania         | `goi`                         | All                 |
| Guarulhos       | `gua`                         | Active              |
| Maceio          | `mac`                         | Active              |
| Manaus          | `man`                         | Active              |
| Natal           | `nat`                         | Active              |
| Porto Alegre    | `poa`                         | All                 |
| Recife          | `rec`                         | All                 |
| Rio de Janeiro  | `rio`                         | All                 |
| Salvador        | `sal`                         | Active              |
| Sao Goncalo     | `sgo`                         | Active              |
| Sao Luis        | `slz`                         | Active              |
| Sao Paulo       | `spo`                         | All                 |

## Examples

``` r
# Read accessibility estimates of a single city
df <- read_access(
  city = 'Fortaleza',
  mode = 'public_transport',
  year = 2019,
  showProgress = FALSE
)

# Read accessibility estimates for all cities
all <- read_access(
  city = 'all',
  mode = 'walk',
  year = 2019,
  showProgress = FALSE
)
```
