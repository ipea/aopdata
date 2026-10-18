# Data dictionary \[EN\]

Data dictionary in English:

``` r

aopdata_dictionary(lang = 'en')
```

## General variables (population, land use, transport)

| data_type | column | description | values |
|----|----|----|----|
| temporal | year | Year of reference |  |
| geographic | id_hex | Unique id of hexagonal cell |  |
| geographic | abbrev_muni | Abbreviation of city name (3 letters) |  |
| geographic | name_muni | City name |  |
| geographic | code_muni | 7-digit code of each city |  |
| sociodemographic | P001 | Total number of residents |  |
| sociodemographic | P002 | Number of white residents |  |
| sociodemographic | P003 | Number of black residents |  |
| sociodemographic | P004 | Number of Indigenous residents |  |
| sociodemographic | P005 | Number of asian-descendents residents |  |
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
| land use | T001 | Total number of formal jobs |  |
| land use | T002 | Number of formal jobs with primary education |  |
| land use | T003 | Number of formal jobs with secuodary education |  |
| land use | T004 | Number of formal jobs with tertiary education |  |
| land use | E001 | Total number of public schools |  |
| land use | E002 | Number of public schools - early childhood |  |
| land use | E003 | Number of public schools - elementary schools |  |
| land use | E004 | Number of public schools - high schools |  |
| land use | M001 | Total number of school enrollments |  |
| land use | M002 | Number of school enrollments - early childhood |  |
| land use | M003 | Number of school enrollments - elementary schools |  |
| land use | M004 | Number of school enrollments - high schools |  |
| land use | S001 | Total number of healthcare facilities |  |
| land use | S002 | Number of healthcare facilities - low complexity |  |
| land use | S003 | Number of healthcare facilities - medium complexity |  |
| land use | S004 | Number of healthcare facilities - high complexity |  |
| land use | C001 | Total number of Social Assistance Reference Centers (CRAS) |  |
| transport | mode | Transport mode | walk; bicycle; public_transport; car |
| transport | peak | Peak and off-peak | 1 (peak); 0 (off-peak) |

## Accessibility indicators

##### Organization of the columns with accessibility estimates

The name of the columns with accessibility estimates are the junction of
three components: 1) Type of accessibility indicator 2) Type of
opportunity / population 3) Time threshold

#### 1) Type of accessibility indicator

| Indicator | Description | Observation |
|----|----|----|
| CMA | Cumulative opportunity measure (active) |  |
| CMP | Cumulative opportunity measure (passive) |  |
| TMI | Travel time to closest opportunity | Value = Inf when travel time is longer than 2h (public transport or car) or 1,5h (walking or bicycle) |

#### 2) Type of opportunity / population

| Type of opportunity | Description | Observation: available in combination with |
|----|----|----|
| TT | All jobs | CMA indicator |
| TB | Jobs with primary education | CMA indicator |
| TM | Jobs with secuodary education | CMA indicator |
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

| People | Description | Observation: available in combination with |
|----|----|----|
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

#### 3) Time threshold (only applicable to CMA and CMP estimates)

| Time threshold | Description | Observation: only applicable to |
|----|----|----|
| 15 | Opportunities accessible within 15 min. | Active transport modes |
| 30 | Opportunities accessible within 30 min. | All transport modes |
| 45 | Opportunities accessible within 45 min. | Active transport modes |
| 60 | Opportunities accessible within 60 min. | All transport modes |
| 90 | Opportunities accessible within 90 min. | Public transport and car |
| 120 | Opportunities accessible within 120 min. | Public transport and car |

## Examples

- **CMAEF30**: Number of elementary schools accessible within 30 minutes
- **TMISB**: Travel time from to the closest healthcare facility with
  low complexity services
- **CMPPM60**: Number of women who can access a given hexagon cell in
  under 60 minutes
