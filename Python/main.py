#
#   Author: Klaus Niederberger
#   Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 22.12.2022
#
# this software creates SNN parameters based on an existing ANN with ReLU activation

# import submodules
import normalization as norm
import functions as fct
import ann_model as model
import coding as code


# Settings
steps = 64                          # number of steps to evaluate every pixel for
img_name = 'combi_snap.png'         # name of image (needs to be in the same folder as the project)
fp_factor = 2**8                    # factor to convert fixed point variables for vhdl

print("Start Program")

# read input image
original_img, img = fct.read_img(img_name)

# process input
input_array, width, height = fct.process_img(img)

# initialize network based on ANN
network_structure, ann_weights, ann_biases, class_th = model.load_model()

# create ANN network
ann_neuron_array = fct.create_neurons(network_structure, ann_weights, ann_biases, 0, 0, 'ANN')

# calculate ANN
print("Calculating ANN...")
output_array, max_activation = fct.calculate_network(network_structure, ann_neuron_array, input_array, 0, 'ANN')

# create output img of ANN
output_img = fct.create_output_img(output_array, width, class_th)

# data based normalization
weight_factor, bias_factor, v_th = norm.data_normalization(max_activation)

# scale weights and biases according to normalization procedure
snn_weights, snn_biases = fct.scale_model(network_structure, ann_weights, ann_biases, weight_factor, bias_factor, 0)

# create SNN network
snn_neuron_array = fct.create_neurons(network_structure, snn_weights, snn_biases, steps, [1, 1], 'SNN')

# calculate SNN
print("Calculating SNN...")
output_spikes, not_used = fct.calculate_network(network_structure, snn_neuron_array, input_array, steps, 'SNN')

# decode spikes of output neurons
spike_ratio = code.decode_output_spikes(output_spikes, steps)

# create output img of SNN
sp_output_img = fct.create_output_img(spike_ratio, width, class_th/max_activation[-1])

# write to file
fct.write_to_file(snn_weights, snn_biases, v_th, class_th/max_activation[-1], fp_factor, steps, network_structure)

# show images
fct.show_output(original_img, output_img, sp_output_img)
