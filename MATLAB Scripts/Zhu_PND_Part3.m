% Xiaomeng (Miranda) Zhu
% LSA 2025 Annual Meeting Symposium: Dynamic Field Theory for unifying 
% discrete and continuous aspects of linguistic representations
% Title: A Dynamic Neural Field Model for Production Mode and Phonological 
% Neighborhood Density Effects
% This script contains the simulation for Part 3, which attempts to model 
% production mode as the amplitude of the neighbor input (a_N)


%% set some parameter values

% competitor is mean effect of phonological neighbors
competitor_l = 50; % competitor location 
competitor_width = 15; % competitor width

% target is /u/ 
target_l = 25; % target location
target_a = 8; % target amplitude
target_width = 10;

% Set range of neighbor input amplitude
max_competitor_amplitude = 16;

% we'll consider a field that is 100 neurons wide
fieldSize = 100;

%% Loop through values of neighbor input amplitude
for competitor_a = 1:max_competitor_amplitude
    actual_competitor_a = competitor_a - 10; 

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
constriction.addElement(GaussStimulus1D('competitor', fieldSize, competitor_width, actual_competitor_a, competitor_l), ...
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

% rows are neighbor amplitude; columns are activation values
ahist(competitor_a,:) = constriction.getComponent('field Constriction', 'activation');
[value, position] = max(ahist(competitor_a,:)); % taking the max index and value of the vector
field_output(competitor_a) = position; 

thresh = rt > 0; % check which neurons crossed threhold
[i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1);
field_rt(competitor_a) = ReactionTime;


end %return to the next value of neighbor amplitude

%% plot activation
% plot neighbor amplitude by field output
figure;
plot([1-10:competitor_a-10],field_output)
xlabel('Neighbor Amplitude'); ylabel('Field output');

figure;
surf(ahist); 
set(gca, 'XDir', 'reverse')
xlabel('Constriction'); ylabel('Neighbor Amplitude'); zlabel('activation')

figure;
plot([1-10:competitor_a-10], field_rt)
xlabel('Neighbor Amplitude'); ylabel('Reaction Time');