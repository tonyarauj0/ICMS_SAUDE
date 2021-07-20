# Importar dados em csv ----
# CNES - Recursos Humanos até julho de 2007 - Ocupações classificadas pela CBO 1994 (medicos_cg_1) e
# CNES - Recursos Humanos a partir de agosto de 2007 - Ocupações classificadas pela CBO 2002 (medicos_cg_2)


medicos_cg_1<- read_delim("raw-data/medico_clinico_geral_segundo_CBO_1994_municipios(2005-2006).csv", 
                           ";", escape_double = FALSE, trim_ws = TRUE, 
                           skip = 4) #importar dados brutos csv

medicos_cg_2<- read_delim("raw-data/medico_clinico_geral_segundo_CBO_2002_municipios(2007-2020).csv", 
                           ";", escape_double = FALSE, trim_ws = TRUE, 
                           skip = 4) 


#Renomear colunas ---- 
names(medicos_cg_1) <- c ("id_municipio_6", "2005", "2006")

names(medicos_cg_2) <- c ("id_municipio_6", c(2007:2020))



#Excluir últimas linhas ----
linhas <- length(medicos_cg_1$id_municipio_6)- 2 #2006 e 2005

medicos_cg_05_06 <- medicos_cg_1[1:linhas, ] #2006 e 2005

linhas <- length(medicos_cg_2$id_municipio_6)- 7 #2007 a 2020

medicos_cg_07_20 <- medicos_cg_2[1:linhas, ] ##2007 a 20205

#Selecionar apenas o código dos municipios na variavel id_municipio_6 ----
medicos_cg_05_06$id_municipio_6 <- str_sub(
  medicos_cg_05_06$id_municipio_6, start = 1, end = 6
)

medicos_cg_07_20$id_municipio_6 <- str_sub(
  medicos_cg_07_20$id_municipio_6, start = 1, end = 6
)

#Modificar para o formato long data ----
medicos_cg_05_06 <- pivot_longer(medicos_cg_05_06, !id_municipio_6,
                                  names_to = "ano",
                                  values_to = "n_medicos_cg")

medicos_cg_07_20 <- pivot_longer(medicos_cg_07_20, !id_municipio_6,
                                  names_to = "ano",
                                  values_to = "n_medicos_cg")

# Substituir "-" nos valores por 0 e deixar variavel como numérica ----
medicos_cg_05_06$n_medicos_cg <- as.numeric (
  replace(medicos_cg_05_06$n_medicos_cg, medicos_cg_05_06$n_medicos_cg == "-", 0)
)

medicos_cg_07_20$n_medicos_cg <- as.numeric (
  replace(medicos_cg_07_20$n_medicos_cg, medicos_cg_07_20$n_medicos_cg == "-", 0)
)

#Juntar ambas as bases ----
medicos_cg <- bind_rows(medicos_cg_05_06, medicos_cg_07_20)

#salvar
save(medicos_cg, file = "processed-data/medicos_cg_municipios(2005-2020).Rda")
