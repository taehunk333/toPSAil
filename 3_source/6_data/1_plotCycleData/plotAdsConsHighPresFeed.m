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
%Code last modified on : 2022/10/20/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotAdsConsHighPresFeed.m
%Source     : common
%Description: plot the adsobed phase concentrations for all columns
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             colNum       - a number for the column to plot the gas phase
%                            concentrations
%Outputs    : the plots for adsorbed phase concentrations for all species 
%             for all adsorption columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotAdsConsHighPresFeed(params,sol,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotAdsConsHighPresFeed';
    
    %Unpack Params
    nComs        = params.nComs             ;  
    lastStep     = sol.lastStep             ;
    aConScaleFac = params.aConScaleFac      ;
    heightCol    = params.heightCol         ; 
    nVols        = params.nVols             ;
    sStepCol     = params.sStepCol(colNum,:); %For the current column
    nSteps       = params.nSteps            ;
    sCom         = params.sCom              ;
    colorBnW     = params.colorBnW          ;
    nLKs         = params.nLKs              ;
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
                      ' Adsorbed Phase Conc. Profile');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [cm]');

    %Determine y-axis (absicissa) label
    ylabel('Conc. [mol/kg]');

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
    indHpEnd = lastStep-nSteps+indHp(end);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the adsorbed phase concentration profiles for the last high 
    %pressure feed
                                 
    %For each species,
    for i = 1 : nComs

        %Hold on to the figure
        hold on;

        %Grab total pressure for jth adsorption column in ith step
        pressure = sol.(append('Step',int2str(indHpEnd))). ...
                   col.(append('n',int2str(colNum))).adsCons. ...
                   (append('C',int2str(i)))(end,:) ...
                 * aConScaleFac;
             
        %If light key, then
        if i <= nLKs
            
            %Get the vector for the color
            rgb = grabColor(2,colorBnW);
        
        else
        %If heavy key, then
             
            %Get the vector for the color
            rgb = grabColor(1,colorBnW);
            
        end

        %Plot the ith step with jth column
        plot(height,pressure,'LineWidth',2.0,'Color',rgb);                

    end                 
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend(sCom,'Location','SouthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
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