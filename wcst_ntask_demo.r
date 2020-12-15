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
# Authors: Mike Jovanovich, Joshua L. Phillips
# Created: May 15, 2017
#
# This program provides a demo of the n-task learning algorithm 
# functionality. The task simulated is one in which stimuli of several
# dimensions are presented to the agent, and the agent picks one. One 
# dimension determines reward. After a predefined number of consecutive
# correct trials, the round is considered learned. 
#
# Desired output can be toggled with the output parameter
#
# Example usage: Rscript wcst_ntask_demo.r 1 4 3 3
#
##########################################################################

source("hrr.r")
require(methods)
require(Matrix)

args <- commandArgs(trailingOnly = TRUE)

# Set the seed for repeatability
set.seed(as.integer(args[1]))

# Length of the HRRs
n <- 1024
# number of dimensions; not all of these may be used for task rules,
# but all will be given to the agent as action choices
ndims <- as.integer(args[2])
# number of features per dimension
nfeatures <- as.integer(args[3])
# number of tasks to solve
num_tasks <- as.integer(args[4]) # The total number of tasks (rules)

# Identity vector
hrr_i <- rep(0,n)
hrr_i[1] <- 1

# Dimensions and features don't have friendly names, only indexes
features <- array(replicate(ndims*nfeatures,hrr(n,normalized=TRUE)),dim=c(n,ndims,nfeatures))

# to index: [,dim,feature]
# pseudo-permutation vector for WM and actions
ac_features <- array(replicate(ndims*nfeatures,hrr(n,normalized=TRUE)),dim=c(n,ndims,nfeatures))

# Weight vectors
W_ac <- hrr(n,normalized=TRUE)

# This ancillary NN is not used by the algorithm - it simply allows us to see what is being learned
# by each task rep;
# It could be removed and everything should still work fine
# This NN cannot have a bias
W_tr_anc <- hrr(n,normalized=TRUE) 

# TD parameters
# We might have to find a way around this so that we can still have an optimistic critic
bias_ac <- 1.0
default_reward <- 0.0
success_reward <- 1.0
gamma <- 0.0            # not used (single step problem)
lambda <- 0.0           # not used (single step problem)
lrate <- 0.05 
epsilon_ac <- 0.005

# Test parameters
trials_per_task <- 8        # consecutive trials to complete task
tasks_to_complete <- 250    # tasks completed before quitting
max_trials <- 50000         # this will override the above setting and quit when the number of trials is reached
reward_dim <- 1

tasks_complete <- 0
consecutive_correct <- 0
total_trials <- 0
submoves <- 0

## Set the output that we want to measure
#output <- 'submove'
#output <- 'td'
#output <- 'repvals'
output <- 'repvals_final'
#output <- 'plotreps'

# These are free parameters for task switching
# The model is very sensitive to these params

bias_tr <- 1.0
plot_freq <- 1                      # granularity for plots
#learn_num_taskreps <- TRUE         # If false then num_reps will never change; if true set this to one
learn_num_taskreps <- FALSE         # If false then num_reps will never change; if true set this to one
transform <- TRUE                   # If true then log transform applied to all td learning
#include_task_switch_trial_for_learning <- TRUE # If false and a task switch occurs the bad trial won't be learned
include_task_switch_trial_for_learning <- FALSE # If false and a task switch occurs the bad trial won't be learned
#num_reps <- 3
num_reps <- num_tasks ## Since we have "learn_num_taskreps = false" just assume we already know the number of tasks
max_reps <- 10
lrate_tr <- 0.0075
lrate_tr_anc <- 0.05
lambda_tr_anc <- 0.0

#NOTE: rep and replicate seem to be the same thing with the order of parameters swapped
# Eligibility trace
eligibility_ac <- rep(0,n)

# Each task rep is associated with an eligibility trace
# This is done just for the sake of demonstrating what it being learned by the task reps
# index as: eligibility_tr_anc[,tr]
eligibility_tr_anc <- array(replicate(num_reps,rep(0,n)),dim=c(n,num_reps))

# We are not using a neural network for task rep values - it's strictly driven by error feedback
V_tr <- rep(bias_tr,num_reps)

# These 'dictionaries' should contain the optimal values
# for the parameter at each number of task reps

## These are tuned for 5x5 state space, include_task_switch_trial_for_learning=FALSE
lrate_ts <- list(.004,.002,.00175,.002,.002)
lrate_ts <- c(lrate_ts,replicate(5,.002))

# Override threshold (currently tuned for three)
tr_add_threshold <- c(replicate(10,.6))      # This should be higher than tr_remove_threshold
tr_remove_threshold <- c(replicate(10,.5))   # This should be lower than tr_add_threshold

# Initialize task switch variables
task_switch_threshold <- -1 * bias_ac  # This is learned with q_error; it MUST start at this value
task_rep <- 1

# hrrs for abstract concepts
p <- replicate(num_reps,hrr(n,normalized=TRUE))

## Commented for demo usability
#while( total_trials < max_trials && tasks_complete < tasks_to_complete*2 )

while( total_trials < max_trials && tasks_complete < tasks_to_complete )
{
    ## OVERRIDE TASK REP SWITCHING
    #task_rep <- 1               # No task reps
    #task_rep <- reward_dim      # Perfect task reps

## Commented for demo usability
##     # Accomodate scenarios where the number of true tasks changes
##     if( tasks_complete < tasks_to_complete )
##         num_tasks = num_tasks1
##     else
##         num_tasks = num_tasks2

    ## #####################
    ## UPDATE WORKING MEMORY
    ## #####################

    eligibility_ac[] <- 0
    r <- default_reward 
    current_ac <- hrr_i

    # Get a random feature for each dimension for this trial
    trial <- replicate(ndims,sample(nfeatures,1))
    state <- apply(mapply(function(d,f) features[,d,f], seq(ndims), trial), 1, sum)

    ## ################################
    ## SELECT ACTION (USING UPDATED WM)
    ## ################################

    ac_candidates <- mapply(function(d,f) ac_features[,d,f], seq(ndims), trial)
    ac_values <- apply(ac_candidates,2,function(x) 
        ## not-normalized dot product
        nndot(convolve(convolve(x,state),p[,task_rep]),W_ac) + bias_ac
    )
    ac_move <- which(ac_values==max(ac_values))[1]

    # Epsilon-soft WM updates
    if (runif(1) < epsilon_ac)
        ac_move <- sample(dim(ac_candidates)[2],1)

    # Store current action info
    current_ac <- ac_candidates[,ac_move]
    current_q <- ac_values[ac_move]

    ## ################################
    ## DETERMINE TRIAL CORRECTNESS
    ## ################################
    
    if( ac_move == reward_dim ) {
        r <- success_reward
        consecutive_correct <- consecutive_correct + 1
    } else {
        consecutive_correct = 0
        submoves <- submoves + 1
    }

    ## ####################
    ## ABSORB REWARD
    ## ####################

    eligibility_ac <- (lambda * eligibility_ac + (convolve(convolve(state,current_ac),p[,task_rep])))
    if( lambda > 0 )
        eligibility_ac <- (eligibility_ac / sqrt(2))
    td_error <- r - current_q

    # Update action weights
    # The transform here helped stabilize task learning
    if( transform )
        W_ac <- W_ac + lrate * eligibility_ac * sign(td_error) * log(abs(td_error)+1)
    else
        W_ac <- W_ac + lrate * eligibility_ac * td_error

    # Update task thresholds
    if( transform )
        task_switch_threshold <- task_switch_threshold + lrate_ts[[num_reps]] * -1 * sign(td_error) * 
          log(abs(td_error)+1)
    else
        task_switch_threshold <- task_switch_threshold + lrate_ts[[num_reps]] * -1 * td_error

    ## ####################
    ## UPDATE TASK
    ## ####################

    # Note: this is not strict TD learning - there is no temporal credit assignment
    # We do not want past task reps taking any credit

    # use Q reward to calculate error
    # By performing the 'if' check here learning becomes more stable (values do not jump
    # up and down just because the task switched)
    
    # We only want to add the action to the task rep eligibility trace
    eligibility_tr_anc[,task_rep] <- (lambda_tr_anc * eligibility_tr_anc[,task_rep] + 
      convolve(current_ac,p[,task_rep]))

    if( lambda_tr_anc > 0 )
        eligibility_tr_anc[,task_rep] <- (eligibility_tr_anc[,task_rep] / sqrt(2))

    if( num_reps == 1 || include_task_switch_trial_for_learning || td_error >= task_switch_threshold ) {
        error <- r - V_tr[task_rep]
        error_tr_anc <- r - nndot(eligibility_tr_anc[,task_rep],W_tr_anc)
        if( transform ) {
            V_tr[task_rep] <- V_tr[task_rep] + lrate_tr * sign(error) * log(abs(error)+1)
            W_tr_anc <- W_tr_anc + lrate_tr_anc * eligibility_tr_anc[,task_rep] * sign(error_tr_anc) * 
              log(abs(error_tr_anc)+1)
        }
        else {
            V_tr[task_rep] <- V_tr[task_rep] + lrate_tr * error
            W_tr_anc <- W_tr_anc + lrate_tr_anc * eligibility_tr_anc[,task_rep] * error
        }
    }

    ## ####################
    ## UPDATE TASK TALLIES
    ## ####################

    if( consecutive_correct == trials_per_task ) {
        tasks_complete = tasks_complete + 1 
        consecutive_correct = 0

        new_reward_dim <- reward_dim
        if( num_tasks > 1 ) {
            while( new_reward_dim == reward_dim ) {
                new_reward_dim = sample.int(num_tasks,1)
            }
            reward_dim <- new_reward_dim
        }
    }

    ## ############################################
    ## DETERMINE WHETHER TO ADD/REMOVE TASK REP OR SWITCH TASKS
    ## ############################################
    TS <- '0,'

    # This is a little redundant, but it makes it easier to follow
    # what's going on for the 'learn_num_taskreps' mode
    if( !learn_num_taskreps && td_error < task_switch_threshold ) {
        task_rep <- ((task_rep %% num_reps) + 1)
        TS <- '1,'
    }

    if( learn_num_taskreps && td_error < task_switch_threshold ) {
        TS <- '1,'

        # Calculate individual, max, and mean task rep values
        reps_to_remove <- c()
        avg_tr_val <- 0
        max_task_rep <- task_rep
        max_task_rep_val <- -999
        for( i in 1:num_reps ) {
            rep_val <- V_tr[i]
            avg_tr_val <- avg_tr_val + rep_val

            if( rep_val < tr_remove_threshold[num_reps] )
                reps_to_remove <- c(reps_to_remove,i)
            if( rep_val > max_task_rep_val ) {
                max_task_rep <- i
                max_task_rep_val <- rep_val
            }
        }
        avg_tr_val <- avg_tr_val / num_reps

        # Remove any poor performing task reps
        if( avg_tr_val > tr_add_threshold[num_reps] && length(reps_to_remove) > 0 && num_reps > 1 ) {
            p <- as.matrix(p[,-reps_to_remove])
            V_tr <- V_tr[-reps_to_remove]
            eligibility_tr_anc <- as.matrix(eligibility_tr_anc[,-reps_to_remove])
            num_reps <- num_reps - length(reps_to_remove)
            task_rep <- 1 # have to reset task rep so that it stays in bounds
        }
        else if( avg_tr_val < tr_add_threshold[num_reps] && num_reps < max_reps ) {
            # Add new task reps
            num_reps <- num_reps + 1
            task_rep <- 1

            # We're 'starting fresh' with the learning at this point, so reinitialize everything
            task_switch_threshold <- -1 * bias_ac  # This is learned with q_error; it MUST start at this value
            p <- replicate(num_reps,hrr(n,normalized=TRUE))
            eligibility_tr_anc <- array(replicate(num_reps,rep(0,n)),dim=c(n,num_reps))
            W_ac <- hrr(n,normalized=TRUE)
            V_tr <- rep(bias_tr,num_reps)
        }
        else {
            # If the mean task rep value is above the add threshold, then switch tasks
            task_rep <- ((task_rep %% num_reps) + 1)
        }
    }

    ## ####################
    ## DEBUG PRINTS
    ## ####################

    if( output == 'repvals' ) {
        # Plot the values learned by the ancillary rep value NN
        for( r in 1:num_reps ) {
            for( d in 1:ndims ) {
                for( f in 1:nfeatures ) {
                    current_ac <- ac_features[,d,f]
                    cat(sprintf('%.4f',nndot(convolve(current_ac,p[,r]),W_tr_anc)))
                    if( d != ndims || f != nfeatures )
                        cat(',')
                }
            }
        }
        cat('\n')
    }
    if( output == 'plotreps' && total_trials %% plot_freq == 0 ) {
        # Plot the actual rep vals used by the algorithm
        cat(TS)
        cat(sprintf('%.4f,',as.integer(tasks_complete>tasks_to_complete)))
        cat(sprintf('%.4f,',task_switch_threshold))
        cat(sprintf('%.4f,',tr_add_threshold[num_reps]))
        cat(sprintf('%.4f,',tr_remove_threshold[num_reps]))
        for( r in 1:num_reps) {
            cat(sprintf('%.4f',V_tr[r]))
            if( r != num_reps )
                cat(',')
        }
        cat('\n')
    }
    if( output == 'td' ) {
        cat(sprintf('%.4f,',task_switch_threshold))
        cat(sprintf('%.4f,',td_error))
        cat('\n')
    }

    # Update total trial tally
    total_trials <- total_trials + 1
}

if( output == 'submove' )
    print( submoves/tasks_complete )

if( output == 'repvals_final' ) {
    # Plot the values learned by the ancillary rep value NN
    for( r in 1:num_reps ) {
        for( f in 1:nfeatures ) {
            for( d in 1:ndims ) {
                current_ac <- ac_features[,d,f]
                cat(sprintf('%.4f',nndot(convolve(current_ac,p[,r]),W_tr_anc)))
                if( d != ndims || f != nfeatures )
                    cat(',')
            }
        }
        cat('\n')
    }
}
