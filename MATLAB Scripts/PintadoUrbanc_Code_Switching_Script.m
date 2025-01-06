% This is the base script for Pintado-Urbanc, A. (2025). 'Asymmetric Interference Effects in Code-Switching' 
% a talk part of the LSA 2025 symposium titled: Dynamic Field Theory for unifying discrete and continuous aspects
% of linguistic representations

% The script is divided into two parts: the first section runs simulations for English dominant speakers while 
% the second does so for Spanish dominant speakers. For each section, the script will simulate a single trial 
% and will then plot the following two figures: 
    % (1) final activation in the form of a 2D plot
    % (2) activation over time in the form of a 3D SURF plot

%% Simulation I: English Dominant Speaker Simulation

% The following code simulates trials for an English Dominant Speaker in a code-switching task. 
% To simulate the different trial types of Olson (2013) (English Stay, English Switch, Spanish Stay and Spanish 
% Switch), for an English dominant speaker, use the corresponding activation values. Change only these values in 
% the script. Here, 'ENG' refers to the activation of the English input and 'SPAN' refers to that for the Spanish
% input. 

% To model a ENG Stay Trial use the following activation values:    ENG_a = 6 and SPAN_a = 1
% To model a ENG Switch Trial use the following activation values:  ENG_a = 4 and SPAN_a = 3 
% To model a SPAN Stay Trial use the following activation values:   ENG_a = 1 and SPAN_a = 6 
% To model a SPAN Switch Trial use the following activation values: ENG_a = 1 and SPAN_a = 5 

%% Setting Parameter Values:

fieldSize = 120;    %we'll consider a field that is 120 neurons wide

ENG_VOT = 79.43;    %to stand in for 79 ms on a scale of 0 to 120
ENG_a = 6;          %input activation for English

SPAN_VOT = 37.88;   %to stand in for 37.88 ms on a scale of 0 to 120
SPAN_a = 1;         %input activation for Spanish

VOT_width = 21;     %this is the width of the inputs

%% Properties of the Field

% Create object "VOT" by constructor call
VOT = Simulator();  %naming the simulator 'VOT'

% Adding Elements

% Constructor call
    % NeuralField(label, size, tau, h, beta)
    	%label - element label
        %size - field size
        %tau - time constant (default = 10)
        %h - resting level (default = -5)
        %beta - steepness of sigmoid output function (default = 4)

VOT.addElement(NeuralField('field VOT', fieldSize, 20, -5, 4));     % neural field

 % Adding Lateral Interaction

 % LateralInteractions1D(label, size, sigmaExc, amplitudeExc, ...
    %    sigmaInh, amplitudeInh, amplitudeGlobal, circular, normalized, ...
    %    cutoffFactor)
    %    size - size of input and output of the convolution
    %    sigmaExc - width parameter of excitatory Gaussian
    %    amplitudeExc - amplitude of excitatory Gaussian
    %    sigmaInh - width parameter of inhibitory Gaussian
    %    amplitudeInh - amplitude of inhibitory Gaussian
    %    amplitudeGlobal - amplitude of global component
    %    circular - flag indicating whether convolution is circular (default is
    %      true)
    %    normalized - flag indicating whether local kernel components are
    %      normalized before scaling with amplitude (default is true)
    %    cutoffFactor - multiple of larger sigma at which the kernel is cut off
    %      (global component is treated separately; default value is 5)

VOT.addElement(LateralInteractions1D('u -> u', fieldSize, 5, 21, 12.5, 0, -0.90), ...
  'field VOT', 'output', 'field VOT', 'output');

 % GaussStimulus1D(label, size, sigma, amplitude, position, circular, normalized)
  %  label - element label
  %  size - size of the output vector
  %  sigma - width parameter of the Gaussian
  %  amplitude - amplitude of the Gaussian
  %  position - center of the Gaussian
  %  circular - flag indicating whether Gaussian is circular (default value
  %    is true)
  %  normalized - flag indicating whether Gaussian is normalized before
  %    scaling with amplitude (default value is false)

% Adding 1D gaussian stimulus input (English input) with parameters from above 
% English Input
VOT.addElement(GaussStimulus1D('ENG', fieldSize, VOT_width, ENG_a, ENG_VOT), ...
  [], [], 'field VOT')

% Adding 1D gaussian stimulus input (Spanish input) with parameters from above 
% Spanish Input
VOT.addElement(GaussStimulus1D('SPAN', fieldSize, VOT_width, SPAN_a, SPAN_VOT), ...
  [], [], 'field VOT');

% Adding noise stimulus and noise kernel

% Constructor call:
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

% Noise element
VOT.addElement(NormalNoise('noise', fieldSize, 0));

% Noise kernel
VOT.addElement(GaussKernel1D('noise kernel', fieldSize, 1, 1.0, true, true), 'noise', 'output', 'field VOT');

% All field parameters have been specified

%% Run the Simulation

% Initialize the Simulator
  VOT.init();

% Specify the number of time steps
  tstep = 100; 

% Pre-allocate activation history; this sets up an empty variable
    ahist = zeros(tstep,fieldSize);

% Run the simulation for 100 timesteps
for i = 1 : tstep
  VOT.step();
  % just advances the equation one step
  %in this step we are pulling out the activation history 
  ahist(i,:) = VOT.getComponent('field VOT', 'activation');
  % this variable stores the activation across the field
end

%% Plot the Simulation Results

% This 2D figure shows the final activation of neural field
figure;
plot(VOT.getComponent('field VOT', 'activation'), 'b');
xlabel('field position'); ylabel('activation');

% This 3D figure shows the VOT and activation across the timesteps
figure;
surf(ahist); 
xlabel('VOT'); ylabel('Timestep'); zlabel('Activation'); title('Single Simulation of Field Evolution for English Dominant Participant','FontSize',20,'Color','black')

% Calculate the reaction time (i.e. the first neuron to cross threshold) 
thresh = ahist > 0; 
[i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1)

%% Simulation II: Spanish Dominant Speaker Simulation

% The following code simulates trials for an Spanish Dominant Speaker in a code-switching task. 
% To simulate the different trial types of Olson (2013) (Spanish Stay, Spanish Switch, English Stay and English 
% Switch), for an Spanish dominant speaker, use the corresponding activation values. Change only these values in 
% the script. Here, 'SPAN' refers to the activation of the Spanish input and 'ENG' refers to that for the English
% input. 

% To model a SPAN Stay Trial use the following activation values:   SPAN_a = 6 and ENG_a = 1  
% To model a SPAN Switch Trial use the following activation values: SPAN_a = 4 and ENG_a = 3 
% To model a ENG Stay Trial use the following activation values:    SPAN_a = 1 and ENG_a = 6  
% To model a ENG Switch Trial use the following activation values:  SPAN_a = 1 and ENG_a = 5   

%% Setting Parameter Values:

fieldSize = 120;    %we'll consider a field that is 120 neurons wide

SPAN_VOT = 31.22;   %to stand in for 31.22 ms on a scale of 0 to 120
SPAN_a = 6;         %input activation for Spanish

ENG_VOT = 73.47;    %to stand in for 73.47 ms on a scale of 0 to 120
ENG_a = 1;          %input activation for English

VOT_width = 21;     %this is the width of the inputs 

%% Properties of the Field

% Create object "VOT" by constructor call
VOT = Simulator();  %naming the simulator 'VOT'

% Adding Elements

% Constructor call
    % NeuralField(label, size, tau, h, beta)
    	%label - element label
        %size - field size
        %tau - time constant (default = 10)
        %h - resting level (default = -5)
        %beta - steepness of sigmoid output function (default = 4)

VOT.addElement(NeuralField('field VOT', fieldSize, 20, -5, 4));     % neural field

 % Adding Lateral Interaction

 % LateralInteractions1D(label, size, sigmaExc, amplitudeExc, ...
    %    sigmaInh, amplitudeInh, amplitudeGlobal, circular, normalized, ...
    %    cutoffFactor)
    %    size - size of input and output of the convolution
    %    sigmaExc - width parameter of excitatory Gaussian
    %    amplitudeExc - amplitude of excitatory Gaussian
    %    sigmaInh - width parameter of inhibitory Gaussian
    %    amplitudeInh - amplitude of inhibitory Gaussian
    %    amplitudeGlobal - amplitude of global component
    %    circular - flag indicating whether convolution is circular (default is
    %      true)
    %    normalized - flag indicating whether local kernel components are
    %      normalized before scaling with amplitude (default is true)
    %    cutoffFactor - multiple of larger sigma at which the kernel is cut off
    %      (global component is treated separately; default value is 5)

VOT.addElement(LateralInteractions1D('u -> u', fieldSize, 5, 21, 12.5, 0, -0.90), ...
  'field VOT', 'output', 'field VOT', 'output');

 % GaussStimulus1D(label, size, sigma, amplitude, position, circular, normalized)
  %  label - element label
  %  size - size of the output vector
  %  sigma - width parameter of the Gaussian
  %  amplitude - amplitude of the Gaussian
  %  position - center of the Gaussian
  %  circular - flag indicating whether Gaussian is circular (default value
  %    is true)
  %  normalized - flag indicating whether Gaussian is normalized before
  %    scaling with amplitude (default value is false)

% Adding 1D gaussian stimulus input (English input) with parameters from above 
% English Input
VOT.addElement(GaussStimulus1D('ENG', fieldSize, VOT_width, ENG_a, ENG_VOT), ...
  [], [], 'field VOT')

% Adding 1D gaussian stimulus input (Spanish input) with parameters from above 
% Spanish Input
VOT.addElement(GaussStimulus1D('SPAN', fieldSize, VOT_width, SPAN_a, SPAN_VOT), ...
  [], [], 'field VOT');

% Adding noise stimulus and noise kernel

% Constructor call:
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

% Noise element
VOT.addElement(NormalNoise('noise', fieldSize, 0));

% Noise kernel
VOT.addElement(GaussKernel1D('noise kernel', fieldSize, 1, 1.0, true, true), 'noise', 'output', 'field VOT');

% All field parameters have been specified

%% Run the Simulation

% Initialize the Simulator
  VOT.init();

% Specify the number of time steps
  tstep = 100; 

% Pre-allocate activation history; this sets up an empty variable
    ahist = zeros(tstep,fieldSize);

% Run the simulation for 100 timesteps
for i = 1 : tstep
  VOT.step();
  % just advances the equation one step
  %in this step we are pulling out the activation history 
  ahist(i,:) = VOT.getComponent('field VOT', 'activation');
  % this variable stores the activation across the field
end

%% Plot the Simulation Results

% This 2D figure shows the final activation of neural field
figure;
plot(VOT.getComponent('field VOT', 'activation'), 'b');
xlabel('field position'); ylabel('activation');

% This 3D figure shows the VOT and activation across the timesteps
figure;
surf(ahist); 
xlabel('VOT'); ylabel('Timestep'); zlabel('Activation'); title('Single Simulation of Field Evolution for Spanish Dominant Participant','FontSize',20,'Color','black')

% Calculate the reaction time (i.e. the first neuron to cross threshold) 
thresh = ahist > 0; 
[i,ReactionTime,Neurons_across_threshold] = find(sum(transpose(thresh)),1)

% End