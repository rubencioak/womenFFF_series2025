
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
cleant_path    <- paste(computer, "Dropbox/WORK/data/REGCON/Files/SECTOR/cleant", sep = "")

#source(paste0(Main_path,"/build_sector/labelcnae.R"))

# ------------------------------------------------------------------------------
#   Programme
# ------------------------------------------------------------------------------

load(paste(cleant_path, "/regconsector_cleant.R", sep = ""))

#--------------Filter and reduce the scope of the database ---------------------

# Create variable to indicate those CA that are not informed

REGCON_SECTOR <- REGCON_SECTOR %>% 
    mutate(informed = (!is.na(dtpubli) == 'TRUE')&(!is.na(dtstrnego) == 'TRUE'))
#val_lab(REGCON_SECTOR$informed) = make_labels("1 Yes 0 No")
REGCON_SECTOR %>% group_by(informed)%>%
    summarise(val = mean(as.numeric(informed)), n = n(), freq = n()/as.numeric(count(REGCON_SECTOR)))


# Create variable to agregate the types of agreements nature

REGCON_SECTOR$nature2 <-  case_when(
    (as.numeric(REGCON_SECTOR$nature) == 1 | (as.numeric(REGCON_SECTOR$nature) == 2) | (as.numeric(REGCON_SECTOR$nature) == 6) | (as.numeric(REGCON_SECTOR$nature) == 7)) ~ 1, 
    (as.numeric(REGCON_SECTOR$nature) == 3 | (as.numeric(REGCON_SECTOR$nature) == 4) | (as.numeric(REGCON_SECTOR$nature) == 5)) ~ 2,
    (as.numeric(REGCON_SECTOR$nature) == 16 | (as.numeric(REGCON_SECTOR$nature) == 17)) ~ 3,
    (as.numeric(REGCON_SECTOR$nature) != c(1,2,3,4,5,6,7,16,17)) ~ 4)
REGCON_SECTOR['nature2'] <- lapply(REGCON_SECTOR['nature2'], factor)
REGCON_SECTOR$nature2 <- factor(REGCON_SECTOR$nature2, levels = c("1","2","3","4"), labels = c("CA", "MA", "Limited CA", "Rest"))

# Drop observations different from CA

REGCON_SECTOR <- REGCON_SECTOR %>%
    filter(nature2 == "CA")

# Drop observations of CAs that have been 'cancelled by a court ruling'

REGCON_SECTOR <- REGCON_SECTOR %>%
    filter(state != "Cancelled by Court Ruling")

# Drop observations form CAs that are not informed

REGCON_SECTOR <- REGCON_SECTOR %>% 
    filter(informed == TRUE)

# Create date variables in MM-YYYY format

REGCON_SECTOR <- REGCON_SECTOR %>%
    mutate(dtregism = zoo::as.yearmon(dtregis)) %>%
    mutate(dtpublim = zoo::as.yearmon(dtpubli)) %>%
    mutate(dtstrvalm = zoo::as.yearmon(dtstrval)) %>%
    mutate(dtendvalm = zoo::as.yearmon(dtendval)) %>%
    mutate(dtstrnegom = zoo::as.yearmon(dtstrnego)) %>%
    mutate(dtsingcam = zoo::as.yearmon(dtsingca))

# Variables for the different levels of the industry variable (cnae)
# REGCON_SECTOR <- REGCON_SECTOR %>%
#     mutate(cnae1 = labelcnae(cnae4,1)) %>%
#     mutate(cnae2 = labelcnae(cnae4,2)) %>%
#     mutate(cnae3 = labelcnae(cnae4,3)) %>%
#     mutate(cnae4 = labelcnae(cnae4,4)) 

#-Create DBs of family welfare and sex equality, union delegates, and compensation -

source("build_sector/build_sectorfwf.R") # Variables related to family welfare and sex equality
source("build_sector/build_sectortu.R") # Database of union delegates
source("build_sector/build_sectorsal.R") # Variables related to compensation

#------------------------------- Merge databases -------------------------------

# Merge data bases
tufwf = merge(x = SECTOR_CN, y = SECTOR_FWF) # tufwf = tradeunion and family welfare
sectortufwfsal = merge(x = tufwf, y = SECTOR_SAL) # tufwfsal = tradeunion + family welfare + salary

# ------------------------------------------------------------------------------
#   Save database
# ------------------------------------------------------------------------------

save(REGCON_SECTOR, file = paste(Main_path, "/build_sector/regconsector_built.R", sep = ""))
write.csv(REGCON_SECTOR,file= paste(Main_path, "/build_sector/regconsector_built.csv", sep = ""), row.names=FALSE)
save(sectortufwfsal, file = paste(Main_path, "/build_sector/sectortufwfsal_built.R", sep = ""))

# to save in stata format
write_dta(data = sectortufwfsal,file.path(getwd(), "build_sector", "sectortufwfsal_built.dta"), version = 15,
    label = attr(sectortufwfsal, "TU, family welfare, and salary variables"),
    strl_threshold = 2045,
    adjust_tz = TRUE
)

rm(REGCON_SECTOR,SECTOR_CN,SECTOR_FWF,SECTOR_SAL,tufwf)
