
sTime = -4
eTime = 4
countFigNum=1

load("dataset_timeCourse.rda")
data_timeCourse_ave = data_timeCourse[data_timeCourse$data_x >= -0.1 & data_timeCourse$data_x <= 0,]
data_timeCourse_ave$data_y = data_timeCourse_ave$Baseline
data_timeCourse_ave = aggregate( data_y ~ sub*numOfSwitch, data = data_timeCourse_ave, FUN = "mean")
anovakun(data_timeCourse_ave,"sA",long=T, peta=T)

config = list(lim_x = c(sTime,eTime),
              lim_y = c(-0.5, 0.7),
              # lim_y = c(-7.5, 1),
              alpha = 0.4,
              stride = 0.1,
              label_x = "Time [sec]",
              label_y = "Baseline pupil size\n[z-score]",
              title = ""
              # grCol = c( "gray","#FFFFFF"),
              # gr_outline =c("black","black")
)

data_timeCourse$data_y = data_timeCourse$Baseline
p <- disp(data_timeCourse,config,1,c("numOfSwitch","numOfSwitch"))

p = setEmptyStyle(p)
p = p +
  scale_y_continuous(breaks=round(seq(-0.6,0.6,0.2),2))+
  coord_cartesian(ylim=c(-0.5,0.7),expand=FALSE) +
  annotate(x=-4, xend=-4, y=-0.4, yend=0.6, colour="black", lwd=0.75, geom="segment") +
  annotate(x=-4, xend=4, y=-0.5, yend=-0.5, colour="black", lwd=0.75, geom="segment")

p <- p + theme(
  # legend.position = 'none'
  legend.position = c(0.9, 0.9),
  legend.text=element_text(size=14)
)
eval(parse(text=paste("p", countFigNum ,"=p", sep="")))
countFigNum = countFigNum+1

config$label_y = "Transient pupil change\n[z-score]"
data_timeCourse$data_y = data_timeCourse$Transient
p <- disp(data_timeCourse,config,1,c("numOfSwitch","numOfSwitch"))

p = setEmptyStyle(p)
p = p +
  scale_y_continuous(breaks=round(seq(-0.6,0.6,0.2),2))+
  coord_cartesian(ylim=c(-0.5,0.7),expand=FALSE) +
  annotate(x=-4, xend=-4, y=-0.4, yend=0.6, colour="black", lwd=0.75, geom="segment") +
  annotate(x=-4, xend=4, y=-0.5, yend=-0.5, colour="black", lwd=0.75, geom="segment")

p <- p + theme(
  # legend.position = 'none'
  legend.position = c(0.9, 0.9),
  legend.text=element_text(size=14)
)

eval(parse(text=paste("p", countFigNum ,"=p", sep="")))
countFigNum = countFigNum+1

p = combineGraphs(seq(1,countFigNum-1),'p',NULL)
plot(p)


# all average -------------------------------------------------------------
data_timeCourse = aggregate( data_y ~ sub*data_x, data = data_timeCourse, FUN = "mean")
data_timeCourse$numOfSwitch = 0

p <- disp(data_timeCourse,config,1,c("numOfSwitch","numOfSwitch"))

p = setEmptyStyle(p)
p = p +
  scale_y_continuous(breaks=round(seq(-0.05,0.2,0.05),2))+
  coord_cartesian(ylim=c(-0.05,0.25),expand=FALSE) +
  annotate(x=-4, xend=-4, y=0, yend=0.2, colour="black", lwd=0.5, geom="segment") +
  annotate(x=-4, xend=4, y=-0.05, yend=-0.05, colour="black", lwd=0.5, geom="segment")

p <- p + theme(
  legend.position = 'none',
  legend.text=element_text(size=14)
)
eval(parse(text=paste("p", countFigNum ,"=p", sep="")))
countFigNum = countFigNum+1


# width_fig=6
# height_fig=4
# CairoFonts(regular = "Times","Times")
# CairoPDF(file=paste(saveLoc,"e2_fig_timeCourse0", sep = ""),
#          width=width_fig, height=height_fig)
# print(p3)
# dev.off()
# width_fig=8
# height_fig=4
# ggsave(file = paste(saveLoc,"e2_fig_timeCourse.pdf", sep = ""),
#        plot = p, dpi = 500,
#        width = width_fig, height = height_fig,
#        family="Times")
