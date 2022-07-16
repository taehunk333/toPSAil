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
%Code last modified on : 2022/3/8/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotRaTaPresProfiles.m
%Source     : common
%Description: plot the pressure profile for the raffinate product tank
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the pressure profile for all product tanks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotRaTaPresProfiles(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotRaTaPresProfiles';
    
    %Unpack Params
    tiScaleFac   = params.tiScaleFac  ;
    lastStep     = sol.lastStep       ;   
    color        = params.color       ;
    teScaleFac   = params.teScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    gasCons      = params.gasCons     ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);
    
    %Set the title for the figure
    %title('Raffinate Product Tank Pressure Profile');

    %Determine x-axis (ordinate) label
    xlabel('Time [=] sec');

    %Determine y-axis (absicissa) label
    ylabel('Pressure [=] bar');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the pressure profiles for all tanks for all simulated steps all
    %in one plot
      
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
        pressure = sol.(append('Step',int2str(i))).raTa.n1.gasConsTot ...
                .* gConScaleFac ...
                .* sol.(append('Step',int2str(i))).raTa.n1.temps.cstr ...
                .* teScaleFac ...
                .* gasCons;

        %Plot the ith step with jth column
        plot(time,pressure,'LineWidth',2.0,'Color',rgb);
 
    end            
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('n1','Location','SouthEast');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%