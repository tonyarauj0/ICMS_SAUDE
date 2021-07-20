# População Residente Municipal---- 
## t = tabela
## n = territorio 
## v = variavel
## p = período
###http://api.sidra.ibge.gov.br/
###OBS: O espaço é simbolizado por %20.

#Requisitando os dados pelo API do SIDRA 
t_pop  <-  6579 #tabela
ufs <-  c(11:17, 21:29, 31:33, 35, 41:43, 50:53) 
populacao <- paste("/t/", t_pop, "/n6/in%20n3%20", ufs,
                   "/p/all", sep = "")
sidra <- function(x) {
  get_sidra(api = x)
}

pop  <- lapply(populacao, sidra)

#Juntando todas as listas em um unico df
pop <- bind_rows(pop)

#salvar 
save(pop, file = "raw-data/Pop_municipal_residente_01-20")
load("raw-data/Pop_municipal_residente_01-20.Rda")
# Pib Municipal---- 
#Requisitando os dados pelo API do SIDRA
t_pib  <-  5938 #tabela
v_pib <- "/v/37"
pib <- paste("/t/", t_pib, v_pib,"/n6/in%20n3%20", ufs,
             "/p/all", sep = "")

pib  <- lapply(pib, sidra)

#Juntando todas as listas em um unico df
pib <- bind_rows(pib)

#salvar 
save(pib, file = "raw-data/pib_municipal_corrente_02-18(2010).Rda")
load("raw-data/pib_municipal_corrente_02-18(2010).Rda")
# Baixar códigos do IBGE via Base de Dados Mais ----

#id de projeto no BQ
basedosdados::set_billing_id("projeto-base-dados")

#Query para buscar os codigos
query.cd_mun <- "SELECT id_municipio, municipio, sigla_uf, id_municipio_6 FROM `basedosdados.br_bd_diretorios_brasil.municipio`"
cd_mun_ibge<- read_sql(query.cd_mun)
save(cd_mun_ibge, file = "raw-data/codigos_municipios_ibge.Rda")
load("raw-data/codigos_municipios_ibge.Rda")
#Pib municipal per capita ----

#Modificar nomes e selecionar variáveis a serem usadas
populacao <- pop %>% 
  select(`Município (Código)`, Ano, Valor) %>% 
  rename(id_municipio = `Município (Código)`, pop_res = Valor) %>% 
  clean_names()

pib_nominal <- pib %>% 
  select(`Município (Código)`, Ano, Valor) %>% 
  rename(id_municipio = `Município (Código)`, pib_corrente = Valor) %>% 
  clean_names()

#Merge para calcular pib per capita
pib_per <- full_join(cd_mun_ibge, pib_nominal) %>% 
  left_join(populacao)  

#Salvar
save(pib_per, file = "processed-data/pib_per_capita_nominal_municipios(2002-2018).Rda")


