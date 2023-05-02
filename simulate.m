% Simulate function

%SNRdB is either good SNR value or bad based on what channel is getting
%picked
%jammer is 1 if jammer and victom select the same channel else jammer is 0
function [simThroughput, bler] = simulate(SNRdB, jammer)
    
   

    jammerEffect = 0;
    if jammer == 1
        jammerEffect = 0.2;
    end

    npdschInfo = hNPDSCHInfo;
    npdschInfo.NPDSCHDataType = NPDSCHDataType;
    npdschInfo.ISF = ISF;
    if strcmpi(NPDSCHDataType,'SIB1NB')  % NPDSCH carrying SIB1-NB
        npdschInfo.SchedulingInfoSIB1 = SchedulingInfoSIB1;
    else % NPDSCH not carrying SIB1-NB
        npdschInfo.IRep = ireps; % Repetition number field in DCI (DCI format N1 or N2)
        npdschInfo.IMCS = IMCS;          % Modulation and coding scheme field in DCI (DCI format N1 or N2)
    end

    npdsch.NSF = npdschInfo.NSF;
    npdsch.NRep = npdschInfo.NRep;
    npdsch.NPDSCHDataType = NPDSCHDataType;
    npdsch.RNTI = 1;

    [~,info] = lteNPDSCHIndices(enb,npdsch);
    rmoutlen = info.G;           % Bit length after rate matching, i.e. codeword length
    trblklen = npdschInfo.TBS;   % Transport block size

    displayPattern = false;
    % Display NPDSCH repetition pattern
    if displayPattern == true
        npdschInfo.displaySubframePattern;
    end

    % Absolute subframe number at the starting point of the simulation
    NSubframe = enb.NFrame*10+enb.NSubframe;      

    % Initialize BLER and throughput result
    maxThroughput = 0;
    simThroughput = 0;
    bler = 0;

    enb_init = enb;
    channel_init = channel;

    % TODO: check about the nested loop thing in the other example

    fprintf('\nSimulating %d transport blocks at %gdB SNR\n',numTrBlks,SNRdB);

    enb = enb_init;         % Initialize eNodeB configuration
    channel = channel_init; % Initialize fading channel configuration
    txcw = [];              % Initialize the transmitted codeword
    numBlkErrors = 0;       % Number of transport blocks with errors
    estate = [];            % Initialize NPDSCH encoder state
    dstate = [];            % Initialize NPDSCH decoder state
    lastOffset = 0;         % Initialize overall frame timing offset
    offset = 0;             % Initialize frame timing offset
    subframeGrid = lteNBResourceGrid(enb); % Initialize the subframe grid

    subframeIdx = NSubframe;
    numRxTrBlks = 0;
    while (numRxTrBlks < numTrBlks)

        % Set current subframe and frame numbers  
        enb.NSubframe = mod(subframeIdx,10);
        enb.NFrame = floor((subframeIdx)/10);

        % Generate the NPSS symbols and indices
        npssSymbols = lteNPSS(enb);
        npssIndices = lteNPSSIndices(enb);
        % Map the symbols to the subframe grid
        subframeGrid(npssIndices) = npssSymbols;

        % Generate the NSSS symbols and indices
        nsssSymbols = lteNSSS(enb);
        nsssIndices = lteNSSSIndices(enb);
        % Map the symbols to the subframe grid
        subframeGrid(nsssIndices) = nsssSymbols;

        % Establish if either NPSS or NSSS is transmitted and if so,
        % do not transmit NPDSCH in this subframe
        isDataSubframe = isempty(npssSymbols) && isempty(nsssSymbols);

        % Create a new transport block and encode it when the
        % transmitted codeword is empty. The receiver sets the codeword
        % to empty to signal that all subframes in a bundle have been
        % received (it is also empty before the first transmission)
        if isempty(txcw)
            txTrBlk = randi([0 1],trblklen,1);
            txcw = lteNDLSCH(rmoutlen,txTrBlk);
        end

        if (isDataSubframe)
            % Generate NPDSCH symbols and indices for a subframe
            [txNpdschSymbols,estate] = lteNPDSCH(enb,npdsch,txcw,estate);
            npdschIndices = lteNPDSCHIndices(enb,npdsch);
            % Map the symbols to the subframe grid
            subframeGrid(npdschIndices) = txNpdschSymbols;
            % Generate the NRS symbols and indices
            nrsSymbols = lteNRS(enb);
            nrsIndices = lteNRSIndices(enb);
            % Map the symbols to the subframe grid 
            subframeGrid(nrsIndices) = nrsSymbols;
        end

        % Perform OFDM modulation to generate the time domain waveform
        [txWaveform,ofdmInfo] = nbOFDMModulate(enb,subframeGrid);

        % Add 25 sample padding. This is to cover the range of delays
        % expected from channel modeling (a combination of
        % implementation delay and channel delay spread)
        txWaveform =  [txWaveform; zeros(25, enb.NBRefP)]; %#ok<AGROW>

        % Initialize channel time for each subframe
        channel.InitTime = subframeIdx/1000;

        % Pass data through channel model
        channel.SamplingRate = ofdmInfo.SamplingRate;
        [rxWaveform,fadingInfo] = lteFadingChannel(channel, txWaveform);

        % Calculate noise gain including compensation for downlink power
        % allocation


        % Here is where the snr would get calculated
        SNR = 10^(SNRdB/10);

        % Normalize noise power to take account of sampling rate, which
        % is a function of the IFFT size used in OFDM modulation, and
        % the number of antennas
        N0 = 1/sqrt(2.0*enb.NBRefP*double(ofdmInfo.Nfft)*SNR);

        % Create additive white Gaussian noise
        noise = N0*complex(randn(size(rxWaveform)), ...
                                randn(size(rxWaveform)));

        % Add AWGN to the received time domain waveform        
        rxWaveform = rxWaveform + noise + jammerEffect;

        %------------------------------------------------------------------
        %            Receiver
        %------------------------------------------------------------------

        % Perform timing synchronization, extract the appropriate
        % subframe of the received waveform, and perform OFDM
        % demodulation
        if(perfectChannelEstimator)
            offset = hPerfectTimingEstimate(fadingInfo);
       else
            % In this example, the subframe offset calculation relies
            % on NPSS present in subframe 5, so we need to pad the
            % subframes before it so that the frame offset returned by
            % lteNBDLFrameOffset is the offset for subframe 5
            sfTsamples = ofdmInfo.SamplingRate*1e-3;
            if (enb.NSubframe==5) 
                padding = zeros([sfTsamples*5,size(rxWaveform,2)]);
                offset = lteNBDLFrameOffset(enb, [padding; rxWaveform]);
                if (offset > 25) || (offset < 0)
                    offset = lastOffset;
                end
                lastOffset = offset;
            end
        end

        % Synchronize the received waveform
        rxWaveform = rxWaveform(1+offset:end, :);

        % Perform OFDM demodulation on the received data to recreate the
        % resource grid
        rxSubframe = nbOFDMDemodulate(enb,rxWaveform);

        % Channel estimation
        if(perfectChannelEstimator) 
            % Perfect channel estimation
            estChannelGrid = nbDLPerfectChannelEstimate(enb, channel, offset);
            noiseGrid = nbOFDMDemodulate(enb, noise(1+offset:end ,:));
            noiseEst = var(noiseGrid(:));
        else

            [estChannelGrid, noiseEst] = lteDLChannelEstimate( ...
            enb, cec, rxSubframe);
        end

        if (isDataSubframe)
            % Get NPDSCH indices
            npdschIndices = lteNPDSCHIndices(enb, npdsch);

            % Get PDSCH resource elements from the received subframe. Scale the
            % received subframe by the PDSCH power factor Rho. The PDSCH is
            % scaled by this amount, while the cell reference symbols used for
            % channel estimation (used in the PDSCH decoding stage) are not.
            [rxNpdschSymbols, npdschHest] = lteExtractResources(npdschIndices, ...
                    rxSubframe, estChannelGrid);

            % Decode NPDSCH
            [rxcw,dstate,symbols] = lteNPDSCHDecode(...
                                     enb, npdsch, rxNpdschSymbols, npdschHest, noiseEst,dstate);

            % Decode the transport block when all the subframes in a bundle
            % have been received
            if dstate.EndOfTx
                [trblkout,blkerr] = lteNDLSCHDecode(trblklen,rxcw);
                numBlkErrors = numBlkErrors + blkerr;
                numRxTrBlks = numRxTrBlks + 1;
                % Re-initialize to enable the transmission of a new transport block
                txcw = [];
            end
        end

        subframeIdx = subframeIdx + 1;

    end

    % Calculate the block error rate
    bler = numBlkErrors/numTrBlks;
    fprintf('NPDSCH BLER = %.4f \n',bler);
    % Calculate the maximum and simulated throughput
    maxThroughput = trblklen*numTrBlks; % Max possible throughput
    simThroughput = trblklen*(numTrBlks-numBlkErrors);  % Simulated throughput
    fprintf('NPDSCH Throughput(%%) = %.4f %%\n',simThroughput*100/maxThroughput);

end


