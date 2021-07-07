# -------------setting path and initializing--------
currentLoc = dirname( sys.frame(1)$ofile )
root = strsplit(currentLoc , "Rscript")
root = paste(root[[1]][[1]], "/Rscript/",sep="")
path_toolbox = paste(root, "toolbox/",sep="")
source(paste(path_toolbox, "initialization.R", sep = ""))
# ----------------------------------------------------

sTime = -4
eTime = 5
# analysisWin = 2
countFigNum=1
# saveLoc = "/Users/yutasuzuki/Box/Journal_Paper/P05_AuditoryStream/[Rmd]Results/data/Exp2/"
saveLoc = "/Users/yutasuzuki/Box/R/Rscript_working/Pxx_auditoryIllusion/e1_endogenous_Switching/final/"

FONT_SIZE = 18

f1 = "State"
g1 = c("unswitch","switch")
g2 = c("T1", "T2", "T3", "T4", "T5")

go1 = c("1", "2", "3", "4", "5")
go2 = c("switch", "unswitch")
go3 = c("0", "1", "2", "3", "4", "5")

# # python test ------------------------------------------------------------
data=fromJSON(file="/Users/yutasuzuki/Desktop/Python/Pxx_auditoryIllusion/e1_endogenous_Switching/analysis/data/data20210610.json")
dat <- list((matrix(unlist(data$PDR_baseline),nrow=length(data$PDR_baseline),byrow=T)),
            (matrix(unlist(data$PDR),nrow=length(data$PDR),byrow=T)),
            unlist(data$PDR_size_sorted),
            unlist(data$PDR_size),
            unlist(data$sub),
            unlist(data$responses_sorted),
            unlist(data$responses),
            unlist(data$numOfTrial),
            unlist(data$tertile),
            unlist(data$RT))
dat_deriv = list(matrix(unlist(data$PDR),nrow=length(data$PDR),byrow=T))

names(dat) <- c('PDR_baseline','y', 'PDRsize_sorted', 'PDRsize', 'sub',
                'responses_sorted', 'responses',
                'numOfTrial','Tertile','RT')

numOfTrial = dim(dat$y)[1]
numOfSub = length(unique(dat$sub))
lengthOfTime = dim(dat$y)[2]
timeLen = c(sTime,eTime)

x = seq(sTime,eTime,length=lengthOfTime)

ind_RT <- data.frame(
  sub = dat$sub,
  Responses = dat$responses,
  RT = dat$RT
)
data_RT = aggregate( RT ~ sub*Responses, data = ind_RT, FUN = "mean")

ind_data <- data.frame(
  sub =  rep( dat$sub, times = rep( lengthOfTime, numOfTrial)),
  data_y = t(matrix(t(dat$y),nrow=1)),
  data_x = x,
  Size = rep(dat$PDRsize, times = rep( lengthOfTime, numOfTrial)),
  Size_sorted = rep(dat$PDRsize_sorted, times = rep( lengthOfTime, numOfTrial)),
  Tertile = rep( go1[dat$Tertile], times = rep( lengthOfTime, numOfTrial)),
  Responses = rep( dat$responses, times = rep( lengthOfTime, numOfTrial)),
  Responses_sorted = rep( dat$responses_sorted, times = rep( lengthOfTime, numOfTrial)),
  numOfTrial = rep( dat$numOfTrial, times = rep( lengthOfTime, numOfTrial)),
  RT = rep( dat$RT, times = rep( lengthOfTime, numOfTrial))
)

data_timeCourse = data.frame(
  sub =  rep( dat$sub, times = rep( lengthOfTime, numOfTrial)),
  Baseline = t(matrix(t(dat$PDR_baseline),nrow=1)),
  Transient = t(matrix(t(dat$y),nrow=1)),
  data_x = x,
  Responses = rep( dat$responses, times = rep( lengthOfTime, numOfTrial))
)

data_timeCourse = aggregate( . ~ sub*data_x*Responses, data = data_timeCourse, FUN = "mean")

# save(data_timeCourse,file = paste(saveLoc,"/dataset_timeCourse_e1.rda", sep = ""))

data_res_phasic = ind_data[ind_data$data_x > 0,]
# data_res_phasic$Tertile = NULL
# data_res_phasic$numOfTrial = NULL
data_corr = aggregate( data_y ~ sub*Responses*numOfTrial, data = data_res_phasic, FUN = "mean")
data_res_phasic = aggregate( data_y ~ sub*Responses, data = data_res_phasic, FUN = "mean")

data_res_tonic = ind_data
# data_res_tonic$Tertile = NULL
# data_res_phasic$numOfTrial = NULL
t = aggregate( Size ~ sub*Responses*numOfTrial, data = data_res_tonic, FUN = "mean")
data_corr$Size = t$Size

data_numOfTrial = aggregate( numOfTrial ~ sub*Responses, data = data_res_tonic, FUN = "max")
data_res_tonic = aggregate( Size ~ sub*Responses, data = data_res_tonic, FUN = "mean")
data_res_tonic$data_y = data_res_tonic$Size
data_res_tonic$Size = NULL

data_res = rbind(data_res_phasic,data_res_tonic)
data_res$type = rep(c("changes","size"),times=c(dim(data_res_phasic)[1],dim(data_res_tonic)[1]))

# tonic -------------------------------------------------------------------
data_tonic = ind_data
data_tonic = aggregate( Size_sorted ~ sub*Tertile, data = data_tonic, FUN = "mean")

sd = aggregate( Size_sorted ~ Tertile, data = data_tonic, FUN = "sd")
data_tonic = aggregate( Size_sorted ~ Tertile, data = ind_data, FUN = "mean")

data_tonic$SE_min = data_tonic$Size_sorted - (sd$Size_sorted / sqrt(numOfSub))
data_tonic$SE_max = data_tonic$Size_sorted + (sd$Size_sorted / sqrt(numOfSub))

# phasic ------------------------------------------------------------------
# data_phasic = ind_data
# data_phasic = data_phasic[data_phasic$data_x > analysisWin,]
# 
# data_phasic = aggregate( data_y ~ sub*Tertile, data = data_phasic, FUN = "mean")
# 
# sd = aggregate( data_y ~ Tertile, data = data_phasic, FUN = "sd")
# data_phasic = aggregate( data_y ~ Tertile, data = data_phasic, FUN = "mean")
# 
# data_phasic$SE_min = data_phasic$data_y - (sd$data_y / sqrt(numOfSub))
# data_phasic$SE_max = data_phasic$data_y + (sd$data_y / sqrt(numOfSub))

# Tertile -----------------------------------------------------------------
ind_data = data.frame(
  Tertile = go1[dat$Tertile],
  sub = dat$sub,
  Responses_sorted = dat$responses_sorted,
  Size_sorted = dat$PDRsize_sorted,
  numOfTrial = dat$numOfTrial
)

# tmp = aggregate( Responses_sorted ~ sub*Tertile, data = ind_data, FUN = "mean")
# x = as.numeric(tmp$Tertile)
# y = tmp$Responses_sorted
# val = cor.test(x,y)

data_tertile = aggregate( . ~ sub*Tertile, data = ind_data, FUN = "mean")
data_tertile$numOfTrial = NULL

save(data_RT,data_res,
     data_tonic,data_tertile,data_corr,
     file = paste(saveLoc,"dataset_e120210610.rda", sep = ""))
