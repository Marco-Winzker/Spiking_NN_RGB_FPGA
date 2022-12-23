#
#   Author: Klaus Niederberger
#   Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 22.12.2022
#
# data-based normalization
# based on "Theory and Tools for the Conversion of Analog to Spiking Convolutional Neurlal Networks" by Rueckauer et al.

def data_normalization(max_activation):
    weight_factor = [1, 1]
    bias_factor = [1, 1]
    v_th = [1, 1]

    for i, value in enumerate(weight_factor):               # layer-wise adaption of weights
        weight_factor[i] = value * max_activation[i] / max_activation[i + 1]
    for i, value in enumerate(bias_factor):                 # layer-wise adaption of biases
        bias_factor[i] = value / max_activation[i + 1]

    return weight_factor, bias_factor, v_th
