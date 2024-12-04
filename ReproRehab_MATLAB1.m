%MATLAB #1
%James Finley Video 1: https://www.youtube.com/watch?v=5g-9rYCMgKg&t=1510s&ab_channel=ReproRehab

clear all

%Matrix laboratory
%Used for matrix manipulation, data visualization, creating and executing
%algorithms

%Make a Mathworks Account! https://www.mathworks.com/
%allows you to access mathworks content, download scripts

%% ENVIRONMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%James Finley Video 2: https://www.youtube.com/watch?v=LEMKyLuiuKw&list=PLV4PTzGI0GjXsLB__HYAsNhbcfk-lL70Z&index=2&ab_channel=ReproRehab

%Current Folder
%Workspace - stored variables and info
%Editor
%Command Window - execute script / see the outcome

% = comment

%Execute line:
Height=68;
%Will appear in command window
%In workspace you can see the value, and type of variable (change by
%settings)
% ; suppress lines

Height=68

%same variable name = overwrite!
%Matlab is case-sensitive
%IMPORTANT TO CLEAR ALL IN THE BEGINNING
Height= [72, 70, 68];
height= [72, 70, 68];

%you can easily store text data as well
x = 'Hello World';

x

%Current folder
%make sure that you are working in the correct folder with your MATLAB
%script and/or where you want to store data
%If you are working in a different folder from where your 'processing
%scripts' are located, you can add path

cd('/Users/sumiresato/Documents/Matlab/ReproRehab')

%check current working directory - can also check path above
cd
%add path! - this way you can run scripts from this 'path' while working in
%a different directory
addpath('/Users/sumiresato/Documents/Matlab/ReproRehab');
%check paths under 'Set Path' in Home tab

%clear everything in workspace
clc

Basic_Height

%test in another folder; because you already added to path, you will be
%able to run Basic_Height from different folder!

%loading data
clc
filename = '/Users/sumiresato/Documents/Matlab/ReproRehab/Data/36422-0001-Data.csv';
%file is a character variable
data = readtable(filename);
%open dataset

%basic plotting
%plot(x,y)
figure
x = data.AGE;
y = data.LOS;
plot(x, y,'Color','k','LineStyle','none', 'Marker', 'x',...
    'MarkerSize', 10)
xlabel('Age')
ylabel('Length of Stay')
box off

%see help documentation
help plot



%EXERCISE#1: Download Davioinplot and add to path
%Objectives: Make mathworks account, get familiar with environment, and
%add path!
%c https://www.mathworks.com/matlabcentral/fileexchange/136524-daviolinplot-beautiful-violin-and-raincloud-plots?s_tid=FX_rc1_behav
%BONUS: Run the demo

