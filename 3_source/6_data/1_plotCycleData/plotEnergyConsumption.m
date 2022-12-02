%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%U.S. Department of Energy 
%American Institute of Chemical Engineers
%Rapid Advancement in Process Intensification Deployment (RAPID) Institute
%Center for Process Modeling (CPM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,
%Georgia Institute of Technology,
%311 Ferst Drive NW, Atlanta, GA 30332-0100.
%Scott Research Group
%https://www.jkscottresearchgroup.com/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project title :
%Dynamic Modeling and Simulation of Pressure Swing Adsroption (PSA)
%Process Systems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code by               : Taehun Kim
%Review by             : Taehun Kim
%Code created on       : 2021/2/23/Tuesday
%Code last modified on : 2022/11/28/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotEnergyConsumption.m
%Source     : common
%Description: plot the energy efficiency of the PSA cycle for producing
%             raffinate and extract product.
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the cycle purity plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotEnergyConsumption(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotEnergyConsumption';
    
    %Unpack Params          
    nSteps    = params.nSteps              ;
    laststep  = sol.lastStep               ;    
    energyEff = sol.perMet.energyEfficiency;
    numPrSt   = params.numPrSt             ;
    colorBnW  = params.colorBnW            ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Calculate needed quantities
    
    %Get the last cycle number
    lastCycNo = laststep/nSteps;
    
    %Create a linearly spaces cycle number vectors
    cycleNums = linspace(1,lastCycNo,lastCycNo)'; 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);                      
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%  
    %Plot the energy efficiency values over the cycles for all species
    
    %For each product stream, 
    for i = 1 : numPrSt          
        
        %Get the vector for the color
        rgb = grabColor(1,colorBnW);
        
        %Scale the units from kJ to kWh: 3,600kJ = 1kWh
        energyData = energyEff(1:lastCycNo,i) ...
                   / 3600;
        
        %Plot the data
        plot(cycleNums,energyData,'-x','LineWidth',2.0,'Color',rgb);    
        
        %Hold on to the figure
        hold on;
    
    end
    
    %Take off the hold
    hold off;
    %---------------------------------------------------------------------%  

    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Get the string for the title
    %strTitle = 'Energy Consumption vs. Cycle';
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Cycle Number');

    %Determine y-axis (absicissa) label
    ylabel('E. Req. [kWh_{e}/mol]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;  
    
    %Add entry to the legend
    legend('Raffinate','Extract','Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Set the limit on the x-axis
    xlim([1,lastCycNo]);
    
    %Set integer spacing
    set(gca,'xtick',0:laststep/nSteps);
    
    %Zoom into the data set
    zoom on;
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%