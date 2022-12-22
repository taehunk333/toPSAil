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
%Code created on       : 2021/3/25/Thursday
%Code last modified on : 2022/10/19/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotCssConv.m
%Source     : common
%Description: plot the cyclic steady state (CSS) convergence results of the
%             simulated PSA cycle.
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the cycle purity plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotCssConv(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotCssConv';
    
    %Unpack Params            
    nSteps   = params.nSteps  ;
    modSp    = params.modSp   ;
    numZero  = params.numZero ;
    laststep = sol.lastStep   ; 
    css      = sol.css        ;    
    colorBnW = params.colorBnW;
    %---------------------------------------------------------------------%

              
        
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Get the last cycle number
    lastCycNo = laststep/nSteps;
    
    %Create a linearly spaces cycle number vectors
    cycleNums = linspace(2,lastCycNo+1,lastCycNo)';
    
    %Create a numerical zero vector
    numZeros = ones(1,lastCycNo)*numZero;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Plot the CSS convergence values over the cycles for all species
                                  
    %Get the string for the color
    rgb = grabColor(1,colorBnW);
    
    %Plot the CSS convergence data
    semilogy(cycleNums,css(2:lastCycNo+1),'-x','LineWidth',2.0,'Color',rgb);
    
    %Hold on to the figure
    hold on;
    
    %plot the numerical zero line
    plot(cycleNums,numZeros,'--r','LineWidth',2);
    
    %Turn on the grid
    grid on;
    
    %Take off the hold
    hold off;
    %---------------------------------------------------------------------%  

    
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting (Continued)
    
    %Get the string for the title
    str1 = 'CSS convergence ';
    
    %Append the strings
    %strTitle = append(str1,'(Type ',int2str(modSp(7)),') ',' vs. Cycle');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Start of the n^{th} PSA Cycle');

    %Determine y-axis (absicissa) label
    ylabel("L2-Norm Diff. Sq.");

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;  
    
    %Set the x limit
    xlim([2,lastCycNo+1]);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Write an entry for the legend
    str2 = append('modSp7 = ',int2str(modSp(7)));
    
    %Add entry to the legend
    %legend(str2,'Location','SouthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);    
    
    %Set integer spacing
    set(gca,'xtick',0:laststep/nSteps+1);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%