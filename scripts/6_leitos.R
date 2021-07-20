# Importar dados em csv ----
files <- list.files(path = "raw-data" ,pattern = "^Leitos_RepousoObservacao_") #Criando lista de arquivos brutos dos leitos

ler_arq  <- function(x) {
  read_delim(paste0("raw-data/", x), ";", escape_double = F, skip = 3)
} #funcao para ler os arquivos csv


df.leitos <- map(files, ler_arq) #lista de arquivos csv

#Renomear colunas e listas ---- 
colnames <- c("id_municipio_6", c(2005:2020)) #novos nomes

df.leitos <- lapply(df.leitos, setNames, colnames) #renomeando colunas


names(df.leitos) <- c("fem", "ind", "mas", "ped") #renomeando listas

#salvar


#Modificar para o formato long data ----
leitos <- lapply(df.leitos, function (x) {
  pivot_longer(x, !id_municipio_6, names_to = "ano", values_to = "n_leitos_" ) 
  }
  )

#Modificar nome das variaveis n_leitos e acrescentar o tipo
##obs: Buscar um loop para isso
leitos[["fem"]] <- leitos[["fem"]] %>% rename("n_leitos_fem" = "n_leitos_")
leitos[["ind"]] <- leitos[["ind"]] %>% rename("n_leitos_ind" = "n_leitos_")
leitos[["mas"]] <- leitos[["mas"]] %>% rename("n_leitos_mas" = "n_leitos_")
leitos[["ped"]]<- leitos[["ped"]] %>% rename("n_leitos_ped" = "n_leitos_")

#Juntar tudo em um unico objeto
leitos <- reduce(leitos, left_join)

# Substituir "-" nos valores por 0 e deixar variavel como numérica ----
leitos[,3:6] <- apply(leitos[, 3:6], 2, function (x) { #colunas 3 a 6 serão modificadas pela funcao anonima
  as.numeric(
    replace(x, x == "-", 0)
  )
}
)
#Selecionar apenas o código dos municipios na variavel id_municipio_6 ----

leitos$id_municipio_6 <- str_sub(
  leitos$id_municipio_6, start = 1, end = 6
)


#Excluir últimas linhas ----

#Primeiro, excluir codigos do municipio iguai a 000000
leitos <- leitos %>% filter(id_municipio_6 != "000000")

#Depois, excluir linhas cujo código é formado por letras
leitos <- leitos %>% filter(!str_detect(id_municipio_6, "[:alpha:]"))

#salvar ----
save(leitos, file = "processed-data/leitos_ambulatorios_por_tipo_municipios(2005-2020).Rda")
