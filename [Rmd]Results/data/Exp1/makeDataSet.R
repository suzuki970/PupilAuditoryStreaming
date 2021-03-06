

## lib loading ------------------------------------------------------------
library(rjson)
library(ggplot2)
library(ggpubr)
library(Cairo)
library(gridExtra)
library(effsize)
library(BayesFactor)
library(reshape)
library(lme4)
library(permutes)

## config ------------------------------------------------------------
sTime = -4
eTime = 5

analysisWin = 0
countFigNum=1
mmFlg = TRUE
auFlg = FALSE

saveLoc = "../../../[Python]PreProcessing/Exp1/data/"
go1 = c("1", "2", "3", "4", "5")
go2 = c("unswitched(=0)", "switched(>0)", "switched(>0)", "switched(>0)", "switched(>0)")
go3 = c("0", "1", "2+","3","4","5")
go4 = c("0", "1", "2+")

## data load ------------------------------------------------------------
if(mmFlg){
  data=fromJSON(file=paste(saveLoc,"data_mm.json", sep = ""))
}else if(auFlg){
  data=fromJSON(file=paste(saveLoc,"data_au.json", sep = ""))
}else{
  data=fromJSON(file=paste(saveLoc,"data_norm.json", sep = ""))
}

dat <- list((matrix(unlist(data$PDR_baseline),nrow=length(data$PDR_baseline),byrow=T)),
            (matrix(unlist(data$PDR),nrow=length(data$PDR),byrow=T)),
            unlist(data$PDR_size_sorted),
            unlist(data$PDR_size),
            unlist(data$sub),
            unlist(data$tertile),
            unlist(data$numOfSwitch_sorted),
            unlist(data$numOfSwitch),
            unlist(data$numOfTrial),
            unlist(data$ampOfmSaccade),
            unlist(data$RT))

names(dat) <- c('PDR_baseline','y', 'PDRsize_sorted', 'PDRsize', 'sub', 
                'Tertile','numOfSwitch_sorted',
                'numOfSwitch','numOfTrial','ampOfmSaccade','RT')

numOfTrial = dim(dat$y)[1]
numOfSub = length(unique(dat$sub))
lengthOfTime = dim(dat$y)[2]
timeLen = c(sTime,eTime)

x = seq(sTime,eTime,length=lengthOfTime)

## make data frame ------------------------------------------------------------

ind_RT <- data.frame(
  sub = dat$sub,
  numOfSwitch = dat$numOfSwitch,
  RT = dat$RT
)
ind_RT[ind_RT$numOfSwitch > 2,]$numOfSwitch = 2
data_RT = aggregate( RT ~ sub*numOfSwitch, data = ind_RT, FUN = "mean")

ind_data <- data.frame(
  sub =  rep( dat$sub, times = rep( lengthOfTime, numOfTrial)),
  data_y = t(matrix(t(dat$y),nrow=1)),
  data_x = x,
  Size = rep(dat$PDRsize, times = rep( lengthOfTime, numOfTrial)),
  Size_sorted = rep(dat$PDRsize_sorted, times = rep( lengthOfTime, numOfTrial)),
  # Tertile = rep( go1[dat$Tertile], times = rep( lengthOfTime, numOfTrial)),
  State = rep( go2[dat$numOfSwitch+1], times = rep( lengthOfTime, numOfTrial)),
  numOfTrial = rep( dat$numOfTrial, times = rep( lengthOfTime, numOfTrial)),
  numOfSwitch = rep( dat$numOfSwitch, times = rep( lengthOfTime, numOfTrial)),
  # numOfSwitch_sorted = rep( dat$numOfSwitch_sorted, times = rep( lengthOfTime, numOfTrial)),
  # ampOfmSaccade = rep( dat$ampOfmSaccade, times = rep( lengthOfTime, numOfTrial)),
  RT = rep( dat$RT, times = rep( lengthOfTime, numOfTrial))
)

data_timeCourse = data.frame(
  sub =  rep( dat$sub, times = rep( lengthOfTime, numOfTrial)),
  Baseline = t(matrix(t(dat$PDR_baseline),nrow=1)),
  Transient = t(matrix(t(dat$y),nrow=1)),
  data_x = x,
  numOfSwitch = rep( dat$numOfSwitch, times = rep( lengthOfTime, numOfTrial))
)

data_timeCourse[data_timeCourse$numOfSwitch > 2,]$numOfSwitch = 2
data_timeCourse$numOfSwitch = go4[data_timeCourse$numOfSwitch+1]
data_timeCourse = aggregate( . ~ sub*data_x*numOfSwitch, data = data_timeCourse, FUN = "mean")
# save(data_timeCourse,file = paste(saveLoc,"/dataset_timeCourse_e2.rda", sep = ""))

data_res_phasic = ind_data[ind_data$data_x > analysisWin,]
data_res_phasic[data_res_phasic$numOfSwitch > 2,]$numOfSwitch = 2
data_res_phasic$numOfSwitch = go3[data_res_phasic$numOfSwitch+1]

data_res_phasic = ind_data[ind_data$data_x > analysisWin,]


data_res_phasic = aggregate( data_y ~ sub*data_x*numOfSwitch, data = data_res_phasic, FUN = "mean")
data_res_phasic = aggregate( data_y ~ sub*numOfSwitch, data = data_res_phasic, FUN = "mean")

data_res_tonic = ind_data
data_res_tonic[data_res_tonic$numOfSwitch > 2,]$numOfSwitch = 2
data_res_tonic$numOfSwitch = go3[data_res_tonic$numOfSwitch+1]
t = aggregate( Size ~ sub*numOfTrial*numOfSwitch, data = data_res_tonic, FUN = "mean")
# data_corr$Size = t$Size

data_numOfTrial = aggregate( numOfTrial ~ sub*numOfSwitch, data = data_res_tonic, FUN = "max")
data_res_tonic = aggregate( Size ~ sub*numOfSwitch, data = data_res_tonic, FUN = "mean")

#### save data -------------------------------------------------------------------
if(mmFlg){
  save(data_RT,data_res_phasic,data_res_tonic,
       data_numOfTrial,
       file = "figure2_mm.rda")
}else if(auFlg){
  save(data_RT,data_res_phasic,data_res_tonic,
       data_numOfTrial,
       file = "figure2_au.rda")
}else{
  save(data_RT,data_res_phasic,data_res_tonic,
       data_numOfTrial,
       file = "figure2_norm.rda")
}

# data_corr = aggregate( data_y ~ sub*numOfTrial*numOfSwitch, data = data_res_phasic, FUN = "mean")
# data_corr = aggregate( numOfTrial ~ sub*numOfSwitch, data = data_corr, FUN = "max")
# tmp = data.frame()
# for(iSub in unique(data_corr$sub)){
#   for(iSwitch in 0:5){
#     t = data_corr[data_corr$sub == iSub & data_corr$numOfSwitch == iSwitch,]
#     if (dim(t)[1] == 0){
#       tmp = rbind(tmp,data.frame(
#         sub = iSub,
#         numOfSwitch = iSwitch,
#         numOfTrial = 0
#       ))
#     }
#   }
# }
# data_corr = rbind(data_corr,tmp)

# config = list(alpha = 0.4,
#               stride = 0.1,
#               label_x = "# of altanations",
#               label_y = "# of trials"
# )
# data_corr$data_y = data_corr$numOfTrial
# p = dispBarGraph(data_corr,config,c("numOfSwitch"))
# config$ylim = round(seq(0,50,10),2)
# config$ylim_stride = 2
# config$xlim = round(seq(0,5,1),2)
# config$xlim_stride = 0.5
# 
# p = setEmptyStyle(p,config)
# p <- p + theme(
#   legend.position = 'none'
# )
# 
# width_fig=4
# height_fig=5
# CairoFonts(regular = "Times","Times")
# CairoPDF(file="./numOftrials",
#          width=width_fig, height=height_fig)
# print(p)
# dev.off()

# anovakun(data_corr,"sA",long=T, peta=T)


# # tonic -------------------------------------------------------------------
# data_tonic = ind_data
# data_tonic = aggregate( Size_sorted ~ sub*Tertile, data = data_tonic, FUN = "mean")
# 
# sd = aggregate( Size_sorted ~ Tertile, data = data_tonic, FUN = "sd")
# data_tonic = aggregate( Size_sorted ~ Tertile, data = ind_data, FUN = "mean")
# 
# data_tonic$SE_min = data_tonic$Size_sorted - (sd$Size_sorted / sqrt(numOfSub))
# data_tonic$SE_max = data_tonic$Size_sorted + (sd$Size_sorted / sqrt(numOfSub))

# # phasic ------------------------------------------------------------------
# data_phasic = ind_data[ind_data$data_x > analysisWin,]
# data_phasic$State = NULL
# data_phasic$numOfTrial = NULL
# data_phasic$Size = NULL
# data_phasic$numOfSwitch = NULL
# data_phasic = aggregate( data_y ~ sub*Tertile, data = data_phasic, FUN = "mean")
# 
# sd = aggregate( data_y ~ Tertile, data = data_phasic, FUN = "sd")
# data_phasic = aggregate( data_y ~ Tertile, data = data_phasic, FUN = "mean")
# 
# data_phasic$SE_min = data_phasic$data_y - (sd$data_y / sqrt(numOfSub))
# data_phasic$SE_max = data_phasic$data_y + (sd$data_y / sqrt(numOfSub))

# # # of switch -------------------------------------------------------------
# ind_data = data.frame(
#   Tertile = go1[dat$Tertile],
#   sub = dat$sub,
#   numOfSwitch_sorted = dat$numOfSwitch_sorted,
#   Size_sorted = dat$PDRsize_sorted,
#   numOfTrial = dat$numOfTrial
# )

# data_tertile = aggregate( . ~ sub*Tertile, data = ind_data, FUN = "mean")
# data_tertile$data_y = data_tertile$numOfSwitch_sorted
# data_tertile$numOfTrial = NULL
# data_tertile$numOfSwitch_sorted = NULL



