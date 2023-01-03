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
%Code created on       : 2022/12/19/Monday
%Code last modified on : 2022/12/19/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotRaTaPressureComparisons.m
%Source     : common
%Description: plots the pressure for the raffinate product tank for 
%             different simulations (i.e., event+flow driven, time+pressure
%             driven with HP step 105 seconds, 150 seconds, and 200
%             seconds)
%Inputs     : none         - n.a.
%Outputs    : the plot for the raffinate tank pressure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotRaTaPressureComparisons()

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotRaTaPressureComparisons';    
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure();
    
    %Get the string for the title
    %strTitle = append('Raffinate Tank Pressure');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Time [seconds]');

    %Determine y-axis (absicissa) label
    ylabel('Pressure [bar]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot each simulation result for the side-by-side comparisons of the
    %purity inside the raffinate product tank
        
        %-----------------------------------------------------------------%
        %The first simulation result
        
        %Hold on to the figure
        hold on;
        
        %Load the simulation result
        load('eventFlowDrivenRaTa');

        %Grab the x and y data
        [time1, pressure1] = grabRaTaPresProfilesComp(params,sol);

        %Plot the results
        plot(time1,pressure1,'-','LineWidth',2.0,'Color',[0,0,0]);

        %Clear the work space
        clearvars -except color time1;
        %-----------------------------------------------------------------%
    
    
    
        %-----------------------------------------------------------------%
        %The second simulation result
        
        %Hold on to the figure
        hold on;
        
        %Load the simulation result
        load('timePresDrivenHP105RaTa');
        
        %Grab the x and y data
        [time2, pressure2] = grabRaTaPresProfilesComp(params,sol);

        %Plot the results
        plot(time2,pressure2,':','LineWidth',2.0,'Color',[0.6,0.6,0.6]);        
        %-----------------------------------------------------------------%        
              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Set the height of the adsorber
    timeMax = max([max(time1),max(time2)]);
    
    %Add entry to the legend
    legend('flow+event', ...
           'pres.+time', ...
           'Location', ...
           'SouthEast');
    
    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
    
    %Set the limit on the x-axis
    xlim([0,timeMax]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,'compRaTaPres.pdf'), ...
                   'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%