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
%Code created on       : 2021/2/10/Wednesday
%Code last modified on : 2021/2/23/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotGasConsHighPresFeed.m
%Source     : common
%Description: plot the gas phase concentrations for all columns
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             colNum       - a number for the column to plot the gas phase
%                            concentrations
%Outputs    : the plots for gas phase concentrations for all species for
%             all adsorption columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotGasConsHighPresFeed(params,sol,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotGasConsHighPresFeed';
    
    %Unpack Params
    nComs        = params.nComs          ;  
    lastStep     = sol.lastStep          ;
    gConScaleFac = params.gConScaleFac   ;
    heightCol    = params.heightCol      ;
    nVols        = params.nVols          ;
    sStep        = params.sStep(colNum,:); %For the current column
    nSteps       = params.nSteps         ;
    sCom         = params.sCom           ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);
    
    %Get the string for the title
    strTitle = ...
        append('Column ', ...
               int2str(colNum), ...
               ' Gas Phase Concentration Profile');
    
    %Set the title for the figure
    title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [=] cm');

    %Determine y-axis (absicissa) label
    ylabel('Concentration [=] mol/cc');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Calculate axial distance for the adsorption column 
    height = linspace(1,heightCol,nVols);
    
    %Find the high pressure step
    indHp = find(sStep=="HP");
    
    %Find the last high pressure step
    indHpEnd = lastStep ...
             - nSteps ...
             + indHp(end);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the gas phase concentration profiles for the last high pressure
    %feed
                                 
    %For each species,
    for i = 1 : nComs

        %Hold on to the figure
        hold on;

        %Grab total pressure for jth adsorption column in ith step
        pressure = sol.(append('Step',int2str(indHpEnd))). ...
                   col.(append('n',int2str(colNum))).gasCons. ...
                   (append('C',int2str(i)))(end,:) ...
                 * gConScaleFac;

        %Plot the ith step with jth column
        plot(height,pressure,'LineWidth',2.0);                

    end                 
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend(sCom,'Location','SouthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,500]);
    
    %Set the limit on the x-axis
    xlim([0,heightCol]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%