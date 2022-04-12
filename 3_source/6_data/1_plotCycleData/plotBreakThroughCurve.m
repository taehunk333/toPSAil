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
%Code last modified on : 2022/2/17/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotBreakThroughCurve.m
%Source     : common
%Description: plot the breakthrough curve for an adsorption column
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             colNum       - a number for the column to plot the gas phase
%                            concentrations
%Outputs    : the plot for the breakthrough curve (i.e. dimensionless gas 
%             phase light key concentration of Nth CSTR vs time for a given
%             adsorption column)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotBreakThroughCurve(params,sol,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotBreakThroughCurve';
    
    %Unpack Params
    brkThrPur  = params.yRaC(1)   ;   
    tiScaleFac = params.tiScaleFac;    
    sComNums   = params.sComNums  ;
    sColNums   = params.sColNums  ;    
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);
    
    %Get the string for the title
    strTitle = append('Column ', ...
               int2str(colNum), ...
               ' Breakthrough Curve');
    
    %Set the title for the figure
    title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Time [=] sec');

    %Determine y-axis (absicissa) label
    ylabel('Purity [=] -');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
            
    %Find all the indices for the high pressure step in the currend
    %adsorption column
    [indHpEnd,eveCount] = grabHighPresFeedEvent(params,sol,colNum);
    
    %If no event happened at all,
    if sum(eveCount) == 0

        %Close the figure
        close(figure(figNum));

        %Return to the invoking function
        return
    
    %If an event happened, 
    else
        
        %Pick the last high pressure step with the event
        indHpEnd= indHpEnd(end); 
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the pressure profiles for all columns for all simulated steps all
    %in one plot
                                     
    %Hold on to the figure
    hold on;
    
    %Grab dimensional times
    time = tiScaleFac ...
         * sol.(append('Step',int2str(indHpEnd))).timePts;
    
    %Grab the total concentration for the adsorption column
    
    %Grab the total concentration
    totConc = sol.(append('Step',int2str(indHpEnd))). ...
              col.(sColNums{colNum}).gasConsTot(:,end);

    %Grab the total pressure for jth adsorption column in ith step
    purity = sol.(append('Step',int2str(indHpEnd))). ...
             col.(sColNums{colNum}).gasCons.(sComNums{1})(:,end) ...
          ./ totConc;

    %Plot the ith step with jth column
    plot(time,purity,'LineWidth',2.0);                   
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('Purity','Location','NorthEastOutside');
    
    %Resize the figure
    set(gcf,'Position',[200,200,700,500]);
    
    %Set the limit on the x-axis
    xlim([time(1),time(end)]);
    
    %Set the limit on the y-axis
    ylim([brkThrPur,1]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%