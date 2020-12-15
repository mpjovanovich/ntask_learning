# ntask_learning

This program encapsulates the core methodology that was used for the below research:

Jovanovich, M., & Phillips, J. (2018, July). n-task Learning: Solving Multiple or Unknown Numbers of Reinforcement Learning Problems. In CogSci (pp. 584-589).
https://cogsci.mindmodeling.org/2018/papers/0126/index.html

The entry point is wcst_ntask_demo.r, which can be run using the arguments specified in the code file header. Depending on the provided arguments

The hrr.r file is a supporting library - holographic reduced representations were used to provide easy encoding into the neural networks that servered as 
reward and task switching functions for the model.


# INTERPRETING RESULTS:

Using the print values for "repvals" final, you may see output like this:

0.2594,0.3530,0.2585,0.0496,0.2525,0.2568,0.2040,0.2101,0.9988,0.9993,0.9979,1.0000
0.3671,-0.0666,0.1726,0.1040,0.9997,0.9605,1.0003,1.0002,0.8306,0.5345,0.8042,0.5479
0.9999,0.9991,0.9997,1.0001,0.3336,0.4137,0.4928,0.4165,0.0078,0.1574,0.1369,-0.0647

In this case there are three dimensions of four values (features) each. E.g. color = { red, blue, green, yellow }.

If the correct dimension "rule"


# Contact

If you have any questions, feel free to reach out to me at mpjovanovich@gmail.com.
