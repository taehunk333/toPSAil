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
%Code last modified on : 2022/1/31/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotColCstrTempProfiles.m
%Source     : common
%Description: plot the temperature of the CSTRs for a given adsorption
%             column along the axial direction
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             colNum       - a number for the column to plot the gas phase
%                            concentrations
%Outputs    : the CSTR temperature profile plot for a given adsorption
%             column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotColCstrTempProfiles(params,sol,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotColCstrTempProfiles';
    
    %Unpack Params    
    lastStep   = sol.lastStep          ;    
    heightCol  = params.heightCol      ;
    nVols      = params.nVols          ;
    sStep      = params.sStep(colNum,:); %For the current column
    nSteps     = params.nSteps         ;
    teScaleFac = params.teScaleFac     ;
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
             ' Internal Temperature Profile');
    
    %Set the title for the figure
    title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [=] cm');

    %Determine y-axis (absicissa) label
    ylabel('Temperature [=] K');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',10)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Calculate axial distance for the adsorption column 
    height = linspace(1,heightCol,nVols);
    
    %Find the high pressure step
    indHp = find(sStep=="HP");
    
    %Find the last high pressure step
    indHpEnd = lastStep ...
             - nSteps ...
             + indHp(end);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Plot the inital temperature profile for the last HP step

    %Hold on to the figure
    hold on;

    %Grab the initial cloumn temperature
    initTempCstr = sol.(append('Step',int2str(indHpEnd))). ...
                   col.(append('n',int2str(colNum))).temps.cstr(1,:) ...
                 * teScaleFac;

    %Plot the ith step with jth column
    plot(height,initTempCstr,'LineWidth',2.0);                
    %---------------------------------------------------------------------%  



    %---------------------------------------------------------------------%  
    %Plot the final temperature profile for the last HP step

    %Hold on to the figure
    hold on;

    %Grab the final cloumn temperature
    finalTempCstr = sol.(append('Step',int2str(indHpEnd))). ...
                    col.(append('n',int2str(colNum))).temps.cstr(end,:) ...
                  * teScaleFac;

    %Plot the ith step with jth column
    plot(height,finalTempCstr,'LineWidth',2.0);            
    %---------------------------------------------------------------------%  

    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend({'Initial (HP)','Final (HP)'},'Location','NorthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,500]);
    
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