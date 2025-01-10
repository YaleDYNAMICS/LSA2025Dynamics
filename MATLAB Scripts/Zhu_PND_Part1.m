% Xiaomeng (Miranda) Zhu
% LSA 2025 Annual Meeting Symposium: Dynamic Field Theory for unifying 
% discrete and continuous aspects of linguistic representations
% Title: A Dynamic Neural Field Model for Production Mode and Phonological 
% Neighborhood Density Effects
% This script contains the simulation for Part 1, which attempts to model 
% production mode as the field resting level (h) parameter


%% set some parameter values

% competitor is mean effect of phonological neighbors
competitor_l = 50; % competitor location at the center of the field 
competitor_a = 14; % competitor amplitude, excitatory
competitor_width = 20;

% target is /u/
target_l = 25; % target location
target_a = 16; % target amplitude
target_width = 5;

% Set range of resting level
max_resting_level = 11;
min_resting_level = 1;

% we'll consider a field that is 100 neurons wide
fieldSize = 100;

%% Loop through values of resting level, step size = 10
for resting_level = min_resting_level:max_resting_level
resting_level_actual = resting_level - 16;

% define the properties of the field 
constriction = Simulator();
% add elements
% neural field
constriction.addElement(NeuralField('field Constriction', fieldSize, 20, resting_level_actual, 4));
% lateral interaction
constriction.addElement(LateralInteractions1D('u -> u', fieldSize, 5, 15, 12.5, 5, -0.90), ...
  'field Constriction', 'output', 'field Constriction', 'output');
% target input 
constriction.addElement(GaussStimulus1D('target', fieldSize, target_width, target_a, target_l), ...
  [], [], 'field Constriction')
% competitor input
constriction.addElement(GaussStimulus1D('competitor', fieldSize, competitor_width, competitor_a, competitor_l), ...
  [], [], 'field Constriction');
% noise stimulus and noise kernel
constriction.addElement(NormalNoise('noise', fieldSize, 1.0));
constriction.addElement(GaussKernel1D('noise kernel', fieldSize, 0, 1.0, true, true), 'noise', 'output', 'field Constriction');
%% Simulate the evolution of the field

% initialize the simulator
constriction.init();

% number of time steps
tstep = 100; 

% run the simulation 
for i = 1 : tstep
  constriction.step();
  rt(i,:) = constriction.getComponent('field Constriction', 'activation');
end

%% pull activation values from the end of the simulation

% plotting the effect of resting level on the position where the field
% stabilizes
% rows are resting level; columns are activation values
ahist(resting_level,:) = constriction.getComponent('field Constriction', 'activation');
[value, position] = max(ahist(resting_level,:)); % taking the max index and value of the vector
field_output(resting_level) = position; 

thresh = rt > 0; % check which neurons crossed threhold
[i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1);
field_rt(resting_level) = ReactionTime;


end %return to the next value of resting level

%% plot activation
% plot resting level by field output
figure;
plot([1-16:resting_level-16],field_output)
xlabel('Field Resting Level'); ylabel('Field output');

figure;
surf(ahist);
set(gca, 'XDir', 'reverse')
xlabel('Constriction'); ylabel('Field Resting Level'); zlabel('activation')

% Plot reaction time
figure;
plot([1-16:resting_level-16], field_rt)
xlabel('Field Resting Level'); ylabel('Reaction Time');