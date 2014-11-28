% Put all your input data in a dataTest folder in the previous directory.
disp('=====================================');
disp('Generating Features from the data');
disp('=====================================');
scriptTest
disp('=====================================');
disp('Generating Patients wise Complete matrices');
disp('=====================================');
data_generatorTest
% All final patient wise mat file will be generated in ../MatFiles folder
disp('=====================================');
disp('Running LibSVM on it');
disp('=====================================');
run
% runEqual
% runMedian