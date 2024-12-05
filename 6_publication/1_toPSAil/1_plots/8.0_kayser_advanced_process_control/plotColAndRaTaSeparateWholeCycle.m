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
%Function   : plotColAndRaTaSeparateWholeCycle.m
%Source     : common
%Description: plots the pressure for the selected adsorber and the
%             raffinate product tank, separately for the entire PSA cycle.
%Inputs     : nAds         - the current adsorber number
%Outputs    : the plots for the adsorber pressure for the selected adsorber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotColAndRaTaSeparateWholeCycle(nAds)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotColAndRaTaSeparateWholeCycle';    
    
    
    %Define knowns
    redColor = [0.6350 0.0780 0.1840];
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    %figure();
    
    %Get the string for the title
    %strTitle = append('Raffinate Tank Pressure');
    
    %Set the title for the figure
    %title(strTitle);   
    
    %Create a figure
    fig = figure;

    %Create a tile
    t = tiledlayout(2,1);
               
    %Resize the figure
    set(gcf,'Position',[100,25,575,500]);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot each simulation result for the side-by-side comparisons of the
    %purity inside the raffinate product tank
        
        %-----------------------------------------------------------------%
        %The first simulation result
                
        %Load the simulation result
        load('eventFlowDrivenRaTa');

        %Grab the x and y data
        [colTime1, colPressure1] ...
            = grabColPresProfilesComp(params,sol,nAds);

        %Clear the work space
        clearvars -except redColor ...
                          fig color colTime1 colPressure1 nAds;
        %-----------------------------------------------------------------%
    
    
    
        %-----------------------------------------------------------------%
        %The second simulation result
        
        %Load the simulation result
        load('timePresDrivenHP105RaTa');
        
        %Grab the x and y data
        [colTime2, colPressure2] ...
            = grabColPresProfilesComp(params,sol,nAds);
        
        %Clear the work space
        clearvars -except redColor ...
                          fig color colTime1 colPressure1 nAds ...
                          colTime2 colPressure2;
        %-----------------------------------------------------------------%  
        
        
        
        %-----------------------------------------------------------------%
        %The first simulation result
        
        %Load the simulation result
        load('eventFlowDrivenRaTa');

        %Grab the x and y data
        [raTaTime1, raTaPressure1] ...
            = grabRaTaPresProfilesComp(params,sol);

        %Clear the work space
        clearvars -except redColor ...
                          fig color colTime1 colPressure1 nAds ...
                          colTime2 colPressure2 raTaTime1 raTaPressure1;
        %-----------------------------------------------------------------%
    
    
    
        %-----------------------------------------------------------------%
        %The second simulation result                
        
        %Load the simulation result
        load('timePresDrivenHP105RaTa');
        
        %Grab the x and y data
        [raTaTime2, raTaPressure2] ...
            = grabRaTaPresProfilesComp(params,sol);       
        %-----------------------------------------------------------------%  
              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Set the height of the adsorber
    timeMax = max([max(colTime1),max(colTime2), ...
                   max(raTaTime1),max(raTaTime2)]);                
    
    %Set the limit on the x-axis
    xlim([0,timeMax]);
    
    %Determine the maximum pressure
    presMax = round(max([max(colPressure1),max(colPressure2), ...
                         max(raTaPressure1),max(raTaPressure2)])) ...
                         +0.5;
    
    %Set the limit on the y-axia
    ylim([0,presMax]);     

        %-----------------------------------------------------------------%
        %Plot the subfigure(1,1)    
        
        %Get the next tile
        nexttile
        
        %Set the title
        title('Adsorber');
    
        %Determine x-axis (ordinate) label
        xlabel('Time [seconds]');

        %Determine y-axis (absicissa) label
        ylabel('Pressure [bar]'); 
        
        %Shift the time
        colTime1 = colTime1 - 630 - 2.432;
        colTime2 = colTime2 - 630        ;
        
        %Hold on to the figure
        hold on;                
        
        %Add the plots
        plot(colTime1,colPressure1,'-', ...
             'LineWidth',2.0,'Color',[0,0,0]);
        hold on
        plot(colTime2,colPressure2,':', ...
             'LineWidth',2.0,'Color',[0.6,0.6,0.6]);         
        
        %Make sure that the plot is surrounded by a box
        box on;

        %Set the x limits
        xlim([0,210])
        
        %Add the legend
        legend('flow+event','pres.+time','Location','NorthEast');
        
        %Set the y limits
        ylim([0,3.5])

        %Set the style of the axis font as LaTeX type
        set(gca,'TickLabelInterpreter','latex');
        set(gca,'FontSize',14)                 ;  
        %-----------------------------------------------------------------%
        
        
                
        %-----------------------------------------------------------------%
        %Plot the subfigure(2,1)
        
        %Get the next tiles
        nexttile
        
        %Set the title
        title('Raffinate Product Tank');

        %Determine x-axis (ordinate) label
        xlabel('Time [seconds]');

        %Determine y-axis (absicissa) label
        ylabel('Pressure [bar]');  
        
        %Shift the time
        raTaTime1 = raTaTime1 - 630 - 2.432;
        raTaTime2 = raTaTime2 - 630        ;
        
        %Hold on to the figure
        hold on;
        
        %Add the plots        
        plot(raTaTime1,raTaPressure1,'-', ...
             'LineWidth',2.0,'Color',[0,0,0]);
        hold on
        plot(raTaTime2,raTaPressure2,':', ...
             'LineWidth',2.0,'Color',[0.6,0.6,0.6]); 

        %Make sure that the plot is surrounded by a box
        box on;
        
        %Set the x limits
        xlim([0,210])
        
        %Add the legend
        legend('flow+event','pres.+time','Location','SouthEast');

        %Set the style of the axis font as LaTeX type
        set(gca,'TickLabelInterpreter','latex');
        set(gca,'FontSize',14)                 ;  
        %-----------------------------------------------------------------%               
    
    %Hold on to the figure
    
    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;
        
    %Hold off of the figure
    hold off;    
    
    %Get the legend
    %TBD
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,'compPresUpAndDown.pdf'), ...
                   'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%