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
%Code created on       : 2022/10/20/Thursday
%Code last modified on : 2022/10/20/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotGasConsHighPresFeed.m
%Source     : common
%Description: plot the gas phase concentrations for an adsorption column at
%             different number of CSTRs n_c. The data for the concentration
%             of species vs position is read in from .csv file in the same
%             directory.
%Inputs     : none         - n.a.
%Outputs    : the plots for gas phase concentrations for all species for
%             an adsorption column, at different number of CSTRs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotCompareGasConsHighPresFeed()

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotGasConsHighPresFeed';
    
    %Set the known parameters
    nCases       = 5                      ; %The number of different nVols
    sCases       = {'100', ...
                    '75', ...
                    '50', ...
                    '25', ...
                    '10'};
    nComs        = 2                      ; 
    sCom         = {'O2','N2'}            ;
    colorBnW     = {[0,0,0],[0.6,0.6,0.6]};
    nLKs         = 1                      ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure();
    
    %Get the string for the title
    strTitle = append('Adsorber 1, Gas Phase Conc. Profile');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [cm]');

    %Determine y-axis (absicissa) label
    ylabel('Conc. [mol/cc]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays

    %Initialize the array for storing the adsorber heights from each case
    heightCol = zeros(nCases,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the gas phase concentration profiles for the last high pressure
    %feed
                    
    %For each case, 
    for i = 1 : nCases
        
        %Grab the table name
        tableName = strcat('nc',sCases{i});

        %Grab the .csvfile and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Grab the vector of positions
        positions = matrix4Data{:,1};

        %Update the max height
        heightCol(i) = positions(end);

        %For each species,
        for j = 1 : nComs
    
            %Hold on to the figure
            hold on;
    
            %Grab the jth species concentration in ith case
            specConc = matrix4Data{:,j+1};
            
            %If light key, then
            if j <= nLKs
                
                %Get the vector for the color
                rgb = colorBnW{2};
            
            else
            %If heavy key, then
                 
                %Get the vector for the color
                rgb = colorBnW{1};
                
            end
                 
            %Plot the ith step with jth column
            plot(positions,specConc,'LineWidth',2.0,'Color',rgb);                
    
        end             

    end
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Set the height of the adsorber
    heightCol = max(heightCol);
    
    %Add entry to the legend
    legend(sCom,'Location','SouthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Set the limit on the x-axis
    xlim([0,heightCol]);
    
    %Add descriptors
%     text(55,5.75e-5,'n_c = 10','FontSize',14);
%     text(60,1.025e-4,'n_c = 100','FontSize',14);
%     text(60,1.50e-5,'n_c = 100','FontSize',14);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,'comp.pdf'),'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%