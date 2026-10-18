# Dicionário de dados \[PT\]

Dicionário de dados em Português:

``` r

aopdata_dictionary(lang = 'pt')
```

## Variáveis gerais (população, uso do solo e transporte)

| tipo_dado | coluna | descrição | valores |
|----|----|----|----|
| temporal | year | Ano de referência |  |
| geografico | id_hex | Identificador único do hexágono |  |
| geografico | abbrev_muni | Sigla de 3 letras do município |  |
| geografico | name_muni | Nome do município |  |
| geografico | code_muni | Código 7 dígitos IBGE do município |  |
| sociodemografico | P001 | Quantidade total de pessoas |  |
| sociodemografico | P002 | Quantidade de pessoas de cor branca |  |
| sociodemografico | P003 | Quantidade de pessoas de cor negra |  |
| sociodemografico | P004 | Quantidade de pessoas de cor indígena |  |
| sociodemografico | P005 | Quantidade de pessoas de cor amarela |  |
| sociodemografico | P006 | Quantidade de homens |  |
| sociodemografico | P007 | Quantidade de mulheres |  |
| sociodemografico | P010 | Quantidade de pessoas de idade 0 a 5 anos |  |
| sociodemografico | P011 | Quantidade de pessoas de idade 6 a 14 anos |  |
| sociodemografico | P012 | Quantidade de pessoas de idade 15 a 18 anos |  |
| sociodemografico | P013 | Quantidade de pessoas de idade 19 a 24 anos |  |
| sociodemografico | P014 | Quantidade de pessoas de idade 25 a 39 anos |  |
| sociodemografico | P015 | Quantidade de pessoas de idade 40 a 69 anos |  |
| sociodemografico | P016 | Quantidade de pessoas de idade 70 ou mais anos |  |
| sociodemografico | R001 | Renda domiciliar per capta média | R\$ (Reais), valores de 2010 |
| sociodemografico | R002 | Quintil de renda | 1 (pobres), 2, 3, 4, 5 (ricos) |
| sociodemografico | R003 | Decil de renda | 1 (pobres), 2, 3, 4, 5, 6, 7, 8, 9, 10 (ricos) |
| uso do solo | T001 | Quantidade total de empregos |  |
| uso do solo | T002 | Quantidade de empregos de baixa escolaridade |  |
| uso do solo | T003 | Quantidade de empregos de média escolaridade |  |
| uso do solo | T004 | Quantidade de empregos de alta escolaridade |  |
| uso do solo | E001 | Quantidade total de estabelecimentos de ensino |  |
| uso do solo | E002 | Quantidade de estabelecimentos de ensino infantil |  |
| uso do solo | E003 | Quantidade de estabelecimentos de ensino fundamental |  |
| uso do solo | E004 | Quantidade de estabelecimentos de ensino médio |  |
| uso do solo | M001 | Quantidade total de matrículas de ensino |  |
| uso do solo | M002 | Quantidade de matrículas de ensino infantil |  |
| uso do solo | M003 | Quantidade de matrículas de ensino fundamental |  |
| uso do solo | M004 | Quantidade de matrículas de ensino médio |  |
| uso do solo | S001 | Quantidade total de estabelecimentos de saúde |  |
| uso do solo | S002 | Quantidade de estabelecimentos de sáude de baixa complexidade |  |
| uso do solo | S003 | Quantidade de estabelecimentos de sáude de média complexidade |  |
| uso do solo | S004 | Quantidade de estabelecimentos de sáude de alta complexidade |  |
| uso do solo | C001 | Quantidade total de Centro de Referência da Assistência Social (CRAS) |  |
| transporte | mode | Modo de transporte do indicador de acessibilidade | walk; bicycle; public_transport; car |
| transporte | peak | Informação se o indicador é em hora pico ou fora-pico | 1 (pico); 0 (fora pico) |

## Indicadores de Acessibilidade

##### Composição da nomeclatura do indicador de acessibilidade

O nome das colunas com estimativas de acessibilidade são a junção de
três componentes: 1) Tipo de indicador de acessibilidade 2) Tipo de
oportunidade / pessoas 3) Tempo limite.

#### 1) Tipo de indicador de acessibilidade

| Indicador | Descrição | Obervação |
|----|----|----|
| CMA | Indicador de acessibilidade cumulativo ativo |  |
| CMP | Indicador de acessibilidade cumulativo passivo |  |
| TMI | Indicador de tempo mínimo até oportunidade mais próxima | Valor = Inf quando tempo de viagem for maior do que 2h (transporte público ou carro) ou 1,5h (a pé ou de bicicleta) |

#### 2) Oportunidade ou Pessoas

| Oportunidade | Descrição | Obervação: disponível para |
|----|----|----|
| TT | Para todos os empregos indicador | CMA |
| TB | Para empregos de baixa escolaridade indicador | CMA |
| TM | Para empregos de média escolaridade indicador | CMA |
| TA | Para empregos de alta escolaridade indicador | CMA |
| ST | Para todos os estabelecimentos de saúde indicadores | CMA e TMI |
| SB | Para estabelecimentos de sáude de baixa complexidade indicadores | CMA e TMI |
| SM | Para estabelecimentos de sáude de média complexidade indicadores | CMA e TMI |
| SA | Para estabelecimentos de sáude de alta complexidade indicadores | CMA e TMI |
| ET | Para todos os estabelecimentos de educação indicadores | CMA e TMI |
| EI | Para estabelecimentos de educação infantil indicadores | CMA e TMI |
| EF | Para estabelecimentos de educação fundamental indicadores | CMA e TMI |
| EM | Para estabelecimentos de educação média indicadores | CMA e TMI |
| MT | Para matrículas de todos níveis de ensino indicadores | CMA e TMI |
| MI | Para matrículas de ensino infantil indicadores | CMA e TMI |
| MF | Para matrículas de ensino fundamental indicadores | CMA e TMI |
| MM | Para matrículas de ensino médio indicadores | CMA e TMI |
| CT | Para todos os Centros de Referência da Assistência Social (CRAS) | CMA e TMI |

| Pessoas | Descrição                              | Obervação: disponível para |
|---------|----------------------------------------|----------------------------|
| PT      | População total                        | indicador CMP              |
| PH      | População de homens                    | indicador CMP              |
| PM      | População de mulheres                  | indicador CMP              |
| PB      | População branca                       | indicador CMP              |
| PA      | População amarela                      | indicador CMP              |
| PI      | População indígena                     | indicador CMP              |
| PN      | População negra                        | indicador CMP              |
| P0005I  | População de 0 a 5 anos de idade       | indicador CMP              |
| P0614I  | População de 6 a 14 anos de idade      | indicador CMP              |
| P1518I  | População de 15 a 18 anos de idade     | indicador CMP              |
| P1924I  | População de 19 a 24 anos de idade     | indicador CMP              |
| P2539I  | População de 25 a 39 anos de idade     | indicador CMP              |
| P4069I  | População de 40 a 69 anos de idade     | indicador CMP              |
| P70I    | População com 70 anos ou mais de idade | indicador CMP              |

#### 3) Tempo limite (aplicável apenas para estimativas CMA e CMP)

| Tempo Limite | Descrição | Obervação: aplicável somente para |
|----|----|----|
| 15 | Oportunidades acessíveis em até 15 minutos de viagem | Modos de transporte ativos |
| 30 | Oportunidades acessíveis em até 30 minutos de viagem | Todos os modos |
| 45 | Oportunidades acessíveis em até 45 minutos de viagem | Modos de transporte ativos |
| 60 | Oportunidades acessíveis em até 60 minutos de viagem | Todos os modos |
| 90 | Oportunidades acessíveis em até 90 minutos de viagem | Transporte público e carro |
| 120 | Oportunidades acessíveis em até 120 minutos de viagem | Transporte público e carro |

## Exemplos

- **CMAEF30**: Número de escolas de ensino fundamental acessíveis em até
  30 minutos
- **TMISB**: Tempo de viagem até o estabelecimento de saúde mais próximo
  com serviços de baixa complexidade
- **CMPPM60**: Quantidade de mulheres que conseguem acessar determinado
  hexágono em até 60 minutos
