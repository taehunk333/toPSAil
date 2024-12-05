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
%Function   : definePath2SourceFolders.m
%Source     : run
%Description: a MATLAB� function file that defines paths to the folders
%             containing functions needed for simulating a system defined
%             by the information specified by the user
%Inputs     : user         - a struct containing user specified information
%                            on the simulation
%Outputs    : cuFolder     - a string denoting a location of the current
%                            folder
%             soFolder     - a string denoting a location of the source
%                            folder
%             exFolder     - a string denoting a location of the example
%                            folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cuFolder,soFolder,exFolder] = definePath2SourceFolders(user)

    %---------------------------------------------------------------------%
    %Initialize the path assignment
    
    %Restore the default path to MATLAB by removing any previously added
    %paths
    restoredefaultpath;        
    %---------------------------------------------------------------------%
    
    

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    st     = dbstack                      ;
    funcId = st.name                      ;
    funcId = convertCharsToStrings(funcId);
    
    %Unpack the struct called user
    name = user.folderNameExample;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Define paths for MATLAB� functions to be used for the simulation
        
    %Define the path of the current folder
    cuFolder = fileparts(which(funcId));

    %Define the path for the folder containing folders containing source 
    %functions
    soFolder = fullfile(cuFolder,'..','3_source');
    
    %Define the path for the folder containing configuration files from
    %MATLAB file exchange. 
    coFolder = fullfile(cuFolder,'..','1_config');    
    
    %Define the path for the folder containing examples
    exFolder = fullfile(cuFolder,'..','4_example');
    
    %Choose a specific example to be simulated
    exFolder = fullfile(exFolder,name);    
    
    %Define the path for the folder containing test scripts
    teFolder = fullfile(cuFolder,'..','5_tests');
    
    %Add paths for the folders
    addpath(genpath(soFolder));          
    addpath(genpath(coFolder));
    addpath(genpath(exFolder));
    addpath(genpath(teFolder));
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%