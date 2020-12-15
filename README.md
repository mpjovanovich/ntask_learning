# ntask_learning

This program encapsulates the core methodology that was used for the below research:

Jovanovich, M., & Phillips, J. (2018, July). n-task Learning: Solving Multiple or Unknown Numbers of Reinforcement Learning Problems. In CogSci (pp. 584-589).
https://cogsci.mindmodeling.org/2018/papers/0126/index.html

The entry point is wcst_ntask_demo.r, which can be run using the arguments specified in the code file header. Depending on the provided arguments

The hrr.r file is a supporting library - holographic reduced representations were used to provide easy encoding into the neural networks that servered as 
reward and task switching functions for the model.


# INTERPRETING RESULTS:

If you run the program as "Rscript wcst_ntask_demo.r 1 4 3 3" using the print values for "repvals" final, you may see the first line of output like this:

Rule 1 results: 0.3491,0.3887,0.9935,-0.0401,0.2184,0.3543,0.9989,0.1132,0.3304,0.1701,0.9733,-0.0098
Rule 2 results: ...
Rule 3 results: ...

We really want these to be rearranged as follows, so that the dimensions (candidate for the learning rule) are along the x-axis, and the features are
along the y-axis:

0.3491, 0.3887, 0.9935, -0.0401,
0.2184, 0.3543, 0.9989, 0.1132,
0.3304, 0.1701, 0.9733, -0.0098
 
The above may correspond to something like this:
 
red     banana  solid     big
blue    grape   spotted   medium
green   apple   checkered small

In a single trial the candidate is presented with an object of four features, and asked to select one. The rule, which alternates after several correct selections (see WCST references in the paper), corresponds to a dimension. From the results, we can see that the rule for reward was "pattern".
    If the trial was "big red spotted banana", the candidate should pick "spotted" from the four possible choices to get a reward.
    If the trial was "small green solid grape", the candidate should pick "solid" from the four possible choices to get a reward.
    
There are A LOT of variables that can be toggled in this application to cover the ground from the research - I'd recommend starting with the defaults if you want to give it a try.

# Contact

If you have any questions, feel free to reach out to me at mpjovanovich@gmail.com.
