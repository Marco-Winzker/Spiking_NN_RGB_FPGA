# import libraries
import numpy as np


# network structure, weights, biases and activation of output neurons of existing ANN
def load_model():
    network_structure = [3, 7, 2]               # input layer, hidden layer, output layer
    weights = np.array([[0.063, 0.28, 1.06],    # every line is one neuron (no neurons for input layer)
                        [0.33, 0.19, -0.55],
                        [0.15, -0.29, -0.17],
                        [1.03, 0.54, -0.85],
                        [0.05, 0.34, -0.28],
                        [0.61, 0.25, 0.41],
                        [-0.67, -0.00, 0.99],
                        [0.502, -0.754, 0.188, -0.704, 0.281, -0.456, 0.892],
                        [-0.652, 0.146, -0.437, 1.271, -0.276, 0.023, -0.988]], dtype=object)
    biases = np.array([0.52, 0.93, 0.06, 0.15, -0.19, -0.43, 0.25, 0.282, 0.454])
    classification_threshold = 0.5              # output activation needed to assign to class

    return network_structure, weights, biases, classification_threshold
