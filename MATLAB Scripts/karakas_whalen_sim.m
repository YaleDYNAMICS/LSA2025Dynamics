% Ayla Karakaş
% 
% This script simulates the results of Whalen (1989) for the talk 
% 'Deriving sibilant-vowel phonotactics from a soft bias in perception,' 
% as part of the 'Dynamic Field Theory for unifying discrete and continuous
% aspects of linguistic representations' organized session at 
% 2025 LSA Annual Meeting.

% Given a value for an F2 preshape and a value for an external F2 stimulus
% this script simulates an F2 field and 
% - prints the average position in the field where neurons first cross
% threshold activation
% - displays a plot of the evolution of the F2 DNF over time

% This script also keeps track of the time it takes for neurons to first
% cross activation threshold (analogous to reaction time), but this 
% functionality is not used nor relevant for what is covered in the talk.

%% acoustic parameters

s_F2_preshape = 100; % 100 = 1500 Hz
sh_F2_preshape = 115;

% Some F2 values of synthetic vowel to try out:
% 1490 Hz -> 99
% 1515 Hz -> 102 (101.499)
% 1545 Hz -> 105
% 1600 Hz -> 110
% 1675 Hz -> 118 (117.5)
vowel_F2 = 110;

%% field parameters

fieldSize = 200;

F2_preshape_p = sh_F2_preshape; % change this for fricative
F2_preshape_w = 5;
F2_preshape_a = 4;

F2_p = vowel_F2;
F2_w = 8;
F2_a = 6;

%% initialize field

F2 = Simulator();

% NeuralField constructor call
    %NeuralField(label, size, tau, h, beta)
    	%label - element label
        %size - field size
        %tau - time constant (default = 10)
        %h - resting level (default = -5)
        %beta - steepness of sigmoid output function (default = 4)
F2.addElement(NeuralField('field F2', fieldSize, 10, -5, 4));

% lateral interactions
    %LateralInteractions1D(label, size, sigmaExc, amplitudeExc, ...
%      sigmaInh, amplitudeInh, amplitudeGlobal, circular, normalized, ...
%      cutoffFactor)
    %    size - size of input and output of the convolution
    %    sigmaExc - width parameter of excitatory Gaussian
    %    amplitudeExc - amplitude of excitatory Gaussian
    %    sigmaInh - width parameter of inhibitory Gaussian
    %    amplitudeInh - amplitude of inhibitory Gaussian
    %    amplituudeGlobal - amplitude of global component
    %    circular - flag indicating whether convolution is circular (default is
    %      true)
    %    normalized - flag indicating whether local kernel components are
    %      normalized before scaling with amplitude (default is true)
    %    cutoffFactor - multiple of larger sigma at which the kernel is cut off
    %      (global component is treated separately; default value is 5)

% F2.addElement(LateralInteractions1D('u -> v', fieldSize, 5, 10, 12.5, 5, -0.90), ...
%   'field F2', 'output', 'field F2', 'output');
F2.addElement(LateralInteractions1D('u -> u', ...
    fieldSize, ...
    10, 10, ...
    12.5, 5, ...
    -0.9), ...
  'field F2', 'output', 'field F2', 'output');

% Stimuli
 %GaussStimulus1D(label, size, sigma, amplitude, position, circular, normalized)
  %  label - element label
  %  size - size of the output vector
  %  sigma - width parameter of the Gaussian
  %  amplitude - amplitude of the Gaussian
  %  position - center of the Gaussian
  %  circular - flag indicating whether Gaussian is circular (default value
  %    is true)
  %  normalized - flag indicating whether Gaussian is normalized before
  %    scaling with amplitude (default value is false)

% F2 preshape stimulus (from fricative)
F2.addElement(GaussStimulus1D('F2 preshape', fieldSize, ...
    F2_preshape_w, F2_preshape_a, F2_preshape_p), ...
  [], [], 'field F2');

% F2 stimulus
F2.addElement(GaussStimulus1D('vowel F2', fieldSize, ...
    F2_w, F2_a, F2_p), ...
  [], [], 'field F2');

% output of the 'noise' element is added to fields
%Constructor call:
  %GaussKernel1D(label, size, sigma, amplitude, circular, normalized, ...
   %   cutoffFactor)
    %label - element label
    %size - size of input and output of the convolution
    %sigma - width parameter of Gaussian kernel
    %amplitude - amplitude of kernel
    %circular - flag indicating whether convolution is circular (default is
     % true)
    %normalized - flag indicating whether kernel is normalized before
     % scaling with amplitude (default is true)

%noise stimulus and noise kernel
F2.addElement(NormalNoise('noise', fieldSize, 1.0));
F2.addElement(GaussKernel1D('noise kernel', fieldSize, 0, 1.0, true, true), ...
    'noise', 'output', 'field F2');

%% simulation
numIterations = 500;

rt_results = zeros(numIterations, 1);
thresh_results = zeros(numIterations, 1);

for j = 1:numIterations

    F2.init();
    tsteps = 50; 
    
    % initializes activation history
    F2_ahist = zeros(tsteps, fieldSize);
    
    % runs the simulation for 10 steps
    for i = 1 : tsteps
      F2.step();
    
      % advances the equation one step
      F2_ahist(i,:) = F2.getComponent('field F2', 'activation');
    end
    
    thresh = F2_ahist > 0; % checks which neurons crossed threhold
    [i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1);
    neuron_positions = thresh(ReactionTime, :);

    neuron_idxs = [];

    for col = 1:size(thresh, 2)  
            if thresh(ReactionTime, col) == 1  
                neuron_idxs = [neuron_idxs, col];  
            end
    end

    neuron_pos = median(neuron_idxs);
    rt_results(j, i) = ReactionTime;
    thresh_results(j, i) = neuron_pos;
end 

%% data
disp(['Average position of activation in field: ', num2str(mean(thresh_results))]);

%% plots

% plots F2 activation over time
figure;
surf(F2_ahist); 
title('F2 field');
xlabel('F2'); ylabel('time'); zlabel('activation')


