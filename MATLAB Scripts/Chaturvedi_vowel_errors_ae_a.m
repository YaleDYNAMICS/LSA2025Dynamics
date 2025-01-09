% Manasvi Chaturvedi
% For LSA 2025
% this script attempts to capture trace effects in vowel errors
% we use a field defined over constriciton location


%Define the input values (arbritrary for now)
ae_loc = 68;
ae_act = 4;

a_loc = 39;
a_act = 6;

%sigma for both inputs (width)
vowel_width_ae = 28;
vowel_width_a = 18; 

%we'll consider a field that is 100 wide
fieldSize = 100;
tau = 20;

% create object "CL" by constructor call
CL = Simulator();

% add neural field and the lateral interactions in it
CL.addElement(NeuralField('field CL', fieldSize, tau, -5, 4));

CL.addElement(LateralInteractions1D('u -> u', fieldSize, 5, 15, 12.5, 5, -0.90), ...
  'field CL', 'output', 'field CL', 'output');

%add vowel inputs
CL.addElement(GaussStimulus1D('ae', fieldSize, vowel_width_ae, ae_act, ae_loc), ...
  [], [], 'field CL')
CL.addElement(GaussStimulus1D('a', fieldSize, vowel_width_a, a_act, a_loc), ...
  [], [], 'field CL');

%create noise stimulus and noise kernel
CL.addElement(NormalNoise('noise', fieldSize, 1.5));
CL.addElement(GaussKernel1D('noise kernel', fieldSize, 0, 1.0, true, true), 'noise', 'output', 'field CL');

%initialize simulator
CL.init();

%number of time steps
tstep = 100;

%run for tsteps
for i = 1 : tstep
  CL.step();
  ahist(i,:) = CL.getComponent('field CL', 'activation');
end


% show final activation of neural field
final_activation = CL.getComponent('field CL', 'activation');
final_CL = final_activation; 
figure;
plot(final_CL, 'b');
xlabel('CL field position'); ylabel('activation'); title('Field activation at end of simulation')


% figure of time course
timecourse = figure;

% Create axes
axes1 = axes('Parent',timecourse);
grid(axes1,'on');

%plot data
surf(ahist); %you can also try: mesh(ahist)
xlabel('CL'); ylabel('time steps'); zlabel('activation')

view(axes1,[-25.8383858267717 44.4421052631579]);
grid(axes1,'on');
hold(axes1,'off');
%set(axes1,'XTickLabel',{'0','25','50','75', '100'});











