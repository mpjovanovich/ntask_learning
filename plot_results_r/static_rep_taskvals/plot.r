# plotreps - Combine all rep values
# This is the one we're using
#setwd("")
pdf(file="static_rep_taskvals.pdf",width=6.5,height=2.5,pointsize=10)
par(mar=c(3,4,0.5,4.2)) # set margins (b,l,t,r)
par(xpd=TRUE) # turn off clip to plot area
num_trials <- 5000
x <- (1:num_trials)

plot(NULL,frame.plot=FALSE,xlim=c(0,num_trials),ylim=c(0,1),ylab='',xlab='')
title(ylab='Mean ATR Value', line=2.4, cex.lab=1) # use 'line' to adjust closeness to axis
title(xlab='Round', line=2, cex.lab=1) # use 'line' to adjust closeness to axis

#setwd("")
num_tasks <- 1
m <- matrix(nrow=100,ncol=num_trials)
m <- as.matrix(read.table(paste('r',1,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_tasks+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_tasks+1,lwd=1)

#setwd("")
num_tasks <- 2
m <- matrix(nrow=100,ncol=num_trials)
m <- as.matrix(read.table(paste('r',1,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
for( i in 2:num_tasks )
  m <- m + as.matrix(read.table(paste('r',i,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
m <- m / num_tasks
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_tasks+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_tasks+1,lwd=1)

#setwd("")
num_tasks <- 3
m <- matrix(nrow=100,ncol=num_trials)
m <- as.matrix(read.table(paste('r',1,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
for( i in 2:num_tasks )
  m <- m + as.matrix(read.table(paste('r',i,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
m <- m / num_tasks
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_tasks+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_tasks+1,lwd=1)

#setwd("")
num_tasks <- 4
m <- matrix(nrow=100,ncol=num_trials)
m <- as.matrix(read.table(paste('r',1,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
for( i in 2:num_tasks )
  m <- m + as.matrix(read.table(paste('r',i,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
m <- m / num_tasks
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_tasks+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_tasks+1,lwd=1)

#setwd("")
num_tasks <- 5
m <- matrix(nrow=100,ncol=num_trials)
m <- as.matrix(read.table(paste('r',1,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
for( i in 2:num_tasks )
  m <- m + as.matrix(read.table(paste('r',i,sep=''),sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",20000-num_trials))))
m <- m / num_tasks
means <- apply(m,2,mean)
sem <- apply(m,2,function(x) sd(x)/sqrt(length(x)))
polygon(c(x,rev(x)),c(means+2*sem,rev(means-2*sem)),col=adjustcolor(num_tasks+1,alpha.f=0.33),border=FALSE)
lines(x,means,col=num_tasks+1,lwd=1)

#plot(NULL,frame.plot=FALSE,xlim=c(0,num_trials),ylim=c(0,1),ylab='Task Representation Value',xlab='Trial')
legend("right",col=2:6,pch='-',bty='n',pt.cex=2,cex=1,horiz=F,inset=c(-0.125, 0),
       legend = c(
         '1 ATR\n(SARSA)',
         '2 ATRs',
         '3 ATRs',
         '4 ATRs',
         '5 ATRs'))
dev.off()
