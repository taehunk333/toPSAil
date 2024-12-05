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
%Function   : plotColAndRaTaTogetherWholeCycle.m
%Source     : common
%Description: plots the pressure for the selected adsorber (left y-axis)
%             and the pressure for the raffinate product tank (right 
%             y-axis), altogether.
%Inputs     : nAds         - the current adsorber number
%Outputs    : the plots for the adsorber pressure for the selected adsorber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotColAndRaTaTogetherWholeCycle(nAds)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotColAndRaTaTogether';    
    
    
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
               
    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
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
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Plot the results  

    %Hold on to the figure
    hold on;

    %Set the title
%     title('Pressure versus time at the last PSA Cycle');

    %Determine x-axis (ordinate) label
    xlabel('Time [seconds]');

    %Determine y-axis (absicissa) label
        ylabel('Pressure [bar]'); 

    %Hold on to the figure
    hold on;

    %Add the plots on the left
    yyaxis left
    plot(colTime2,colPressure2,':', ...
         'LineWidth',2.0,'Color',[0.6,0.6,0.6]);
    hold on
    plot(colTime1,colPressure1,'-', ...
         'LineWidth',2.0,'Color',[0.0,0.0,0.0]);

    %Add the plots on the right
    yyaxis right        
    hold on
    plot(raTaTime2,raTaPressure2,':r','LineWidth',2.0);
    hold on
    plot(raTaTime1,raTaPressure1,'-','LineWidth',2.0, ...
         'Color',redColor);

    %Determine y-axis (absicissa) label
        ylabel('Pressure [bar]');

    %Determine the colors of the axes
    ax = gca;
    ax.YAxis(1).Color = 'k'                   ; %Black
    ax.YAxis(2).Color = redColor; %Red

    %Make sure that the plot is surrounded by a box
    box on;

    %Set the x limits
    xlim([630,840])

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;  
    %---------------------------------------------------------------------%  
        
    
    
    %---------------------------------------------------------------------%  
    %Add information to the plot
    
    %Get the handles
%     ax          = axes(fig);
%     han         = gca      ;
%     han.Visible = 'off'    ;

%     %Left label
%     yyaxis(ax, 'left')                           ;
%     ylabel('Pressure [bar]')                     ;
%     han.YLabel.Visible  = 'on'                   ;
%     han.YLabel.Color    = 'k'                    ;
%     han.YLabel.Position = han.YLabel.Position ...
%                         + [-0.025, 0, 0]         ;
%     
%     %Right label
%     yyaxis(ax, 'right')                          ;
%     ylabel('Pressure [bar]')                     ;
%     han.YLabel.Visible  = 'on'                   ;
%     han.YLabel.Color    = redColor               ;
%     han.YLabel.Position = han.YLabel.Position ...
%                         + [0.025, 0, 0]          ;
    
    %Hold on to the figure
    
    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;
    
    
    %Hold off of the figure
    hold off;    
    
    %Get the legend
    legend('pres.+time', ...
           'flow+event', ....
           'pres.+time', ...
           'flow+event', ...
           'Location','northeast', ...
           'Orientation','vertical');        
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,'compPresWhole.pdf'), ...
                   'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%