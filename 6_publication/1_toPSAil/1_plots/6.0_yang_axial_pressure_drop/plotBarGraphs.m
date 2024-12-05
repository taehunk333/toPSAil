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
%Function   : plotBarGraphs.m
%Source     : common
%Description: plots the CSS convergence criteria vs. PSA cycle number for 
%             the differen simulation modes for a given experimental
%             system. The simulation modes are:
%             (1) pressure-driven + time-driven (i.e., uncontrolled)
%             (2) pressure-driven + event-driven
%             (3) flow-driven + time-driven
%             (4) flow-driven + event-driven (i.e., controlled)
%Inputs     : numExamples  - the number of different simulations where we
%                            plan on importing the data
%Outputs    : the plot for comparing the numerical intagration statistics
%             for different simulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotBarGraphs(numExamples)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotCssComparisons';
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Create the figure
    figure;
    
    %Get the string for the title
    %strTitle = append('Numerical Integration Stats.');
    
    %Set the title for the figure
    %title(strTitle);

    %Determine x-axis (ordinate) label
    xlabel('Steps in a PSA cycle [-]');

    %Determine y-axis (absicissa) label
    ylabel('Solver steps [-]');

    %Set the style of the axis font as LaTeX type
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',14)                 ; 
    
    %Force the y-axis to be log scale
    set(gca,'YScale','log');

    %Determine the color scales
    colorRgb = linspace(0,0.6,numExamples);

    %Initialize the cell array
    colorRgbCell = cell(numExamples,1);

    %For each example,
    for i = 1 : numExamples

        %Set the cell array for stroing the colors
        colorRgbCell{i} = [colorRgb(i),colorRgb(i),colorRgb(i)];

    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the necessary quantity
    
    %Initialize the max step
    getMax = 0;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the bar graphs

    %For each simulation
    for i = 1 : numExamples
  
        %-----------------------------------------------------------------%
        %Obtain and analyze the data
    
        %Grab the table name
        tableName = strcat('data',int2str(i));
    
        %Grab the .csv file and get the matrix
        matrix4Data = readtable(tableName, ...
                                'VariableNamingRule', ...
                                'preserve');

        %Get the number of steps
        [~,nc]  = size(matrix4Data);
        numSteps = nc-1             ;
    
        %Obtain the step names as a cell array containing the strings
        stepNames = matrix4Data.Properties.VariableNames(2:end);

        %Grab the success data
        successData = matrix4Data{1,2:end};
    
        %Grab the failure data
        failureData = matrix4Data{2,2:end};  
        
        %Update the max data count
        getMax = max([successData+failureData,getMax]);
        %-----------------------------------------------------------------%
    
    
        
        %-----------------------------------------------------------------%
        %Initailzie the needed quantities

        %Initialize the y-data for the bar charts for the given simulation
        ySuccess = zeros(numSteps,numExamples);
        yFailure = zeros(numSteps,numExamples); 
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Plot each simulation result for the side-by-side comparisons of 
        %the statistics for the numerical integration of different 
        %simulation results
                   
        %Hold on to the figure
        hold on;

        %Obtain the step names
        x = categorical(stepNames);

        %Populate the y-data
        
        %For each step in a PSA cycle
        for k = 1 : numSteps

           %Update ySuccess
           ySuccess(k,i) = successData(k);
           
           %Update yFailure
           yFailure(k,i) = failureData(k);
               
        end

        %For each j \in {success, failure},
        for j = 1 : 2
            
            %When doing success
            if j == 1
                
                %Plot a box plot, only with a boarder
                bar(x,ySuccess+yFailure,'white')

                %Let the next plot to be added
                set(gca,'nextplot','add')
                    
            %When doing failure
            elseif j == 2

                %Plot a box plot, only with a boarder
                bar(x,yFailure,'FaceColor',colorRgbCell{i})

                %Let the next plot to be added
                set(gca,'nextplot','add')

            end

        end

        %Hold off of a figure
        hold off          
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%  
      

    
    %---------------------------------------------------------------------%  
    %Make any terminal settings                       

    %Resize the figure
    set(gcf,'Position',[100,25,575,250]);
    
    %Set the limit on the y-axis
    ylim([1,getMax+300]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    
    %Adjust margin
    a = annotation('rectangle',[0.0 0.0 1 1],'Color','w');
    
    %File name
    outputName = strcat('stats','.pdf');
    
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