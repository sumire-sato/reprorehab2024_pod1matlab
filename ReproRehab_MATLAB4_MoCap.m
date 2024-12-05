%ReproRehab MATLAB #4 Motion capture
clear all

cd('/Users/sumiresato/Documents/MATLAB/ReproRehab/Data/MotionCapture')
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

%% Looking at data
%data = 100 Hz for 30 s = 3000 samples
%data.trajectories contain mocap data
%4 columnns
%x-y-z-error
%this contains 30 s of walking data from a treadmill at 0.5 m/s

%%


Trajectory = mocapdata.data.Trajectories.Labeled;
%number of markers
n = Trajectory.Count;

for i = 1:n %loop through markers
    
    %filter
    KFR = 100; %sampling rate for mocap
    Knq = KFR/2; %nyquist

  for j = 1:3
    
    yk(:,1) = Trajectory.Data(i,j,:);
    
    %preferably fill in all nan values in mocap software.
    %if not, fill in before filtering
    interpolateddata = fillmissing(yk, 'spline');
    %rawinterpolated(i,j,:) = interpolateddata;
    
    %if you need to filter
    %change the filter threshold based on your joint of interest
    [Ak,Bk] = butter(3,8/Knq,'low'); 
    lowpassm(i,j,:) = filtfilt(Ak,Bk,interpolateddata);
    
   
  end
    
    %if using filtered data
    Marker = genvarname(Trajectory.Labels{i});
    data3D.([Marker 'X'])(:,1) = lowpassm(i,1,:);
    data3D.([Marker 'Y'])(:,1) = lowpassm(i,2,:);
    data3D.([Marker 'Z'])(:,1) = lowpassm(i,3,:);
    
    %Marker = genvarname(Trajectory.Labels{i});
    %data3D.([Marker 'X'])(:,1) = rawinterpolated(i,1,:);
    %data3D.([Marker 'Y'])(:,1) = rawinterpolated(i,2,:);
    %data3D.([Marker 'Z'])(:,1) = rawinterpolated(i,3,:);
    
end

%% calculate joint angles
%based on euler angles

LMT     = [data3D.LTOEX      data3D.LTOEY     data3D.LTOEZ];
LAnkle  = [data3D.LANKLEX     data3D.LANKLEY	data3D.LANKLEZ];
LKnee   = [data3D.LKNEEX     data3D.LKNEEY    data3D.LKNEEZ];
LHip    = [data3D.LHIPX      data3D.LHIPY     data3D.LHIPZ];
LPelvis = [data3D.LASISX     data3D.LASISY    data3D.LASISZ];
RMT     = [data3D.RTOEX     data3D.RTOEY	data3D.RTOEZ];
RAnkle  = [data3D.RANKLEX   data3D.RANKLEY	data3D.RANKLEZ];
RKnee   = [data3D.RKNEEX    data3D.RKNEEY	data3D.RKNEEZ];
RHip    = [data3D.RHIPX     data3D.RHIPY	data3D.RHIPZ];
RPelvis = [data3D.RASISX    data3D.RASISY	data3D.RASISZ];

%ankle
a = RMT - RAnkle;
b = RKnee - RAnkle;
a_norm = sqrt(a(:,1).^2 + a(:,2).^2 + a(:,3).^2);
b_norm = sqrt(b(:,1).^2 + b(:,2).^2 + b(:,3).^2);
jointAngle.RAnkleAngle = 110 - acos(dot(a,b,2)./(a_norm.*b_norm))*180/pi;


%knee
a = RAnkle - RKnee;
b = RHip - RKnee;
a_norm = sqrt(a(:,1).^2 + a(:,2).^2 + a(:,3).^2);
b_norm = sqrt(b(:,1).^2 + b(:,2).^2 + b(:,3).^2);
jointAngle.RKneeAngle = 180 - acos(dot(a,b,2)./(a_norm.*b_norm))*180/pi;


%hip (sagittal)
a = RHip - RKnee;
jointAngle.RHipAngleXZ = atan2(a(:,1),a(:,3))*180/pi;
jointAngle.RHipAngle = -atan2(a(:,2),a(:,3))*180/pi; %sagittal
%limb angle
a = RHip - RMT;
jointAngle.RLimbAngleXZ = atan2(a(:,1),a(:,3))*180/pi;
jointAngle.RLimbAngle = -atan2(a(:,2),a(:,3))*180/pi; %sagittal

%ankle
a = LMT - LAnkle;
b = LKnee - LAnkle;
a_norm = sqrt(a(:,1).^2 + a(:,2).^2 + a(:,3).^2);
b_norm = sqrt(b(:,1).^2 + b(:,2).^2 + b(:,3).^2);
jointAngle.LAnkleAngle = 110 - acos(dot(a,b,2)./(a_norm.*b_norm))*180/pi;


%knee
a = LAnkle - LKnee;
b = LHip - LKnee;
a_norm = sqrt(a(:,1).^2 + a(:,2).^2 + a(:,3).^2);
b_norm = sqrt(b(:,1).^2 + b(:,2).^2 + b(:,3).^2);
jointAngle.LKneeAngle = 180 - acos(dot(a,b,2)./(a_norm.*b_norm))*180/pi;

%hip (sagittal)
a = LHip - LKnee;
jointAngle.LHipAngleXZ = atan2(a(:,1),a(:,3))*180/pi;
jointAngle.LHipAngle = -atan2(a(:,2),a(:,3))*180/pi; %sagittal

%limb (sagittal)
a = LHip - LMT;
jointAngle.LLimbAngleXZ = atan2(a(:,1),a(:,3))*180/pi;
jointAngle.LLimbAngle = -atan2(a(:,2),a(:,3))*180/pi; %sagittal
%}

save('Mocapdata_001.mat','jointAngle','-append')

%% plot data

%overlay L limb angle to R limb angle

figure
plot(jointAngle.LLimbAngleXZ, 'k')
hold on
plot(jointAngle.RLimbAngleXZ, 'r')


%% changing gears.... raincloud plots

%I will use the package here: 
%https://www.mathworks.com/matlabcentral/fileexchange/136524-daviolinplot-beautiful-violin-and-raincloud-plots
%check out the demo.. you can do a a lot of different types

clear all

%unfortunately data is not shareable at this point
root='/Users/sumiresato/UFL Dropbox/Sumire Sato/Seidler Lab UF/DTI-ALPS Aging/Data/';
dat1 = readtable(fullfile(root, 'DTIALPS_concatenated_24Apr11.csv'));
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
daviolinplot(dat1.avg_ALPS,'groups',dat1.Group,'outsymbol','k+',...
    'color',c,'scatter',2,'jitter',1,...
    'box',1,'boxcolors','same','scattercolors','same',...
    'boxspacing',1.1, 'xtlabels', group_names);
ylabel('ALPS-index');


set(gcf,'PaperPositionMode','auto','PaperOrientation','portrait','Position',[0 0 450 500])




