%%% This script combines synchronized analog data files with task data and
%%% processes the task data into a usable form (i.e., smooths/interpolates
%%% kinematics, extracts trial labels, etc.). It then adds neural activity
%%% timestamp matrices to the trials as well.
%%%
%%% Adam Smoulder, 10/27/22

dbstop if error

% Edit folder/filenames and file tags (what they start with) here
spikeAndAnalogDataFileList = {...
    'F:\~~~RockyData\BORTRig\~alignedSpikeAndAnalogData_synchDrops\Rocky_synchedSpikeAndAnalogData_noSPM_20220302.mat';
    };
taskDataFolderList = {...
    'F:\~~~RockyData\BORTRig\TaskData\20220216to20220303_chokingReachingExperimentsAndChoice\centerOutData_20220302_153642\';
    };
workingFolder = [pwd '\']; % This is where the functions and classes needed are, at least beneath it
outputFolder = ['C:\Users\xzhou\Documents\GitHub\preprocessingCode\data\processed_partial\'] ; % where to save files

% Things that shouldn't change over days
trialDataTag = 'Trial0'; % what each trial data file starts with
rewardNames = {'Small','Medium','Large','Jackpot'}; % Searches target names for these

% Quickly check to make sure numbers of files all line up
nfiles = length(spikeAndAnalogDataFileList);
assert(length(taskDataFolderList)==nfiles);

% Go to working folder
cd(workingFolder) 

% % Adam uses this to remove paths to other stuff
% rmpath(genpath('D:\AdamMatlab'))
% addpath(genpath(pwd))


%% For each day, preprocess the data and save a file

for f = 1:nfiles
    dateString = taskDataFolderList{f}(end-15:end-1) % show it for confirmation
    load([taskDataFolderList{f} 'taskInfo.mat'])
    
    % Set up file name
    procTimeString = datestr(now,'yyyymmdd_HHMMSS');
    saveFilenameBase = ['Rocky' ...
        taskDataFolderList{f}(end-15:end-8) ...
        '_Trials' num2str(trialData(1).trial) ...
        '_' num2str(trialData(end).trial) '_behaviorAndSpikesInitialProcessed_' ...
        ];
    
    % Do an initial processing of the behavior
    load(spikeAndAnalogDataFileList{f})
    [trialData,taskInfo,kinematicData] = pp_preprocessTaskAndKinematicData(taskDataFolderList{f},rewardNames,synchInfo);
    save([outputFolder saveFilenameBase 'TSK_' procTimeString],'trialData')
    save([outputFolder saveFilenameBase 'KIN_' procTimeString],'kinematicData')
    
    % Attach spikes to trialData
    [trialData,taskInfo,neuralData] = pp_spikeAlignmentToTrial(taskAlignedSpiketimes,synchInfo,trialData,taskInfo);
    save([outputFolder saveFilenameBase 'NER_' procTimeString],'neuralData')
    
    % Preprocess EMG and ECG data
    
    % Preprocess eye data
    
    % Assess various data streams for behavioral metrics (i.e., peak speed,
    % saccade reaction time, average heart rate, etc.)
    
    
    
%     % Save!
%     saveFilename = ['Rocky' ...
%         taskDataFolderList{f}(end-15:end-8) ...
%         '_Trials' num2str(trialData(1).trial) ...
%         '_' num2str(trialData(end).trial) '_behaviorAndSpikesInitialProcessed_' ...
%         datestr(now,'yyyymmdd_HHMMSS')];
%     save([outputFolder saveFilename],'trialData','taskInfo','analogData','synchInfo','taskAlignedSpiketimes')
    
%     % If these files get too big, split up into smaller files
%     disp('Saving in sections of 500 trials')
%     allData = data; clear data
%     nsections = ceil(length(allData)/500);
%     for s = 1:nsections
%         if s == nsections
%             data = allData((s-1)*500+1:end);
%         else
%             data = allData((s-1)*500+1:s*500);
%         end
%         saveFilename = [data(1).Overview.subjectName taskName ...
%         num2str(floor(data(1).Overview.date/1E6)) ...
%         '_Trials' data(1).Overview.trialNumber(6:end) ...
%         '_' data(end).Overview.trialNumber(6:end) '_behaviorAndSpikesInitialProcessed_' ...
%         grabDateTimeString]
%         save([saveFolder saveFilename],'data','taskInfo')
%         clear data
%     end; clear s
    
%     disp('Saved!')
    disp(['Completed preprocessing for file ' num2str(f) ' of ' num2str(nfiles)])
    
%     clear trialData analogData synchInfo taskAlignedSpiketimes taskInfo
end; clear f





