#### Package installation #### 
library(rjson)
library(ggplot2)
library(ggpubr)
library(Cairo)
library(gridExtra)
library(effsize)
library(BayesFactor)
library(rjson)
library(reshape)
library(lme4)
library(lmerTest)
library(permutes)
library(RColorBrewer)

if(exists(".anovakun.env")){
  sys.source("./data/anovakun_485.R", envir = .anovakun.env)
}else{
  .anovakun.env <- new.env()
  sys.source("./data/anovakun_485.R", envir = .anovakun.env)
  attach(.anovakun.env)
}
subName = NULL
for( i in seq(30)){ 
  if(i<10){subName = rbind(subName,paste("s0", i, sep = ""))} 
  else{subName = rbind(subName,paste("s", i, sep = ""))}
}

setEmptyStyle <- function(gData,config,size_font=20){
  gData <- gData +theme(
    panel.border = element_blank(), 
    axis.ticks.length=unit(.5, "cm"),
    axis.ticks.x = element_line(colour = "black",size = 0.5),
    # axis.line = element_line(),
    axis.text.x = element_text(colour="black"),
    axis.text.y = element_text(colour="black"),
    panel.background = element_rect(fill = "transparent",size = 0.5),
    panel.grid.major = element_line(colour = NA),
    panel.grid.major.y = element_line(colour = "gray", size = 0.05),
    panel.grid.major.x = element_line(colour = NA),
    panel.grid.minor = element_line(colour = NA),
    axis.ticks = element_line(colour = "black",size = 0.5),
    text = element_text(size = size_font,family = "Times"),
    # text = element_text(size = size_font,family = "Source Han Sans JP ExtraLight"),
    legend.title = element_text(size=(size_font)),
    legend.text = element_text(size=(size_font)),
    legend.key=element_rect(colour="transparent", fill=NA),
    plot.background=element_rect(fill="transparent", colour=NA),
    legend.background=element_rect(fill="transparent", colour=NA),
    plot.title = element_text(size = size_font,hjust=-0.2)
  )
  
  gData = gData + 
    scale_y_continuous(breaks=config$ylim)+
    # scale_x_continuous(breaks=config$xlim)+
    coord_cartesian(xlim=c(config$xlim[1]-config$xlim_stride,rev(config$xlim)[1]+config$xlim_stride),
                    ylim=c(config$ylim[1]-config$ylim_stride,rev(config$ylim)[1]+config$ylim_stride),
                    expand=FALSE)+
    annotate(x=config$xlim[1],xend=rev(config$xlim)[1], 
             y=config$ylim[1]-config$ylim_stride, yend=config$ylim[1]-config$ylim_stride, 
             colour="black", lwd=0.5, geom="segment")+
    annotate(x=config$xlim[1]-config$xlim_stride, xend=config$xlim[1]-config$xlim_stride,
             y=config$ylim[1], yend=rev(config$ylim)[1], 
             colour="black", lwd=0.5, geom="segment")+
    theme(
      axis.ticks = element_line(colour = "black",size = 0.5)
    )
  
  return(gData)
}

# Function definition
rejectOutlier <- function(ribbondata, vName){
  
  eval(parse(text=paste("dat_mean = tapply(ribbondata$",vName,
                        ",list(ribbondata$sub),mean)", sep="")))
  
  eval(parse(text=paste("dat_sd = tapply(ribbondata$",vName,
                        ",list(ribbondata$sub),sd)", sep="")))
  
  numOfSub = unique(ribbondata$sub)
  
  dat_mean = matrix(dat_mean,ncol = 1)
  dat_mean = dat_mean[!is.na(dat_mean)]
  dat_sd = matrix(dat_sd,ncol = 1)*3
  dat_sd = dat_sd[!is.na(dat_sd)]
  
  t=NULL
  for(i in 1:length(numOfSub)){
    t = rbind(t,dim(ribbondata[ribbondata$sub == numOfSub[i],])[1])
  }
  
  dat_mean = rep(dat_mean,times = t)
  ribbondata$minsd = dat_mean - rep(dat_sd,times = t)
  ribbondata$maxsd = dat_mean + rep(dat_sd,times = t)
  
  eval(parse(text=paste("ribbondata = ribbondata[ribbondata$",vName,
                        "< ribbondata$maxsd,]", sep="")))
  eval(parse(text=paste("ribbondata = ribbondata[ribbondata$",vName,
                        "> ribbondata$minsd,]", sep="")))
  return(ribbondata)
}

combineGraphs <- function(graphNum,p,layout){
  
  titleStr = c("'A'", "'B'", "'C'", "'D'", "'E'", "'F'", "'G'")
  st = paste(p,graphNum, sep = "", collapse=",")
  labelSt = titleStr[seq(1,length(graphNum))]
  labelSt = paste(labelSt, collapse=",")
  
  ncolNum = round(length(graphNum) / 2 )
  
  if (is.numeric(layout)){
    eval(parse(text=paste("p = grid.arrange(", 
                          st ,",layout_matrix = layout)",
                          sep="")))
  }else{
    eval(parse(text=paste("p = ggarrange(",
                          st ,",labels = c(",
                          labelSt,
                          "),font.label = list(size = 20),ncol = 2, nrow =", ncolNum, ")",
                          sep="")))
  }
  return(p)
}

dispBarGraph <- function(ribbondata, config, factors,numOfSub = 0){
  
  if(numOfSub == 0) {numOfSub = length(unique(ribbondata$sub))}
  
  if(length(factors) == 1){
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1], ", data = ribbondata, FUN = 'mean')", sep="")))
  }
  else if(length(factors) == 2){
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1],"*",factors[2], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1],"*",factors[2], ", data = ribbondata, FUN = 'mean')", sep="")))
  }else{
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1],"*",factors[2],"*",factors[3], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1],"*",factors[2],"*",factors[3], ", data = ribbondata, FUN = 'mean')", sep="")))
  }
  
  std_data$data_y = std_data$data_y / sqrt(numOfSub)
  
  ribbondata$SE_min <- ribbondata$data_y - std_data$data_y
  ribbondata$SE_max <- ribbondata$data_y + std_data$data_y
  
  if(length(factors) == 1){ 
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y,color =",factors[1] ,",fill =",factors[1] ,"))", sep="")))
  } else if(length(factors) == 2){
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y, color=",factors[2],",fill = ",factors[2],"))", sep="")))
  } else{
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y, color = interaction(", factors[1],",",factors[2],",",factors[3],"),",
                          "fill = interaction(", factors[1],",",factors[2],",",factors[3],")","))", sep="")))
  }
  
  p <- p + 
    geom_bar(stat = "identity", position = "dodge")+
    geom_errorbar(aes(ymin = SE_min, ymax = SE_max),
                  width = 0.3, size=0.2, position = position_dodge(.9)) +
    geom_hline(yintercept=0, colour="black", linetype="solid", size = 0.5) +
    ggtitle(config$title) +
    xlab(config$label_x) + ylab(config$label_y) + 
    theme(
      axis.ticks.x = element_blank(),
      # axis.text.x = element_text(angle = 30, hjust = 1),
      axis.line.x = element_blank()
    )
  
  if(!is.null(config$grCol)){
    p=p+scale_fill_manual(values = config$grCol)+
      scale_color_manual(values = config$gr_outline)
  }
  
  return(p)
}

dispLineGraph <- function(ribbondata, config, factors,numOfSub = 0){
  
  if(numOfSub == 0) {numOfSub = length(unique(ribbondata$sub))}
  
  if(length(factors) == 1){ 
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1], ", data = ribbondata, FUN = 'mean')", sep="")))
  }
  else if(length(factors) == 2){ 
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1],"*",factors[2], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1],"*",factors[2], ", data = ribbondata, FUN = 'mean')", sep="")))
  }else{
    eval(parse(text=paste("std_data = aggregate( data_y ~ ",factors[1],"*",factors[2],"*",factors[3], ", data = ribbondata, FUN = 'sd')", sep="")))
    eval(parse(text=paste("ribbondata = aggregate( data_y ~ ",factors[1],"*",factors[2],"*",factors[3], ", data = ribbondata, FUN = 'mean')", sep="")))
  }
  
  std_data$data_y = std_data$data_y / sqrt(numOfSub)
  
  ribbondata$SE_min <- ribbondata$data_y - std_data$data_y
  ribbondata$SE_max <- ribbondata$data_y + std_data$data_y
  # , color = ", factors[1],, color = ", factors[1],aes(shape = ", factors[2],"), 
  if(length(factors) == 1){ 
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y))", sep="")))
    eval(parse(text=paste("p = p + geom_point(size = 3,color='black')", sep="")))
  } else if(length(factors) == 2){
    # , shape =  factors[2], 
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[2],", y = data_y",
                          # ",group = interaction(",factors[1],",",factors[2],
                          "))", sep="")))
    eval(parse(text=paste("p = p + geom_point(size = 3)", sep="")))
  } else{
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y, color = ", factors[1],", group = ",factors[2],"))", sep="")))
    eval(parse(text=paste("p = p + geom_point(aes(shape = ", factors[2],"), size = 3)", sep="")))
  }
  
  if(!is.null(config$grCol)){
    p = p + scale_color_manual(values = config$grCol)
  }
  if(!is.null(config$title)){
    p = p + ggtitle(config$title)
  }
  p = p +  
    geom_errorbar(aes(ymin = SE_min, ymax = SE_max),size = 0.1, width = 0.1,color="black")+ 
    xlab(config$label_x) + ylab(config$label_y) +
    theme(
      axis.ticks.x = element_blank(),
      axis.line.x = element_blank()
    )
  
  return(p)
}

dispBoxGraph <- function(ribbondata, config, factors,numOfSub = 0){
  
  if(length(factors) == 1){ 
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y))", sep="")))
    eval(parse(text=paste("p = p + geom_boxplot(width=0.3)", sep="")))
    # eval(parse(text=paste("p = p + geom_jitter(width = 0.1,alpha=0.2)", sep="")))
  }else if(length(factors) == 2){ 
    eval(parse(text=paste("p <- ggplot(ribbondata,aes(x = ", factors[1],", y = data_y, group = interaction(", factors[1],",",factors[2],")))", sep="")))
    eval(parse(text=paste("p = p + geom_boxplot(width=0.3)", sep="")))
  }
  if(!is.null(config$grCol)){
    p = p + scale_color_manual(values = config$grCol)
  }
  if(!is.null(config$title)){
    p = p + ggtitle(config$title)
  }
  p = p +  
    xlab(config$label_x) + ylab(config$label_y) +
    theme(
      axis.ticks.x = element_blank(),
      axis.line.x = element_blank()
    )
  
  return(p)
}


makeSigPair <- function(forDrawingPost) {
  
  sigPairA = NULL
  if(length(forDrawingPost[["A"]]) > 1) {
    t = as.character(forDrawingPost[["A"]][["bontab"]][["significance"]])
    p = forDrawingPost[["A"]][["bontab"]][["adj.p"]]
    for(i in 1:length(t)){
      t0 = strsplit(t[i], " ")
      if(t0[[1]][4] == "*"){
        sigPairA = rbind(sigPairA,t0[[1]][1:3])
      }
      
      if(t0[[1]][2] == "="){
        sigPairA = rbind(sigPairA,t0[[1]][1:3])
      }
    }
    sigPairA = cbind(sigPairA,p)
  }
  
  sigPairB = NULL
  if(length(forDrawingPost[["B"]]) > 1) {
    t = as.character(forDrawingPost[["B"]][["bontab"]][["significance"]])
    for(i in 1:length(t)){
      t0 = strsplit(t[i], " ")
      if(t0[[1]][4] == "*"){
        sigPairB = rbind(sigPairB,t0[[1]][1:3])
      }
    }
  }
  return(rbind(sigPairA,sigPairB))
}

drawSignificance <- function(p,sigPair,y_pos,range,nsFlag) {
  if(!is.null(sigPair)){
    for(i in 1:dim(sigPair)[1]){
      if(sigPair[i,2] == '='){
        if(nsFlag){
          p <- p + geom_signif(xmin=sigPair[i,1], xmax=sigPair[i,3],annotations="n.s.", y_position = y_pos+(i-1)*range,
                               textsize = 5, size=0.2, tip_length = 0.00,family="Times")
        }
      }else{
        if(sigPair[i,4] < 0.05 & sigPair[i,4] > 0.01){
          p <- p + geom_signif(xmin=sigPair[i,1], xmax=sigPair[i,3],annotations="*", y_position = y_pos+(i-1)*range,
                               textsize = 5, size=0.2, tip_length = 0.00,family="Times")
        }else if(sigPair[i,4] < 0.01 & sigPair[i,4] > 0.001){
          p <- p + geom_signif(xmin=sigPair[i,1], xmax=sigPair[i,3],annotations="**", y_position = y_pos+(i-1)*range,
                               textsize = 5, size=0.2, tip_length = 0.00,family="Times")
        }else{      
          p <- p + geom_signif(xmin=sigPair[i,1], xmax=sigPair[i,3],annotations="***", y_position = y_pos+(i-1)*range,
                               textsize = 5, size=0.2, tip_length = 0.00,family="Times")
        }
      }
    }
  }
  return(p)
}

disp <- function(ribbondata,config,shadeFl,factors,numOfSub=0){
  
  if (shadeFl == 1) {
    if(numOfSub == 0) {numOfSub = length(unique(ribbondata$sub))}
    eval(parse(text=paste(
      "data_std = aggregate( data_y ~ data_x * ",factors[1],"*",factors[2],
      ", data = ribbondata, FUN = 'sd')",
      sep=""))) 
    eval(parse(text=paste(
      "ribbondata = aggregate( data_y ~ data_x * ",factors[1],"*",factors[2],
      ", data = ribbondata, FUN = 'mean')",
      sep="")))
    
    data_std$data_y <- data_std$data_y / sqrt(numOfSub)
    ribbondata$ymin <- ribbondata$data_y - data_std$data_y
    ribbondata$ymax <- ribbondata$data_y + data_std$data_y
    
    eval(parse(text=paste(
      "p <- ggplot(ribbondata,
      aes(x = data_x, y = data_y, colour = ", factors[1],", group = ",factors[1],"))+",
      # "annotation_raster(image, -Inf, Inf, -Inf, Inf) +",
      "geom_ribbon(aes(ymin = ymin, ymax = ymax, fill = ",factors[2],", group = ",factors[1], "), color = 'gray', fill = 'gray', alpha = config$alpha, size = 0.05) +",
      "geom_line()",
      # "geom_line(aes(linetype=",factors[1],"))",
      sep="")))
    
    if(!is.null(config$grCol)){
      p <- p +
        # scale_color_manual(values = config$grCol, name = factors[1])+
        scale_fill_manual(values = config$grCol)+
        scale_color_manual(values = config$grCol)
    }
    
    p <- p +
      ggtitle(config$title) +
      xlab(config$label_x) + ylab(config$label_y) +
      coord_cartesian(xlim = config$lim_x,ylim = config$lim_y) +
      scale_x_continuous(expand = c(0, 0)) 
    
  }else{ 
    
    eval(parse(text=paste(
      "p <- ggplot(ribbondata,aes(x = data_x, y = data_y, colour = ", factors[1],", group = ",factors[2],"))+", 
      # "geom_line(aes(linetype = Type))",
      "geom_line()",
      sep="")))
    
    if(!is.null(config$grCol)){
      p <- p +
        scale_color_manual(values = config$grCol)
    }
    p <- p + 
      geom_vline(xintercept=0, colour='black', linetype='longdash', size = 0.1) +
      ggtitle(config$title) +
      xlab(config$label_x) + ylab(config$label_y) +
      coord_cartesian(xlim=config$lim_x, ylim=config$lim_y) +
      scale_x_continuous(expand = c(0, 0))
    # scale_y_continuous(expand = c(0, 0.1))
    # scale_y_continuous(breaks = seq(config$lim_y[1],config$lim_y[2],config$stride),expand = c(0, 0))
    
  }
  
  # p = setBarFigureStyle(p)
  
  return(p)
}

