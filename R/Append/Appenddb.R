
rm(list = ls())

# ------------------------------------------------------------------------------
#     Paths and Files
# ------------------------------------------------------------------------------

library("haven")
library("dplyr")
library("ggplot2")
library("tidyr")
library("expss")

hp <- 1 
if (hp == 1) {
    computer <- "C:/Users/ruben.perezs/"
} else {
    computer <- "C:/Users/lenovo/"
}

setwd(paste0(computer,"Dropbox/PROJECTS/06.women_FFF/Work/R"))
Main_path   <- paste(computer, "Dropbox/PROJECTS/06.women_FFF/Work/R", sep = "")
output_path <- paste(computer, "Dropbox/PROJECTS/06.women_FFF/Work/Data", sep = "")

#source(paste0(Main_path,"/build_sector/labelcnae.R"))

# ------------------------------------------------------------------------------
#   Programme
# ------------------------------------------------------------------------------

load(paste(Main_path, "/build_firm/tufwfsal_built.R", sep = ""))
load(paste(Main_path, "/build_sector/sectortufwfsal_built.R", sep = ""))

#-------------------- Add dummy variables in the sector db ----------------------

#drop <- c("firmid","firmcity","firmprovince","firmownership")
#tufwfsal = tufwfsal[,!names(tufwfsal) %in% drop]
sectortufwfsal$firmname <- NA
sectortufwfsal$firmid <- NA
sectortufwfsal$firmcity <- NA
sectortufwfsal$firmprovince <- NA
sectortufwfsal$firmownership <- NA

#-------------------- Add dummy variables in the sector db ----------------------

tufwfsal <- tufwfsal %>% select(-starts_with("sect"),
                                -n_cnae4, -neg_com, -neg_other, -neg_tu,
                                -cnae4cod,-funcscope)


#------------------------------ create the level variable ----------------------

tufwfsal <- tufwfsal %>%
    mutate(level = "F")

sectortufwfsal <- sectortufwfsal %>%
    mutate(level = "S")

#------------------------------ Append databases -------------------------------

Appendeddb <- rbind(sectortufwfsal,tufwfsal)
Appendeddb <- Appendeddb %>% mutate(dtsingcay = as.numeric(substring(dtsingca,1,4)))

# ------------------------------------------------------------------------------
#   Save database
# ------------------------------------------------------------------------------

save(Appendeddb, file = paste(output_path, "/Appendeddb.R", sep = ""))

# to save in stata format
write_dta(data = Appendeddb,file.path(output_path, "appendeddb.dta"), version = 14,
          label = attr(Appendeddb, "TU, family welfare, and salary variables in firm and sector CBAs"),
          strl_threshold = 2045,
          adjust_tz = TRUE
)




