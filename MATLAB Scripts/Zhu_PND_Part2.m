% Xiaomeng (Miranda) Zhu
% LSA 2025 Annual Meeting Symposium: Dynamic Field Theory for unifying 
% discrete and continuous aspects of linguistic representations
% Title: A Dynamic Neural Field Model for Production Mode and Phonological 
% Neighborhood Density Effects
% This script contains the simulation for Part 2, which attempts to model 
% production mode as the width of the target input (w_T)


%% set some parameter values

% competitor is mean effect of phonological neighbors
competitor_l = 50; % competitor location 
competitor_a = 4; % competitor amplitude, excitatory if > 0
competitor_width = 20;

% target is /u/
target_l = 25; % target location
target_a = 6; % target amplitude

% Set range of target width
max_target_width = 50;

% we'll consider a field that is 100 neurons wide
fieldSize = 100;

%% Loop through values of target width
for target_width = 1:max_target_width

% define the properties of the field 
constriction = Simulator();
% add elements
% neural field
constriction.addElement(NeuralField('field Constriction', fieldSize, 20, -5, 4));
% lateral interaction
constriction.addElement(LateralInteractions1D('u -> u', fieldSize, 5, 15, 12.5, 5, -0.90), ...
  'field Constriction', 'output', 'field Constriction', 'output');
% target input 
constriction.addElement(GaussStimulus1D('target', fieldSize, target_width, target_a, target_l), ...
  [], [], 'field Constriction')
% competitor input
constriction.addElement(GaussStimulus1D('competitor', fieldSize, competitor_width, competitor_a, competitor_l), ...
  [], [], 'field Constriction');
% constriction.addElement(GaussStimulus1D('inhibitor', fieldSize, 25, -2, 75), ...
%   [], [], 'field Constriction');
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

% rows are target input width; columns are activation values
ahist(target_width,:) = constriction.getComponent('field Constriction', 'activation');
[value, position] = max(ahist(target_width,:)); % taking the max index and value of the vector
field_output(target_width) = position; 

thresh = rt > 0; % check which neurons crossed threhold
[i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1);
field_rt(target_width) = ReactionTime;

end %return to the next value of target width

%% plot activation
% plot target input width by field output
figure;
plot([1:target_width],field_output)
xlabel('Vowel input width'); ylabel('Field output');

figure;
surf(ahist); 
set(gca, 'XDir', 'reverse')
xlabel('Constriction'); ylabel('Vowel input width'); zlabel('activation')

% Plot reaction time
figure;
plot([1:target_width], field_rt)
xlabel('Vowel input width'); ylabel('Reaction Time');