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
%Code created on       : 2022/12/5/Monday
%Code last modified on : 2022/12/5/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : adsConcComp.m
%Source     : common
%Description: plots the adsorbed phase concentrations for the two different 
%             simulation results to enable comparisons. We are interested 
%             in plotting isothermal vs. nonisothermal results.
%Inputs     : wsVarName1   - a string variable for the workspace variable
%                            name
%             wsVarName2   - a string variable for the workspace variable
%                            name
%Outputs    : plot         - the CSTR temperature profile plot for a given 
%                            adsorption column at different time points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function adsConcComp(wsVarName1,wsVarName2)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'adsConcComp';
    
    %Load the workspace variables    
    load(wsVarName1);
    
    %Current adsorber
    colNum = 1;
    
    %Unpack fullParams
    nComs        = fullParams.nComs             ;  
    lastStep     = sol.lastStep                 ;
    aConScaleFac = fullParams.aConScaleFac      ;
    heightCol    = fullParams.heightCol         ; 
    nVols        = fullParams.nVols             ;
    sStepCol     = fullParams.sStepCol(colNum,:); %For the current column
    nSteps       = fullParams.nSteps            ;
    nLKs         = fullParams.nLKs              ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure(1);
    
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
            rgb = [0.6 0.6 0.6];
        
        else
        %If heavy key, then
             
            %Get the vector for the color
            rgb = [0 0 0];
            
        end

        %Plot the ith step with jth column
        plot(height,pressure,':','LineWidth',2.0,'Color',rgb);                

    end                 
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Clear the work space
    clearvars -except wsVarName2;
    
    %Load the workspace variables    
    load(wsVarName2);
    
    %Current adsorber
    colNum = 1;
    
    %Unpack fullParams
    nComs        = fullParams.nComs             ;  
    lastStep     = sol.lastStep                 ;
    aConScaleFac = fullParams.aConScaleFac      ;
    heightCol    = fullParams.heightCol         ; 
    nVols        = fullParams.nVols             ;
    sStepCol     = fullParams.sStepCol(colNum,:); %For the current column
    nSteps       = fullParams.nSteps            ;
    nLKs         = fullParams.nLKs              ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %hold on to the figure
    hold on;                
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
            rgb = [0.6 0.6 0.6];
        
        else
        %If heavy key, then
             
            %Get the vector for the color
            rgb = [0 0 0];
            
        end
    
        %Plot the ith step with jth column
        plot(height,pressure,'*','LineWidth',2.0,'Color',rgb);                

    end                 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Add entry to the legend
    legend('Nonisothermal (H2)','Nonisothermal (CO)', ...
           'Isothermal (H2)', 'Isothermal (CO)', ...
           'Location','SouthWest');
    
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
    exportgraphics(gcf,fullfile(pwd,'ads.pdf'),'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%