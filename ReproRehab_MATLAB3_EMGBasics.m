%ReproRehab MATLAB #3 Electromyography signal processing basics

%In this tutorial, I will be using a dataset from:
%https://data.mendeley.com/datasets/f2fv7gb577/1
%Bipolar surface EMG signals and heel accelerations (1D) were recorded at
%2400 Hz from 71 individuals with and without a history of knee injury
%3-12 years prior during one minute of treadmill walking (4.5 km/h).
%EMG signals were obtained bilaterally from five muscles:
%Vastus lateralis (VL), biceps femoris (BF), medial hamstrings (MH),
%gastrocnemius lateralis (GL), gastrocnemius medialis (GM).
%Recordings from 61 individuals were used for further analysis.
%Raw EMG data and the time points (sample numbers) of heel strike for the
%right and left leg of each individual can be found in the .mat file 'Raw_Data'.
%(1-VL,2-BF,3-MH,4-GL,5-GM)
data = load('/Users/sumiresato/Documents/Matlab/ReproRehab/Data/Raw_Data.mat');

%% ALWAYS PLOT RAW DATA FIRST!
figure
%first subject, leg#1 (right), plot first 40,000 frames
plot(data.DATA_EXPORT_SORTED{1, 3}(:,1))
hold on
xlim([0,40000])


%% LOOP THROUGH EACH EMG CHANNEL AND FILTER

AFR = 2400;
ANyq = AFR/2;

subject_ids = cell2mat(data.DATA_EXPORT_SORTED(:,1));
% Find unique subject IDs
unique_subject_ids = unique(subject_ids);

%EMG labels for loop
EMG.Labels{1} = 'VL';
EMG.Labels{2} = 'BF';
EMG.Labels{3} = 'MH';
EMG.Labels{4} = 'GL';
EMG.Labels{5} = 'GM';

for s = 1 %loop through subjects
    %for s = 1:length(unique_subject_ids)
    
    thissubject = unique_subject_ids(s);
    %find subject index
    idx_subj = find(unique_subject_ids == thissubject);
    
    for l = 1 %loop through legs - in reality, this should loop both llegs 1:2
        
        EMG.Data = data.DATA_EXPORT_SORTED{idx_subj, 3};
        %column 3 are where EMGs are located
        
        
        for i = 1:5 %loop thrrough 5 EMG channels
            
            %fix nan data
            emgdata=EMG.Data(:,i);
            edata=(1:length(emgdata))';
            emgdata = interp1(edata(~isnan(emgdata)),emgdata(~isnan(emgdata)),edata);
            
            %covert EMG labels into character variable
            emgID = char(genvarname(EMG.Labels(i)));
            %assignEMG labeled to EMG
            dataEMG.(emgID) = emgdata;
            raw = dataEMG.(emgID);
            %demean the EMG
            demean = mean(raw);
            [A,B] = butter(3,45/ANyq,'high');
            highpass = filtfilt(A,B,raw-demean);
            rec = abs(highpass-mean(highpass)); %rectify
            %[A,B] = butter(3,35/ANyq,'low');
            %lowpass = filtfilt(A,B,rec);
            procEMG.(emgID) = rec(:);
        end
    end
    thissubjectStr = num2str(thissubject);
    save([thissubjectStr  '_procEMG'],'procEMG')
    %if you want to append to various data
    %save([thissubjectStr  '_procEMG'],'raw','-append')
end

%%

figure
plot(procEMG.VL)
xlim([0,40000])

%% looping through data and producing multiple of pages of figures
%loop through data to create one ps file per subject

for s = 1 %loop through subjects
    %for s = 1:length(unique_subject_ids)
    
    thissubject = unique_subject_ids(s);
    %find subject index
    idx_subj = find(unique_subject_ids == thissubject);
    
    for l = 1 %loop through legs - in reality, this should loop both llegs 1:2
        
        EMG.Data = data.DATA_EXPORT_SORTED{i, 3};
        %column 3 are where EMGs are located
        
        points_per_plot = 48000; %20s @ 2400Hz
        num_plots = floor(length(EMG.Data(:,1)) / points_per_plot);
        %assuming all channels have same data length
        
        for j = 1:num_plots % loops through the number of plots
            
            
            %for the start of the each plot
            start_index = (j-1) * points_per_plot + 1;
            %for the end of each plot
            end_index = start_index + points_per_plot - 1;
            
            figure
            plot(EMG.Data(start_index:end_index,1))
            hold on
            plot(EMG.Data(start_index:end_index,2)+1)
            plot(EMG.Data(start_index:end_index,3)+2)
            plot(EMG.Data(start_index:end_index,4)+3)
            plot(EMG.Data(start_index:end_index,5)+4)
            %add offset for each plot for visualization
            
            
            title(['Data Points from ', num2str(start_index), ' to ', num2str(end_index)]);
            xlabel('Index');
            ylabel('mV');
            
            
            h = gcf;
            set(h,'PaperPositionMode','auto','PaperOrientation','landscape','Position',[50 50 800 600]);
            
            %for each subject
            
            thissubjectStr = num2str(thissubject);
            print(h,'-dpsc2',[ thissubjectStr '_rawEMG'],'-append')
            
        end
        
        
    end
end


%% looping through data and producing multiple of pages of figures
% loop through subjects

for s = 1:3 %loop through subjects
    %for s = 1:length(unique_subject_ids)
    
    thissubject = unique_subject_ids(s);
    %find subject index
    idx_subj = find(unique_subject_ids == thissubject);
    
    for l = 1 %loop through legs - in reality, this should loop both llegs 1:2
        
        EMG.Data = data.DATA_EXPORT_SORTED{s, 3};
        %column 3 are where EMGs are located
        
        points_per_plot = 48000; %20s @ 2400Hz
        num_plots = floor(length(EMG.Data(:,1)) / points_per_plot);
        %assuming all channels have same data length
        
        figure
        tiledlayout(3,3) %assuming max number of plots is 6
        
        for j = 1:num_plots
            
            
            
            start_index = (j-1) * points_per_plot + 1;
            end_index = start_index + points_per_plot - 1;
            
            nexttile
            plot(EMG.Data(start_index:end_index,1))
            hold on
            plot(EMG.Data(start_index:end_index,2)+1)
            plot(EMG.Data(start_index:end_index,3)+2)
            plot(EMG.Data(start_index:end_index,4)+3)
            plot(EMG.Data(start_index:end_index,5)+4)
            
            
            title(['Data Points from ', num2str(start_index), ' to ', num2str(end_index)]);
            xlabel('Index');
            ylabel('mV');
            
            
            h = gcf;
            set(h,'PaperPositionMode','auto','PaperOrientation','landscape','Position',[50 50 800 600]);
            
            %for each subject
            
        end
        
        
    end
    
    print(h,'-dpsc2',['allsubj_rawEMG'],'-append')
end

