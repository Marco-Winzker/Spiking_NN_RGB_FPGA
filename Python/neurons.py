# import libraries
import numpy as np      # numpy


# Integrate and Fire Neuron Object
class IF_Neuron:
    def __init__(self, layer, weights, bias, steps, v_th):
        self.layer = layer                          # Layer of Neuron
        self.weights = weights                      # Weights
        self.bias = bias                            # Bias

        # IF Properties
        self.steps = steps                          # Number of steps for calculation
        self.v = np.empty([self.steps])             # Neuron Value
        self.v[0] = 0                               # Set start Value
        self.spikes = np.empty([self.steps])        # Output spike train
        self.n_spikes = 0                           # Number of spikes
        self.v_th = v_th                            # Threshold

    def reset(self):                                # Reset Neuron
        self.v = np.empty([self.steps])
        self.v[0] = 0
        self.spikes = np.empty([self.steps])
        self.n_spikes = 0

    def calculate(self, neuron_input):
        for i in range(self.steps):                 # for every step
            if i > 0:                               # not first element
                self.v[i] = self.v[i-1]
            for j in range(len(neuron_input)):      # for every input channel
                if neuron_input[j][i]:              # if spike present
                    self.v[i] = self.v[i] + self.weights[j]
            self.v[i] = self.v[i] + self.bias
            if self.v[i] > self.v_th:               # if above threshold
                self.n_spikes += 1                  # increase number of spikes
                self.spikes[i] = 1                  # add spike to spike trace
                self.v[i] = self.v[i] - self.v_th   # difference reset
                # self.Vm[i] = self.bias            # hard reset
            else:                                   # add no spike to spike trace
                self.spikes[i] = 0


# Neuron Object for ANN
class Neuron:
    def __init__(self, layer, weights, bias):
        self.layer = layer                          # layer
        self.weights = weights                      # weights
        self.bias = bias                            # bias
        self.output = 0                             # output

    def calculate(self, inputs):                    # calculation
        relu_activation = ReLU()
        x = np.dot(self.weights, inputs) + self.bias
        self.output = relu_activation.calculate(x)


# ReLU activation function
class ReLU:
    def __init__(self):
        self.output = 0

    def calculate(self, x):
        self.output = np.maximum(0, x)              # relu function
        return self.output
