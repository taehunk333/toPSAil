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
%Code created on       : 2022/12/7/Wednesday
%Code last modified on : 2022/12/7/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotAxialPressureProfiles.m
%Source     : common
%Description: plots the axial pressure distribution of different simulation
%             runs.
%Inputs     : none         - n.a.
%Outputs    : the plots for gas phase concentrations for all species for
%             an adsorption column, at different number of CSTRs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotAxialPressureProfiles(tableNameStr)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotAxialPressureProfiles';
    
    %Set the known parameters
    nEqs         = 2; %Ergun and Kozeny-Carman
    nVolFls      = 3; %Large, medium, and small Cv
    %Large Cv  = 1.27E-05
    %Medium Cv = 
    %Small Cv  = 
  
    nHeats       = 2; %Isothermal vs. Nonisothermal
    nCases       = nEqs*nVolFls*nHeats; %The number of different nVols
    tableNames   = {'iso_v_large_ergun', ...
                    'iso_v_large_kozeny_carman', ...
                    'non_iso_v_large_ergun', ...
                    'non_iso_v_large_kozeny_carman', ...
                    'iso_v_medium_ergun', ...
                    'iso_v_medium_kozeny_carman', ...
                    'non_iso_v_medium_ergun', ...
                    'non_iso_v_medium_kozeny_carman', ...
                    'iso_v_small_ergun', ...
                    'iso_v_small_kozeny_carman', ...
                    'non_iso_v_small_ergun', ...
                    'non_iso_v_small_kozeny_carman'};  
                    
    %black = Ergun equation, gray = Kozeny-Carman equation
    colorBnW = {[0,0,0],[0.6,0.6,0.6]}; 
    
    %Let isothermal simulations be represented as dashed lines, and 
    %nonisothermal simulations be represented as solid lines
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure(1);
    
    %Get the string for the title
    strTitle = append('Pressures vs. Axial Direction');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Height [cm]');

    %Determine y-axis (absicissa) label
    ylabel('Pressure [bar]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays and read in the table
    
    %Initialize the cell array for containing the figures
    figCell = cell(nCases,1);
    
    %Grab the .csvfile and get the matrix
    matrix4Data = readtable(tableNameStr, ...
                            'VariableNamingRule', ...
                            'preserve');    
                        
    %Grab the vector of positions
    positions = matrix4Data{:,1};
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the gas phase concentration profiles for the last high pressure
    %feed
                    
    %For each case, 
    for i = 1 : nCases
        
        %Grab the table name
        tableName = tableNames{i};
        
        %Check to see if the table name contains "Ergun"
        hasErgun = contains(tableName,'ergun');
        
        %Check to see if the table name contains "non_iso"
        hasNonIso = contains(tableName,'non_iso');
        
        %If it does, then use black, 
        if hasErgun == 1
            
            %Set the color scale
            rgb = colorBnW{1};
            
        %otheriwse, use gray
        else
        
            %Set the color scale
            rgb = colorBnW{2};
            
        end
        
        %Get the pressure for the current case
        presCase = matrix4Data{:,i+1};
        
        %Hold on to the figure
        hold on;
        
        %If the figure is nonisothermal, use a solid line
        if hasNonIso == 1
            
            %Plot the ith step with jth column
            figCell{i} = ...
                plot(positions,presCase,'LineWidth',2.0,'Color',rgb);                 
        
        %Otherwise, use a dotted line
        else
            
            %Plot the ith step with jth column
            figCell{i} = ...
                plot(positions,presCase,'--','LineWidth',2.0,'Color',rgb);                     
            
        end

    end
    
    %Hold off the figure
    hold off;
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Set the height of the adsorber
    heightCol = max(positions);
    
    %Add entry to the legend
    %legend(,'Location','SouthWest');
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Set the limit on the x-axis
    xlim([0,heightCol]); 
    
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