% This script is for analyzing the monitor delay the occur when displaying
% visual stimuli. It reads a LFP file recorded in neuralynx by connecting a
% photodiod to the monitor and channel1 on the neuralynx system. This
% timing is then compared to events in neuralynx event file. For the
% current program the stim on event is 50 and the stim off event is 51.
% 
% This script depends on my basic NLX functions
% Christian Brandt 04/06-2014

% Add my basic NLX functions to the search path
addpath(genpath('H:\GitHub\NeuralynxAnalysis\'));



%% TFT monitor setup
FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';
FName2 = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\LFP1.ncs';
timeBins = 27:0.4:62;
displayLimits = [40,65];
monitorName = 'TFT monitor';

%% CRT monitor setup
FName = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\Events.Nev';
FName2 = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\LFP1.ncs';
timeBins = 10:0.001:11;
displayLimits = [10.4,11];
monitorName = 'CRT monitor';

%% Read the files and extract the data
[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);

StartEvent = 255;
StopEvent = 254;

[DividedEventfile] = NLX_DivideEventfile(AutomaticEvents,StartEvent,StopEvent);

[SampleArray,SampleRate] = NLX_CutCSCFile(FName2);

[dividedSampleArray] = NLX_divideCSCArray(SampleArray,DividedEventfile);


%% Analyze time delay in monitor

% initialize
delay = zeros( length(DividedEventfile) * 50 ,1 ); 
z=1;
% Loop trough all trials and all events in each trial
for TRIAL = 1:length(DividedEventfile)
  event50 = (DividedEventfile{TRIAL}(:,2) == 50);
  event50TimeStamps = DividedEventfile{TRIAL}(event50,1);
  sampleArray = dividedSampleArray{TRIAL};
  for EVENT = 1:length(event50TimeStamps)
    startTime = event50TimeStamps(EVENT);
    stopTime = startTime + 100000;
    withinTime = (sampleArray(:,1)>startTime) & (sampleArray(:,1)<stopTime);
    samplesOfInterest = sampleArray(withinTime,:);
    IsAboveTreshold = (samplesOfInterest(:,2)>10000);
    index = find( IsAboveTreshold ,1, 'first' );
    CrossingTime = samplesOfInterest(index,1);
    delay(z) = CrossingTime - startTime;
    z = z + 1;
  end
end

delay = delay(1:z-1); % remove the values we over initialized
delayMs = delay/1000; % Original time is in yS 

%% display the delay data

disp(['Delay: ',num2str(mean(delayMs)),' ',setstr(177),num2str(std(delayMs))]);
disp(['Min delay ',num2str(min(delayMs)),' Max delay ',num2str(max(delayMs))]);

hist(delayMs,timeBins);

title(['Delay from on event to screen on ',monitorName]);
xlabel('Delay in ms');
ylabel('Number of occurrences');
xlim(displayLimits);


%% display a part of the real data
splitCSCArray = dividedSampleArray;

figure
i=3;
startTime = min(DividedEventfile{i}(:,1));
plot(splitCSCArray{i}(:,1)-startTime,splitCSCArray{i}(:,2));
hold on
Event50 = (DividedEventfile{i}(:,2) == 50);
plot(DividedEventfile{i}(Event50,1)-startTime,DividedEventfile{i}(Event50,2),'.k');
plot(DividedEventfile{i}(~Event50,1)-startTime,DividedEventfile{i}(~Event50,2),'.r');
xlim([1,1000000]);
hold off


        
   


