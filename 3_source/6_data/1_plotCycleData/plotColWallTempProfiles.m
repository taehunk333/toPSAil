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
%Code last modified on : 2022/10/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotColWallTempProfiles.m
%Source     : common
%Description: plot the CSTR wall temperatures for a given adsorption column 
%             along the axial direction
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             colNum       - a number for the column to plot the gas phase
%                            concentrations
%Outputs    : the CSTR wall temperature profile plot for a given adsorption
%             column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotColWallTempProfiles(params,sol,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotColWallTempProfiles';
    
    %Unpack Params
    lastStep   = sol.lastStep             ;    
    heightCol  = params.heightCol         ;
    nVols      = params.nVols             ;
    sStepCol   = params.sStepCol(colNum,:); %For the current column
    nSteps     = params.nSteps            ;
    teScaleFac = params.teScaleFac        ;
    colorBnW   = params.colorBnW          ;
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
             ' Wall Temperature Profile');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height (cm)');

    %Determine y-axis (absicissa) label
    ylabel('Temp. (K)');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Calculate axial distance for the adsorption column 
    height = linspace(0,heightCol,nVols);
    
    %Find the high pressure steps
    indHp = contains(sStepCol,"HP");
    
    %Find the last high pressure step
    indHp = find(indHp,1,'last');
    
    %Find the last high pressure step
    indHpEnd = lastStep ...
             - nSteps ...
             + indHp(end);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Plot the inital temperature profile for the last HP step

    %For the wall temperature, use a black color
    rgb = grabColor(1,colorBnW);
    
    %Hold on to the figure
    hold on;

    %Grab the initial cloumn temperature
    initTempCstr = sol.(append('Step',int2str(indHpEnd))). ...
                   col.(append('n',int2str(colNum))).temps.wall(1,:) ...
                 * teScaleFac;

    %Plot the ith step with jth column
    plot(height,initTempCstr,'LineWidth',2.0,'Color',rgb);                
    %---------------------------------------------------------------------%  



    %---------------------------------------------------------------------%  
    %Plot the final temperature profile for the last HP step

    %For the CSTR temperature, use a light gray color
    rgb = grabColor(2,colorBnW);
    
    %Hold on to the figure
    hold on;

    %Grab the final cloumn temperature
    finalTempCstr = sol.(append('Step',int2str(indHpEnd))). ...
                    col.(append('n',int2str(colNum))).temps.wall(end,:) ...
                  * teScaleFac;
 
    %Plot the ith step with jth column
    plot(height,finalTempCstr,'LineWidth',2.0,'Color',rgb);            
    %---------------------------------------------------------------------%  

    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend({'Initial (HP)','Final (HP)'},'Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
    
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