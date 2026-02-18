# ------------------------------------------------------------------------------
#     Create a DB of trade unions
# ------------------------------------------------------------------------------

# Expand database by the unions in each CA. REGCON_CN = REGCON Comision Negociadora
REGCON_CN <- REGCON_FIRM %>%
    select(c('idca','codca','neg_com','neg_tu','neg_other','neg_comp','neg_sign','neg_nosign')) %>%
    separate(neg_comp,c('v1','v2','v3','v4','v5','v6','v7','v8','v9'), sep = '\\*') %>%
    separate(neg_nosign,c('w1','w2','w3','w4','w5','w6','w7','w8','w9'), sep = '\\*') %>%
    pivot_longer(cols=c('v1','v2','v3','v4','v5','v6','v7','v8','v9'),
                 names_to='v',
                 values_to='TU_n') %>%
    filter(!is.na(TU_n)) %>%
    mutate(TU_code = as.numeric(substr(TU_n,1,1))) %>%
    mutate(TU_nmales = as.numeric(substr(TU_n,unlist(gregexpr("Hombres",TU_n))+8,unlist(gregexpr("Hombres",TU_n))+8))) %>%
    mutate(TU_nfemales = as.numeric(substr(TU_n,unlist(gregexpr("Mujeres",TU_n))+8,unlist(gregexpr("Mujeres",TU_n))+8)))

# Recode for those unions that do not sign the agreement
varlist <- c('w1','w2','w3','w4','w5','w6','w7','w8','w9')
for (var in varlist) {
    REGCON_CN[[var]] <- substr(REGCON_CN[[var]],1,unlist(regexpr(pattern = '#', REGCON_CN[[var]]))-1)
}


# Change name by its code
for (var in varlist) {
    REGCON_CN[[var]]<-ifelse(is.na(REGCON_CN[[var]]),NA_character_,
                             ifelse(REGCON_CN[[var]] == "CCOO","1",
                                    ifelse(REGCON_CN[[var]] == "UGT","2",
                                           ifelse(REGCON_CN[[var]] == "USO","3",
                                                  ifelse(REGCON_CN[[var]] == "CIG","4",
                                                         ifelse(REGCON_CN[[var]] == "GRUPODETRABAJADORESINDEPENDIENTES","5",
                                                                ifelse(REGCON_CN[[var]] == "ELA","6",
                                                                       ifelse(REGCON_CN[[var]] == "LAB","7",
                                                                              ifelse(REGCON_CN[[var]] == "CGT","8","9"))))))))
    )
    REGCON_CN[[var]]<-as.numeric(REGCON_CN[[var]])
}

# Compare TU_code with w*, to know what unions have not sign the CA
REGCON_CN <- REGCON_CN %>%
    mutate(neg_nosign = ((TU_code == w1)|(TU_code == w2)|(TU_code == w3)|(TU_code == w4)|(TU_code == w5)
                         |(TU_code == w6)|(TU_code == w7)|(TU_code == w8)|(TU_code == w9))) %>%
    mutate(nosignmales = ifelse(is.na(neg_nosign),0,TU_nmales)) %>%
    mutate(nosignfemales = ifelse(is.na(neg_nosign),0,TU_nfemales))

# At this point a new data base could be saved if we were interested in TUs


# Sum the number of delegates participating of negotiations, and those that have not signed the CA
REGCON_CN <- REGCON_CN %>%
    group_by(idca) %>% 
    mutate(sumcnmales = sum(TU_nmales)) %>%
    mutate(sumcnfemales = sum(TU_nfemales)) %>%
    mutate(sumnosignmales = sum(nosignmales)) %>%
    mutate(sumnosignfemales = sum(nosignfemales))

REGCON_CN = apply_labels(REGCON_CN,
    sumcnmales = "Number of males in the negotiating table",
    sumcnfemales = "Number of females in the negotiating table",
    sumnosignmales = "Number of males in the negotiating table who do not sign the agreement",
    sumnosignfemales = "Number of females in the negotiating table who do not sign the agreement")

REGCON_CN <- REGCON_CN %>%
    subset(select = -c(w1,w2,w3,w4,w5,w6,w7,w8,w9,v,TU_n,TU_nmales,TU_nfemales,neg_nosign,nosignmales,nosignfemales))

REGCON_CN$TU_code <- as.factor(REGCON_CN$TU_code)
REGCON_CN$TU_code <- factor(REGCON_CN$TU_code,
                            levels = c(
                                "1",
                                "2",
                                "3",
                                "4",
                                "5",
                                "6",
                                "7",
                                "8",
                                "9"
                            ),
                            labels = c(
                                "CCOO",
                                "UGT",
                                "USO",
                                "CIG",
                                "GRUPO DE TRABAJADORES INDEPENDIENTES",
                                "ELA",
                                "LAB",
                                "CGT",
                                "OTROS SINDICATOS"
                            )
)

REGCON_CN <- REGCON_CN %>%
    pivot_wider(names_from = TU_code, values_from = TU_code)

varlist<- c("CCOO","UGT","USO","CIG","GRUPO DE TRABAJADORES INDEPENDIENTES","ELA","LAB","CGT","OTROS SINDICATOS")
for (var in varlist) {
    REGCON_CN[[var]] <- ifelse(REGCON_CN[[var]] == "NULL",0,1)
}

REGCON_CN<- rename(REGCON_CN, GTI = "GRUPO DE TRABAJADORES INDEPENDIENTES",
                   OtherTU = "OTROS SINDICATOS")

# REGCON_CN <-  subset(REGCON_CN,select = -c(20))
REGCON_CN = REGCON_CN[,!names(REGCON_CN) %in% c("NA")]
