%ReproRehab MATLAB #5 Motion capture continued
%also group analysis figures
%linear regression plots
clear all

cd('/Users/sumiresato/Documents/Matlab/ReproRehab/Data/MotionCapture')
mocapdata = load('Mocapdata_001.mat');

%here I am able to directly load in my datafile because it is a mat file
%however, if you are working with .c3d data types  you will have to
%download a toolbox and add the toolbox to your path.
%toolbox that I recommend is here: https://github.com/mocaptoolbox/mocaptoolbox

%addpath
%addpath('/Users/sumiresato/Documents/Matlab/mocaptoolbox')
% Load motion capture data
%mocapData = mcread('02_01.c3d');
% Visualize the data
%mcanimate(mocapData);


%% on filters
%Butterworth filter: is a type of signal processing filter designed to have
% a frequency response that is as flat as possible in the passband. 
% Butterworth doesn’t have any 'ripples', making it ideal for motion
% analysis.

%order of filter; the rate at which the signal attenuates beyond the cutoff frequency
%video on filter order: https://www.youtube.com/watch?v=dmzikG1jZpU&ab_channel=AdamPanagos

%filters can be low-pass, high-pass, or bandwidth
%movement is typically lower in frequency, so i use low-pass filter
%EMG should NOT have movement artifacts. these can be filtered using
%high-pass of band-width (if you want to filter out higher frequency
%artifacts like electrical noise).
%% find heel-strike and toe-off in mocap using mocap


%plot data

%overlay L limb angle to R limb angle

figure
plot(mocapdata.jointAngle.LLimbAngleXZ, 'k')
hold on
plot(mocapdata.jointAngle.RLimbAngleXZ, 'r')
%
%%
%this is treadmill data; you can find approximate heel strike and toe-off
%by location of limb angles in saggital plane
%saves sample number of events
%must convert to time with sampling frequency rate
[peaks, Events.LTO] = findpeaks(mocapdata.jointAngle.LLimbAngleXZ, 'MinPeakProminence', 10);
[peaks, Events.RTO] = findpeaks(mocapdata.jointAngle.RLimbAngleXZ, 'MinPeakProminence', 10);

invert_LLimbAng = - mocapdata.jointAngle.LLimbAngleXZ;
invert_RLimbAng = - mocapdata.jointAngle.RLimbAngleXZ;


[peaks, Events.LHS] = findpeaks(invert_LLimbAng, 'MinPeakProminence', 10);
[peaks, Events.RHS] = findpeaks(invert_RLimbAng, 'MinPeakProminence', 10);


%%
figure

%tiled layout is a 'newer' way to configure subplots
tiledlayout(1,2)

nexttile
plot(mocapdata.jointAngle.LLimbAngleXZ, 'k')
hold on
plot(mocapdata.jointAngle.RLimbAngleXZ, 'r')
% Add vertical lines at each HS

xline(Events.LTO, '--b', 'LineWidth', 1.5);
xline(Events.LHS, 'b', 'LineWidth', 1.5);

nexttile
plot(mocapdata.jointAngle.LLimbAngleXZ, 'k')
hold on
plot(mocapdata.jointAngle.RLimbAngleXZ, 'r')
% Add vertical lines at each HS

xline(Events.RTO, '--m', 'LineWidth', 1.5);
xline(Events.RHS, 'm', 'LineWidth', 1.5);

%% if all looks correct, append the events data

save('Mocapdata_001.mat','Events','-append')


%% changing gears.... raincloud plots

%I will use the package here:
%https://www.mathworks.com/matlabcentral/fileexchange/136524-daviolinplot-beautiful-violin-and-raincloud-plots
%check out the demo.. you can do a a lot of different types

clear all

%unfortunately data is not shareable at this point
root='/Users/sumiresato/UFL Dropbox/Sumire Sato/Seidler Lab UF/DTI-ALPS Aging/Data/';
data = readtable(fullfile(root, 'DTIALPS_concatenated_24Apr11.csv'));
%data is organized in a way that there is one value in each row for each
%subject.
%there is a Group column that indicates which group subjects are in
%there is a YA = young adults
%OA-HF = Old adults high function
%OA-LF = Old adults low function

group_names = {'YA', 'OA-HF', 'OA-LF'};

% an alternative color scheme for some plots
%these are rgb triplets - modify as needed
c =  [0.45, 0.80, 0.69;...
    0.98, 0.40, 0.35;...
    0.55, 0.60, 0.79];

figure
%for full settings open daviolinplot
daviolinplot(data.avg_ALPS,'groups',data.Group,'outsymbol','k+',...
    'color',c,'scatter',2,'jitter',1,...
    'box',1,'boxcolors','same','scattercolors','same',...
    'boxspacing',1.1, 'xtlabels', group_names);
ylabel('ALPS-index');


set(gcf,'PaperPositionMode','auto','PaperOrientation','portrait','Position',[0 0 450 500])

%% simpler box plots

figure;
boxplot(data.avg_ALPS, data.Group);
xlabel('Groups');
ylabel('ALPS-index');
title('Boxplot for Three Groups');

%but there are different types and styles even in matlab default 'boxplot'
%function. look at help tool for different settings.

%% simple linear regression plots with confidence intervals

variable = 'avg_ALPS'; %set x
yvariable = 'gaitspeed_400m'; %sety

mdl = fitlm(data.(yvariable), data.(variable));
summary =  anova(mdl,'summary')
%%
figure
plot(mdl)

xlabel('ALPS-index')
ylabel('Walking speed')
title({['MODEL: F(' num2str(summary.DF('Model')) ',' num2str(summary.DF('Residual')),...
    ') = ', num2str(round(summary.F('Model'),2)), ', p = ' num2str(round(summary.pValue('Model'), 3))]});
set(gca,'FontSize',24)

%% plotting group interactions
% you would need to calculate best fit line seperately.


YC = find(data.Agegroup == 1);
OA = find(data.Agegroup == -1);

%make sure variable is set to categorical/factorical
data.Agegroup = categorical(data.Agegroup);
clc
%calculate model with age group interaction
mdl_interaction = fitlm(data, [yvariable '~' variable '* Agegroup']);
summary_interaction =  anova(mdl_interaction,'summary');

%%%%% Young controls model
x1 = data.(variable)(YC);
y1 = data.(yvariable)(YC);
idx = intersect(find(isnan(x1)==0), find(isnan(y1)==0));
ft1 = fit(x1(idx),y1(idx),'poly1');
%prediction interval
%pft = predint(ft1,sort(x1(idx)), 0.95,'observation','off');
idxy1 = isnan(y1);

mdl1 = fitlm(x1,y1);

%%%% older adults model
dat2.x2 = data.(variable)(OA);
dat2.y2 = data.(yvariable)(OA);
%subject ids and convert to string variable for labeling
dat2.subject_ids = data.subject_ids(OA);
labels2 = string(data.subject_ids(OA));
idx = intersect(find(isnan(dat2.x2)==0), find(isnan(dat2.y2)==0));
ft2 = fit(dat2.x2(idx),dat2.y2(idx),'poly1');
pft = predint(ft2,sort(dat2.x2(idx)), 0.95,'observation','off');
idxy2 = isnan(dat2.y2);

mdl2 = fitlm(dat2.x2,dat2.y2);

%%%%plot seperately

%SLR young
min1 = mdl1.Coefficients.Estimate(1) + mdl1.Coefficients.Estimate(2) * min(x1(~idxy1));
max1 = mdl1.Coefficients.Estimate(1) + mdl1.Coefficients.Estimate(2) * max(x1(~idxy1));
xslr1 = [min(x1(~idxy1)) max(x1(~idxy1))];
yslr1 = [min1 max1];

%SLR OA
min2 = mdl2.Coefficients.Estimate(1) + mdl2.Coefficients.Estimate(2) * min(dat2.x2(~idxy2));
max2 = mdl2.Coefficients.Estimate(1) + mdl2.Coefficients.Estimate(2) * max(dat2.x2(~idxy2));
xslr2 = [min(dat2.x2(~idxy2)) max(dat2.x2(~idxy2))];
yslr2 = [min2 max2];

figure
%plot young adults scatterplot
plot(x1, y1,'Color','k','LineStyle','none', 'Marker', 'x',...
    'MarkerSize', 10, 'HandleVisibility','off')
hold on
%plot best fit line for younger adults
plot(xslr1, yslr1,'Color','k')
%plot older adults scatterplot
plot(dat2.x2, dat2.y2,'Color','r','LineStyle','none', 'Marker', 'x',...
    'MarkerSize', 10, 'HandleVisibility','off')
%plot older adults best fit line
plot(xslr2, yslr2,'Color','r')
set(gca,'FontSize',12)

legend('Young', 'OA')

box off

xlabel('ALPS-index')
ylabel('Walking speed')
 title({['MODEL: F(' num2str(summary_interaction.DF('Model')) ',' ,...
    num2str(summary_interaction.DF('Residual')), ') = ',...
    num2str(round(summary_interaction.F('Model'),2)), ', p = ' num2str(round(summary_interaction.pValue('Model'), 3)),...
    '; Xvar.p-value = ' num2str(round(mdl_interaction.Coefficients.pValue(variable),3))]...
    ['Agegroup1.p-value = ' num2str(round(mdl_interaction.Coefficients.pValue('Agegroup_1'),3)),...
    '; Agegroup1.Estimate = ' num2str(round(mdl_interaction.Coefficients.Estimate('Agegroup_1'),3))]});
set(gca,'FontSize',18)

%if you want subjectID data to identify outliers
text(dat2.x2, dat2.y2, num2str(dat2.subject_ids), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

set(gcf,'PaperPositionMode','auto','PaperOrientation','landscape','Position',[0 0 1200 500])
