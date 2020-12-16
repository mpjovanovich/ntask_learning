
## PLOT ATR VALUES ##
pdf(file="learn_num_tasks.pdf",width=6.5,height=3.5,pointsize=10)
par(xpd=FALSE)

debug <- FALSE
m <- matrix(c(1,2,3),nrow = 3,ncol = 1,byrow = TRUE)
layout(matrix(c(1,2,3),nrow = 3,ncol = 1,byrow = TRUE))

max_trials <- 20000
num_trials <- 12500
t_a <- .5
#t_r <- .3
x <- (1:num_trials)
ticks <- c(.2,.4,.6,.8,1)
#ticks <- c(.2,.6,1)

par(mar=c(1.5,5,.2,0)) # set margins (b,l,t,r)
plot(NULL,frame.plot=FALSE,xlim=c(0,num_trials),ylim=c(.2,1),ylab='',xlab='',xaxt='n',yaxt='n')
axis(2, at=ticks, labels=ticks,cex.axis=1.2)
#mtext('ATR Value',side=2,line=2.6,adj=0,cex=.9,at=0.4)
mtext('Value',side=2,line=2.6,adj=0,cex=1,at=-0.1)

#abline(h=t_a,lwd=2,lty=5) # Make sure this threshold is right - check the file
lines(x=1:num_trials,y=rep(t_a,num_trials),lwd=1,lty=5) # Make sure this threshold is right - check the file

if(debug==FALSE) { #begin debug

if(file.exists('r1')) {
num_tasks <- 1
m <- as.matrix(read.table('r1',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=num_tasks+1,lwd=2)
}
if(file.exists('r2')) {
num_tasks <- 2
m <- as.matrix(read.table('r2',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=num_tasks+1,lwd=2)
}
if(file.exists('r3')) {
num_tasks <- 3
m <- as.matrix(read.table('r3',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=num_tasks+1,lwd=2)
}
if(file.exists('r4')) {
num_tasks <- 4
m <- as.matrix(read.table('r4',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=num_tasks+1,lwd=2)
}
if(file.exists('r5')) {
num_tasks <- 5
m <- as.matrix(read.table('r5',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=num_tasks+1,lwd=2)
}

#if(file.exists('task_switch')) {
#m <- as.matrix(read.table('task_switch',sep=',',header=FALSE))
#means <- apply(m,2,mean)
#abline(v=means[1])
#}

} # end debug

par(mar=c(4,5,0,0)) # set margins (b,l,t,r)
plot(NULL,frame.plot=FALSE,xlim=c(0,num_trials),ylim=c(-1,-.2),ylab='',xlab='',yaxt='n',cex.axis=1.2)
axis(2, at=-1*ticks, labels=-1*ticks,cex.axis=1.2)
title(xlab='Trial', line=2.8, cex.lab=1.5) # use 'line' to adjust closeness to axis
#mtext('s',side=2,line=2.6,adj=0,cex=1,at=-1.35)

if(debug==FALSE) {

if(file.exists('ts_threshold')) {
m <- as.matrix(read.table('ts_threshold',sep=',',header=FALSE,colClasses=c(rep("double",num_trials),rep("NULL",max_trials-num_trials))))
means <- apply(m,2,mean)
lines(x,means,col=1,lwd=2)
}

} # end debug

par(mar=c(0,0,0,0)) # set margins (b,l,t,r)
par(xpd=TRUE)
plot(1, type = "n", axes=FALSE, xlab="", ylab="")

# 2 rows
legend("top",col=c(rep(1,2)),bty='n',cex=1.4,inset=c(0.0,-0.05),horiz=T,
       lty=c(1,5),lwd=c(2,1),text.width=c(.19,.1),
       legend = c(
         'Task Switch Threshold (t)',
         'Task Add Threshold (a)'))
legend("top",col=c(2:6),bty='n',cex=1.4,inset=c(0.0,0.1),horiz=T,
       lty=c(1,1,1,1,1),lwd=c(2,2,2,2,2),text.width=c(rep(.075,5)),
       legend = c(
         'ATR 1',
         'ATR 2',
         'ATR 3',
         'ATR 4',
         'ATR 5'))

dev.off()

