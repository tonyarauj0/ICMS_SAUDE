# Importar dados em csv ----
# CNES - Recursos Humanos até julho de 2007 - Ocupações classificadas pela CBO 1994 (medicos_esf_1) e
# CNES - Recursos Humanos a partir de agosto de 2007 - Ocupações classificadas pela CBO 2002 (medicos_esf_2)
medicos_esf_1<- read_delim("raw-data/medicos_esf_municipios_(2005-2006).csv", 
                                                ";", escape_double = FALSE, trim_ws = TRUE, 
                                                skip = 4) #importar dados brutos csv

medicos_esf_2<- read_delim("raw-data/medicos_esf_municipios_(2007-2020).csv", 
                           ";", escape_double = FALSE, trim_ws = TRUE, 
                           skip = 4) 


#Renomear colunas ---- 
names(medicos_esf_1) <- c ("id_municipio_6", "2005", "2006")

names(medicos_esf_2) <- c ("id_municipio_6", c(2007:2020))



#Excluir últimas linhas ----
linhas <- length(medicos_esf_1$id_municipio_6)- 2 #2006 e 2005

medicos_esf_05_06 <- medicos_esf_1[1:linhas, ] #2006 e 2005

linhas <- length(medicos_esf_2$id_municipio_6)- 8 #2007 a 2020

medicos_esf_07_20 <- medicos_esf_2[1:linhas, ] ##2007 a 20205

#Selecionar apenas o código dos municipios na variavel id_municipio_6 ----
medicos_esf_05_06$id_municipio_6 <- str_sub(
  medicos_esf_05_06$id_municipio_6, start = 1, end = 6
  )

medicos_esf_07_20$id_municipio_6 <- str_sub(
  medicos_esf_07_20$id_municipio_6, start = 1, end = 6
)

#Modificar para o formato long data ----
medicos_esf_05_06 <- pivot_longer(medicos_esf_05_06, !id_municipio_6,
                                  names_to = "ano",
                                  values_to = "n_medicos_esf")

medicos_esf_07_20 <- pivot_longer(medicos_esf_07_20, !id_municipio_6,
                                  names_to = "ano",
                                  values_to = "n_medicos_esf")

# Substituir "-" nos valores por 0 e deixar variavel como numérica ----
medicos_esf_05_06$n_medicos_esf <- as.numeric (
  replace(medicos_esf_05_06$n_medicos_esf, medicos_esf_05_06$n_medicos_esf == "-", 0)
  )

medicos_esf_07_20$n_medicos_esf <- as.numeric (
  replace(medicos_esf_07_20$n_medicos_esf, medicos_esf_07_20$n_medicos_esf == "-", 0)
)

#Juntar ambas as bases ----
medicos_esf <- bind_rows(medicos_esf_05_06, medicos_esf_07_20)

#salvar
save(medicos_esf, file = "processed-data/medicos_esf_municipios(2005-2020).Rda")
