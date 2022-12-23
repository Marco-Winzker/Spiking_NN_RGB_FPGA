# import libraries
import numpy as np
import random


# create spike trace for R, G and B channel
def create_input_spikes(input_array, steps):
    input_spikes = np.zeros(shape=(3, steps))

    for i, rgb_value in enumerate(input_array):             # for every channel
        for step in range(steps):                           # for every step
            rnd = random.randrange(0, 255) / 255            # create rdm numbers between 0 and 1
            if rnd < rgb_value:                             # create spikes
                input_spikes[i][step] = 1

    return input_spikes


# get spike rate
def decode_output_spikes(spikes, steps):
    spike_ratio = np.array(spikes)/steps                    # spike_ratio = number_of_spikes/number_of_steps

    return spike_ratio
