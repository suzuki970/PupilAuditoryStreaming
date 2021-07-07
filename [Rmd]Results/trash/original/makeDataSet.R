
sTime = -4
eTime = 4
analysisWin = 0
countFigNum=1
saveLoc = "./Desktop/"

go1 = c("1", "2", "3", "4", "5")
go2 = c("unswitched(=0)", "switched(>0)", "switched(>0)", "switched(>0)", "switched(>0)")
go3 = c("0", "1", "2+","3","4","5")
go4 = c("0", "1", "2+")

## data loading ------------------------------------------------------------
data=fromJSON(file="/Users/yutasuzuki/Desktop/Pxx_auditoryIllusion/e2_baseLinePupil_Switch/data.json")

dat <- list((matrix(unlist(data$PDR_baseline),nrow=length(data$PDR_baseline),byrow=T)),
            (matrix(unlist(data$PDR),nrow=length(data$PDR),byrow=T)),
            unlist(data$PDR_size_sorted),
            unlist(data$PDR_size),
            unlist(data$sub),
            unlist(data$tertile),
            unlist(data$numOfSwitch_sorted),
            unlist(data$numOfSwitch),
            unlist(data$numOfTrial),
            unlist(data$ampOfmSaccade))

names(dat) <- c('PDR_baseline','y', 'PDRsize_sorted', 'PDRsize', 'sub', 
                'Tertile','numOfSwitch_sorted',
                'numOfSwitch','numOfTrial','ampOfmSaccade')

numOfTrial = dim(dat$y)[1]
numOfSub = length(unique(dat$sub))
lengthOfTime = dim(dat$y)[2]
timeLen = c(sTime,eTime)

x = seq(sTime,eTime,length=lengthOfTime)

ind_data <- data.frame(
  sub =  rep( dat$sub, times = rep( lengthOfTime, numOfTrial)),
  data_y = t(matrix(t(dat$y),nrow=1)),
  data_x = x,
  Size = rep(dat$PDRsize, times = rep( lengthOfTime, numOfTrial)),
  Size_sorted = rep(dat$PDRsize_sorted, times = rep( lengthOfTime, numOfTrial)),
  Tertile = rep( go1[dat$Tertile], times = rep( lengthOfTime, numOfTrial)),
  State = rep( go2[dat$numOfSwitch+1], times = rep( lengthOfTime, numOfTrial)),
  numOfTrial = rep( dat$numOfTrial, times = rep( lengthOfTime, numOfTrial)),
  numOfSwitch = rep( dat$numOfSwitch, times = rep( lengthOfTime, numOfTrial)),
  numOfSwitch_sorted = rep( dat$numOfSwitch_sorted, times = rep( lengthOfTime, numOfTrial))
  # ampOfmSaccade = rep( dat$ampOfmSaccade, times = rep( lengthOfTime, numOfTrial))
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
save(data_timeCourse,file = "/Users/yutasuzuki/Box/Journal_Paper/Pxx_AuditoryStream/[Rmd]Results/original/dataset_timeCourse.rda")

data_res_phasic = ind_data[ind_data$data_x > analysisWin,]
data_res_phasic[data_res_phasic$numOfSwitch > 2,]$numOfSwitch = 2
data_res_phasic$numOfSwitch = go3[data_res_phasic$numOfSwitch+1]
data_corr = aggregate( data_y ~ sub*numOfTrial*numOfSwitch, data = data_res_phasic, FUN = "mean")
data_res_phasic = aggregate( data_y ~ sub*data_x*numOfSwitch, data = data_res_phasic, FUN = "mean")
data_res_phasic = aggregate( data_y ~ sub*numOfSwitch, data = data_res_phasic, FUN = "mean")

data_res_tonic = ind_data
data_res_tonic[data_res_tonic$numOfSwitch > 2,]$numOfSwitch = 2
data_res_tonic$numOfSwitch = go3[data_res_tonic$numOfSwitch+1]
t = aggregate( Size ~ sub*numOfTrial*numOfSwitch, data = data_res_tonic, FUN = "mean")
data_corr$Size = t$Size

data_numOfTrial = aggregate( numOfTrial ~ sub*numOfSwitch, data = data_res_tonic, FUN = "max")
data_res_tonic = aggregate( Size ~ sub*numOfSwitch, data = data_res_tonic, FUN = "mean")

# # tonic -------------------------------------------------------------------
data_tonic = ind_data
data_tonic = aggregate( Size_sorted ~ sub*Tertile, data = data_tonic, FUN = "mean")

sd = aggregate( Size_sorted ~ Tertile, data = data_tonic, FUN = "sd")
data_tonic = aggregate( Size_sorted ~ Tertile, data = ind_data, FUN = "mean")

data_tonic$SE_min = data_tonic$Size_sorted - (sd$Size_sorted / sqrt(numOfSub))
data_tonic$SE_max = data_tonic$Size_sorted + (sd$Size_sorted / sqrt(numOfSub))

# # # of switch -------------------------------------------------------------
ind_data = data.frame(
  Tertile = go1[dat$Tertile],
  sub = dat$sub,
  numOfSwitch_sorted = dat$numOfSwitch_sorted,
  Size_sorted = dat$PDRsize_sorted,
  numOfTrial = dat$numOfTrial
)

data_tertile = aggregate( . ~ sub*Tertile, data = ind_data, FUN = "mean")
data_tertile$data_y = data_tertile$numOfSwitch_sorted
data_tertile$numOfTrial = NULL
data_tertile$numOfSwitch_sorted = NULL

# data_phasic,
save(data_res_phasic,data_res_tonic,
     data_tertile,data_numOfTrial,
     data_tonic,data_corr,
     file = "/Users/yutasuzuki/Box/Journal_Paper/Pxx_AuditoryStream/[Rmd]Results/original/dataset_e2.rda")
