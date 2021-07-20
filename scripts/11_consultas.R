# Importar dados em csv ----
##PRODUÇÃO AMBULATORIAL DO SUS - BRASIL - POR LOCAL DE RESIDÊNCIA
#Qtd.aprovada por Ano atendimento segundo Município
#Subgrupo proced.: 0301 Consultas / Atendimentos / Acompanhamentos
#Período: Dez/2008, Dez/2009, Dez/2010, Dez/2011, Dez/2012, Dez/2013, Dez/2014, Dez/2015, Dez/2016, Dez/2017, Dez/2018

consultas<- read_delim("raw-data/consultas_atendimentos_acompanhamentos_municipios(2008-2020).csv", 
                          ";", escape_double = FALSE, trim_ws = TRUE, 
                          skip = 4) #importar dados brutos csv

#Renomear colunas ---- 
names(consultas) <- c("id_municipio_6", 2008:2020, "total")

#Excluir últimas linhas e ultima coluna ----

linhas <- length(consultas$id_municipio_6) - 12 
consultas <- consultas[1:linhas, ] 
consultas <- consultas %>% select(-total)

#Selecionar apenas o código dos municipios na variavel id_municipio_6 ----
consultas$id_municipio_6 <- str_sub(
  consultas$id_municipio_6, start = 1, end = 6
)

#Modificar para o formato long data ----
consultas <- pivot_longer(consultas, !id_municipio_6,
                                 names_to = "ano",
                                 values_to = "n_consultas")

# Substituir "-" nos valores por 0 e deixar variavel como numérica ----
consultas$n_consultas <- as.numeric (
  replace(consultas$n_consultas, consultas$n_consultas == "-", 0)
)


#salvar
save(consultas, file = "processed-data/consultas_municipios(2008-2020).Rda")
