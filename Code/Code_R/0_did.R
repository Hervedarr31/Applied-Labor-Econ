# **************************************************************************** #
# ****                                                                    **** #
# ****     Staggered DID - Application of Callaway & Sant'Anna's model    **** #
# ****                                                                    **** #
# **************************************************************************** #


# **************************************************************************** #
# ****            1.Import of packages and declaration of paths           **** #
# **************************************************************************** #

install.packages("did")
library(glue)
library(did)
library(ggplot2)

data_path <- "C:/Users/Public/Documents/Darricau_Blanco/Data"
output_path <- "C:/Users/Public/Documents/Darricau_Blanco/Output"

list_sex = c("Women",
             "Men")
list_cat_duree = c("Less than 1 month",
                   "Less than 3 month",
                   "Less than 6 month",
                   "Less than 9 month",
                   "Less than 12 month", 
                   "Less than 18 month",
                   "Less than 3 years", 
                   "More than 3 years")

ant <- c(0,0,1,2,3,4,6,12)

# **************************************************************************** #
# ****                  2. Import and format of the data                  **** #
# **************************************************************************** #

df <- read.csv(paste0(data_path, "/final/database_did_trim_dummies.csv"))

format_df <- function(data=df){
  data$cat_parcours <- as.factor(ifelse(data$cat_duree_parcours == "Less than 1 month", 0,
                               ifelse(data$cat_duree_parcours == "Less than 3 month", 1,
                               ifelse(data$cat_duree_parcours == "Less than 6 month", 2,
                               ifelse(data$cat_duree_parcours == "Less than 9 month", 3,
                               ifelse(data$cat_duree_parcours == "Less than 12 month", 4,
                               ifelse(data$cat_duree_parcours == "Less than 18 month", 5,
                               ifelse(data$cat_duree_parcours == "Less than 3 years", 6, 
                               ifelse(data$cat_duree_parcours == "More than 3 years", 7, 9)))))))))
    data <- subset(data, select = -c(cat_duree_parcours))
    return (data)
}

cov_formula <- function(data, covariates){
  cov_names <- ""
  for (elem in covariates){
    new_names <- head(grep(glue("^{elem}_"), names(data), value = TRUE), -1)
    cov_names <- c(cov_names, new_names)
  }
  cov_names <- tail(cov_names, -1)
  cov_form <- as.formula(paste("~", paste0(cov_names, collapse = "+")))
  return (cov_form)
}

# **************************************************************************** #
# ****    3. Calculation of ATT  and AGGTE (with anticipation or not)     **** #
# **************************************************************************** #

calculate_aggte <- function(data=df, alpha=0.05, nb_last_cat=6, aggte_type="simple", covariates = NULL){
  
  # To do an aggregate event study --> aggte_type="dynamic"
  
  data <- format_df(data)
  
  # Transformation of the list of covariates into a formula usable by the package
  
  xformula <- NULL
  if (!is.null(covariates)){
    xformula <- cov_formula(data, covariates)
  }
  # Initialization of the dataframe which stocks the ATT
  aggte_df <- data.frame(cat_parcours = c(-1),
                         sx = c(0),
                         att = c(0),
                         se = c(0),
                         avg_wage = c(0))
  
  # We calculate the ATT and we aggregate for each sex and category
  for (cat_duree in 0:nb_last_cat){
    print(cat_duree)
    df_parcours <- data[data$cat_parcours == cat_duree,]
    
    out_f <- att_gt(yname = "wage_hour_",
                    gname = "group",
                    idname = "idfhda",
                    tname = "period",
                    xformla = xformula,
                    data = df_parcours[df_parcours$sx == 0,],
                    est_method = "ipw",
                    control_group = "notyettreated",
                    allow_unbalanced_panel = TRUE,
                    anticipation = ant[(1+cat_duree)])
    
    out_m <- att_gt(yname = "wage_hour_",
                    gname = "group",
                    idname = "idfhda",
                    tname = "period",
                    xformla = xformula,
                    data = df_parcours[df_parcours$sx == 1,],
                    est_method = "ipw",
                    control_group = "notyettreated",
                    allow_unbalanced_panel = TRUE,
                    anticipation = ant[(1+cat_duree)])
    
    # Aggregation of ATT for each sex and category
    agg_f <- aggte(out_f,
                   balance_e = 5,
                   min_e = -5,
                   type = aggte_type,
                   na.rm = TRUE)
    agg_m <- aggte(out_m,
                   balance_e = 5,
                   min_e = -5,
                   type = aggte_type,
                   na.rm = TRUE)
    
    # Average hourly wage - last period before treatment
    df_parcours$ref_period <- df_parcours$group - ant[(1+cat_duree)] - 1
    df_avg_wage <- df_parcours[df_parcours$period == df_parcours$ref_period,]
    avg_wages <-c()
    for (i in 0:1){
      df_avg_wage_sx <- df_avg_wage[df_avg_wage$sx == i,]
      avg_wages <- c(avg_wages, mean(df_avg_wage_sx$wage_hour))
    }
    
    
    # AGGTE are stocked in a same dataframe
    aggte_df[nrow(aggte_df) + 1,] = list(cat_duree, 0, agg_f[[1]], agg_f[[2]], avg_wages[1])
    aggte_df[nrow(aggte_df) + 1,] = list(cat_duree, 1, agg_m[[1]], agg_m[[2]], avg_wages[2])
  }
  
  # Removal of the initialization line of the dataframe
  aggte_df <- aggte_df[aggte_df$cat_parcours != -1,]
  return (aggte_df)
}

# **************************************************************************** #
# ****                         4. Graph of AGGTE                          **** #
# **************************************************************************** #

graph_aggte <- function(data=df, alpha=0.05, nb_last_cat=6, aggte_type="simple", covariates = NULL, perc = FALSE) {
  
  # Calculate of the AGGTE
  aggte_df <- calculate_aggte(data, alpha, nb_last_cat, aggte_type, covariates)
  
  # A column for confidence intervals is added
  aggte_df$ci <- aggte_df$se * qnorm(1 - alpha/2)
  aggte_df$sx <- as.factor(aggte_df$sx)
  
  # A column of percentage wage gain/loss is added
  if (perc) {
    aggte_df$evo <- (aggte_df$att / aggte_df$avg_wage) * 100
    aggte_df$se2 <- (aggte_df$se / aggte_df$avg_wage) * 100
    aggte_df$ci2 <- aggte_df$se2 * qnorm(1 - alpha/2)
  }
  print(aggte_df)
  print(perc)
  
  x_lab <- c("0" = "Less than 1 month",
    "1" = "Less than 3 month",
    "2" = "Less than 6 month",
    "3" = "Less than 9 month",
    "4" = "Less than 12 month",
    "5" = "Less than 18 month",
    "6" = "Less than 3 years",
    "7" = "More than 3 years")

  pd <- position_dodge(0.1)
  
  if (perc) {
    agg_err_bars <- ggplot(aggte_df, aes(x=cat_parcours, y=evo, colour=sx, group=sx)) +
      geom_errorbar(aes(ymin=evo-se2, ymax=evo+se2, group=sx), width=.5, size = 1, position=pd) +
      geom_line(position=pd, size=1) +
      geom_point(position=pd, size=4, shape=21, fill="white") +
      xlab("Unemployment duration category") +
      ylab("Average Treatment Effect on Treated over the first 5 periods") +
      scale_colour_hue(name="Gender",
                       breaks=c(0,1),
                       labels=c("Women", "Men"),
                       l=40) +
      ggtitle("Effect of unemployment program on hourly wage") +
      scale_y_continuous() +
      # scale_x_discrete() +
      theme_bw() +
      theme(plot.title = element_text(hjust = 0.5, size = 16),
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            legend.justification  = c(0,0),
            legend.position = c(0.005,0.005))
  }
  else {
    agg_err_bars <- ggplot(aggte_df, aes(x=cat_parcours, y=att, colour=sx, group=sx)) +
      geom_errorbar(aes(ymin=att-se, ymax=att+se, group=sx), width=.5, size = 1, position=pd) +
      geom_line(position=pd, size=1) +
      geom_point(position=pd, size=4, shape=21, fill="white") +
      xlab("Unemployment duration category") +
      ylab("Average Treatment Effect on Treated over the first 5 periods") +
      scale_colour_hue(name="Gender",
                       breaks=c(0,1),
                       labels=c("Women", "Men"),
                       l=40) +
      ggtitle("Effect of unemployment program on hourly wage") +
      scale_y_continuous() +
      # scale_x_discrete() +
      theme_bw() +
      theme(plot.title = element_text(hjust = 0.5, size = 16),
            axis.title.x = element_text(size = 14),
            axis.title.y = element_text(size = 14),
            legend.justification  = c(0,0),
            legend.position = c(0.005,0.005))
  }
  
  
  # Modfication of filename depending on covariates
  suffixe <- ""
  if (!is.null(covariates)){
    suffixe <- paste0("_", paste0(covariates, collapse = "_"))
  }
  sfx <- "lvl"
  if (perc){
    sfx <- "prc"
  }
  
  ggsave(glue("aggte{suffixe}_{aggte_type}_{sfx}.png"),
         plot = agg_err_bars,
         device = "png",
         path = glue("{output_path}/0_Figures"))
}

# **************************************************************************** #
# * 5. Calculation of ATT and l'AGGTE Event Study (with anticipation or not) * #
# **************************************************************************** #
scale <- list(c(-0.5,1),c(-0.5,1),c(-1,1),c(-1,2),c(-5,5),c(-5,5),c(-10,10))


graph_aggte_es <- function(data=df, alpha=0.05, nb_last_cat=6, covariates = NULL){

  # aggte_df_dynamic <- calculate_aggte(data, alpha, ant, nb_last_cat, "dynamic", covariates)
  sex <- c("F","H")
  
  # Modification of filename depending on covariates
  suffixe <- ""
  if (!is.null(covariates)){
    suffixe <- paste0("_", paste0(covariates, collapse = "_"))
  }
  
  data <- format_df(data)
  
  xformula <- NULL
  if (!is.null(covariates)){
    xformula <- cov_formula(data, covariates)
  }
  
  
  for (cat_duree in 0:nb_last_cat){
    print(cat_duree)
    df_parcours <- data[data$cat_parcours == cat_duree,]
    scale_cat<- scale[[(cat_duree+1)]]
    
    for (i in 0:1){
      out <- att_gt(yname = "wage_hour_",
                      gname = "group",
                      idname = "idfhda",
                      tname = "period",
                      xformla = xformula,
                      data = df_parcours[df_parcours$sx == i,],
                      est_method = "ipw",
                      control_group = "notyettreated",
                      allow_unbalanced_panel = TRUE,
                      anticipation = ant[(1+cat_duree)])
      
      agg_es <- aggte(out,
                      balance_e = 5,
                      min_e = -5,
                      type = "dynamic",
                      na.rm = TRUE)
      
      print(agg_es)
      
      es_plot <- ggdid(agg_es,
                       title = glue("Average Effect at each period for  {list_sex[1+i]} in {list_cat_duree[1+cat_duree]} program"), 
                       xlab = "Period (quarter)", 
                       ylab= "DiD estimates", 
                       xgap = 2,
                       ylim = scale_cat)
      
      ggsave(filename = glue("agg_es_ant{ant[(1+cat_duree)]}_{sex[1+i]}_{cat_duree}{suffixe}.png"),
             plot = es_plot,
             device = "png",
             path = glue("{output_path}/0_Figures"))
    }
  }
}