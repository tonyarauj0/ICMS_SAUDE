#Buscar dados do BD+ ----

#id de projeto no BQ
basedosdados::set_billing_id("projeto-base-dados")

#Query 
query <- "SELECT ano, id_municipio ,localizacao, rede, tdi_ensino_fund, tdi_ensino_fund_anos_iniciais,
tdi_ensino_fund_anos_finais, tdi_ensino_medio
FROM `basedosdados.br_inep_indicadores_educacionais.municipio`"

#Salvando resultados em um banco de dados
tx_distorcao_idade_serie_1 <- read_sql(query)

#transformar variaveis de merge em  caractere(string)
tx_distorcao_idade_serie_1 <- tx_distorcao_idade_serie_1 %>% 
  mutate(ano = as.character(ano), id_municipio = as.character(id_municipio))

save(tx_distorcao_idade_serie_1, file = "processed-data/taxa_distorcao_idade_serie_municipios(2006-2020).Rda")

