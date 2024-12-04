%MATLAB 2
%variable types, conditionals, for-loops, ACTIVITY: Forest plot with for
%loops

% Clear the workspace and command window
clc;
clear;

% Define a number
num = 5;

% Display the number
fprintf('The number is: %d\n', num);

% Conditional statements
if num > 0
    disp('The number is positive.');
elseif num < 0
    disp('The number is negative.');
else
    disp('The number is zero.');
end



%% Part 2: For-Loops
%For-loops are used to repeat a block of code a specified number of times


%The "for" keyword starts the loop.
%i = 1:5" means the loop will run with i taking values from 1 to 5.
% Each iteration, the value of i is printed.



for i = 1:5
    fprintf('Current number: %d\n', i);
end

%% Part 3: Combining Conditionals and For-loops


% Define the range of numbers
start_num = 1;
end_num = 10;

% Loop through each number in the range
for num = start_num:end_num
    % Check if the number is even or odd
    if mod(num, 2) == 0
        fprintf('%d is even.\n', num);
    else
        fprintf('%d is odd.\n', num);
    end
end


%Range Definition: The script defines a range of numbers from start_num to end_num.
%For Loop: The for loop iterates through each number in the defined range.
%Conditionals: Inside the loop, the if statement checks if the number is even using the mod function. If the remainder when divided by 2 is zero,

%% ACTIVITY: Forest plot


% Example data
data.studies = {'Study 1', 'Study 2', 'Study 3', 'Study 4'}';
data.effect_sizes = [0.2, 0.5, -0.3, 0.1]';
data.lower_ci = [0.1, 0.3, -0.5, -0.1]';
data.upper_ci = [0.3, 0.7, -0.1, 0.3]';

% Convert the structure array to a table
T = struct2table(data);
errors = [T.effect_sizes - T.lower_ci, T.upper_ci - T.effect_sizes];
%errors is a 2-column variable


figure
hold on;
errorbar(T.effect_sizes, 1:length(T.effect_sizes), errors(:,1), errors(:,2), 'o');
%effect size = x
%y = index number (bottom to up)
% error bars lower and upper
set(gca, 'ytick', 1:length(T.studies), 'yticklabel', T.studies);
xlabel('Effect Size', 'Fontsize', 20);
ylabel('Study');
title('Forest Plot');
xlim([-0.5, 0.7])
grid on;
hold off;


%You can customize the plot further by adjusting the marker styles, colors,
%and adding more details like a vertical line for the overall effect size.

%% 
%but suppose you want in particular order, or you don't want all the
%dataset included, you can use for-loops!


figure
hold on;

%suppose you want to plot bottom-up Study3, Study 4, then Study 2
Studies2include = {'Study 3', 'Study 4', 'Study 2'};

% Loop through each study
for i = 1:length(Studies2include)
    
    % Find the index of the current study in the original studies array
    this_study = Studies2include{i};
    %create index telling where 'this study' is in T.studies
    idx = find(strcmp(T.studies, this_study));
    
    % Plot the effect size with error bars
    errorbar(T.effect_sizes(idx), i, errors(idx,1), errors(idx,2), 'o');
    %x = effect size
    %y = study (according to index)
    %length/size of error bar = lower, upper
    %marker is o
end


% Customize the plot
set(gca, 'ytick', 1:length(Studies2include), 'yticklabel', Studies2include);
xlabel('Effect Size');
ylabel('Study');
%plot first, then change the x-axis size
xlim([-0.5, 0.7])
%grid off