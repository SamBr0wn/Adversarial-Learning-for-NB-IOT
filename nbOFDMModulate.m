% NB-IoT DL OFDM Modulator
function [waveform,info] = nbOFDMModulate(enb,grid)
    % Apply default window size according to TS 36.104 Table E.5.1-1a
    if(~isfield(enb,'Windowing'))
        enb.Windowing = 6;
    end
    % Use NB-IoT SC-FDMA to get the 1/2 subcarrier shift on the OFDM modulation
    enb.NBULSubcarrierSpacing = '15kHz';
    [waveform,info] = lteSCFDMAModulate(enb,grid);
end



