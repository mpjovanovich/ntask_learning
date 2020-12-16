import sys
import numpy as np
import tensorflow as tf

## Task variables
trials_per_task = 8
num_dims = 3
num_features = 3
num_tasks = 100

## NN config variables
learning_rate = 0.1

## TF variables
#batch_size = None
batch_size = 1
num_steps = 1
num_classes = num_dims * num_features

np.random.seed(int(sys.argv[1]))
tf.set_random_seed(int(sys.argv[1]))

def softmax_select(x):
    cur_max = 0.0
    r = np.random.uniform()
    for i in range(len(x)):
        cur_max += x[i]
        if r < cur_max:
            return i
    ## This should never happen
    return -1

def get_trial(cur_sort_rule):
    x = np.zeros(num_classes)
    y = np.zeros(1)
    cur_trial = [i*num_features+np.random.randint(0,num_features) for i in range(0,num_dims)]
    for i in range(num_dims):
        x[cur_trial[i]] = 1.0
    y[0] = cur_trial[cur_sort_rule]
    return x.reshape([batch_size,num_steps,num_classes]), y.reshape([batch_size, num_steps])

"""
Placeholders
"""
x = tf.placeholder(tf.float32, [batch_size, num_steps, num_classes], name='input_placeholder')
y = tf.placeholder(tf.int32, [batch_size, num_steps], name='labels_placeholder')

"""
Predictions, loss, training step
"""
with tf.variable_scope('softmax'):
    W = tf.get_variable('W', [num_classes, num_classes])
    b = tf.get_variable('b', [num_classes], initializer=tf.constant_initializer(0.0))

logits = tf.reshape(tf.matmul(tf.reshape(x,[-1,num_classes]),W) + b, [batch_size, num_steps, num_classes])
predictions = tf.nn.softmax(logits)

## There is only one loss for a standard NN
losses = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
total_loss = tf.reduce_mean(losses)
train_step = tf.train.AdagradOptimizer(learning_rate).minimize(total_loss)

"""
Do the WCST
"""

## Store incorrect moves per task for optimizing
moves = []

with tf.Session() as sess:
    sess.run(tf.global_variables_initializer())

    tasks_complete = 0
    while tasks_complete < num_tasks:

        ## Get new task
        cur_sort_rule = -1
        temp_sort_rule = np.random.randint(num_dims)
        while temp_sort_rule == cur_sort_rule:
            temp_sort_rule = np.random.randint(num_dims)
        cur_sort_rule = temp_sort_rule

        ## Override the sort rule for initial testing
        #cur_sort_rule = 0

        consecutive_correct_trials = 0
        incorrect_moves = 0
        while consecutive_correct_trials < trials_per_task:
            ## Get a trial
            X, Y = get_trial(cur_sort_rule)

            ## Run the TF graph and select an action
            ## We are assuming a batch and step size of 1
            p, l, tl, _ = sess.run([predictions,losses,total_loss,train_step],feed_dict={x:X,y:Y})
            ac = softmax_select(p[0][0])

            ## Check for trial correctness
            if ac == Y[0]:
                consecutive_correct_trials += 1
            else:
                consecutive_correct_trials = 0
                incorrect_moves += 1

        ## Outputs
        #print(incorrect_moves)
        moves.append(incorrect_moves)
        tasks_complete += 1
print(format(np.mean(moves),'.4f'))

