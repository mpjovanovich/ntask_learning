
##### LATICE SOLN ######
#library(lattice)

#r <- read.table('r_3task_1rep_acvals',sep=',',header=FALSE,nrows=10000)

## Pick whatever row to make the matrix
## show 2029 - good point; 2130 - bad point
#hm_a <- levelplot( matrix(as.numeric(r[2029,]),nrow=5,ncol=5), xlab="Feature", ylab="Dimension", col.regions=heat.colors(100)[length(heat.colors(100)):1] )
#hm_b <- levelplot( matrix(as.numeric(r[2130,]),nrow=5,ncol=5), xlab="Feature", ylab="Dimension", col.regions=heat.colors(100)[length(heat.colors(100)):1] )

#print(hm_a, split = c(1, 1, 2, 1), more = TRUE)
#print(hm_b, split = c(2, 1, 2, 1), more = FALSE)


##### PLOTLY SOLN ######
library(plotly)

m <- list(
  l = 20,
  r = 0,
  b = 25,
  t = 0,
  pad = 0
)
a <- list(
  autotick = FALSE
)
w <- 250

## Pick whatever row to make the matrix
## show 2029 - good point; 2130 - bad point
r <- read.table('r_3task_1rep_acvals_lastrow',sep=',',header=FALSE)
hm_a <- plot_ly(x=1:5,y=1:5,z=matrix(as.numeric(r[1,]),byrow=TRUE,nrow=5,ncol=5),colors=colorRamp(c('white','yellow','orange','red')),type='heatmap',zmin=0.0,zmax=1.0,showscale=FALSE) %>%
  layout(autosize = F, width = w, height = w, margin = m)%>%
  layout(xaxis = a, yaxis = a)
#hm_b <- plot_ly(x=1:5,y=1:5,z=matrix(as.numeric(r[2130,]),byrow=TRUE,nrow=5,ncol=5),colors=colorRamp(c('white','yellow','orange','red')),type='heatmap',zmin=0.0,zmax=1.0,showscale=FALSE) %>%
#  layout(autosize = F, width = w, height = w, margin = m)%>%
#  layout(xaxis = a, yaxis = a)

r <- read.table('r_3task_3rep_acvals1_lastrow',sep=',',header=FALSE)
hm_b <- plot_ly(x=1:5,y=1:5,z=matrix(as.numeric(r[1,]),byrow=TRUE,nrow=5,ncol=5),colors=colorRamp(c('white','yellow','orange','red')),type='heatmap',zmin=0.0,zmax=1.0,showscale=FALSE) %>%
  layout(autosize = F, width = w, height = w, margin = m)%>%
  layout(xaxis = a, yaxis = a)
#r <- read.table('r_3task_3rep_acvals2',sep=',',header=FALSE,nrows=10000)
#hm_d <- plot_ly(x=1:5,y=1:5,z=matrix(as.numeric(r[5000,]),byrow=TRUE,nrow=5,ncol=5),colors=colorRamp(c('white','yellow','orange','red')),type='heatmap',zmin=0.0,zmax=1.0,showscale=TRUE) %>%
#    layout(autosize = F, width = 350, height = w, margin = m)%>%
#    layout(xaxis = a, yaxis = a)

export(hm_a, file="hm_a.pdf")
export(hm_b, file="hm_b.pdf")
#export(hm_c, file="hm_c.pdf")
#export(hm_d, file="hm_d.pdf")

