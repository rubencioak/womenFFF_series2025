
rm(list = ls())

# ------------------------------------------------------------------------------
#     Paths and Files
# ------------------------------------------------------------------------------

library("haven")
library("dplyr")
library("ggplot2")
library("tidyr")
library("expss")

dell <- 0
if (dell == 1) {
    computer <- "C:/Users/jj22684/"
} else {
    computer <- "C:/Users/lenovo/"
}

setwd(paste0(computer,"Dropbox/PROJECTS/06.women_FFF/Work/R"))
Main_path   <- paste(computer, "Dropbox/PROJECTS/06.women_FFF/Work/R", sep = "")
built_path    <- paste(computer, "Dropbox/WORK/data/REGCON/Files/SECTOR/built/maps", sep = "")

#source(paste0(Main_path,"/build_sector/labelcnae.R"))

# ------------------------------------------------------------------------------
#   Programme
# ------------------------------------------------------------------------------

load(paste(built_path, "/mappriority.R", sep = ""))
load(paste(Main_path, "/build_sector/sectortufwfsal_built.R", sep = ""))

# remove variables that are in both db and not used for the join (redundant)
sectortufwfsal <- sectortufwfsal %>%
    select(-codca, -dtstrval, -dtendval,-cnae4)
    
# merge both databses
priorshare <- dplyr::left_join(mappriority, sectortufwfsal, by = c("idca"))

# create variables for women share
priorshare <- priorshare %>%
    mutate(sectsumcn = sumcnmales + sumcnfemales + sumnosignmales + sumnosignfemales) %>%
    mutate(sectwsh = (sumcnfemales + sumnosignfemales)/sectsumcn)


# ------------------------------------------------------------------------------
# Saving
# ------------------------------------------------------------------------------
save(priorshare, file = paste(Main_path, "/build_sector_prior/priorshare.R", sep = ""))
