# ------------------------------------------------------------------------------
#     Create a DB of trade unions
# ------------------------------------------------------------------------------

# Create a database with the variables relating to salary and employment
# SECTOR_SAL <- REGCON_SECTOR %>% # SAL = Salary
#     subset(select = c(
#         idca,                 codca,
#         wvar,                 working_clauses,       working_yearlyhours,  
#         holiday_nat,          holiday_lab,
#         overtime,             employ)) %>%
#     mutate(holiday_nat = ifelse(is.na(holiday_nat),0,as.numeric(holiday_nat))*5/7) %>%
#     mutate(holiday_lab = ifelse(is.na(holiday_lab),0,as.numeric(holiday_lab))) %>%
#     mutate(holiday = holiday_nat + holiday_lab, .after = working_yearlyhours) %>%
#     mutate(holiday_nat = NULL, holiday_lab = NULL)

SECTOR_SAL <- REGCON_SECTOR %>% # SAL = Salary
    subset(select = c(
        idca,                 codca,
        wvar,                 working_clauses,       working_yearlyhours,  
        holiday_nat,          holiday_lab,
        overtime,             employ,                retire,
        illness,              WC_participation,      training)) %>%
    mutate(wvar = (is.na(wvar)==0) ,
           working_yearlyhours = (is.na(working_yearlyhours)==0),
           holiday  = (is.na(holiday_nat)==0)|(is.na(holiday_lab)==0))
    
    
    







