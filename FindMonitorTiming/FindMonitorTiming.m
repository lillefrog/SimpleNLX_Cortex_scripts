% This script is for analyzing the monitor delay the occur when displaying
% visual stimuli. It reads a LFP file recorded in neuralynx by connecting a
% photodiod to the monitor and channel1 on the neuralynx system. This
% timing is then compared to events in neuralynx event file. For the
% current program the stim on event is 50 and the stim off event is 51.
% 
% This script depends on my basic NLX functions
% Christian Brandt 04/06-2014

% Add my basic NLX functions to the search path
addpath(genpath('E:\doc\GitHub\NeuralynxAnalysis\'));



%% TFT monitor setup
FName = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\Events.Nev';
FName2 = 'C:\Dropbox\temp\TFT_2014-05-23_17-52-13\LFP1.ncs';
THRESHOLD = 1000; % threshold depends on the recording settings
timeBins = 27:0.4:62;
displayLimits = [40,65];
monitorName = 'TFT monitor';

%% CRT monitor setup
FName = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\Events.Nev';
FName2 = 'C:\Dropbox\temp\CRT_2014-05-23_17-37-02\LFP1.ncs';
THRESHOLD = 1000; % threshold depends on the recording settings
timeBins = 10:0.001:11;
displayLimits = [10.4,11];
monitorName = 'CRT monitor';

%% monitor setup 2
FName = 'E:\CRT Center 2014-06-04_18-35-38\Events.Nev';
FName2 = 'E:\CRT Center 2014-06-04_18-35-38\LFP1.ncs';
THRESHOLD = -500; % threshold depends on the recording settings
timeBins = 4.4:0.001:5.5;
displayLimits = [4.4,6];
monitorName = 'CRT monitor Center';

%% monitor setup 2
FName = 'E:\CRT Top Left 2014-06-04_18-42-38\Events.Nev';
FName2 = 'E:\CRT Top Left 2014-06-04_18-42-38\LFP1.ncs';
THRESHOLD = -500; % threshold depends on the recording settings
timeBins = 0.4:0.001:1.0;
displayLimits = [0.4,1.5];
monitorName = 'CRT monitor Top Left';

%% monitor setup 2
FName = 'E:\CRT Bottom Right 2014-06-04_18-47-30\Events.Nev';
FName2 = 'E:\CRT Bottom Right 2014-06-04_18-47-30\LFP1.ncs';
THRESHOLD = -500; % threshold depends on the recording settings
timeBins = 12.2:0.001:14;
displayLimits = [12.2,14];
monitorName = 'CRT monitor Bottom Right';

%% Read the files and extract the data
[AutomaticEvents,ManualEvents] = NLX_ReadEventFile(FName);

StartEvent = 255;
StopEvent = 254;

[dividedEventfile] = NLX_DivideEventfile(AutomaticEvents,StartEvent,StopEvent);

[SampleArray,SampleRate] = NLX_ReadCSCFile(FName2);

[dividedSampleArray] = NLX_DivideCSCArray(SampleArray,dividedEventfile);


%% Analyze time delay in monitor

STIM_ON = 50;
% initialize
delay = zeros( length(dividedEventfile) * 50 ,1 ); 
EventCount=1; 
% Loop trough all trials and all events in each trial
for TRIAL = 1:length(dividedEventfile)
  stimOnEvents = (dividedEventfile{TRIAL}(:,2) == STIM_ON);
  stimOnEventsTime = dividedEventfile{TRIAL}(stimOnEvents,1);
  sampleArray = dividedSampleArray{TRIAL};
  for EVENT = 1:length(stimOnEventsTime)
    startTime = stimOnEventsTime(EVENT);
    stopTime = startTime + 100000;
    withinTime = (sampleArray(:,1)>startTime) & (sampleArray(:,1)<stopTime);
    samplesOfInterest = sampleArray(withinTime,:);
    IsAboveTreshold = (samplesOfInterest(:,2)<THRESHOLD);
    index = find( IsAboveTreshold ,1, 'first' );
    CrossingTime = samplesOfInterest(index,1);
    delay(EventCount) = CrossingTime - startTime;
    EventCount = EventCount + 1;
  end
end

delay = delay(1:EventCount-1); % remove the values we over initialized
delayMs = delay/1000; % Original time is in yS 

%% display the delay data

disp(['Delay: ',num2str(mean(delayMs)),' ',setstr(177),num2str(std(delayMs))]);
disp(['Min delay ',num2str(min(delayMs)),' Max delay ',num2str(max(delayMs))]);

hist(delayMs,timeBins);

title(['Delay from on event to screen on ',monitorName],'fontsize',16);
xlabel('Delay in ms','fontsize',16);
ylabel('Number of occurrences','fontsize',16);
set(gca,'FontSize',14)
xlim(displayLimits);


%% display a part of the real data

i=3; % select a trial to plot

STIM_ON = 50;
figure % create a new figure to avoid overwriting the old one

startTime = min(dividedEventfile{i}(:,1));
plot(dividedSampleArray{i}(:,1)-startTime,dividedSampleArray{i}(:,2));
hold on
stimOnEvents = (dividedEventfile{i}(:,2) == STIM_ON);
plot(dividedEventfile{i}(stimOnEvents,1)-startTime,dividedEventfile{i}(stimOnEvents,2),'.k');
plot(dividedEventfile{i}(~stimOnEvents,1)-startTime,dividedEventfile{i}(~stimOnEvents,2),'.r');
xlim([1,1000000]);
xlabel('Time in ys','fontsize',16);
ylabel('Signal in yV','fontsize',16);
hold off


        
   


