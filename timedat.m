%This is the file we used that captures vibrational data and converts it into a way that is more easily useable for us. 

classdef timedat
    % TIMEDAT Container class for measured time series
    % data, sampling and geometry
    properties (Dependent)
        data % [M x N] double, M data series for N channels
        nSensors % [1 x 1] double, Number of sensor channels (N)
        nSamples % [1 x 1] double, Number of time samples (M)
        duration % [1 x 1] double, Duration of time series
        timeStamp % [1 x M] datetime, absolute timestamps for each sample
        time % [1 x M] double, relative timestamps (from 0) in seconds
    end
    
    properties
        fs(1,1) double {mustBePositive} = 1 %[1 x 1] double, sampling rate (Hz)
        startTime(1,1) datetime = datetime(zeros(1,6)); %[1 x 1] datetime, starting timestamp
        units string = '' % string, units
        coords(:,3) double % [N x 3] double, cartesian coordinates for each sensor
        orient(:,3) double % [N x 3] double, orientation vector for each sensor
        serial double  % [N x 1] double, serial number
        info cell % [N x P] cell, general info on each sensor (can be anything)
        sensorName cell % [N x 1] cell of strings, Sensor display name
        sensorID cell % [N x 1] cell of strings, Unique sensor identifier
        sensorIndex double % [N x 1] double, sensor index
        %used to find reference sensors in multiple setup identifications
    end
   
    properties (Access = private)
        data_priv double
        nSensors_priv double
        nSamples_priv double
    end
    
    methods (Access = protected)
        function validatePropertiesImpl(obj)
            if  numel(obj.sensorName) ~= obj.nSensors
                error('SensorName must match number of sensors.');
            end
            
            if numel(obj.sensorID) ~= obj.nSensors
                error('SensorID must match number of sensors.');
            end
            
            if size(obj.coords,1) ~= obj.nSensors
                error('Coords must be [nSensors x 3].');
            end
            
            if size(obj.orient,1) ~= obj.nSensors
                error('Orient must be [nSensors x 3].');
            end
            
            if size(obj.sensorIndex) ~= obj.nSensors
                error('sensorIndex must match number of sensors.');
            end
        end
    end
    
    methods
        %% Declaration
        function obj = timedat(data,fs,varargin)
            switch nargin
                case 1
                    obj.data_priv = data;
                case 2
                    obj.data_priv = data;
                    obj.fs =fs;
                otherwise
                    if mod(numel(varargin),2) ~=0
                        error('Invalid key/value pairs');
                    end
                    if nargin > 3
                        obj.data_priv = data;
                        obj.fs =fs;
                        
                        for k = 1:2:length(varargin)-1
                            switch varargin{k}
                                case 'Units'
                                    obj.units = varargin{k+1};
                                case 'StartTime'
                                    obj.startTime = varargin{k+1};
                                case 'SensorName'
                                    obj.sensorName = varargin{k+1};
                                case 'SensorID'
                                    obj.sensorID = varargin{k+1};
                                case 'Coords'
                                    obj.coords = varargin{k+1};
                                case 'Orient'
                                    obj.orient = varargin{k+1};
                                case 'SensorIndex'
                                    obj.sensorIndex = varargin{k+1};
                                case 'Serial'
                                    obj.serial = varargin{k+1};
                                case 'Info'
                                    obj.info = varargin{k+1};
                                otherwise
                                    error(['Key ' varargin{k}...
                                        ' not recognized!'])
                            end
                        end
                    end
            end
            
            % Defaul initializations for unassigned properties
            if isempty(obj.sensorID)
                obj.sensorID = cell(obj.nSensors,1);
                for k = 1:obj.nSensors
                    obj.sensorID{k} = ['S' num2str(k)];
                end
            end
            
            if isempty(obj.sensorName)
                obj.sensorName = cell(obj.nSensors,1);
                for k = 1:obj.nSensors
                    obj.sensorName{k} = ['S' num2str(k)];
                end
            end
            
            if isempty(obj.info)
                obj.info = cell(obj.nSensors,1);
                for k = 1:obj.nSensors
                    obj.info{k} = '';
                end
            end
            
            if isempty(obj.coords)
                obj.coords = zeros(obj.nSensors,3);
            end
            
            if isempty(obj.orient)
                obj.orient = zeros(obj.nSensors,3);
            end
            
            if isempty(obj.serial)
                obj.serial = zeros(obj.nSensors,1);
            end
            
            if isempty(obj.sensorIndex)
                obj.sensorIndex = 1:obj.nSensors;
            end
            
        end
        
        %% ------------ Setter functions ----------------------------------
        function obj = set.data(obj,newVal)
            [~,n2] = size(newVal);
            if n2 == obj.nSensors_priv
                obj.data_priv = newVal;
            else
                error('Data columns do match numer of sensors, create a new timedat object instead.');
            end
        end
        
        function obj = set.data_priv(obj,newVal)
            obj.data_priv = newVal;
            obj.nSensors_priv = size(newVal,2);
            obj.nSamples_priv = size(newVal,1);
        end
        
        function obj = set.sensorName(obj,newVal)
            if  numel(newVal) ~= obj.nSensors_priv
                error('SensorName must match number of sensors.');
            else
                obj.sensorName = newVal;
            end
        end
        
        function obj = set.sensorID(obj,newVal)
            if  numel(newVal) ~= obj.nSensors_priv
                error('SensorID must match number of sensors.');
            else
                obj.sensorID = newVal;
            end
        end
        
        function obj = set.serial(obj,newVal)
            if  numel(newVal) ~= obj.nSensors_priv
                error('serial must match number of sensors.');
            else
                obj.serial = newVal;
            end
        end
        
        function obj = set.info(obj,newVal)
            if  size(newVal,1) ~= obj.nSensors_priv
                error('info must match number of sensors.');
            else
                obj.info = newVal;
            end
        end
        
        function obj = set.coords(obj,newVal)
            if  size(newVal,1) ~= obj.nSensors_priv
                error('coords length must match number of sensors.');
            else
                obj.coords = newVal;
            end
        end
        
        function obj = set.orient(obj,newVal)
            if  size(newVal,1) ~= obj.nSensors_priv
                error('orient length must match number of sensors.');
            else
                obj.orient = newVal;
            end
        end
        %% ------------ Getter functions ----------------------------------
        function data = get.data(obj)
            data = obj.data_priv;
        end
        %% nSensors getter function
        function nSensors = get.nSensors(obj)
            nSensors = obj.nSensors_priv;
        end
        
        %% nSamples getter function
        function nSamples = get.nSamples(obj)
            nSamples = size(obj.data_priv,1);
        end
        
        %% time getter function
        function time = get.time(obj)
            time = (0:(obj.nSamples-1))/obj.fs;
        end
        
        %% duration getter function
        function dur = get.duration(obj)
            dur = duration(0,0,obj.nSamples/obj.fs); %#ok<CPROP>
        end
        
        %% timeStamp getter function
        function timeStamp = get.timeStamp(obj)
            if ~isempty(obj.startTime)
                timeStamp = obj.startTime + duration(0,0,obj.time);
            else
                error('Cannot return time stamps if startTime is unassigned.');
            end
        end
        
        %% ---------- Data handling functions -----------------------------
        % Note: The data, sensorID, sensorName, and coords properties must
        % agree in size. The class provides special functions for
        % adding, removing or reassigning these properties.
        
        %% Data manipulation
        function obj = trim(obj,varargin)
            %data1_trim = data1.trim('Key',Value)
                % Returns timedat object which has been trimmed based on the
                % specified key/value pairs:
                % 'Time', timeRange : Relative time in seconds, timeRange is a
                % [1 x 2] double with the start and end times.
                % 'DateTime', timeRange : timeRange is a [1 x 2] datetime
                % with the start and end dates/times.
                % 'SensorName', names : names is a [N x 1] cell
                % with list of N sensorNames to remove.
                % 'SensorID', names : names is a [N x 1] cell
                % with list of N sensorIDs to remove.
                % 'SensorIndex', names : names is a [N x 1] double
                % with list of N indices, corresponding to sensors to remove.
            for k = 1:2:length(varargin)-1
                switch varargin{k}
                    case 'Time'
                        timeRange = varargin{k+1};
                        tI = obj.time >= timeRange(1) &...
                            obj.time < timeRange(2);
                        tII = find(tI);
                        st = obj.timeStamp(tII(1));
                        obj.data_priv = obj.data_priv(tI,:);
                        obj.startTime = st;
                    case 'DateTime'
                        timeRange = varargin{k+1};
                        tI = obj.timeStamp >= timeRange(1) &...
                            obj.timeStamp < timeRange(2);
                        tII = find(tI);
                        st = obj.timeStamp(tII(1));
                        obj.data_priv = obj.data_priv(tI,:);
                        obj.startTime = st;
                    case 'SensorName'
                        subList = varargin{k+1};
                        sensI = findSublistIndex(obj.sensorName,subList);
                        obj.data_priv = obj.data_priv(:,sensI);
                        obj.sensorName = obj.sensorName(sensI);
                        obj.sensorID = obj.sensorID(sensI);
                        obj.sensorIndex = obj.sensorIndex(sensI);
                        obj.serial = obj.serial(sensI);
                        obj.info = obj.info(sensI);
                        obj.orient = obj.orient(sensI,:);
                        obj.coords = obj.coords(sensI,:);
                    case 'SensorID'
                        subList = varargin{k+1};
                        sensI = findSublistIndex(obj.sensorID,subList);
                        obj.data_priv = obj.data_priv(:,sensI);
                        obj.sensorName = obj.sensorName(sensI);
                        obj.sensorID = obj.sensorID(sensI);
                        obj.sensorIndex = obj.sensorIndex(sensI);
                        obj.serial = obj.serial(sensI);
                        obj.info = obj.info(sensI);
                        obj.orient = obj.orient(sensI,:);
                        obj.coords = obj.coords(sensI,:);
                    case 'SensorIndex'
                        subList = varargin{k+1};
                        sensI = findSublistIndex(obj.sensorIndex,subList);
                        obj.data_priv = obj.data_priv(:,sensI);
                        obj.sensorName = obj.sensorName(sensI);
                        obj.sensorID = obj.sensorID(sensI);
                        obj.sensorIndex = subList;
                        obj.serial = obj.serial(sensI);
                        obj.info = obj.info(sensI);
                        obj.orient = obj.orient(sensI,:);
                        obj.coords = obj.coords(sensI,:);
                    otherwise
                        error(['Key ' varargin{k}...
                            ' not recognized!'])
                end
            end
        end
        
        function obj = appendSamples(obj,data2)
            % Add time series samples to the end of the file.
            % data1_ext = data1.appendSamples(data2);
                % data1 is timedat with data = M x N double
                % data2 is Q x N double or timedat with data = Q x N double
            if isa(data2,'double')
                if size(data2,2) == obj.nSensors
                    obj.data_priv = [obj.data_priv; data2];
                else
                    error('Data columns must match.');
                end
            else
                if data2.nSensors == obj.nSensors
                    obj.data_priv = [obj.data_priv; data2.data];
                else
                    error('Data columns must match.');
                end
            end
        end
        
        function obj = join(obj,data1)
            % Join two timedat obj with same sampling configuration
            %data_joined = data1.join(data2)
                % data2 is a timedat obj of the same number of samples
                if data1.nSamples == obj.nSamples && data1.fs == obj.fs
                    %if sampling configuration is the same
                    obj.data_priv = [obj.data_priv, data1.data];
                    obj.sensorID = [obj.sensorID; data1.sensorID];
                    obj.sensorName = [obj.sensorName; data1.sensorName];
                    obj.coords = [obj.coords; data1.coords];
                    obj.orient = [obj.orient; data1.orient];
                    obj.serial = [obj.serial; data1.serial];
                    obj.info = [obj.info; data1.info];
                end
        end
                
        function obj = addSensors(obj,data,sensorID,sensorName,coords,...
                orient,serial,info)
            % Add new sensors and data to object
            %data1_add = data1.addSensors(data2,sensorID,sensorName,coords,orient,serial,info)
                % data1 is M x N double
                % data2 is M x P double
                % sensorID is P x 1 cell
                % sensorName is P x 1 cell
                % sensorID is P x 1 cell
                % coords is P x 3 double
                % orient is P x 3 double
                % serial is P x 1 double
                % info is P x Q cell
           
            ndat = size(data,2);
            if ndat == size(sensorID,1) && ndat == size(sensorName,1) &&...
                    ndat == size(coords,1)
                obj.data_priv = [obj.data_priv, data];
                obj.sensorID = [obj.sensorID; sensorID];
                obj.sensorName = [obj.sensorName; sensorName];
                obj.coords = [obj.coords; coords];
                obj.orient = [obj.orient;orient];
                obj.serial = [obj.serial;serial];
                obj.info = [obj.info;info];
            else
                error('Data columns must match length of sensorID, sensorName, and coords.');
            end
        end
        
        function obj = filter(obj,wc,type)
            % filter the time signal using a 4th order butterworth IIR, forwards-backward (zero phase) filter
            %data1_filt = data1.filter(wc,type)                
                % wc is cutoff frequency(ies) in Hz
                % type is the type of filter
                % Lowpass filter: type = 'low', wc = double
                % Highpass filter: type = 'high', wc = double
                % Bandpass filter: type = 'bandpass', wc = [1 x 2] double
            switch type
                case 'high'
                    if wc > 0
                        [b,a] = butter(4,2*wc/obj.fs,'high');
                        data1 = filtfilt(b,a,obj.data_priv);
                    else
                        data1 = detrend(obj.data,'constant');
                    end
                case 'low'
                    [b,a] = butter(4,2*wc/obj.fs,'low');
                    data1 = filtfilt(b,a,obj.data_priv);
                case 'bandpass'
                    [b,a] = butter(4,2*wc/obj.fs,'bandpass');
                    data1 = filtfilt(b,a,obj.data_priv);
            end
            obj.data_priv = data1;
        end
        
        function obj = decimate(obj,r)
            % decimates data (see MATLAB decimate documentation)
                % r is [1x1] integer representing decimation factor
            data1 = zeros(ceil(obj.nSamples/r),obj.nSensors);
            
            if r~= 1
                if r> 12
                    dec_order = factor(r);
                else
                    dec_order = r;
                end
                
                %decimate
                for i = 1:obj.nSensors
                    temp = obj.data_priv(:,i);
                    for k = 1:numel(dec_order)
                        temp = decimate(temp,dec_order(k));
                    end
                    data1(:,i) = temp;
                end
                
                obj.data_priv = data1;
                obj.fs = obj.fs/r;
            end
        end
        
        function plotTimeFreq(obj,I,wdwsec)
            %% plot time and frequency domain summaries of data
            %I = sensor indices or sensor names
            %wdwsec = PSD window length in seconds
            if nargin < 2
                I = 1:obj.nSensors;
            elseif isempty(I)
                I = 1:obj.nSensors;
            elseif ischar(I)
                sn = I;
                I = find(strcmp(obj.sensorName,sn));
                if isempty(I)
                    error('Sensor not found');
                end
            elseif iscell(I)
                sn = I;
                I = zeros(numel(I),1);
                for i = 1:numel(I)
                    I(i) = find(strcmp(obj.sensorName,sn{i}));
                end
            end
            
            if nargin < 3
                wdwsec = seconds(obj.duration);
                
            end
            
            
            wdw = floor(wdwsec*obj.fs);
            [Paa,f] = pwelch(obj.data(:,I),wdw,wdw/2,wdw,obj.fs);
            
            
            subplot(211)
            plot(obj.time,obj.data(:,I));
            xlabel('Relative time - sec');
            ylabel(obj.units);
            set(gca,'Fontsize',14);
            
            subplot(212)
            plot(f,Paa);
            set(gca,'Yscale','log');
            xlabel('Frequency - Hz ');
            ylabel(['Power Spectral Density - ' obj.units '^2/Hz']);
            legend(obj.sensorName(I));
            grid on
            set(gca,'Fontsize',14);
        end
        
        function I = getSensorIndex(obj,sn)
            % get corresponding indices for a list of sensorNames
            I = zeros(numel(sn),1);
            for i = 1:numel(sn)
                I(i) = find(strcmp(obj.sensorName,sn{i}));
            end
        end
        
    end
end
