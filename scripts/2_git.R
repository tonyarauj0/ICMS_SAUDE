#Configurando o Git

# Parametros
usethis::use_git_config(# Seu nome
  user.name = "Tony Araújo", 
  # Seu email
  user.email = "tonyaraujoce@gmail.com")
 
# editar R envi
usethis::edit_r_environ()
# * Edit 'C:/Users/beatr/Documents/.Renviron'
# * Restart R for changes to take effect

# Token Github
usethis::create_github_token()

#usar o Git
usethis::use_git()

#usar o Github
usethis::use_github()
