% NB-IoT DL Perfect Channel Estimator
function H = nbDLPerfectChannelEstimate(enb,channel,timefreqoffset)
    % Reconfigure NB-IoT UL perfect channel estimator to perform DL perfect
    % channel estimation
    enb.NBULSubcarrierSpacing = '15kHz';
    enb.NTxAnts = enb.NBRefP;
    enb.TotSlots = 2;
    H = lteULPerfectChannelEstimate(enb, channel,timefreqoffset);
end