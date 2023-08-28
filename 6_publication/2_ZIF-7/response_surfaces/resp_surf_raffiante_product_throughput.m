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
response = [2.1194	2.5673	3.0179	3.4621	3.9112	4.3804	4.8719	5.3776	5.9114
            2.6791	3.2166	3.7583	4.3232	4.914	5.5316	6.2069	6.875	7.5323
            3.2367	3.8756	4.5492	5.2503	6.0279	6.8037	7.5777	8.355	9.1359
            3.803	4.5719	5.3846	6.2692	7.1733	8.0646	8.9606	9.8522	10.7563
            4.3889	5.3023	6.2968	7.3178	8.3194	9.3393	10.3414	11.3438	12.5143
            4.9986	6.0878	7.229	8.363	9.4807	10.6023	11.8151	13.0313	14.2955
            5.6684	6.9149	8.147	9.3947	10.6306	11.9536	13.3148	14.6974	16.0363
            6.3649	7.7214	9.0703	10.4264	11.8547	13.3389	14.8724	16.3105	17.8438
            7.0577	8.5324	9.9925	11.5354	13.1058	14.7482	16.333	17.9938	19.5807];

% Create the response surface plot
figure;
surf(X1, X2, response);
xlabel('Duration (seconds)');
ylabel('Feed Molar Flow Rate (mol/sec)');
zlabel('Raffinate Throughput (mol)');
set(gca,"FontSize",16);

%title('Raffinate Throughput (mol)');
hcb = colorbar;
hcb.FontSize = 16;
% hcb = colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Raffinate Throughput (mol)';
% set(colorTitleHandle ,'String',titleString);

% Adjust plot appearance
colormap('jet');
shading('interp');