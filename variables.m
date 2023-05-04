

numTrBlks = 16;        % Number of simulated transport blocks 
NPDSCHDataType = 'NotBCCH'; 

ISF = 0;                % Resource assignment field in DCI (DCI format N1 or N2)
SchedulingInfoSIB1 = 0; % Scheduling information field in MasterInformationBlock-NB (MIB-NB)
IMCS = 4;               % Modulation and coding scheme field in DCI (DCI format N1 or N2)

ireps = 4;

nChannels = 12;

goodSNRdB = -3;
badSNRdB = -15;

mem_length = 10;

channel_evolve_prob = 0.3;

enb.NFrame = 0;     % Simulation starting frame number
enb.NSubframe = 0;  % Simulation starting subframe number
enb.NNCellID = 0;   % NB-IoT physical cell ID
enb.NBRefP = 2;     % Number of NRS antenna ports, should be either 1 or 2
enb.OperationMode = 'Inband-DifferentPCI';  % The allowed values are 'Inband-SamePCI', 'Inband-DifferentPCI', 'Guardband' or 'Standalone'
if strcmpi(enb.OperationMode,'Inband-SamePCI')
    enb.CellRefP = enb.NBRefP;     % The allowed values are NBRefP or 4
    enb.NCellID = enb.NNCellID;
elseif strcmpi(enb.OperationMode,'Inband-DifferentPCI')
    enb.CellRefP = 4; % Number of Cell RS antenna ports (Must be equal to NBRefP or 4)      
    enb.NCellID = 1;
end
if (strcmpi(NPDSCHDataType,'BCCHNotSIB1NB') || strcmpi(NPDSCHDataType,'NotBCCH')) && ...
        (strcmpi(enb.OperationMode,'Inband-SamePCI') || strcmpi(enb.OperationMode,'Inband-DifferentPCI'))
    enb.ControlRegionSize = 3;     % The allowed values are 0...13
end

channel = struct;                    % Initialize channel config structure
channel.Seed = 6;                    % Channel seed
channel.NRxAnts = 1;                 % 1 receive antenna
channel.DelayProfile ='EPA';         % Delay profile
channel.DopplerFreq = 5;             % Doppler frequency in Hz
channel.MIMOCorrelation = 'Low';     % Multi-antenna correlation
channel.NTerms = 16;                 % Oscillators used in fading model
channel.ModelType = 'GMEDS';         % Rayleigh fading model type
channel.InitPhase = 'Random';        % Random initial phases
channel.NormalizePathGains = 'On';   % Normalize delay profile power     
channel.NormalizeTxAnts = 'On';      % Normalize for transmit antennas


perfectChannelEstimator = true;


cec.PilotAverage = 'UserDefined';   % Type of pilot symbol averaging
cec.TimeWindow = 1;                 % Time window size in REs
cec.FreqWindow = 25;                % Frequency window size in REs
cec.InterpType = 'Cubic';           % 2D interpolation type
cec.InterpWindow = 'Centered';      % Interpolation window type
cec.InterpWinSize = 3;              % Interpolation window size
cec.Reference = 'NRS';              % Channel estimator reference signal

save("Parameters");