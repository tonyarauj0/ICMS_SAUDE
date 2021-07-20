#IDEB dados no drive do CGPR ----
load("raw-data/ideb_municipios_2005_2019.Rda")

#selecionar algumas variaveis
ideb <- df.ideb.mun %>% 
  select(id_municipio, rede, ensino, anos_escolares, ano, ideb) %>% 
  filter(ano != 2021)


#modificar tipo das variaveis ano e codigo do municipio
ideb <- ideb %>% mutate(ano = as.character(ano), id_municipio = as.character(id_municipio))

#salvar
save(ideb, file = "processed-data/ideb_municipios_(2005-2019).Rda")
