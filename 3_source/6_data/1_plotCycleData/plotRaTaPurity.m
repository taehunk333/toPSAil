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
%Code last modified on : 2022/2/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotRaTaPurity.m
%Source     : common
%Description: plot the product purity inside the product tank(s)
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             raTaNum      - a product tank number
%Outputs    : the plot for product purity inside product receiver tank(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotRaTaPurity(params,sol,raTaNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotRaTaPurity';
    
    %Unpack Params 
    lastStep   = sol.lastStep     ;
    tiScaleFac = params.tiScaleFac;
    color      = params.color     ;
    %---------------------------------------------------------------------%

    
    
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);
    
    %Get the string for the title
    strTitle = ...
        append('Raffinate Product Tank ', ...
               int2str(raTaNum), ...
               ' Product Purity Profile');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Time [=] sec');

    %Determine y-axis (absicissa) label
    ylabel('LK purity [=] -');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Plot the gas phase concentration profiles for the last high pressure
    %feed
                                 
    %Get the string for the color
    rgb = grabColor(1,color); 
    
    %For each step that was simulated,
    for i = 1 : lastStep
       
        %Grab dimensional times
        time = tiScaleFac ...
             * sol.(append('Step',int2str(i))).timePts;
            
        %Hold on to the figure
        hold on;

        %Grab total pressure for jth adsorption column in ith step
        purity = sol.(append('Step',int2str(i))).raTa.n1.gasCons.C1 ...
              ./ sol.(append('Step',int2str(i))).raTa.n1.gasConsTot;

        %Plot the ith step with jth column
        semilogx(time,purity,'LineWidth',2.0,'Color',rgb);     
    
    end                  
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('n1','Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Turn on the zoom feature
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