
REGCON_FIRMtemp <- REGCON_FIRM %>%
    rename(province_name=firmprovince)

priorshare <- priorshare %>%
    rename(
        sect_paidallow=paidallow_family, 
        sect_caring = caring,
        sect_breast = breastfeeding,
        sect_parttime = parttime,
        sect_equ = equality,
        sect_equopor = equal_opor_measures,
        sect_prefsex = pref_sex,
        sect_antiharass = antiharass,
        sect_wvar = wvar,
        sect_workyearly = working_yearlyhours,
        sect_overtime = overtime,
        sect_holidays = holiday_nat
        ) %>%
    select(idca, codca, dtstrval, dtendval, province_name, cnae4,cnae4cod, 
           region_rank, n_cnae4, sectsumcn, sectwsh,
           sect_paidallow, sect_caring, sect_breast, sect_parttime,
           sect_equ, sect_equopor, sect_prefsex, sect_antiharass,
           sect_wvar, sect_workyearly, sect_overtime, sect_holidays
    )

priorshare$cnae4cod <- as.character(priorshare$cnae4cod)
REGCON_FIRMtemp$cnae4cod <- as.character(REGCON_FIRMtemp$cnae4cod)
REGCON_FIRMtemp$province_name <- as.character(REGCON_FIRMtemp$province_name)

REGCON_SP <- left_join(
    REGCON_FIRMtemp,
    priorshare,
    by = c("cnae4cod","province_name"),
    relationship = "many-to-many"
)

REGCON_SP <- REGCON_SP %>%
    mutate(dateok = dtstrval.x > dtstrval.y & dtstrval.x <= dtendval.y) %>% # create dummy variable with valid dates
    group_by(idca.x) %>%                                # group by unique key
    arrange(region_rank, n_cnae4, dateok) %>%           # prioritize local region, fewer sectors, higher idca
    slice(1) %>%                                        # keep only best-ranked row per group
    ungroup() %>%                                       # drop grouping
    rename(
        idca = idca.x,
        codca = codca.x,
        cnae4 = cnae4.x,
        dtstrval = dtstrval.x,
        dtendval = dtendval.x,
        sectidca = idca.y,
        sectcodca = codca.y,
        sectcnae4 = cnae4.y,
        sectdtstrval = dtstrval.y,
        sectdtendval = dtendval.y,
    ) %>%
    select(idca, starts_with("sect"),n_cnae4)

rm(REGCON_FIRMtemp)