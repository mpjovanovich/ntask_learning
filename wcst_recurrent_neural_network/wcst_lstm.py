## Base code:
## https://r2rt.com/recurrent-neural-networks-in-tensorflow-i.html
import sys
import numpy as np
import tensorflow as tf

# Global config variables
num_steps = 20      # number of truncated backprop steps ('n' in the discussion above)
state_size = 20 
batch_size = 20
num_dims = 2
num_features = 2
num_classes = num_dims * num_features
learning_rate = 0.1
num_tasks = 100000
#num_epochs = 5
num_epochs = 1
trials_per_task = 8

## TODO: set random seed

def gen_data():
    x = []
    y = []
    cur_sort_rule = -1
    sort_rule = -1
    for task in range(num_tasks):
        ## Get a new sorting rule
        while sort_rule == cur_sort_rule:
            sort_rule = np.random.randint(num_dims)
        cur_sort_rule = sort_rule
        ## Make trials
        for trial in range(trials_per_task):
            cur_trial = [x*num_features+np.random.randint(0,num_features) for x in range(0,num_dims)]
            x.append(np.zeros(num_classes))
            y.append(cur_trial[cur_sort_rule])
            for i in range(num_dims):
                x[task*trials_per_task+trial][cur_trial[i]] = 1

    X = np.array(x,dtype=np.float32)
    Y = np.array(y,dtype=np.float32)
    return X, Y

# adapted from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/models/rnn/ptb/reader.py
def gen_batch(raw_data, batch_size, num_steps):
    raw_x, raw_y = raw_data
    data_length = len(raw_x)

    # partition raw data into batches and stack them vertically in a data matrix
    batch_partition_length = data_length // batch_size
    ## 200 x 40 x num_dims
    #data_x = np.zeros([batch_size, batch_partition_length, num_dims], dtype=np.int32)
    data_x = np.zeros([batch_size, batch_partition_length, num_classes], dtype=np.int32)
    data_y = np.zeros([batch_size, batch_partition_length], dtype=np.int32)
    for i in range(batch_size):
        data_x[i] = raw_x[batch_partition_length * i:batch_partition_length * (i + 1)]
        data_y[i] = raw_y[batch_partition_length * i:batch_partition_length * (i + 1)]
    # further divide batch partitions into num_steps for truncated backprop
    epoch_size = batch_partition_length // num_steps

    for i in range(epoch_size):
        x = data_x[:, i * num_steps:(i + 1) * num_steps]
        y = data_y[:, i * num_steps:(i + 1) * num_steps]
        yield (x, y)

def gen_epochs(n, num_steps):
    for i in range(n):
        yield gen_batch(gen_data(), batch_size, num_steps)

"""
Placeholders
"""
rnn_inputs = x = tf.placeholder(tf.float32, [batch_size, num_steps, num_classes], name='input_placeholder')
y = tf.placeholder(tf.int32, [batch_size, num_steps], name='labels_placeholder')

"""
RNN
"""
cell = tf.contrib.rnn.LSTMCell(state_size, state_is_tuple=True)
init_state = cell.zero_state(batch_size, tf.float32)
rnn_outputs, final_state = tf.nn.dynamic_rnn(cell, rnn_inputs, initial_state=init_state)

"""
Predictions, loss, training step
"""
with tf.variable_scope('softmax'):
    W = tf.get_variable('W', [state_size, num_classes])
    b = tf.get_variable('b', [num_classes], initializer=tf.constant_initializer(0.0))
logits = tf.reshape(
            tf.matmul(tf.reshape(rnn_outputs, [-1, state_size]), W) + b,
            [batch_size, num_steps, num_classes])

losses = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
total_loss = tf.reduce_mean(losses)
train_step = tf.train.AdagradOptimizer(learning_rate).minimize(total_loss)
predictions = tf.nn.softmax(logits)

"""
Train the network
"""
def train_network(num_epochs, num_steps, state_size=state_size, verbose=True):
    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())
        training_losses = []
        for idx, epoch in enumerate(gen_epochs(num_epochs, num_steps)):
            training_loss = 0
            #print("\nEPOCH", idx)
            for step, (X, Y) in enumerate(epoch):
                tr_losses, training_loss_, training_state, _ = \
                    sess.run([losses,
                              total_loss,
                              final_state,
                              train_step],
                                  feed_dict={x:X, y:Y})

                training_loss += training_loss_
                ## Output printing
                if False:
                #if step % 100 == 0 and step > 0 and idx == (num_epochs-1):
                    #print("Average loss at step", step, "for last 250 steps:", training_loss/100)
                    #print(predictions.eval(feed_dict={x:X, y:Y}))
                    p = predictions.eval(feed_dict={x:X, y:Y})
                    for a in p:
                        for b in a:
                            for c in b:
                                print(format(c,'.4f'),' ',sep='',end='')
                            print()
                    training_losses.append(training_loss/100)
                    training_loss = 0

    return training_losses

#MAIN
training_losses = train_network(num_epochs,num_steps)
