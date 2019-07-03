function varargout = Accel_plotter(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Accel_plotter_OpeningFcn, ...
                   'gui_OutputFcn',  @Accel_plotter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Accel_plotter_OpeningFcn(hObject, eventdata, handles, varargin)
global SampleRates;
global DevNameStr;
global Chan_IDs;
global MeasTypes;
global HeadText;
global ChannelProps;
global time;
global ChanIDData;
global DevNameData;
global ChannelName;
global data;
global s;
global windows;

ChannelProps = [];
time = [];
data = [];
ChanIDData = [];
DevNameData = [];
ChannelName = {};

s = daq.createSession('ni');
devices = daq.getDevices;
MeasTypes = devices(1,2).Subsystems.MeasurementTypesAvailable';
set(handles.Meas_Type,'String',MeasTypes);
DevNameStr = char(devices.ID);
set(handles.DeviceName,'String',DevNameStr);
SampleRates = zeros(31,1);
MasterClock = 13107200;
SampleRates(:,1)= MasterClock/256./(1:31);
set(handles.SampleRate,'String',num2str(SampleRates));
ChannelNameDisp{1} = 'Ch Name';
set(handles.RemoveCount, 'String', ChannelNameDisp);
Chan_IDs = devices(1,2).Subsystems.ChannelNames;
set(handles.Chan_ID,'String',Chan_IDs);
HeadText = get(handles.HeaderText,'String');
windows = {'0.5', '1', '1.5', '2', '2.5', '3', '5'};
set(handles.triggerWindow, 'String', windows);

% Choose default command line output for Accel_plotter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = Accel_plotter_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function DeviceName_Callback(hObject, eventdata, handles)

function DeviceName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Acq_Callback(hObject, eventdata, handles)
global SampleRates;
global time;
global data;
global s;
global ChannelProps;
global collection_complete;
global duration;
global data_buffer;
global t0;
global test;
global time_buffer;
global triggerWindow
global useTrigger
global test1;
collection_complete = 0;
test1 = {};

if ~useTrigger
    t0 = tic;
else
    t0 = 0;
end
time = [];
data = [];


s.Rate = SampleRates(get(handles.SampleRate,'Value'));
data_buffer = zeros([s.Rate * triggerWindow, length(ChannelProps)]);
time_buffer = ones([s.Rate * triggerWindow, 1]) * -1;
s.IsContinuous = 1;

% s.DurationInSeconds = str2double(get(handles.Acq_duration,'String'));
duration = str2double(get(handles.Acq_duration,'String'));
lh = addlistener(s, 'DataAvailable', @waitForVib);
[signal, signal_f] = Chirp_tool(0);
startBackground(s);
soundsc(signal, signal_f);
% [data, time, ~] = startForeground(s);

while ~collection_complete
    pause(0.1)
end
stop(s);
parse_data(time, data, handles);

function SampleRate_Callback(hObject, eventdata, handles)

function SampleRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Acq_duration_Callback(hObject, eventdata, handles)

function Acq_duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeaderText_Callback(hObject, eventdata, handles)

function HeaderText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WriteData_Callback(hObject, eventdata, handles)
global time;
global data;
global ChannelProps;

[outfilename,outputpath] = uiputfile('raw_vibe_data.txt','Save data to file name');
fid = fopen(strcat(outputpath,outfilename),'wt');
frewind(fid);
HeadText = get(handles.HeaderText,'String');
for j=1:length(HeadText)
        fprintf(fid,'%s\n',HeadText{j});
end

DataHeaders = 'Time';
for jj=1:length(ChannelProps)
    DataHeaders = [DataHeaders, ' ', ChannelProps(jj).ChName];
end

fprintf(fid,'%s \n',DataHeaders);
out_vals = [time, data];
size(out_vals)
out_vals(3,:)
for k=1:length(time)
    fprintf(fid,' %e',out_vals(k,:));
    fprintf(fid,'\r\n');
end
fclose(fid);

function ACcoupled_Callback(hObject, eventdata, handles)

function Meas_Type_Callback(hObject, eventdata, handles)

function Chan_ID_Callback(hObject, eventdata, handles)

function Chan_ID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExCurr_Callback(hObject, eventdata, handles)

function ExCurr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AddChans_Callback(hObject, eventdata, handles)
global ChannelProps;
global s;
global DevNameStr;
global MeasTypes;
global HeadText;
global ChanIDData;
global ChannelName;
global DevNameData;

flag = 0;
devName = [DevNameData get(handles.DeviceName,'Value')];
chID = [ChanIDData get(handles.Chan_ID,'Value')-1];
channelName = [ChannelName get(handles.Ch_name, 'String')];
channelName = string(channelName);
DevConfig = [devName; chID];
for i = 1:length(chID)-1
    if DevConfig(:,i) == DevConfig(:,end)
        if strcmp(channelName(i), channelName(end)) == 0
            errordlg('Same channel cannot be add more than once', 'Channel Configuration Error');
            flag = 1;
            break;
        end
    end
end
if get(handles.Meas_Type, 'Value') == 2 && isempty(get(handles.Acc_Sens, 'String'))
    errordlg('Please enter a value for sensitivity multiplier','Sensitivity Multiplier Error');
    flag = 1;
end
if isempty(get(handles.TrueSens,'String'))
    errordlg('Please enter a value for sensitivity', 'Sensitivity Error');
    flag = 1;
end

if flag == 0
    DevNameData = [DevNameData get(handles.DeviceName,'Value')];
    ChanIDData = [ChanIDData get(handles.Chan_ID,'Value')-1];
    ChannelName{end+1} = get(handles.Ch_name, 'String');
    ChannelNameDisp = string(ChannelName);
    if length(ChannelNameDisp) ~= length(unique(ChannelNameDisp))
        for i = 1:length(ChannelNameDisp)
            if strcmp(ChannelNameDisp(:, i), ChannelNameDisp(:, end))
                removeChannel(s,i);
                HeadText(i+5,:) = [];
                set(handles.HeaderText,'String',HeadText);
                ChannelProps(i) = [];
                ChanIDData(i) = [];
                DevNameData(i) = [];
                break;
            end
        end
    end
    
    ChannelProps(end+1).ChName = get(handles.Ch_name,'String');
    ChannelProps(end).DevName = DevNameStr((get(handles.DeviceName,'Value')),:);
    ChannelProps(end).ChanID = get(handles.Chan_ID,'Value')-1;
    ChannelProps(end).MeasType = MeasTypes(get(handles.Meas_Type,'Value'));
    ChannelProps(end).PlotTime = get(handles.PlotTime,'Value');
    ChannelProps(end).PlotPSD = get(handles.PlotPSD,'Value');
    ChannelProps(end).PlotRC = get(handles.PlotRC,'Value');
    ChannelProps(end).TrueSens = str2double(get(handles.TrueSens,'String'));
    HeadText = get(handles.HeaderText,'String');
    ChanText = strcat('Ch:',ChannelProps(end).ChName,{' '},ChannelProps(end).DevName,{' ai'},num2str(ChannelProps(end).ChanID),{' '},ChannelProps(end).MeasType);
    if get(handles.Meas_Type,'Value') == 4 && (isempty(get(handles.ExCurr,'String')) || str2num(get(handles.ExCurr,'String')) > 0.01 || str2num(get(handles.ExCurr,'String')) < 0.002)
        set(handles.ExCurr,'String', '0.002')
    end
    if strcmp(ChannelProps(end).MeasType, 'IEPE')
        set(handles.ACcoupled,'Value',1);
        ChannelProps(end).ExCurr = str2double(get(handles.ExCurr,'String'));
        ChanText = strcat(ChanText, {' ExCurr:'}, num2str(ChannelProps(end).ExCurr));
    elseif (get(handles.ACcoupled,'Value') == 1)
        ChannelProps(end).Coupling = 'AC';
        ChanText = strcat(ChanText, {' '}, 'AC');
    end
    
    addAnalogInputChannel(s,ChannelProps(end).DevName, ChannelProps(end).ChanID, ChannelProps(end).MeasType)
    
    
    ChannelName = {};
    for i = 1:length(ChannelProps)
        ChannelName{i} = ChannelProps(i).ChName;
    end
    
    ChannelNameRMSDisp = string(ChannelName);
    ChannelNameRemDisp = string([ChannelName 'All']);
    set(handles.RemoveCount,'String', ChannelNameRemDisp);
    set(handles.ChanRMS,'String', ChannelNameRMSDisp);
    set(handles.RSSChan1,'String', ChannelNameRMSDisp);
    
    if strcmp(ChannelProps(end).MeasType, 'IEPE')
        s.Channels(end).ExcitationCurrent = ChannelProps(end).ExCurr;
    elseif (get(handles.ACcoupled,'Value') == 1)
        s.Channels(end).Coupling = 'AC';
    else
        if strcmp(ChannelProps(end).MeasType, 'Accelerometer')
            s.Channels(end).ExcitationSource = 'None';
        end
        s.Channels(end).Coupling = 'DC';
        ChanText = strcat(ChanText, {' '}, 'DC');
    end
    if strcmp(ChannelProps(end).MeasType, 'Accelerometer')
        ChannelProps(end).AccSens = str2double(get(handles.Acc_Sens,'String'));
        s.Channels(end).Sensitivity = ChannelProps(end).AccSens;
        ChanText = strcat(ChanText, {' Sens:'},  num2str(ChannelProps(end).AccSens));
    end
    
    HeadText = vertcat(HeadText,ChanText);
    set(handles.HeaderText,'String',HeadText);
end

function PlotTime_Callback(hObject, eventdata, handles)

function PlotPSD_Callback(hObject, eventdata, handles)

function ClearChannels_Callback(hObject, eventdata, handles)
global s;
global HeadText;
global ChannelProps;
global ChanIDData;
global ChannelName;
global DevNameData;

RemoveSig = get(handles.RemoveCount, 'Value');
RemoveItem = get(handles.RemoveCount, 'String');
SelectedItem = RemoveItem{RemoveSig};
for i = 1:length(ChannelProps)
    if strcmp(ChannelProps(i).ChName, SelectedItem)
        removeChannel(s,i);
        HeadText(i+5,:) = [];
        set(handles.HeaderText,'String',HeadText);
        ChannelProps(i) = [];
        ChanIDData(i) = [];
        DevNameData(i) = [];
        ChannelName(i) = [];
        break;
    end
end

if strcmp('All', SelectedItem)
    removeChannel(s, 1:length(ChannelProps));
    HeadText(6:end, :) = [];
    set(handles.HeaderText, 'String', HeadText);
    ChannelProps = [];
    ChanIDData = [];
    DevNameData = [];
    ChannelName = {};
end

if isempty(ChannelName)
    ChannelNameRemDisp = 'Ch Name';
    set(handles.RemoveCount, 'Value', 1);
    set(handles.RemoveCount,'String', ChannelNameRemDisp);
    set(handles.ChanRMS,'String', ChannelNameRemDisp);
    set(handles.RSSChan1,'String', ChannelNameRemDisp);
else
    ChannelNameRemDisp = string([ChannelName 'All']);
    set(handles.RemoveCount,'String', ChannelNameRemDisp);
    ChannelNameDisp = string(ChannelName);
    set(handles.ChanRMS,'String', ChannelNameDisp);
    set(handles.RSSChan1,'String', ChannelNameDisp);
end


function Ch_name_Callback(hObject, eventdata, handles)

function Ch_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Acc_Sens_Callback(hObject, eventdata, handles)

function Acc_Sens_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SaveCfg_Callback(hObject, eventdata, handles)
global HeadText;
global ChannelProps;

HeadText = get(handles.HeaderText,'String');
uisave({'HeadText','ChannelProps'},'VibeAcqCfg.mat');

function LoadCfg_Callback(hObject, eventdata, handles)
global ChannelProps;
global s;
global DevNameStr;
global MeasTypes;
global ChanIDData;
global DevNameData;
global ChannelName;

HeadText = get(handles.HeaderText,'String');
HeadTextnew = [];
matches = strfind(HeadText,'Ch:');
for row = 1:length(HeadText)
    if(isequal(matches(row,:),{[]}))
        HeadTextnew = vertcat(HeadTextnew,HeadText(row,:));
    end
end
set(handles.HeaderText,'String',HeadTextnew);
ChannelProps=[];
uiopen('load');
s = daq.createSession('ni');
ChannelCount = length(ChannelProps);

ChanIDData = [];
DevNameData = [];
ChannelName = {};
for Channel=1:ChannelCount
    addAnalogInputChannel(s,ChannelProps(Channel).DevName, ChannelProps(Channel).ChanID, ChannelProps(Channel).MeasType);
    ChanIDData = [ChanIDData ChannelProps(Channel).ChanID];
    DevNameData = [DevNameData str2num(ChannelProps(Channel).DevName(end))];
    ChannelName{Channel} = ChannelProps(Channel).ChName;
    if strcmp(ChannelProps(Channel).MeasType, 'IEPE')
        s.Channels(Channel).ExcitationCurrent = ChannelProps(Channel).ExCurr;
    elseif strcmp(ChannelProps(Channel).MeasType, 'Accelerometer')
        s.Channels(Channel).ExcitationSource = 'None';
        s.Channels(Channel).Sensitivity = ChannelProps(Channel).AccSens;
    end
end

ChannelNameRMSDisp = string(ChannelName);
ChannelNameRemDisp = string([ChannelName 'All']);
set(handles.RemoveCount,'String', ChannelNameRemDisp);
set(handles.ChanRMS,'String', ChannelNameRMSDisp);
set(handles.RSSChan1,'String', ChannelNameRMSDisp);

set(handles.HeaderText,'String',HeadText);
set(handles.Ch_name,'String',ChannelProps(Channel).ChName);
matches = strmatch(ChannelProps(Channel).DevName, DevNameStr, 'exact');
set(handles.DeviceName,'Value',matches);
set(handles.Chan_ID,'Value',ChannelProps(Channel).ChanID + 1);
matches = strmatch(ChannelProps(Channel).MeasType, MeasTypes, 'exact');
set(handles.Meas_Type,'Value',matches);
if isfield(ChannelProps, 'Coupling')
    if isequal(ChannelProps(Channel).Coupling,'AC')
        set(handles.ACcoupled,'Value',1);
    else
        set(handles.ACcoupled,'Value',0);
    end
end
if isfield(ChannelProps, 'ExCurr')
    set(handles.ExCurr,'String',num2str(ChannelProps(Channel).ExCurr));
end
if isfield(ChannelProps, 'AccSens')
    set(handles.Acc_Sens,'String',num2str(ChannelProps(Channel).AccSens));
end
if isfield(ChannelProps, 'TrueSens')
    set(handles.TrueSens,'String',num2str(ChannelProps(Channel).TrueSens));
end
if isfield(ChannelProps, 'PlotTime')
    set(handles.PlotTime,'Value',ChannelProps(Channel).PlotTime);
end
if isfield(ChannelProps, 'PlotPSD')
    set(handles.PlotPSD,'Value',ChannelProps(Channel).PlotPSD);
end
if isfield(ChannelProps, 'PlotRC')
    set(handles.PlotRC,'Value',ChannelProps(Channel).PlotRC);
end

function SaveMat_Callback(hObject, eventdata, handles)
global time;
global data;
global ChannelProps;

uisave({'time', 'data','ChannelProps'},'AccData.mat');

function TrueSens_Callback(hObject, eventdata, handles)

function TrueSens_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function PlotRC_Callback(hObject, eventdata, handles)

function RemoveCount_Callback(hObject, eventdata, handles)

function RemoveCount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SysMass_Callback(hObject, eventdata, handles)

function SysMass_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BeginHz_Callback(hObject, eventdata, handles)

function BeginHz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndHz_Callback(hObject, eventdata, handles)

function EndHz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TMTfilter_Callback(hObject, eventdata, handles)

function ResultBox_Callback(hObject, eventdata, handles)

function ResultBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RSSChan1_Callback(hObject, eventdata, handles)

function RSSChan1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CalcResult_Callback(hObject, eventdata, handles)
global data;
global ChannelProps;
global s;

gconvert = 9.80665; %conversion from g to m/s^2
RSSChanOne = get(handles.RSSChan1,'Value');
for counterRSS = 1:3
    GData(:,counterRSS)= data(:,RSSChanOne+counterRSS-1)/ChannelProps(RSSChanOne+counterRSS-1).TrueSens;
    GData(:,counterRSS) = GData(:,counterRSS) * str2double(get(handles.SysMass,'String'))*gconvert;
    [P(:,counterRSS),F] = periodogram(detrend(GData(:,counterRSS)),rectwin(length(GData(:,counterRSS))),length(GData(:,counterRSS)),s.Rate);
end

P_RSS = rssq(P,2);
if (get(handles.TMTfilter,'Value') == 1)
    TMTfilter = makeTMTfilter(F);
    P_RSS=P_RSS.*TMTfilter(:,2);
end

%Plot Reverse Cumulative Integral for RSS result and filtered if done
counterRC = 0;
for i=1:length(ChannelProps)
    if ChannelProps(i).PlotRC
        counterRC = counterRC + 1;
        legendRCstrings{counterRC,1} = ChannelProps(i).ChName;
    end  
end

newlegentry = 'RSS of XYZ';
if (get(handles.TMTfilter,'Value') == 1)
    newlegentry = strcat('Filtered ',newlegentry);
end
legendRCstrings{counterRC+1} = newlegentry;

RevCum = flipud(sqrt(-cumtrapz(flipud(F),flipud(P_RSS))));

axes(handles.axes3);
hold on;
h = findobj(gca,'Type','line');
if gt(length(h),counterRC)
    delete(h(1,1));
end
semilogx(F,RevCum);
legend(legendRCstrings);
hold off;

StartHz = str2double(get(handles.BeginHz,'String'));
EndHz = str2double(get(handles.EndHz,'String'));
RMSofRSS = sqrt(bandpower(P_RSS,F,[StartHz,EndHz],'psd'));
set(handles.ResultBox,'String',num2str(RMSofRSS));

function ChanRMS_Callback(hObject, eventdata, handles)
global data;
global ChannelProps;

RMSChanNum = get(handles.ChanRMS,'Value');
ChanRMSVal = rms(detrend(data(:,RMSChanNum)/ChannelProps(RMSChanNum).TrueSens,'constant'));
set(handles.TimeRMSvalue,'String',num2str(ChanRMSVal));

function ChanRMS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TimeRMSvalue_Callback(hObject, eventdata, handles)

function TimeRMSvalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Savefig_Callback(hObject, eventdata, handles)
[FileName, PathName] = uiputfile('*.fig','Save Entire Figure As...');
hgsave(fullfile(PathName,FileName));

function waitForVib(src, event, handles)
    global collection_complete;
    global data_buffer;
    global time_buffer;
    global t0;
    global data;
    global time;
    global duration
    global test;
    
    global test1;
    test = event.Data;
    disp('packet recieved')
    if t0 == 0
        disp('WWWWWW')
        if max(max(data_buffer)) > 0.005
            % Start to collect data
            t0 = tic;
            data = [flipud(data_buffer(time_buffer > -1, :)); event.Data];
            time = [flipud(time_buffer(time_buffer > -1)); event.TimeStamps];
            
        else
            shift = size(event.Data, 1);
            data_buffer = circshift(data_buffer, shift);
            data_buffer(1:shift, :) = flipud(event.Data);
            
            time_shift = size(event.TimeStamps, 1);
            time_buffer = circshift(time_buffer, time_shift);
            time_buffer(1:time_shift, :) = flipud(event.TimeStamps);
        end
    elseif toc(t0) < duration
        data = [data; event.Data];
        time = [time; event.TimeStamps];
        test1{length(test1) + 1} = event.TimeStamps;
    else
        collection_complete = 1;
        disp('FINISHED')
    end

% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global time
global data
global ChannelProps

[file, path] = uigetfile('load');
load(strcat(path, file))

ChannelProps(end+1).ChName = file;
ChannelProps(end).DevName = 'Loaded Data';
ChannelProps(end).ChanID = get(handles.Chan_ID,'Value')-1;
ChannelProps(end).MeasType = 'Voltage';
ChannelProps(end).PlotTime = get(handles.PlotTime,'Value');
ChannelProps(end).PlotPSD = get(handles.PlotPSD,'Value');
ChannelProps(end).PlotRC = get(handles.PlotRC,'Value');
ChannelProps(end).TrueSens = str2double(get(handles.TrueSens,'String'));

parse_data(time, data, handles);

function parse_data(time, data, handles)
    gconvert = 9.80665; %conversion from g to m/s^2
    global ChannelProps;
    global SampleRates;
    global s;
    npts = length(data);
    
    PlotData = [];
    PSDData = [];
    RCData = [];
    counterTimes = 0;
    counterPSD = 0;
    counterRC = 0;
    for i=1:size(data, 2)
        if ChannelProps(i).PlotTime
            counterTimes = counterTimes + 1;
            PlotData(:,counterTimes) = data(:,i);
            legendTimestrings{counterTimes,1} = ChannelProps(i).ChName;
        end
        if ChannelProps(i).PlotPSD
            counterPSD = counterPSD + 1;
            PSDData(:,counterPSD) = data(:,i)/ChannelProps(i).TrueSens;
            [accPSD(:,counterPSD),w]=pwelch(detrend(PSDData(:,counterPSD)),npts,[],npts,s.Rate);
            legendPSDstrings{counterPSD,1} = ChannelProps(i).ChName;
        end
        if ChannelProps(i).PlotRC
            counterRC = counterRC + 1;
            RCData(:,counterRC) = data(:,i)/ChannelProps(i).TrueSens;
            RCData = RCData * str2double(get(handles.SysMass,'String'))*gconvert;
            [P(:,counterRC),F] = periodogram(detrend(RCData(:,counterRC)),rectwin(length(RCData(:,counterRC))),length(RCData(:,counterRC)),s.Rate);
            RevCum = flipud(sqrt(-cumtrapz(flipud(F),flipud(P))));
            legendRCstrings{counterRC,1} = ChannelProps(i).ChName;
        end  
    end

    %Plot Time Series Voltage data for any Channels that were ticked
    axes(handles.axes1);
    plot(time,PlotData);
    title('Time Series');
    xlabel('Time (Secs)');
    ylabel('Volts (V)');
    legend(legendTimestrings, 'Interpreter', 'none');

    %Plot PSD data for any Channels that were ticked
    hold off
    axes(handles.axes2);
    loglog(w,accPSD);
    legend(legendPSDstrings, 'Interpreter', 'none');
    title('Pwelch periodogram');
    xlabel('Frequency (Hz)');
    ylabel('PSD (g^2)/Hz');

    %Plot Reverse Cumulative Integral for any Channels that were ticked
    axes(handles.axes3);
    semilogx(F,RevCum);
    legend(legendRCstrings, 'Interpreter', 'none');
    title('Reverse Cumulative Integral');
    xlabel('Frequency (Hz)');
    ylabel('Newtons (check Mass!)');


% --- Executes on button press in triggerCheck.
function triggerCheck_Callback(hObject, eventdata, handles)
% hObject    handle to triggerCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of triggerCheck
global useTrigger;
useTrigger = get(hObject, 'Value');

function triggerCheck_CreateFnc(hObject, eventdata, handles)
global triggerWindow;
triggerWindow = 0;

% --- Executes on selection change in triggerWindow.
function triggerWindow_Callback(hObject, eventdata, handles)
% hObject    handle to triggerWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns triggerWindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from triggerWindow
global triggerWindow;
selection = cellstr(get(hObject,'String'));
triggerWindow = str2double(selection{get(hObject,'Value')});


% --- Executes during object creation, after setting all properties.
function triggerWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global triggerWindow;
triggerWindow = 0.5;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
