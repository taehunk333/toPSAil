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
response = [79.806087	83.303615	85.981119	88.058705	89.734179	91.136486	92.355655	93.396549	94.257646
            84.010628	86.94609065	89.18644261	90.95931031	92.45417394	93.64456551	94.60267353	95.37826656	95.98974917
            87.026073	89.57305966	91.5411402	93.122936	94.35138379	95.28572021	96.05622172	96.64732666	97.13187642
            89.304038	91.59174348	93.408903	94.68827468	95.68793018	96.42946489	97.0204398	97.52569328	97.88420019
            91.086542	93.24112697	94.70863091	95.80769852	96.59941065	97.2235375	97.72248196	98.08091202	98.29726494
            92.605312	94.48850595	95.71148556	96.59047631	97.28524499	97.81074232	98.15530467	98.34896204	98.46135987
            93.787605	95.39427934	96.456342	97.23017869	97.81185052	98.15288177	98.37050547	98.49686742	98.63475466
            94.673231	96.07474903	97.04029184	97.72642404	98.13843083	98.3718435	98.52212773	98.65380216	98.76552007
            95.509505	96.70110223	97.53838515	98.04886198	98.35323338	98.50216305	98.65990664	98.77419335	98.89553303];

% Create the response surface plot
figure;
surf(X1, X2, response);
xlabel('Duration (seconds)');
ylabel('Feed Molar Flow Rate (mol/sec)');
zlabel('Methane Recovery (%)');
set(gca,"FontSize",16);

%title('Methane Recovery (%)');
hcb = colorbar;
hcb.FontSize = 16;
% hcb = colorbar;
% colorTitleHandle = get(hcb,'Title');
% titleString = 'Methane Recovery (%)';
% set(colorTitleHandle ,'String',titleString);

% Adjust plot appearance
colormap('jet');
shading('interp');