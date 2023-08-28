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
response = [99.94452	99.958932	99.971305	99.985257	99.992844	99.91902	99.682444	99.15822	98.464492
            99.960251	99.97330065	99.99489434	99.9271835	99.64378962	98.91381498	98.01360871	97.25549419	96.59324461
            99.979133	99.99162555	99.83225068	99.23254991	98.20396892	97.29807301	96.56979097	95.91222303	95.33593258
            99.993246	99.81574319	99.08732932	97.9124395	96.9385348	96.12467229	95.43773279	94.87881429	94.30669956
            99.875035	99.15259669	97.85275222	96.77034846	95.89561384	95.15700568	94.54822987	93.94888347	93.17661989
            99.452472	98.14166766	96.82978739	95.80812572	95.04101184	94.36696612	93.60666528	92.83746918	92.11007845
            98.559179	97.12281498	95.99116728	95.07836099	94.33243802	93.48416572	92.65692964	91.90908146	91.34292856
            97.596774	96.2808578	95.27796094	94.44116937	93.54804366	92.64124029	91.83441999	91.23238853	90.69110445
            96.923712	95.64690031	94.69444984	93.72482995	92.78631972	91.885489	91.22780723	90.64215442	90.20487885];

% Create the response surface plot
figure;
surf(X1, X2, response);
xlabel('Duration (seconds)');
ylabel('Feed Molar Flow Rate (mol/sec)');
zlabel('Raffinate Product Purity (%)');
set(gca,"FontSize",16);

%title('Raffinate Product Purity (%)');
hcb = colorbar;
hcb.FontSize = 16;
% hcb = colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Raffinate Product Purity (%)';
% set(colorTitleHandle ,'String',titleString);

% Adjust plot appearance
colormap('jet');
shading('interp');