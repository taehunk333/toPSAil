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
%Code last modified on : 2021/3/29/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotProductPurity.m
%Source     : common
%Description: plot the purity of the each species for each cycle for all 
%             cycle
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the cycle purity plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotProductPurity(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotProductPurity';
    
    %Unpack Params        
    sCom          = params.sCom             ;
    nComs         = params.nComs            ;
    nSteps        = params.nSteps           ;
    laststep      = sol.lastStep            ;    
    productPurity = sol.perMet.productPurity;
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
    %Plot the purity values over the cycles for all species
    
    %For each component, 
    for i = 1 : nComs
                    
        %Plot the data
        semilogx(cycleNums, ...
                 productPurity(1:lastCycNo,i).*100, ...
                 '-x', ...
                 'LineWidth',2.0);    
        
        %Hold on to the figure
        hold on;
    
    end
    
    %Take off the hold
    hold off;
    %---------------------------------------------------------------------%  

    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Get the string for the title
    strTitle = 'Product Purity vs. Cycle';
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Cycle Number [=] -');

    %Determine y-axis (absicissa) label
    ylabel('Purity [=] %');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;    
    
    %Add entry to the legend
    legend(sCom,'Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Set the limit on the x-axis
    %xlim([1,laststep/nSteps]);
    
    %Set integer spacing
    set(gca,'xtick',0:laststep/nSteps);
    
    %Set the limit on the y-axis
    ylim([0,100]);        
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%