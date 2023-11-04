# Adversarial-Learning-for-NB-IOT

The behavior of an NB-IoT communications link using DRL-based dynamic channel selection is explored in the presence of a DRL-based jamming attacker. A reinforcement learning framework is developed using PPO agents, and their behavior is examined under different channel selection conditions. A Markov Decision Process (MDP) is used to model the channel evolution, and a pre-trained victim agent is deployed alongside a pre-trained jammer. Performance results are compared with and without a victim agent defense strategy. Overall, the defensive strategy employed was able to evade the jammer, but not effective enough to be a viable defensive strategy.

## Simulation Instructions:

*Requires Reinforcement Learning and LTE Toolboxes

- To train the initial victim agent, run 'pretrain_victim_script.m'
- To train the jammer agent, run 'pretrain_jammer_script.m'
- To train the defensive victim agent, run 'victim_defense_script'

- To run NB-IOT simulation, run 'main_script'
	- Adjust 'doSim' to control whether NB-IOT sim runs
	- Adjust 'numTrials' to control the number of time steps
	- Adjust 'run_with_jammer' to control whether the jammer is present
	- Adjust 'run_with_fortified_victim' to control whether the initial victim or defensive victim is used
