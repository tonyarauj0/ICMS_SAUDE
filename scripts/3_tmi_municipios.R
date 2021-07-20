# 1. Pacotes ----
library(tidyverse)
library(basedosdados)
library("janitor", "lubridate")


# 2. Óbitos Infantis ----  
#id de projeto no BQ
basedosdados::set_billing_id("projeto-base-dados")

#Query para buscar os dados de mortalidade
query.datasus <-"
SELECT ano, sigla_uf, id_municipio , idade, SUM(numero_obitos) AS total_obitos
FROM `basedosdados.br_ms_sim.municipio_causa_idade`
WHERE idade <= 5
GROUP BY  ano, sigla_uf, id_municipio , idade
"

#Salvando resultados em um banco de dados
base.mortalidade.infantil <- read_sql(query.datasus)
save(base.mortalidade.infantil, file = "raw-data/mortalidade_infantil_1_a_5(1996-2019).Rda")

#Criando obitos infantis ate 1 ano e ate 5 anos.
load("raw-data/mortalidade_infantil_1_a_5(1996-2019).Rda")

base.mortalidade.infantil <- base.mortalidade.infantil %>%
  mutate(idade = as.numeric(idade), total_obitos = as.numeric(total_obitos)) #mudando dados para numerico

obitos.infantis.5 <- as_tibble(base.mortalidade.infantil) %>%
  filter(idade<5) %>% 
  group_by(ano, id_municipio) %>%
  mutate(oi5 = sum(total_obitos)) %>% 
  select(ano, sigla_uf, id_municipio, oi5) %>% 
  distinct() %>% ungroup() #base com obitos de crianças menores de 5 anos
#obs: somou-se o número de óbitos na faixa etaria e atribuiu-se a soma a cada linha, portanto há valores duplicados que foram retirados

obitos.infantis.1 <-as_tibble(base.mortalidade.infantil) %>%
  filter(idade == 0) %>% 
  group_by(ano, id_municipio) %>% 
  mutate(oi1 = sum(total_obitos)) %>% 
  select(ano, sigla_uf, id_municipio, oi1) %>% 
  distinct() %>% ungroup() #filtrando e somando obitos de crianças menores de 1 ano


obitos.infantis <- left_join(obitos.infantis.5, obitos.infantis.1) #merge
obitos.infantis$ano <- as.numeric(obitos.infantis$ano)

#salvar
save(obitos.infantis, file = "processed-data/obitos_infantis_municipios(1996-2019).Rda")
load("processed-data/obitos_infantis_municipios(1996-2019).Rda")
# 3. Número de nascidos ----
library(microdatasus)

#Limpar memoria e aumentar
gc()
memory.limit (9999999999)

#Lista com todas UFs
lista_uf <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG",
 "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO")

#Função para extrarir os dados usando o pacote microdatasus
pegar_dados_nasc <- function(x) {
  fetch_datasus(year_start = 1996,
                year_end = 2019,
                uf = x,
                information_system = "SINASC",
                vars = c("CODMUNRES","DTNASC") #variáveis extraídas
  )
}

#Lista onde cada elemento é composto pelos dados extraídos para cada UF
nascidos <- map(lista_uf, pegar_dados_nasc) #obs: cada linha é um nascimento.

save(nascidos, file = "raw-data/nascidos_vivos_municipios(1996-2019).Rda")

#Load 
load("raw-data/nascidos_vivos_municipios(1996-2019).Rda")

# Preparando a base ----

nascidos <- bind_rows(nascidos) #Juntando todos elementos da lista em um unico 

nascidos <- janitor::clean_names(nascidos) #deixar nomes das variáveis mais faceis para trabalhar

nascidos$ano <- as.numeric(
  str_sub(
    as.character(nascidos$dtnasc), -4)
  )#criar ano

nascimento <- nascidos %>% 
group_by(ano, codmunres) %>% #agrupar por ano e municipio
mutate(nascidos = n()) %>%  #contar número de linhas em cada grupo = número de nascimentos
select(ano, codmunres, nascidos) %>%
  distinct() %>% 
  ungroup()#excluir valores duplicados ( foi inserido numero de observacoes em cada grupo, por isso a duplicidade)

nascimento <- nascimento %>% 
  mutate(id_municipio_6 = 
           ifelse(ano<2006, as.character(substr(codmunres,1,6)), as.character(codmunres))) %>% #renomear codmunres para id_municipio e deixa-la como string
  select(-codmunres) #excluir variavel antiga
##OBS: ATé 2005, os codigos dos municipios tinham 7 digitos, depois passram a ter 6. Unigfiquei tudo para 6.

#Salvar 
save(nascimento, file = "processed-data/nascidos_vivos_municipios(1996-2019).Rda")
load("processed-data/nascidos_vivos_municipios(1996-2019).Rda")

# 4. Juntar nascidos vivos e óbitos ----
# 4.1 Baixar códigos do IBGE via Base de Dados Mais

#Query para buscar os codigos
query.cd_mun <- "SELECT id_municipio, municipio, sigla_uf, id_municipio_6 FROM `basedosdados.br_bd_diretorios_brasil.municipio`"
cd_mun_ibge<- read_sql(query.cd_mun)

#Merge codigo do municipio com base de nascidos vivos
df.tmi <- left_join(cd_mun_ibge, nascimento)

#Merge obitos com nascidos
df.tmi <- left_join(df.tmi, obitos.infantis)

#Criar tmi
df.tmi <- df.tmi %>% 
  mutate( tmi1 = (oi1/nascidos)*1000, tmi5 = (oi5/nascidos)*1000 )

#modificar variavel ano para caractere
df.tmi <- df.tmi %>% 
  mutate(ano = as.character(ano))

#salvar
save(df.tmi, file = "processed-data/tmi_municipal(1996-2019).Rda")




