
rm(list = ls())

# ------------------------------------------------------------------------------
#     Paths and Files
# ------------------------------------------------------------------------------

library("haven")
library("dplyr")
library("ggplot2")
library("tidyr")
library("expss")
library("lubridate")
library("fuzzyjoin")
library("labelled")

dell <- 0 
if (dell == 1) {
    computer <- "C:/Users/jj22684/"
} else {
    computer <- "C:/Users/lenovo/"
}

setwd(paste0(computer,"Dropbox/PROJECTS/06.women_FFF/Work/R"))
Main_path       <- paste(computer, "Dropbox/PROJECTS/06.women_FFF/Work/R", sep = "")
cleant_path     <- paste(computer, "Dropbox/WORK/data/REGCON/Files/FIRM/cleant", sep = "")

# source(paste0(Main_path,"/build_firm/labelcnae.R"))

# ------------------------------------------------------------------------------
#   Programme
# ------------------------------------------------------------------------------

load(paste(cleant_path, "/regconfirm_cleant.R", sep = ""))
load(paste(Main_path, "/build_sector_prior/priorshare.R", sep = ""))

#--------------Filter and reduce the scope of the database ---------------------

# Create variable to indicate those CA that are not informed

REGCON_FIRM <- REGCON_FIRM %>% 
    mutate(informed = (!is.na(dtpubli) == 'TRUE')&(!is.na(dtstrnego) == 'TRUE'))
#val_lab(REGCON_FIRM$informed) = make_labels("1 Yes 0 No")
REGCON_FIRM %>% group_by(informed)%>%
    summarise(val = mean(as.numeric(informed)), n = n(), freq = n()/as.numeric(count(REGCON_FIRM)))


# Create variable to agregate the types of agreements nature

REGCON_FIRM$nature2 <-  case_when(
    (as.numeric(REGCON_FIRM$nature) == 1 | (as.numeric(REGCON_FIRM$nature) == 2)) ~ 1, 
    (as.numeric(REGCON_FIRM$nature) == 3 | (as.numeric(REGCON_FIRM$nature) == 4) | (as.numeric(REGCON_FIRM$nature) == 5)) ~ 2,
    (as.numeric(REGCON_FIRM$nature) == 16 | (as.numeric(REGCON_FIRM$nature) == 17)) ~ 3,
    (as.numeric(REGCON_FIRM$nature) != c(1,2,3,4,5,16,17)) ~ 4)
REGCON_FIRM['nature2'] <- lapply(REGCON_FIRM['nature2'], factor)
REGCON_FIRM$nature2 <- factor(REGCON_FIRM$nature2, levels = c("1","2","3","4"), labels = c("CA", "MA", "Limited CA", "Rest"))

# Drop observations different from CA

REGCON_FIRM <- REGCON_FIRM %>%
    filter(nature2 == "CA")

# Drop observations of CAs that have been 'cancelled by a court ruling'

REGCON_FIRM <- REGCON_FIRM %>%
    filter(state != "Cancelled by Court Ruling")

# Drop observations form CAs that are not informed

REGCON_FIRM <- REGCON_FIRM %>% 
    filter(informed == TRUE)

# Create date variables in MM-YYYY format

REGCON_FIRM <- REGCON_FIRM %>%
    mutate(dtregism = zoo::as.yearmon(dtregis)) %>%
    mutate(dtpublim = zoo::as.yearmon(dtpubli)) %>%
    mutate(dtstrvalm = zoo::as.yearmon(dtstrval)) %>%
    mutate(dtendvalm = zoo::as.yearmon(dtendval)) %>%
    mutate(dtstrnegom = zoo::as.yearmon(dtstrnego)) %>%
    mutate(dtsingcam = zoo::as.yearmon(dtsingca))

# Variables for the different levels of the industry variable (cnae)
# REGCON_FIRM <- REGCON_FIRM %>%
#     mutate(cnae1 = labelcnae(cnae4,1)) %>%
#     mutate(cnae2 = labelcnae(cnae4,2)) %>%
#     mutate(cnae3 = labelcnae(cnae4,3)) %>%
#     mutate(cnae4 = labelcnae(cnae4,4)) 

#-Create DBs of family welfare and sex equality, union delegates, and compensation -

source("build_firm/build_fwf.R")    # Variables related to family welfare and sex equality
source("build_firm/build_tu.R")     # Database of union delegates
source("build_firm/build_sal.R")    # Variables related to compensation
source("build_firm/build_sp.R")     # variables at a sectoral level to instrument

#------------------------------- Merge databases -------------------------------

# Merge data bases
tufwf       = merge(x = REGCON_CN, y = REGCON_FWF) # tufwf = tradeunion and family welfare
tufwfsal    = merge(x = tufwf,     y = REGCON_SAL) # tufwfsal = tradeunion + family welfare + salary
tufwfsal    = merge(x = tufwfsal,  y = REGCON_SP) # tufwfsal = tradeunion + family welfare + salary

# ------------------------------------------------------------------------------
#   Save database
# ------------------------------------------------------------------------------

save(REGCON_FIRM, file = paste(Main_path, "/build_firm/regconfirm_built.R", sep = ""))
write.csv(REGCON_FIRM,file= paste(Main_path, "/build_firm/regconfirm_built.csv", sep = ""), row.names=FALSE)
save(tufwfsal, file = paste(Main_path, "/build_firm/tufwfsal_built.R", sep = ""))

# to save in stata format
write_dta(data = tufwfsal,file.path(getwd(), "build_firm", "tufwfsal.dta"), version = 14,
    label = attr(tufwfsal, "TU, family welfare, and salary variables"),
    strl_threshold = 2045,
    adjust_tz = TRUE
)

#rm(REGCON_CN,REGCON_FIRM,REGCON_FWF,REGCON_SAL,tufwf)
#rm(REGCON_FIRM,REGCON_CN,REGCON_FWF,REGCON_SAL,REGCON_SP,tufwf)