% NB-IoT DL OFDM Demodulator
function grid = nbOFDMDemodulate(enb,rxWaveform)
    % Use NB-IoT SC-FDMA to get the 1/2 subcarrier shift on the OFDM modulation
    enb.NBULSubcarrierSpacing = '15kHz';
    grid = lteSCFDMADemodulate(enb,rxWaveform,0.55); % CP fraction of 0.55
end