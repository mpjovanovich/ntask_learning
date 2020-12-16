# perseveration.pdf
setwd("~/MTSU/Thesis/td_hrr/taskreps/AAAI18_results/perserveration")
pdf(file="perseveration.pdf",width=6.5,height=2.5,pointsize=10)
par(mar=c(3.6,4,.5,.5)) # set margins (b,l,t,r)
r <- read.table('r_3task_1rep',sep=',',col.names = paste0('V', 1:15),fill=TRUE,header=FALSE,nrows=2500)
r <- r[] # zoom in here
x <- (1:dim(r)[1])
plot(NULL,frame.plot=FALSE,xlim=c(0,dim(r)[1]),ylim=c(0,1),ylab='',xlab='')
title(ylab='ATR Value', line=2.4, cex.lab=1) # use 'line' to adjust closeness to axis
title(xlab='Trial', line=2.4, cex.lab=1) # use 'line' to adjust closeness to axis
for (i in 6:dim(r)[2])
    lines(x,r[,i],col=1,lwd=2)
dev.off()

## heatmap action vals
#library("lattice")
#setwd("~/MTSU/Thesis/td_hrr/taskreps/NIPS_results/perserveration")
#r <- read.table('r_3task_1rep_acvals',sep=',',header=FALSE,nrows=10000)
## Pick whatever row to make the matrix
## show 2029 - good point; 2130 - bad point
#levelplot( matrix(r[2029,],nrow=5,ncol=5), xlab="Feature", ylab="Dimension", col.regions=heat.colors(100)[length(heat.colors(100)):1] )

