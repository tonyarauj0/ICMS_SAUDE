## Baixar ipca ----------------------------------------------------------------
install.packages("sidrar")

library(sidrar) 

# Dados ----
#Criar data frame com numeros indices do ipca
## t = tabela
## n1/all = territorio nacional
## v = variavel
## p = período
ipca  = get_sidra(api='/t/1737/n1/all/v/2266/p/all')

# Data Wrangling----
#Melhorar nomes
ipca <- ipca %>% clean_names()

#Mudar base do IPCA para dezembro de 2020
ipca_base = ipca %>%
  filter(mes_codigo == 202012)%>%
  select(valor)%>%
  as.numeric() #definindo valor base como dezembro de 2020

ipca <- ipca %>%
  mutate(ipca1220 = ipca_base/valor) #dividir indice base por cada indice mensal.

#Criar Variável Ano
ipca = ipca %>% mutate(ano =as.integer(substring(mes_codigo, 1, 4)))

#Selecinar apenas os meses finais de cada ano, transformando em número.
ipca_pfinal = ipca %>%
  group_by(ano) %>%
  slice_tail(n = 1)

# Salvar ----
save(ipca, file =  "raw-data/ipca_mensal.Rda")
save(ipca_pfinal, file =  "raw-data/ipca_final.Rda")


