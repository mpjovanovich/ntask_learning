setwd("~/MTSU/Thesis/CogSci_2018/results/task_performance/")
pdf(file="task_performance.pdf",width=6.5,height=2.5,pointsize=10)
par(mar=c(3,4,0.4,4.2)) # set margins (b,l,t,r)
par(xpd=TRUE) # turn off clip to plot area

num_records <- 100
num_tasks <- 100
show_conf_interval <- TRUE
x <- (1:num_tasks)
plot(NULL,frame.plot=FALSE,xlim=c(0,num_tasks),ylim=c(0,100),ylab='',xlab='')
title(ylab='Incorrect Trials', line=2.4, cex.lab=1) # use 'line' to adjust closeness to axis
title(xlab='Round', line=2, cex.lab=1) # use 'line' to adjust closeness to axis

num_reps <- 1
m <- read.table('submoves1',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+1,lwd=1)

num_reps <- 2
m <- read.table('submoves2',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+1,lwd=1)

num_reps <- 3
m <- read.table('submoves3',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+1,lwd=1)

num_reps <- 4
m <- read.table('submoves4',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+1,lwd=1)

num_reps <- 5
m <- read.table('submoves5',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+1,lwd=1)

num_reps <- 6 ## hack to get LSTM in the right spot
m <- read.table('submoves_lstm',header=FALSE,sep=',',colClasses=c(rep("double",num_tasks),rep("NULL",num_records-num_tasks)))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
## color fix; 6 is yellow and doesn't show up
if( show_conf_interval )
  polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_reps+3,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_reps+3,lwd=1)

## TODO: FIX COLORS
legend("right",col=c(2:6,9),pch='-',bty='n',pt.cex=2,cex=1,horiz=F,inset=c(-0.14, 0),
       legend = c(
         '1 ATR\n(SARSA)',
         '2 ATRs',
         '3 ATRs',
         '4 ATRs',
         '5 ATRs',
         'LSTM'))
dev.off()
