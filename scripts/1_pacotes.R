#Pacotes
pacotes = c("tidyr","tidylog", "tidyverse", "janitor","haven", "dbplyr",
            "usethis", "lubridate", "basedosdados", "sidrar","readxl","DataExplorer" )

for (x in pacotes) {
  if(!x %in% installed.packages()) {
    install.packages(x)
  }
}

lapply(pacotes, require, character.only = T)

rm(pacotes, x)

#Pacotes Guthub
install.packages("devtools")
devtools::install_github("rfsaldanha/microdatasus")
