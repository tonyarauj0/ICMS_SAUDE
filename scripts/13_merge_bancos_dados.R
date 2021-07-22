#Juntar todos os dados

#Gerar lista com codigos de todos municipios do BR e depois fazer leftjoin ----
#id de projeto no BQ
basedosdados::set_billing_id("projeto-base-dados")
query.cd_mun <- "SELECT id_municipio, municipio, sigla_uf, id_municipio_6 FROM `basedosdados.br_bd_diretorios_brasil.municipio`"
cd_mun_ibge<- read_sql(query.cd_mun)

#salvar
save(cd_mun_ibge, file = "raw-data/codigos_municipios_ibge.Rda")
load("raw-data/codigos_municipios_ibge.Rda")

#Carregar os dados processados ----
files <- list.files(path = "processed-data", full.names = T) 
file_names <- sub("_municip.*", "", files) 
file_names <- sub(".*processed-data/", "", file_names) 

# function to load objects in new environment
load_obj <- function(f, f_name) {
  env <- new.env()
  nm <- load(f, env)[1]  # load into new environ and capture name
  assign(f_name, env[[nm]], pos = 1) # pos 1 is parent env
}

# Carregando todos ----
mapply(load_obj, files, file_names) 
rm(nascidos_vivos, obitos_infantis)


# Juntar todas as bases ----
##base_dados <- reduce(c(cd_mun_ibge, file_names), dplyr::left_join, .init = cd_mun_ibge ) 
# O comando está retornando um erro que não sei resolver, tentar outro método
#Método ruim

#1. TMI ----
dados <- left_join(cd_mun_ibge,
                   tmi %>% select(-c("nascidos", "oi5", "oi1")))

#2. Gastos de saude e saneamento ----
dados <- left_join(dados,
                   gastos_saude_saneamento %>% select(-c("saude", "saude_e_saneamento", "saneamento")))
#health1 =Após 2002, serão consideradas as despesas de saude.
#health2 =Após 2002, serão consideradas as despesas de saude+saneamento

#3. Ideb ----
dados <- left_join(dados,
                   ideb %>% pivot_wider(
                     names_from = c("rede", "ensino", "anos_escolares"),
                     values_from = ideb,
                     names_prefix = "ideb_"))
#4. leitos ----
dados <- left_join(dados, leitos_ambulatorios_por_tipo)

#5. medicos clinico geral ----
dados <- left_join(dados, medicos_cg)

#6. medicos esf
dados <- left_join(dados, medicos_esf)

#7. pib per capita
dados <- left_join(dados,
                   pib_per_capita_nominal %>%
                     mutate(pib_per_nom = pib_corrente/pop_res))

#8. dados saneamento ----
dados <- left_join(dados,
                   sane_agua_lixo %>%
                     mutate(prop_esg_tratado = `v_esg_trat(es006)` / `v_esg_col(es005)`) %>% 
                     select(-c (`v_esg_col(es005)`, `v_esg_trat(es006)`)))

#9. Tx distorcao idade-serie ----
dados <- left_join(dados,
                   taxa_distorcao_idade_serie %>%
                     filter(localizacao == "total", rede == "total") %>% 
                     filter_at(vars(c(5:8)), any_vars(!is.na(.)))) #excluindo da taxa de distorcao municipios NAS em todas variaveis de distorcao

save(dados, file = "processed-data/base_dados_geral.Rda")


#10. Deflacionar valores para dez/2020----
load("raw-data/ipca_final.Rda")

ipca_pfinal <- ipca_pfinal %>%
  mutate(ano = as.character(ano)) %>%
  select(ano, ipca1220)

dados <- left_join(dados, ipca_pfinal) #juntando deflator e dados

dados <- dados %>%
  mutate(pib = pib_corrente* ipca1220, pib_per = pib_per_nom* ipca1220,
         health1 = health1* ipca1220, health2 = health2* ipca1220) %>% 
  select(-c("pib_corrente", "pib_per_nom", "ipca1220",
            "localizacao", "rede"))

# 12. Consultas ----
load("processed-data/consultas_municipios(2008-2020).Rda")
dados <- left_join(dados,consultas )

save(dados, file = "processed-data/base_dados_geral.Rda")

#11. Relatorios ----
#Relatorio rapido sobre os dados
dados %>% create_report(report_title = "Base dados Geral ICMS-SAUDE", output_dir = "manuscript",
                        output_file = "base_dados_geral_icms-saude.html",
                        y = "tmi1")


