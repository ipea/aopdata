# Download spatial hexagonal grid H3

Results of the AOP project are spatially aggregated on a H3 spatial grid
at resolution 9, with a side of 174 meters and an area of 0.10 km2. More
information about H3 at <https://h3geo.org/docs/core-library/restable/>.
See the documentation 'Details' for the data dictionary.

## Usage

``` r
read_grid(city = NULL, showProgress = FALSE)
```

## Arguments

- city:

  Character. A city name or three-letter abbreviation. If `city="all"`,
  the function returns data for all cities.

- showProgress:

  Logical. If `TRUE`, displays a progress bar. Defaults to `FALSE`.

## Value

An `sf data.frame` object

## Data dictionary:

|               |               |                                       |
|---------------|---------------|---------------------------------------|
| **Data type** | **column**    | **Description**                       |
| geographic    | `id_hex`      | Unique id of hexagonal cell           |
| geographic    | `abbrev_muni` | Abbreviation of city name (3 letters) |
| geographic    | `name_muni`   | City name                             |
| geographic    | `code_muni`   | 7-digit code of each city             |

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
# Read spatial grid of a single city
nat <- read_grid(city = 'Natal', showProgress = FALSE)

# Read spatial grid of all cities in the project
# all <- read_grid(city = 'all', showProgress = FALSE)
```
