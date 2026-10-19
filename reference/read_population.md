# Download population and socioeconomic data

Download population and socioeconomic data from the Brazilian Census at
a fine spatial resolution for the cities included in the AOP project.
See the documentation 'Details' for the data dictionary. The data set
reports information for each hexagon in a H3 spatial grid at resolution
9, with a side of 174 meters and an area of 0.10 km2. More information
about H3 at <https://h3geo.org/docs/core-library/restable/>.

## Usage

``` r
read_population(
  city = NULL,
  year = 2010,
  geometry = FALSE,
  showProgress = TRUE
)
```

## Arguments

- city:

  Character. A city name or three-letter abbreviation. If `city="all"`,
  the function returns data for all cities.

- year:

  Numeric. Year of the census data. Only 2010 is available (the
  default).

- geometry:

  Logical. If `FALSE` (the default), returns a regular data.table of aop
  data. If `TRUE`, returns an `sf data.frame` with simple feature
  geometry of spatial hexagonal grid H3. See details in
  [read_grid](https://ipea.github.io/aopdata/reference/read_grid.md).

- showProgress:

  Logical. Defaults to `TRUE` display progress bar.

## Value

A `data.table`, or an `sf` object (which also inherits from
`data.table`) when `geometry = TRUE`.

## Data dictionary:

|  |  |  |  |
|----|----|----|----|
| **data_type** | **column** | **description** | **values** |
| temporal | year | Year of reference |  |
| geographic | id_hex | Unique id of hexagonal cell |  |
| geographic | abbrev_muni | Abbreviation of city name (3 letters) |  |
| geographic | name_muni | City name |  |
| geographic | code_muni | 7-digit code of each city |  |
| sociodemographic | P001 | Total number of residents |  |
| sociodemographic | P002 | Number of white residents |  |
| sociodemographic | P003 | Number of black residents |  |
| sociodemographic | P004 | Number of indigenous residents |  |
| sociodemographic | P005 | Number of Asian-descendant residents |  |
| sociodemographic | P006 | Number of men |  |
| sociodemographic | P007 | Number of women |  |
| sociodemographic | P010 | Number of people between 0 and 5 years old |  |
| sociodemographic | P011 | Number of people between 6 and 14 years old |  |
| sociodemographic | P012 | Number of people between 15 and 18 years old |  |
| sociodemographic | P013 | Number of people between 19 and 24 years old |  |
| sociodemographic | P014 | Number of people between 25 and 39 years old |  |
| sociodemographic | P015 | Number of people between 40 and 69 years old |  |
| sociodemographic | P016 | Number of people with 70 years old or more |  |
| sociodemographic | R001 | Average household income per capita | R\$ (Brazilian Reais), values in 2010 |
| sociodemographic | R002 | Income quintile group | 1 (poorest), 2, 3, 4, 5 (richest) |
| sociodemographic | R003 | Income decile group | 1 (poorest), 2, 3, 4, 5, 6, 7, 8, 9, 10 (richest) |

## Cities available

|                 |                               |
|-----------------|-------------------------------|
| **City name**   | **Three-letter abbreviation** |
| Belem           | `bel`                         |
| Belo Horizonte  | `bho`                         |
| Brasilia        | `bsb`                         |
| Campinas        | `cam`                         |
| Campo Grande    | `cgr`                         |
| Curitiba        | `cur`                         |
| Duque de Caxias | `duq`                         |
| Fortaleza       | `for`                         |
| Goiania         | `goi`                         |
| Guarulhos       | `gua`                         |
| Maceio          | `mac`                         |
| Manaus          | `man`                         |
| Natal           | `nat`                         |
| Porto Alegre    | `poa`                         |
| Recife          | `rec`                         |
| Rio de Janeiro  | `rio`                         |
| Salvador        | `sal`                         |
| Sao Goncalo     | `sgo`                         |
| Sao Luis        | `slz`                         |
| Sao Paulo       | `spo`                         |

## Examples

``` r
# a single city: pass the city name
bho <- read_population(
  city = 'Belo Horizonte',
  year = 2010,
  showProgress = FALSE
  )

# ... or pass a three-letter abbreviation
bho <- read_population(
  city = 'bho',
  year = 2010,
  showProgress = FALSE
  )

# all cities
all <- read_population(city = 'all', year = 2010)
#> Downloading population data for the year 2010
```
