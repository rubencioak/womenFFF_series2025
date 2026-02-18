# ------------------------------------------------------------------------------
#     Create a DB of trade unions
# ------------------------------------------------------------------------------

# Create a database with the variables relating to family welfare and sex equality
# 
# SECTOR_FWF <- REGCON_SECTOR %>% # FWF = Family Welfare
#   subset(select = c(
#     idca,                             codca,                            firmid,
#     proctype,                         dtpubli,                          cnae4,
#     dtstrval,                         dtendval,                         firmcity,
#     firmprovince,                     firmownership,                    dtstrnego,
#     dtsingca,                         size,                             sizem,
#     sizew,                            familybalance,                    workingday_adapt,
#     workingday_reduction2,            paidallow_family,                 paidallow_current,
#     paidallow_new,                    caring,breastfeeding,             parttime,
#     parttime_time,                    subrogation,                      equality,
#     equality_ca,                      equality_sa,                      equality_future,
#     equal_opor_measures,              equal_opor_hiring,                equal_opor_promotion,
#     equal_opor_stability,             equal_opor_training,              equal_opor_salary,
#     pref_sex,                         pref_sex_hiring,                  pref_sex_promotion,
#     pref_sex_training,                pref_sex_adapt,                   antiharass,
#     protect_gender_victims,           eq_opor_rest))

SECTOR_FWF <- REGCON_SECTOR %>% # FWF = Family Welfare
  subset(select = c(
    idca,                           codca,                          
    proctype,                       dtpubli,                        cnae4,
    #cnae1,                          cnae2,                          cnae3,
    dtstrval,                       dtendval,                       dtstrnego,
    dtsingca,                       size,                           sizem,
    sizew,                          familybalance,
                                    paidallow_family,
                                    caring,breastfeeding,           parttime,
                                    subrogation,                    equality,
    equal_opor_measures,
    pref_sex,
                                                                    antiharass,
    protect_gender_victims,         eq_opor_rest,                   year))

