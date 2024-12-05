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
%Function   : calcMolAvgProp.m
%Source     : common
%Description: given a vector of mole fraction and a vector containing a
%             given property for each species, construct the corresponding
%             molar average property
%Inputs     : moleFrac     - a vector containing the mole fraction of all
%                            the species inside the system
%             property     - a vector containing the property values for
%                            all species inside the system
%Outputs    : molAvgProp   - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function molAvgProp = calcMolAvgProp(moleFrac,property)  
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcMolAvgProp.m';
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------% 
    %Check function inputs
    
    %Check if the inputs are vectors
    if ~isvector(moleFrac) || ~isvector(property)
    
        %Print the error message
        msg = 'Please provide vectors as inputs';
        msg = append(funcId,': ',msg)           ;
        error(msg)                              ; 
        
    end        
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%                  
    %Get molar averaged mixture property
    
    %Elementwise multiply the two vectors 
    molAvgProp = moleFrac.*property;        
    
    %Make the vector a column vector and sum the entries
    molAvgProp = sum(molAvgProp(:),1);    
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%