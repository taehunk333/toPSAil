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
response = [0.0044209	0.00418928	0.00402519	0.00390533	0.00381255	0.00373315	0.00365748	0.0035794	0.00350377
            0.00414448	0.00396837	0.00384261	0.00374278	0.003650384	0.00355534	0.003465597	0.003392591	0.003332659
            0.00396387	0.00382089	0.00370699	0.00359658	0.003486773	0.003399	0.00332839	0.003270108	0.00322098
            0.00383554	0.003703328	0.003575122	0.003456581	0.003362932	0.003290111	0.003230825	0.003181877	0.00313945
            0.00373287	0.003586544	0.003452672	0.003349362	0.003271531	0.003208513	0.003157791	0.003114579	0.003070618
            0.0036331	0.003476921	0.003356648	0.003267869	0.003200341	0.003145551	0.003095935	0.00305327	0.00301607
            0.00353096	0.003385371	0.003282588	0.003204588	0.00314395	0.003090559	0.003044301	0.003005618	0.002974648
            0.00344226	0.003313897	0.003222514	0.003152778	0.003094057	0.003043544	0.003001233	0.002968937	0.002940244
            0.00337048	0.003255223	0.003172903	0.003105905	0.003050809	0.003004344	0.002968482	0.00293771	0.002913312];

% Create the response surface plot
figure;
surf(X1, X2, response);
xlabel('Duration (seconds)');
ylabel('Feed Molar Flow Rate (mol/sec)');
zlabel('Energy Requirement (kWhe/mol)');
set(gca,"FontSize",16);

%title('Energy Requirement (kWhe/mol)');
hcb = colorbar;
hcb.FontSize = 16;
% hcb = colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Energy Requirement (kWhe/mol)';
% set(colorTitleHandle ,'String',titleString);

% Adjust plot appearance
colormap('jet');
shading('interp');