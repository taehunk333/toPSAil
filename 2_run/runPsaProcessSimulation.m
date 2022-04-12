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
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2022/2/17/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : runPsaProcessSimulation.m
%Source     : run
%Description: a MATLAB® function file in which different MATLAB® functions
%             are called to simulate a pressure swing adsorption (PSA)
%             process, plot the simulation results, and save the results as
%             .csv files in the designated folder.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : n.a.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runPsaProcessSimulation(folderName)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'runPsaProcessSimulation.m';        
    %---------------------------------------------------------------------%

    
    
    %---------------------------------------------------------------------%
    %Clear the work space and any open windows
    
    %Clear up the command window
    clc;
    
    %Close all the open figures
    close all;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Print out the license related information
    
    %Read the remark file
    S = fileread('remarks.txt');
    
    %Display the strings
    disp(S);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check the function input and make sure it is a string variable
    %denoting the name of the folder containing the example file
    
    %If the input is not a scalar variable or no input is given, then 
    %terminate the program and post the warning.
    if isstring(folderName) == 0 || isempty(folderName) == 1
        
        %Print the error message
        msg = 'Please provide a string variable (example folder name).';
        msg = append(funcId,': ',msg);
        error(msg);     
        
    end    
    %---------------------------------------------------------------------%
    


    %---------------------------------------------------------------------%
    %Define all the user inputs inside a struct
    
    %Define the name of the example containing folder
    user.folderNameExample = folderName;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Import paths that are relevant for running a simulation
    
    %Call the function that imports all the relevant paths
    [~,~,exampleFolder] = definePath2SourceFolders(user);
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the simulation environment    
    
    %Define a struct called params that contains simulation parameters
    params = getSimParams(exampleFolder);  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Perform the simulation
    
    %If we have a single step,
    if params.nSteps == 1
        
        %We are doing a breakthrough simulation
        fprintf('Beginning a breakthrough simulation...\n\n');
    
    %If more than a single step, 
    else
        
        %We are doing a PSA cycle simulation
        fprintf('Beginning a PSA cycle simulation...\n\n');
        
    end            
    
    %Run the timer
    [initime,time] = startFuncTimer();
       
    %Call runPsaCycle.m function to simulate a given cycle
    sol = runPsaCycle(params);        
      
    %Print out the section header
    fprintf('\n For the cycle simulation, \n');

    %Finish running the timer
    finishFuncTimer(initime,time);
    
    %Enter a line
    fprintf("\n\n");
    
    %If we have a single step,
    if params.nSteps == 1
        
        %We are doing a breakthrough simulation
        fprintf('The breakthrough simulation has finished! \n\n'); 
    
    %If more than a single step, 
    else
        
        %We are doing a PSA cycle simulation
        fprintf('The PSA cycle simulation has finished! \n\n'); 
        
    end               
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Perform post simulation data analysis        
    
    %Insert a preamlbe for the command window output
    fprintf('Begin plotting simulation results...\n\n');
    
    %Plot the simulation results
    plotPsaSimulationResults(params,sol);    
    
    %Insert a conclusion for the command window output
    fprintf('The plotting has finished! \n\n'); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save simulation results
    
    %Insert a preamlbe for the command window output
    fprintf('Saving simulation results...\n\n');
    
    %Save simulation outputs into excel files
    savePsaSimulationResults(params,sol,exampleFolder);
    
    %Insert a conclusion for the command window output
    fprintf('Check the example folder! \n\n'); 
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Clear any path assignments
    
    %Restore the default path to MATLAB by removing any previously added
    %paths
    restoredefaultpath;   
    %---------------------------------------------------------------------%
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%