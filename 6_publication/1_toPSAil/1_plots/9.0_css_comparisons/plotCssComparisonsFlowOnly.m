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
%Function   : plotCssComparisonsFlowOnly.m
%Source     : common
%Description: plots the CSS convergence criteria vs. PSA cycle number for 
%             the flow driven simulation modes for Kayser's and Yang's
%             experiments.
%             numZero      - a scalar denoting the absolute tolerance for
%                            attaining the css 
%Outputs    : the plot for comparing the CSS convergence criteria vs. PSA
%             cycle number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotCssComparisonsFlowOnly(numZero)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotCssComparisonsFlowOnly';
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure;
    
    %Get the string for the title
    %strTitle = append('CSS convergence rates');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('At the end of the n^{th} Cycle. [-]');

    %Determine y-axis (absicissa) label
    ylabel('CSS Conv. [-]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ; 
    
    %Force the y-axis to be log scale
    set(gca,'YScale','log');
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot each simulation result for the side-by-side comparisons of the
    %CSS convergence rates for the different simulation modes
        
        %-----------------------------------------------------------------%
        %The first simulation result: the pressure-driven plus time-driven,
        %i.e., uncontrolled, simulation mode
        
        %Hold on to the figure
        hold on;
        
        %Grab the table name
        tableName = strcat('kayser_flow_time');

        %Grab the .csv file and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Grab the vector of positions
        cycNo1 = matrix4Data{:,1};

        %Update the max height
        cssCrit1 = matrix4Data{:,2};        

        %Plot the results
        semilogy(cycNo1,cssCrit1,'-o', ...
                'LineWidth',2.0,'Color',[0.6,0.6,0.6]);

        %Clear the work space
        clearvars -except numZero expName cycNo1;          
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %The second simulation result: the pressure-driven plus 
        %event-driven simulation mode
    
        %Hold on to the figure
        hold on;
        
        %Grab the table name
        tableName = strcat('kayser_flow_event');

        %Grab the .csv file and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Grab the vector of positions
        cycNo2 = matrix4Data{:,1};

        %Update the max height
        cssCrit2 = matrix4Data{:,2};        

        %Plot the results
        semilogy(cycNo2,cssCrit2,':o', ...
                 'LineWidth',2.0,'Color',[0,0,0]);

        %Clear the work space
        clearvars -except numZero expName cycNo1 cycNo2;        
        %-----------------------------------------------------------------%
                
        
        
        %-----------------------------------------------------------------%
        %The third simulation result: the flow-driven plus time-driven 
        %simulation mode
        
        %Hold on to the figure
        hold on;
        
        %Grab the table name
        tableName = strcat('yang_flow_time');

        %Grab the .csv file and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Grab the vector of positions
        cycNo3 = matrix4Data{:,1};

        %Update the max height
        cssCrit3 = matrix4Data{:,2};        
        
        %Plot the results
        semilogy(cycNo3,cssCrit3,'-square', ...
                 'LineWidth',2.0,'Color',[0.6,0.6,0.6]);
        
        %Clear the work space
        clearvars -except numZero expName cycNo1 cycNo2 cycNo3;
        %-----------------------------------------------------------------%   
        
        
        
        %-----------------------------------------------------------------%
        %The fourth simulation result: the flow-driven plus event-driven,  
        %i.e., controlled, simulation mode
        
        %Hold on to the figure
        hold on;
        
        %Grab the table name
        tableName = strcat('yang_flow_event');

        %Grab the .csv file and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Grab the vector of positions
        cycNo4 = matrix4Data{:,1};

        %Update the max height
        cssCrit4 = matrix4Data{:,2};        
        
        %Plot the results
        semilogy(cycNo4,cssCrit4,':square', ...
                 'LineWidth',2.0,'Color',[0,0,0]);        
        %-----------------------------------------------------------------%
              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Plot the CSS convergence line
    
    %Set the height of the adsorber
    cycNoMax = max([max(cycNo1), ...
                    max(cycNo2), ...
                    max(cycNo3), ...
                    max(cycNo4)]);
    
    %Get a vector of cycle number
    cycNoVex = linspace(1,cycNoMax,cycNoMax);
                
    %Grab a vector of isothermal temperatures
    cycNoCssVec = numZero*ones(1,cycNoMax);
    
    %Hold on to the figure
    hold on
    
    %plot the numerical zero line
    semilogy(cycNoVex,cycNoCssVec,'--r','LineWidth',2);    
    
    %Hold off of a figure
    hold off
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings        
    
    %Add entry to the legend
%     legend('pres.+time', ...
%            'pres.+event', ...
%            'flow+time', ...
%            'flow+event', ...
%            'Location', ...
%            'NorthEast');
    
    legend('[K] flow+time', ...           
           '[K] flow+event', ...
           '[Y] flow+time', ...
           '[Y] flow+event', ...
           'Location', ...
           'NorthEast');

    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
    
    %Set the limit on the x-axis
    xlim([1,cycNoMax]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %File name
    outputName = strcat('CssFlow','.pdf');
    
    %Save the figure as .eps
    exportgraphics(gcf,fullfile(pwd,outputName), ...
                   'ContentType','vector');
    
    %Delete the annotation
    delete(a);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%