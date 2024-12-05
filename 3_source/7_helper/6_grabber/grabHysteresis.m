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
%Function   : grabHysteresis.m
%Source     : common
%Description: given the information about the hysteresis, grab the isotherm
%             parameters that are applicable for the specified hysteresis
%             curve for the adsorption isotherm
%Inputs     : params       - a data structure containing the simulation
%                            parameters.
%             hys          - an vector containing integers denoting which 
%                            hsysteresis curve we are on for each adsorber.
%                            An entery of 0 means no hysteresis, an entry 
%                            of 1 means hysteresis curve for adsorption, 
%                            and an entry of 2 means hysteresis curve for 
%                            desorption.
%Outputs    : params       - a data structure containing the simulation
%                            parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = grabHysteresis(params,hys)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabHysteresis.m';
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%           
    %Perform necessary calculations
    
    %Check to see if we have a zero or zero vector
    isHysZero = ~any(hys);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%           
    %Save the result
    
    %Save hys to params as a field, only when we do not have a zero vector
    if isHysZero == 0
    
        %Save the hysteresis information into the structure
        params.hys = hys;    
        
    end
    %---------------------------------------------------------------------%             
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%