%==========================================================================
%
%   Author: Klaus Niederberger
%   Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 22.12.2022
%
%   Adapted from:
%   Author: Thomas Florkowski
%   Version: 10.08.2020 - (10.2.2021: corrected typo in line 124)
%   Release: Marco Winzker, Hochschule Bonn-Rhein-Sieg, 17.09.2020
%
%   Changes: Activation Function changed from Sigmoid to ReLU 
%            in networkPrediction.m (Line 38) and trainNetwork.m (Line 90).
%            Additionally relu.m was added.  
%
%==========================================================================

%===============================Description================================
%
%   This script trains a network to categorize pixels into three categories.
%   They are named "color_1", "color_2" and "other".
%   The network has only two output neurons but three categories.
%   If the output of a neuron is bigger or equal 0.5 the pixel belongs to that
%   category.
%   If the output of both neurons is less than 0.5 the pixel belongs to the
%   category "other".
%                                          
%   By default all white pixels in the label picture belong to the
%   category "color_1".
%   In the second channel of the label picture they have the value 255.
%   The grey pixel belong to the category "color_2".
%   In the second channel of the label picture they have the value 127.
%   All other pixel belong to the category "other".
%
%   For the training process you need two images.
%   One with which you want to train and a second image that contains the
%   labels (expected output).
%   Each pixel with its corresponding label is a sample for training.
%   This means if you train your network with a picture that has 1280*720
%   pixel your dataset for training has 921600 samples.
%
%   If you want to use different pictures or categories you need to change the
%   script.
%   For the training process you need enough pixels in your categories for
%   training (you maybe need to try to find the right amount).
%
%==========================================================================

clear; clc; close all;

fprintf('Starting Script \n')

%=============== Constants Definition =================

epochs = 250;   %Number of epochs you want to train the network
alpha = 0.00000165;%Learning rate for the training process

width=1280; %Width of the picture you are working with
height=720; %Heigth of the picture you are working with


color2=[127;127;127];   %Output color for the category "color_2"
color1=[255;255;255];   %Output color for the category "color_1"
color0=[0;0;0];         %Output color for the category "other"

% use always the same random numbers for reproducibility
rand ("seed", 123456);

%=============== Prepare Input Data =================
fprintf('Reading and Preparing Training Data \n')


%Picture you want to use for training
inputPicture = imread('combi_snap.png');
%Image with the labels corresponding to your inputPicture
labelPicture = imread('combi_label.png');

%Uncomment the following lines if you want to see your loaded pictures before training
% imshow(inputPicture);
% figure();
% imshow(labelPicture);


%Prepare the data for the training
inputPicture = cast(inputPicture,'double'); %Need to be casted from uint to double

%Create a matrix with the dimensions of the picture for the later label
%vector
%Instead of 0 fill the matrix with 0.01 because the sigmoid function will
%never reach 0
labels = zeros(height,width,2) + 0.01;


%In the second channel of the labelPicture all pixel with a value of 255 (white pixel in the picture)
%belongs to the category "color_1"
%Where the value is 255 insert 0.99 in den labels matrix
%0.99 because the sigmoid function never reaches 1
temp = zeros(height,width) + 0.01;
temp(labelPicture(:,:,2)==255)=0.99;
labels(:,:,1)=temp;

%In the first channel of the labelPicture all pixel with a value of 127 (grey pixel in the picture)
%belongs to the category "color_2"
temp = zeros(height,width) + 0.01;
temp(labelPicture(:,:,1)==127)=0.99;
labels(:,:,2)=temp;


%Reshape the pictures to tables for the training process
labels = reshape(labels,[],2);   % Two columns (because of two output neurons)
inputPicture = reshape(inputPicture,[],3); %Three columns (because three neurons in the input layer)

%Print out debugging statistics
numCategoryOne=(sum(labels(:,1)==0.99)*100)/(width*height);
numCategoryTwo=(sum(labels(:,2)==0.99)*100)/(width*height);
fprintf('Statistics:\n');
fprintf(' - Category 1: %2.2f %%\n',numCategoryOne);
fprintf(' - Category 2: %2.2f %%\n',numCategoryTwo);
fprintf(' - Background: %2.2f %%\n',100-numCategoryOne-numCategoryTwo);

% Scale the input from [0;255] to [0;1] because of the sigmoid function
% Only for input values between [-4;4] the sigmoid function shows significant
% differences in the output
inputPicture = inputPicture/255;

%=============== Generate Network =================
fprintf('Generate Network \n')

%Define the network structure as a vector
%[3 3 1] means for example:
%   - Input layer has three neurons
%   - One hidden layer with three neurons
%   - The output layer has one neuron
%[3 5 6 2] means for example:
%   - Input layer has three neurons
%   - Two hidden layer, the first has five neurons and the second six neurons
%   - The output layer has two neurons

networkStructure = [3 7 2];

%Create the Network
network = generateNetwork(networkStructure);

%=============== Training =================
fprintf('Start Training \n')

%Train the network.
%The small alpha is required to get a working results.
%Bigger alpha work only with fewer pixels per pictures
[trainedNetwork,costLog,accuracyLog]=trainNetwork(inputPicture,labels,network,'epochs',epochs, 'alpha',alpha);

%Accuracy log does not work if the number of output neurons != number of categories
%figure();
%plot(accuracyLog);

%Plot the cost log from training
figCostLog=figure();
plot(costLog);
ylabel('loss');
xlabel('epochs');

fprintf('Training Done\n')

%=============== Prediction =================
fprintf('Using Trained Network for Test Prediction\n')

%Use the trained network on the inputPicture to see results
predOutput = networkPrediction(inputPicture, trainedNetwork);
%Round the values to get a 0 or 1
predOutput = round(predOutput');
%reshape predOutput to the dimensions of a picture
predOutput = reshape(predOutput,height,width,2);

%Create empty picture for the final result
predictionPicture = zeros(height,width,3);

%Add colors to the predictionPicture based on the results of the network
for i=1:height
    for j=1:width
        if(predOutput(i,j,2)==1)
            predictionPicture(i,j,:)=color2;
        elseif (predOutput(i,j,1)==1)
            predictionPicture(i,j,:)=color1;
        else
            predictionPicture(i,j,:)=color0;
        end
    end
end

%Cast back from double to unit
predictionPicture = cast(predictionPicture,'uint8');

figure();
imshow(predictionPicture);

%=============== Generate Results =================
fprintf('Results \n')

%Remove the last line from the first matrix because that would be weights for
%connections that go to the bias in the hidden layer.
%These weights are not needed for the VHDL implementation.
nnParams = trainedNetwork;
nnParams{1} = nnParams{1}(1:end-1,:); %Ignore Last Column

fprintf('\nWeight Matrix from the Input to the Hidden Layer\n')
disp(nnParams{1});
fprintf('Weight Matrix from the Hidden to the Output Layer\n')
disp(nnParams{2});

save('NN_RGB_3_Categories_config.mat','trainedNetwork','networkStructure','nnParams');
%saveas(figCostLog,'NN_RGB_3_Categories_Cost_Log.png','png');
%imwrite(predictionPicture,'NN_RGB_3_Categories_Predicted_Picture','png');


fprintf('\nFinished Script\n')
