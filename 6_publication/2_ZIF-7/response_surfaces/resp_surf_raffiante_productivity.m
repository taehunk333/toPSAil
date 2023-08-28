% Initialize the script
close all
clear all
clc

% Define the ranges for the interaction variables
step_dur = [240 280 320 360 400 440 480 520 560];
mol_flow = [9.49E-03 1.15E-02 1.34E-02 ...
            1.54E-02 1.74E-02 1.94E-02 ...
            2.14E-02 2.33E-02 2.53E-02];

% Create a grid of values for the interaction variables
[X1, X2] = meshgrid(step_dur, mol_flow);

% Provide a matrix of the response data
response = [2.94358566	3.37808505	3.77234029	4.12149231	4.4445524	4.76128539	5.07486672	5.37755491	5.68407445
            3.72094047	4.232408745	4.697830207	5.146683543	5.58407307	6.01256983	6.465481924	6.874968077	7.242598029
            4.49545946	5.099516511	5.686522978	6.250314982	6.849858023	7.395338636	7.893393281	8.355041262	8.784551067
            5.28199626	6.015616126	6.730689106	7.463352104	8.151452981	8.765815998	9.333987496	9.852240362	10.34260209
            6.09568088	6.97667008	7.871050028	8.711669791	9.453808192	10.15143895	10.77224342	11.34384248	12.03298404
            6.94245041	8.010288952	9.036268958	9.957172989	10.77349728	11.52420187	12.30736918	13.03127134	13.7456376
            7.87278503	9.098558456	10.18371287	11.18417028	12.08019765	12.99305581	13.86956009	14.69740339	15.41949321
            8.84014035	10.1597432	11.33785146	12.41238725	13.47124484	14.49879027	15.49209024	16.31046727	17.15751741
            9.8024085	11.2269078	12.49067475	13.73257277	14.89299844	16.03065013	17.01354183	17.99375747	18.82761903];

% Create the response surface plot
figure;
surf(X1, X2, response);
xlabel('Duration (seconds)');
ylabel('Feed Molar Flow Rate (mol/sec)');
zlabel('Raffinate Productivity (mmol/kg-sec)');
set(gca,"FontSize",16);

%title('Raffinate Productivity (mmol/kg-sec)');
hcb = colorbar;
hcb.FontSize = 16;
% hcb = colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Raffinate Productivity (mmol/kg-sec)';
% set(colorTitleHandle ,'String',titleString);

% Adjust plot appearance
colormap('jet');
shading('interp');