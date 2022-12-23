%==========================================================================
%
%   Author: Thomas Florkowski 
%   Version: 10.08.2020
%
%   Modified by: Klaus Niederberger
%   Line: 38        Activation Function changed from Sigmoid to ReLU
%
%==========================================================================
%NETWORKPREDICTION Calculates the output of a neural network to a given
%input.
%   Y = NETWORKPREDICTION(X,network) Calculates response of the given
%   network for X.
%

function[prediction] = networkPrediction(X, network)

 %number of weight matrices and layers
    numberOfThetas = length(network);
    numberOfLayers = numberOfThetas +1;
    
    %matrices for the Output of each Layer
    
    layer=cell(1,numberOfLayers);
    
    
    layer{1} = X';
    %Add offset to the layers 
    layer{1}=[layer{1}; ones(1,size(layer{1},2))];
    
   
    %forward propagation to calculate output using sigmoid function
    for j=1:numberOfThetas
        %By the forward calculation the offset neuron gets inserted
        %into the activation function. This needs to be reveresed befor
        %the next layer if calculated
        layer{j}(end,:)=1;
        layer{j+1} = relu(network{j} * layer{j});
    end
    
    prediction = layer{numberOfLayers};

end