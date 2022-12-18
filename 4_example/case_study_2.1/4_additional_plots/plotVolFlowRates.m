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
%Code created on       : 2022/12/17/Saturday
%Code last modified on : 2022/12/17/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotVolFlowRates.m
%Source     : common
%Description: plot the volumetric flow rates, the positive pseudo
%             volumetric flow rates, and the negative pseudo volumetric
%             flow rates, for the chosen step number in a simulated PSA
%             cycle, at a chosen time point.
%Inputs     : wsVarName    - a string for the file name
%             nStepCurr    - The current step number as an integer
%             nTimePtCurr  - The current time point to plot the volumetric
%                            flow rates
%             nAdsCurr     - the current number of adsorbers
%Outputs    : a single plot, showing all the volumetric flow rates vs.
%             axial direction in column height.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotVolFlowRates(wsVarName,nStepCurr,nTimePtCurr,nAdsCurr)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotVolFlowRates';
    
    %Import a .mat file containing the simulation results
    load(wsVarName);
    
    %Unpack fullParams 
    volScaleFac = fullParams.volScaleFac ;      
    heightCol   = fullParams.heightCol   ; 
    nVols       = fullParams.nVols       ;    
    nTiPts      = fullParams.nTiPts      ;
    tiScaleFac  = fullParams.tiScaleFac  ;   
    
    %Guard against specifying the time points beyond the available time pts
    if nTimePtCurr > nTiPts
       
        %Define strings
        str1 = "toPSAil: please provide a number less than";
        str2 = "for 'nTimePtCurr'"                         ;
        
        %Print out the error
        error(strcat(str1, " %i ", str2), nTiPts);        
        
    end
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Calculate axial distance for the adsorption column 
    height = linspace(0,heightCol,nVols+1);        
    
    %Get the duration of the current step
    durCurrStep = (sol.(append('Step',int2str(nStepCurr))). ...
                   timePts(nTimePtCurr) ...
                  -sol.(append('Step',int2str(nStepCurr))). ...
                   timePts(1))...
                * tiScaleFac;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = 101;
    
    %Create the figure
    figure(figNum);
    
    %Get the string for the title
    %strTitle = append("\it{t} = ", num2str(durCurrStep), ' seconds');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [cm]');

    %Determine y-axis (absicissa) label
    ylabel('Vol. F.R. [cc/sec]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;  
       
    %Get the vector for the color
    rgb = [0.6, 0.6, 0.6];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the adsorbed phase concentration profiles for the last high 
    %pressure feed
    
    %Hold on to the figure
    hold on;

    %Grab total pressure for jth adsorption column in ith step
    volFlOverall = sol.(append('Step',int2str(nStepCurr))). ...
                col.(append('n',int2str(nAdsCurr))).volFlRat ...
                (nTimePtCurr,:) ...
              * volScaleFac;

    %Plot the ith step with jth column
    plot(height,volFlOverall,'-','LineWidth',2.0,'Color',rgb);
    
    %Hold on to the figure
    hold on;
    
    %Grab total pressure for jth adsorption column in ith step
    volFlPlus = sol.(append('Step',int2str(nStepCurr))). ...
                col.(append('n',int2str(nAdsCurr))).volFlPlus ...
                (nTimePtCurr,:) ...
              * volScaleFac;

    %Plot the ith step with jth column
    plot(height,volFlPlus,'--b','LineWidth',2.0);        
    
    %Hold on to the figure
    hold on;
    
    %Grab total pressure for jth adsorption column in ith step
    volFlMinus = sol.(append('Step',int2str(nStepCurr))). ...
                 col.(append('n',int2str(nAdsCurr))).volFlMinus ...
                 (nTimePtCurr,:) ...
               * volScaleFac;

    %Plot the ith step with jth column
    plot(height,volFlMinus,'--r','LineWidth',2.0);            
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('\it{v_n} (\it{t})', ...
           '\it{v_n^+} (\it{t})', ...
           '\it{v_n^-} (\it{t})', ...
           'Location', 'NorthEast', ...           
           'Orientation','horizontal');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Set the limit on the x-axis
    xlim([0,heightCol]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0 0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf, ...
                   fullfile(pwd,strcat(wsVarName,'.pdf')), ...
                   'ContentType', ...
                   'vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%