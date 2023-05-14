# **************************************************************************** #
# ****************                                            **************** #
# ****************              Replication file              **************** #
# ****************                                            **************** #
# **************************************************************************** #

code_path <- "C:/Users/louis/Downloads/Applied-Labor-Econ/Code/Code_R"
source(paste0(code_path, "0_did.R"))


# **************************************************************************** #
# Plots of the event studies for each category of program duration and for each
# sex. The plots are directly saved in the output path defined in the "0_did.R"
# file.
# **************************************************************************** #

graph_aggte_es(data=df,
               alpha=0.05,
               nb_last_cat=6,
               covariates = c("cs1", "cat_age"))

# Parameters : 

# @param data : dataset containing 26 variables among which the following ones are
# necessary : idfhda (identifiaer of each individual), period (a number 
# associated with the quarter of the line), group (the first period when an 
# individual is treated), wage_hour_ (the hourly wage of an individual during
# the quarter) and dummies for each covariates value.

# @param alpha : the significance level

# @param nb_last_cat : the last category of program duration on which to perform
# the event study. In our set-up, there are too few individuals in category 7 so
# it is not included by default. Set the parameter to 1 if the objective is to 
# plot the event study for the first two categories.

# @param covariates: the list of covariates to include in the model. The program
# will automatically include all the dummies (except one) associated with each 
# of the covariates in the list.



# **************************************************************************** #
# Plots of the AGGTE (dynamic) with the y-axis being the average effect in 
# euros, or in percentage of the last hourly wage before unemployment, of being 
# registered in a program for each category of program duration (x-axis) and for
# each sex (women in red, men in blue)
# **************************************************************************** #

graph_aggte(data=df,
            alpha=0.05,
            nb_last_cat=6,
            aggte_type="dynamic",
            covariates = c("cs1", "cat_age"),
            perc = FALSE)

graph_aggte(data=df,
            alpha=0.05,
            nb_last_cat=6,
            aggte_type="dynamic",
            covariates = c("cs1", "cat_age"),
            perc = TRUE)

# @param data : dataset containing 26 variables among which the following ones are
# necessary : idfhda (identifiaer of each individual), period (a number 
# associated with the quarter of the line), group (the first period when an 
# individual is treated), wage_hour_ (the hourly wage of an individual during
# the quarter) and dummies for each covariates value.

# @param alpha : the significance level

# @param nb_last_cat : the last category of program duration on which to compute
# the AGGTE. In our set-up, there are too few individuals in category 7 so
# it is not included by default. Set the parameter to 1 if the objective is to 
# include ontly the first two categories in the graph.

# @param aggte_type : Which type of aggregated treatment effect parameter to 
# compute. One option is "simple" (this just computes a weighted average of all
# group-time average treatment effects with weights proportional to group
# size).  Other options are "dynamic" (this computes average effects across
# different lengths of exposure to the treatment and is similar to an
# event study"; here the overall effect averages the effect of the
# treatment across all positive lengths of exposure); "group" (this
# is the default option and computes average treatment effects across different 
# groups; here the overall effect averages the effect across different groups);
# and "calendar" (this computes average treatment effects across different
# time periods; here the overall effect averages the effect across each
# time period).
#  All of our graphs are plotted with the "dynamic" value of the parameter.

# @param covariates: the list of covariates to include in the model. The program
# will automatically include all the dummies (except one) associated with each 
# of the covariates in the list.

# @param perc : what the y-axis represents in the graph. If FALSE, it is the
# average effect in euros. If TRUE, it is the average effect in percentage of 
# the last average last hourly wage before unemployment