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
%Code last modified on : 2022/10/19/Wednesday
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
    sStepCol   = params.sStepCol  ;
    sComNums   = params.sComNums  ;
    sColNums   = params.sColNums  ; 
    eveLoc     = params.eveLoc    ;
    lastStep   = sol.lastStep     ;
    nSteps     = params.nSteps    ;
    nRows      = params.nRows     ;
    nLKs       = params.nLKs      ; 
    colorBnW   = params.colorBnW  ;
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
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Time [seconds]');

    %Determine y-axis (absicissa) label
    ylabel('LK mole fraction');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
            
    %Find the high pressure steps
    indHp = contains(sStepCol(colNum,:),"HP");
    
    %Find the last high pressure step
    indHp = find(indHp,1,'last');
    
    %Get the current adsorber name
    adsNameCurr = strcat("Adsorber","_",int2str(colNum));
    
    %If an event is expected in the current HP step in the current adsorber
    if contains(eveLoc{indHp},adsNameCurr)

        %Find the last high pressure step with the event
        indHpEnd = lastStep ...
                 - nSteps ...
                 + indHp;     

    %If no event happened at all,    
    else

        %Close the figure
        close(figure(figNum));

        %Return to the invoking function
        return
    
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
    
    %Initialize the sum of the light key concentrations
    sumLkConcs = zeros(nRows,1);

    %Obtain the sum of the light key concentrations
    for j = 1 : nLKs

        %Update the currnet sum of the total gas concentration in the
        %raffinate product tank
        sumLkConcs = sumLkConcs ...
                   + sol.(append('Step',int2str(indHpEnd))). ...
                     col.(sColNums{colNum}).gasCons.(sComNums{j})(:,end);

    end        
          
    %Grab the total pressure for jth adsorption column in ith step
    purity = sumLkConcs ...
          ./ totConc;
      
    %Get the string for the color
    rgb = grabColor(1,colorBnW);

    %Plot the ith step with jth column
    plot(time,purity,'LineWidth',2.0,'Color',rgb);                   
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('Purity','Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
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