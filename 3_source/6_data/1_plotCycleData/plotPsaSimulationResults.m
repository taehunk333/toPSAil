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
%Code created on       : 2019/5/13/Monday
%Code last modified on : 2022/1/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotPsaSimulationResults.m
%Source     : common
%Description: takes in data from dynamic simulation of pressure swing
%             adsorption (PSA) process of choice and returns the vizualized
%             form of the data using MATLAB®'s data visualization tools.
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : the user requested plots of the simulation results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotPsaSimulationResults(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'plotPsaSimulationResults';
    
    %Unpack Params
    plot    = params.plot  ;
    nCols   = params.nCols ;
    figPath = sol.path.figs;
    
    %Get simulation plotting params
    params = getSimPlotParams(params);
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Initialze before plotting
    
    %Close any figures that are currently open
    close all;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for the first plotting mode
    
    %If user requested the plot,     
    if plot(1) == 1
        
        %Plot the pressure profiles for the adsorption column(s)
        plotColPresProfiles(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'colPresProfile.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
                
    end              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for the second plotting mode
    
    %If user requested the plot,     
    if plot(2) == 1
        
        %Plot the pressure profiles for the raffinate product receiver tank
        plotRaTaPresProfiles(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'raTaPresProfile.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
        %Plot the pressure profiles for the extract product receiver tank
        plotExTaPresProfiles(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'exTaPresProfile.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
                        
    end              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Check for the third plotting mode
    
    %If user requested the plot,     
    if plot(3) == 1
        
        %For each adsorption column,
        for i = 1 : nCols
            
            %Plot gas phase concentrations for all species for all 
            %adsorption columns
            plotGasConsHighPresFeed(params,sol,i);
            
            %Get the current figure and its information
            figObj = gcf;

            %Get the full filename
            figName = strcat('gasConsCol', ...
                             int2str(i), ...
                             '.eps'); 

            %Save the figure to a .eps file
            saveFigs2Eps(figObj,figPath,figName);
            
        end
                
    end              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Check for the fourth plotting mode
    
    %If user requested the plot,     
    if plot(4) == 1
        
        %For each adsorption column,
        for i = 1 : nCols
            
            %Plot adsorbed phase concentrations for all species for all 
            %adsorption columns
            plotAdsConsHighPresFeed(params,sol,i);
            
            %Get the current figure and its information
            figObj = gcf;

            %Get the full filename
            figName = strcat('adsConsCol', ...
                             int2str(i), ...
                             '.eps'); 

            %Save the figure to a .eps file
            saveFigs2Eps(figObj,figPath,figName);
            
        end
                        
    end              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Check for the fifth plotting mode
    
    %If user requested the plot,     
    if plot(5) == 1
        
        %For each adsorption column,
        for i = 1 : nCols
            
            %Plot the breakthrough curve for ith adsorption column
            plotBreakThroughCurve(params,sol,i);
            
            %Get the current figure and its information
            figObj = gcf;

            %Get the full filename
            figName = strcat('brkThrCol', ...
                             int2str(i), ...
                             '.eps'); 

            %Save the figure to a .eps file
            saveFigs2Eps(figObj,figPath,figName);
            
        end 
                        
    end              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Check for the sixth plotting mode
    
    %If user requested the plot,     
    if plot(6) == 1
        
        %Plot product purity inside the raffinate product tank
        plotRaTaPurity(params,sol,1);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'raTaPurity.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
        %Plot product purity inside the extract product tank
        plotExTaPurity(params,sol,1);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'exTaPurity.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
     
    end              
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Check for the seventh plotting mode
    
    %If user requested the plot,     
    if plot(7) == 1
        
        %For each adsorption column,
        for i = 1 : nCols
        
            %Plot temperature profile for the cstrs associated with a given
            %adsorption column
            plotColCstrTempProfiles(params,sol,i);
            
            %Get the current figure and its information
            figObj = gcf;

            %Get the full filename
            figName = strcat('cstrTempCol', ...
                             int2str(i), ...
                             '.eps'); 

            %Save the figure to a .eps file
            saveFigs2Eps(figObj,figPath,figName);
            
            %Plot temperature profile for the cstr walls associated with a
            %given adsorption column
            plotColWallTempProfiles(params,sol,i);
            
            %Get the current figure and its information
            figObj = gcf;

            %Get the full filename
            figName = strcat('wallTempCol', ...
                             int2str(i), ...
                             '.eps'); 

            %Save the figure to a .eps file
            saveFigs2Eps(figObj,figPath,figName);
            
        end        
                        
    end              
    %---------------------------------------------------------------------%              
    
    
    
    %---------------------------------------------------------------------%              
    %Check for the eighth plotting mode
    
    %If user requested the plot,     
    if plot(8) == 1
        
        %Plot Product Purity Profile
        plotProductPurity(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'productPurity.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
    end       
    %---------------------------------------------------------------------%   
    
    
    
    %---------------------------------------------------------------------%              
    %Check for the ninth plotting mode
    
    %If user requested the plot,     
    if plot(9) == 1
        
        %Plot Product Purity Profile
        plotProductRecovery(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'productRecovery.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
    end       
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%              
    %Check for the tenth plotting mode
    
    %If user requested the plot,     
    if plot(10) == 1
        
        %Plot Product Purity Profile
        plotProductivity(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'productivity.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
    end       
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%              
    %Check for the eleventh plotting mode
    
    %If user requested the plot,     
    if plot(11) == 1
        
        %Plot Product Purity Profile
        plotEnergyConsumption(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'energyConsumption.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
    end       
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%              
    %Check for the twelfth plotting mode
    
    %If user requested the plot,     
    if plot(12) == 1
        
        %Plot Product Purity Profile
        plotCssConv(params,sol);
        
        %Get the current figure and its information
        figObj = gcf;
        
        %Get the full filename
        figName = 'css.eps'; 
                
        %Save the figure to a .eps file
        saveFigs2Eps(figObj,figPath,figName);
        
    end       
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%