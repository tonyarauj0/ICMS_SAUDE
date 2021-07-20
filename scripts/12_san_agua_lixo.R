#Importar dados ----

saneamento_agua_lixo_municipios<- read_excel("raw-data/saneamento_agua_lixo_municipios(1995-2019).xlsx")

#Melhorar nomes e Selecionar variáveis de interesse

san_agua_lix <- saneamento_agua_lixo_municipios %>% clean_names()

san_agua_lix <- san_agua_lix %>% select(- c("codigo_do_ibge",
                                            "municipio", "estado", "prestadores",
                                            "servicos", "natureza_juridica", "es001_populacao_total_atendida_com_esgotamento_sanitario",
                                            "in030_rs_taxa_de_cobertura_do_servico_de_coleta_seletiva_porta_a_porta_em_relacao_a_populacao_urbana_do_municipio"))
names(san_agua_lix) <- c("id_municipio_6", "ano", "pop_tot_res_c_abs_agua(g12a)",
                         "pop_tot_res_c_esgot_san(g12b)", "v_esg_col(es005)", "v_esg_trat(es006)","pop_urb_col_rdo(co014)",
                         "tx_cob_col_rdo(in015)")  

#excluir ultima linha que é NA por conta da tabela original 
san_agua_lix <- san_agua_lix %>% filter(!is.na(id_municipio_6))

#transformar codigo do municipio em caractere.
san_agua_lix <- san_agua_lix %>% mutate(id_municipio_6 = as.character(id_municipio_6))

#modificar tipo da variavel ano
san_agua_lix <- san_agua_lix %>% mutate(ano = as.character(ano))

#salvar
save(san_agua_lix, file = "processed-data/sane_agua_lixo_municipios(1995-2019).Rda")




