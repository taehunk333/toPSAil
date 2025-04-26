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
%Dynamic Modeling and Simulation of Pressure Swing Adsorption (PSA)
%Process Systems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code by               : Taehun Kim
%Review by             : Taehun Kim
%Code created on       : 2011/2/4/Thursday
%Code last modified on : 2023/7/4/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : programProfiler.m
%Source     : common
%Description: this is a function that calls runPsaProcessSimulation.m so
%             that MATLAB's profiler can be used to optimize the program.
%Inputs     : num          - an integer for the function call number
%Outputs    : n.a.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function programProfiler(varargin)        
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'programProfiler.m';
    
    %If there are user-defined inputs
    if ~isempty(varargin)
        
        %Let the first input be the function call number in integer
        num = varargin{1};
        
    %Otherwise
    else
        
        %Let the input num be an empty input
        num = [];
        
    end
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%
    %Profile the main function
    
    %Examples
    name = strcat("case_study_3.0");
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Get the final folder name
    
    %Append the name
    name = append(name);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Profile the code
            
    %Run the PSA process simulator
    runPsaProcessSimulation(name,num);        
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%