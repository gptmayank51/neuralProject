% This is the script that needs to be run on the data placed in "../DataSet" folder. It will pick the data from there 
% and finally generate "../MatFiles" folder in which where each of the patients feature vectors will be written in seperate mat files

% Put all your input data in a dataTest folder in the previous directory.
disp('=====================================');
disp('Generating Features from the data');
disp('=====================================');
% Generate feature vector for each patient in the Data_generator 
scriptTest
disp('=====================================');
disp('Generating Patients wise Complete matrices');
disp('=====================================');
data_generatorTest
% All final patient wise mat file will be generated in ../MatFiles folder
disp('=====================================');
disp('Running LibSVM on it');
disp('=====================================');
runEqual
% runMedian
