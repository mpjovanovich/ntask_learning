##  n-task Learning Demo
##  Copyright (C) Mike Jovanovich & Joshua L. Phillips
##  Department of Computer Science
##  Middle Tennessee State University; Murfreesboro, Tennessee, USA.

##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 3 of the License, or
##  (at your option) any later version

##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
##  GNU General Public License for more details.

##  You should have recieved a copy of the GNU General Public License
##  along with this program; if not, write to the Free Sotware
##  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

##########################################################################
#
# Authors: Joshua L. Phillips, Mike Jovanovich
# Created: May 15, 2017
#
# This package provides functionality for working with Holographic
# Reduced Representations.
#
##########################################################################

## Make an HRR
hrr <- function(length,normalized=FALSE) {
    if (normalized) {
        myhrr <- runif((length-1) %/% 2, -pi, pi)
        if (length %% 2) {
            myhrr <- Re(fft(complex(modulus=1,argument=c(0,myhrr,-rev(myhrr))),inverse=TRUE))/length
        }
        else {
            myhrr <- Re(fft(complex(modulus=1,argument=c(0,myhrr,0,-rev(myhrr))),inverse=TRUE))/length
        }
    }
    else {
        myhrr <- rnorm(length,0,1.0/sqrt(length))
    }
    return (myhrr)
}

## Convolution - the default R function is incorrect
convolve <- function(x,y,normalize=TRUE) {
    if( normalize==TRUE)
        return (Re(fft(fft(x)*fft(y),inverse=TRUE))/length(x))
    else
        return (Re(fft(fft(x)*fft(y),inverse=TRUE)))
}

## Not normalized dot product
nndot <- function(x,y) {
    x <- as.vector(x)
    y <- as.vector(y)
    return (as.double(x%*%y))
}

