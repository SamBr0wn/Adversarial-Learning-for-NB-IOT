% P = [0.5 0.5 0.0 0.0;
%      0.5 0.0 0.5 0.0;
%      0.0 0.0 0.0 1.0;
%      0.0 0.0 1.0 0.0];
% stateNames = ["Regime 1" "Regime 2" "Regime 3" "Regime 4"];
% mc = dtmc(P,'StateNames',stateNames);
% 
% figure;
% imagesc(P);
% colormap(jet);
% colorbar;
% axis square
% h = gca;
% h.XTick = 1:4;
% h.YTick = 1:4;
% title 'Transition Matrix Heatmap';
% 
% 
% numSteps = 10;
% x0 = [0.5 0.5 0 0];
% X = redistribute(mc,numSteps,'X0',x0);
% 
% figure;
% distplot(mc,X);

% Lets say that we have 12 channels and that 2 of them will be good and the
% rest will be bad. 
% Return int 1-12 to represent the good channel
function current_state = evolveChannel(last_state)
    p = 0.7; % probability that the channel will change
    nChannels = 12;
    event = randi(100)/100;
    current_state = zeros(1:nChannels);

    if (event <= p)
        if (last_state(2) == nChannels )
            current_state(1) = 1;
            current_state(2) = 2;
        else
            current_state(1) = last_state(1) + 1;
            current_state(2) = last_state(2) + 1;
        end
    else
        current_state(1) = last_state(1);
        current_state(2) = last_state(2);
    end

end