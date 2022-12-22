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
%Code created on       : 2022/12/4/Sunday
%Code last modified on : 2022/12/4/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : tempProfHighPresFeed.m
%Source     : common
%Description: plots the temperature of the CSTRs for a given adsorption
%             column along the axial direction at a variety of time points.
%Inputs     : wsVarName    - a string variable for the workspace variable
%                            name
%Outputs    : plot         - the CSTR temperature profile plot for a given 
%                            adsorption column at different time points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tempProfHighPresFeed(wsVarName)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'tempProfHighPresFeed';
    
    %Load the workspace variables    
    load(wsVarName);
    
    %Current adsorber
    colNum = 1;
    
    %Unpack fullParams    
    lastStep   = sol.lastStep                 ;    
    heightCol  = fullParams.heightCol         ;
    nVols      = fullParams.nVols             ;
    sStepCol   = fullParams.sStepCol(colNum,:); %For the current column
    nSteps     = fullParams.nSteps            ;
    teScaleFac = fullParams.teScaleFac        ;
    tempCol    = fullParams.tempCol           ;
    nTiPts     = fullParams.nTiPts            ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
        
    %Create the figure
    figure(1);
    
    %Get the string for the title
    strTitle = ...
      append('Column ', ...
             int2str(colNum), ...
             ' Internal Temperature Profile');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [cm]');

    %Determine y-axis (absicissa) label
    ylabel('Temp. [K]');

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

    %Create a numerical array for holding the RGB values for the time
    %points
    rgbMat = zeros(nTiPts,3);
    
    %Seed for the gray scale
    seedGray = 0.9;
    
    %Initialize the first row with a gray scale
    rgbMat(1,:) = [seedGray,seedGray,seedGray];
    
    %Obtain the increment vector
%     incGray = flip(1./logspace(seedGray,0,nTiPts));
    incGray = linspace(seedGray,0,nTiPts);
    
    %For each time points, update the darkness
    for i = 2 : nTiPts
        
        %Update the matrix
        rgbMat(i,:) = [incGray(i),incGray(i),incGray(i)];
        
    end
    
    %Hold on to the figure
    hold on;

    %For each time point
    for i = 1 : nTiPts
    
        %Grab the current cloumn temperature
        currTempCstr ...
            = sol.(append('Step',int2str(indHpEnd))). ...
              col.(append('n',int2str(colNum))).temps.cstr(i,:) ...
            * teScaleFac;

        %Plot the ith step with jth column
        plot(height,currTempCstr,'LineWidth',2.0,'Color',rgbMat(i,:));   
        
        %Hold on to the figure
        hold on
    
    end
    %---------------------------------------------------------------------%  


    
    %---------------------------------------------------------------------%  
    %Plot isothermal temperature line
    
    %Grab a vector of isothermal temperatures
    tempColVec = tempCol*ones(1,nVols);
    
    %Hold on to the figure
    hold on
    
    %plot the numerical zero line
    plot(height,tempColVec,'--r','LineWidth',2);    
    
    %Hold off of a figure
    hold off
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
    
    %Set the limit on the x-axis
    xlim([0,heightCol]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0 0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,'temp.pdf'),'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%