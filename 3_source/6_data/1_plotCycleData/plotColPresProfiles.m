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
%Code last modified on : 2022/3/8/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotColPresProfiles.m
%Source     : common
%Description: plot the pressure profile for all columns
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the pressure profile for all columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotColPresProfiles(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotColPresProfiles';
    
    %Unpack Params
    nCols        = params.nCols       ;
    tiScaleFac   = params.tiScaleFac  ;
    lastStep     = sol.lastStep       ;
    presColHigh  = params.presColHigh ;
    color        = params.color       ;
    nVols        = params.nVols       ;
    gasCons      = params.gasCons     ;
    teScaleFac   = params.teScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Set up the figure for plotting
    
    %Grab the next figure number
    figNum = grabNextFigNum();
    
    %Create the figure
    figure(figNum);      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %We want to determine the upper bound of the y axis-
      
    %Initialize the upper limit of the y-axis
    yLimUp = 0;
    
    %Compute the test sign
    testSign = round(presColHigh)-presColHigh;
    
    %If the 
    if testSign <= 0 
        
        yLimUp = round(presColHigh) ...
               + 0.5;
        
    elseif testSign > 0
        
        yLimUp = round(presColHigh);
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the pressure profiles for all columns for all simulated steps all
    %in one plot
      
    %For each step that was simulated,
    for i = 1 : lastStep
       
        %Grab dimensional times
        time = tiScaleFac*sol.(append('Step',int2str(i))).timePts;
                
        %For each adsorption column,
        for j = 1 : nCols                        
            
            %Hold on to the figure
            hold on;
            
            %Get the string for the color
            rgb = grabColor(j,color);                        
                                    
            %Grab total pressure for jth adsorption column in ith step
            %(For the sake of computational efforts, just plot the last
            %CSTR total pressure, assuming the axially constant pressure
            %DAE models)
            pressure ...
                = sum(sol.(append('Step',int2str(i))). ...
                      col.(append('n',int2str(j))).gasConsTot,2) ...
               ./ nVols ...
               .* gConScaleFac ...
               .* gasCons ...
               .* sum(sol.(append('Step',int2str(i))). ...
                      col.(append('n',int2str(j))).temps.cstr,2) ...
               ./ nVols ...
               .* teScaleFac;
            
            %Use subplot only when we have more than 1 columns
            if nCols > 1
                
                %Use subplot
                subplot(nCols,1,j);
                
            end
            
            %Plot the ith step with jth column
            plot(time,pressure,'LineWidth',2.0,'Color',rgb);
            
            %Hold on to the figure
            hold on;
            
            %Plot a vertical line, demarcating different step
            xline(time(end),'--','color', [.5 .5 .5]);
            
            %Get the plot title
            titleStr ...
                = append('Adsorption Column ', ...
                          int2str(j), ...
                          ' Average Pressure Profile');
            
            %Set the title for the figure
            %title(titleStr);

            %Determine x-axis (ordinate) label
            xlabel('Time [=] sec');

            %Determine y-axis (absicissa) label
            ylabel('Pressure [=] bar');

            %Set the style of the axis font as LaTeX type
            set(gca,'TickLabelInterpreter','latex');
            set(gca,'FontSize',14)                 ; 
            
            %Set the limit on th y-axis
            ylim([0,yLimUp]);
            
        end
                
    end    
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%  
    %Make any terminal settings
    
    %Resize the figure
    set(gcf,'Position',[100,25,600,250]);
    
    %Hold off of the figure
    hold off;    
    
    %Make sure that the plot is surrounded by a box
    box on;
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%