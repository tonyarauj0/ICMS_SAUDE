# Puxar dados  ----
d_saude_san <- read_excel("raw-data/Despesa_funcao_selecionadas_2000_2019.xlsx",
                          sheet = "saude", na = "NA",
                          col_types = c("numeric", "text", "numeric", "numeric", "numeric", "numeric", 
                                        "numeric", "numeric", "numeric", "numeric"))
##obs1: Algumas variaveis estavam sendo puxadas como valor logico
##obs2: Alguns municipios com gastos negativos. (checado na base  bruta original)
##obs3: Alguns municipios com gasto total por funcao igual a 1. (checado na base bruta original)
##obs4: Alguns municipios com valor gasto igual a zero em saude e saneamento.(checado no acsses do Finbra)

# Data wrangling ----

#Criar nova variavel de saúde
##Até 2001, Saúde e Saneamento eram contabilizados juntos.
## As despesas totais por função, quando informadas, mudam bastante de nomenclatura.


gastos_funcao_saude <- d_saude_san %>%
  select(id_municipio_6, ano, saude_e_saneamento, saude, saneamento) %>%  #selecionar variaveis a serem usadas
  mutate(health1 = ifelse(ano<2002, saude_e_saneamento, saude)) #Após 2002, serão consideradas as despesas de saude e saneamento como despesas de saude.

gastos_funcao_saude <- gastos_funcao_saude %>% 
  mutate(health2 = ifelse(!is.na(health1) & !is.na(saneamento), # se health1 e saneamento nao foram NA
                          health1 + saneamento, #somar
                          ifelse(
                            !is.na(health1) & is.na(saneamento), #se apenas saneamento for NA
                            health1, #health1
                            ifelse(
                              is.na(health1) & is.na(saneamento), #se ambas forem NA
                              NA, #NA
                              saneamento # se apenas health1 for NA, ficar com saneamento
                            )
                          ))
  )

#modificar tipo da variavel ano
gastos_funcao_saude <- gastos_funcao_saude %>% mutate(ano = as.character(ano))

#salvar
save(gastos_funcao_saude, file = "processed-data/gastos_saude_saneamento_municipios(2000-2019).Rda")



