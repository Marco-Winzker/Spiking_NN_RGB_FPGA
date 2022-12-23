# import libraries
import numpy as np              # numpy
import cv2                      # opencv

# import submodules
import neurons
import coding as code


# read png image and change order of channels to RGB
def read_img(image_name):
    original_img = cv2.imread(image_name)       # read png to array
    try:                                        # if input picture exists
        img = original_img[:, :, [2, 1, 0]]     # convert BGR to RGB (cv2 library reads channels in order BGR)
        img = img / 255                         # normalize input data to 0..1
    except TypeError:                           # if picture doesn't exist
        raise Warning(f"No input picture found with Name '{image_name}")

    return original_img, img                    # returns original img (BGR order), and img (RGB order) for processing


# process png img to numpy array and reshape
def process_img(img):
    img_height = 0
    img_width = 0
    process_input_array = []

    for line in img:                                        # for every line in img
        img_width = 0
        for pixel in line:                                  # for every pixel in line
            process_input_array.append(pixel)               # get RGB values of Pixel
            img_width += 1
        img_height += 1
    process_input_array = np.array(process_input_array)     # convert to numpy array

    return process_input_array, img_width, img_height       # input array shape: 3 x number_of_pixels, width, height


# create objects of class Neuron based on network structure
def create_neurons(structure, weights, biases, steps, v_th, net_type):
    neuron_array = []                                       # array in which the neuron objects will be saved
    neuron_number = 0                                       # counter to initialize/create the neuron objects

    for layer in range(1, len(structure)):                  # for every layer (except layer 0 which is input)
        for neuron in range(structure[layer]):              # for number of neurons in layer
            if net_type == 'SNN':                           # create SNN neurons
                neuron_array.append(neurons.IF_Neuron(layer, weights[neuron_number], biases[neuron_number], steps,
                                                      v_th[layer-1]))
            else:                                           # create ANN neurons
                neuron_array.append(neurons.Neuron(layer, weights[neuron_number], biases[neuron_number]))
            neuron_number += 1

    return neuron_array                                     # array of neuron objects


# calculate network
def calculate_network(network_structure, neuron_array, input_array, steps, net_type):
    output_array = []
    max_activation = [0] * len(network_structure)
    max_activation[0] = 1
    number_of_total_spikes = 0

    for i, pixel in enumerate(input_array):                             # for every pixel
        if (i+1)/len(input_array) * 100 % 1 == 0:                       # print status update
            print("\r", f"{int((i+1)/len(input_array)*100)}% done", end="")
        if net_type == 'SNN':                                           # if SNN
            reset_neurons(neuron_array)                                 # reset neurons
            input_spikes = code.create_input_spikes(pixel, steps)       # convert input to spikes
            calculate_pixel(network_structure, neuron_array, input_spikes, net_type)
        else:                                                           # if ANN
            temp_max_act = calculate_pixel(network_structure, neuron_array, pixel, net_type)
            for j, element in enumerate(temp_max_act):
                max_activation[j] = max(max_activation[j], element)
        temp_out = []                                                   # temporary array to store outputs
        for neuron in neuron_array:                                     # for every neuron
            if net_type == 'SNN':
                number_of_total_spikes += neuron.n_spikes
            if neuron.layer == (len(network_structure) - 1):            # if output neuron
                if net_type == 'SNN':
                    temp_out.append(neuron.n_spikes)                    # append number of spikes per output neuron
                else:
                    temp_out.append(neuron.output)                      # append value of output neuron
        output_array.append(temp_out)                                   # append to output values
    print("\r", f"", end="")
    output_array = np.array(output_array)                               # convert tu numpy array

    return output_array, max_activation                                 # output values, max_activation per layer


# call calculate process of Neuron Objects
def calculate_pixel(network_structure, neuron_array, input_elements, net_type):
    max_activation = [0] * len(network_structure)
    for layer in range(1, len(network_structure)):                      # for layer
        if layer == 1:                                                  # if input layer
            neuron_input_array = input_elements                         # get img values as input
        else:                                                           # otherwise, get outputs of previous layer
            neuron_input_array = []
            for neuron in neuron_array:
                if neuron.layer == layer-1:
                    if net_type == 'SNN':
                        neuron_input_array.append(neuron.spikes)        # spikes output
                    else:
                        neuron_input_array.append(neuron.output)
        for neuron in neuron_array:                                     # get all neurons of current layer and calculate
            if neuron.layer == layer:
                if net_type == 'SNN':
                    neuron.calculate(neuron_input_array)
                else:
                    neuron.calculate(neuron_input_array)
                    max_activation[layer] = max(max_activation[layer], neuron.output)
    return max_activation                                               # max activation per layer

#todo: modified here
# classify output values and create array to show output img
def create_output_img(spike_rate_array, width, output_activation):
    output_image_array = []                             # array to create output image
    inline_array = []                                   # contains the values of all pixels in a line
    pixel_in_line = 0                                   # counter for pixels in line

    spike_rate_array = np.array(spike_rate_array)       # convert list to numpy array

    for spike_rate in spike_rate_array:                  # for every pixel
        if spike_rate[0] >= output_activation:          # classify this output as sign 1 (blue sign)
            inline_array.append([255, 255, 255])        # make pixel white (sign 1)
        elif spike_rate[1] >= output_activation:        # classify this output as sign 2 (yellow sign)
            inline_array.append([127, 127, 127])        # make pixel grey (sign 2)
        else:                                           # classify as other
            inline_array.append([0, 0, 0])              # make pixel black (other)
        pixel_in_line += 1
        if pixel_in_line >= width:                      # end of line
            output_image_array.append(inline_array)     # add output line by line
            inline_array = []                           # empty inline array and start counting from 0 for new line
            pixel_in_line = 0

    output_image_array = np.array(output_image_array)           # convert to numpy array
    output_image_array = output_image_array.astype(np.uint8)    # convert to uint8 datatype which is necessary for cv2

    return output_image_array                           # output array of processed image to show image


# scale the weights and biases
def scale_model(structure, weights, biases, w_factor, b_factor, fp_convert):
    scaled_weights = []
    scaled_biases = []
    factor_counter = 0
    inlayer_counter = 0

    for weight in weights:
        if fp_convert:
            scaled_weights.append([round(i * w_factor[factor_counter]) for i in weight])
        else:
            scaled_weights.append([i * w_factor[factor_counter] for i in weight])
        inlayer_counter += 1
        if inlayer_counter >= structure[factor_counter + 1]:
            inlayer_counter = 0
            factor_counter += 1
    factor_counter = 0
    inlayer_counter = 0
    for bias in biases:
        if fp_convert:
            scaled_biases.append(round(bias*b_factor[factor_counter]))
        else:
            scaled_biases.append(bias * b_factor[factor_counter])
        inlayer_counter += 1
        if inlayer_counter >= structure[factor_counter + 1]:
            inlayer_counter = 0
            factor_counter += 1
    # print(f"Scaled Weights: {scaled_weights} Bias: {scaled_biases}")  # debug

    return scaled_weights, scaled_biases


# show images
def show_output(inp_img, ann_img, snn_img):
    cv2.imshow('Input', inp_img)            # show input img
    cv2.imshow('ANN', ann_img)              # show output img calculated with ANN
    cv2.imshow('SNN', snn_img)              # show output img calculated with SNN
    cv2.waitKey(0)                          # press any key to close


# reset neurons, used to evaluate new pixel with empty spike trace
def reset_neurons(neuron_array):
    for neuron in neuron_array:
        neuron.reset()


def write_to_file(weights, biases, v_th, output_activation, fp, steps, structure):

    # convert weights and biases for vhdl
    weights, biases = scale_model(structure, weights, biases, [fp, fp], [fp, fp], 1)

    threshold = [element * fp for element in v_th]

    with open('snn_model_parameters.csv', 'a') as csv_file:
        csv_file.write(f"Steps;Threshold per Layer;Number of Spikes for Activation;Weights;Biases;\n")
        csv_file.write(f"{steps};{threshold};{round(output_activation*steps)};{weights};{biases};")
