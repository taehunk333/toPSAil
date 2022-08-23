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
%Code created on       : 2022/8/16/Tuesday
%Code last modified on : 2022/8/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : removeEnergyBalanceParams.m
%Source     : common
%Description: removes the parameters related to energy balance, after they 
%             are used for once and forever.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = removeEnergyBalanceParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'removeEnergyBalanceParams.m';        
    %---------------------------------------------------------------------%                                                          
    
    
    
    %---------------------------------------------------------------------%                                                          
    %Remove energy balance related fields that are no longer in use
        
    %Remove adsorption column related fields
    params = rmfield(params,'htTrCoInCol');                   
    params = rmfield(params,'htTrCoOutCol');    
    params = rmfield(params,'htCapCol');
    
    %Remove feed tank related fields
    params = rmfield(params,'htTrCoInFeTa');
    params = rmfield(params,'htTrCoOutFeTa');
    params = rmfield(params,'htCapFeTa');
    
    %Remove raffiante product tank related fields
    params = rmfield(params,'htTrCoInRaTa');
    params = rmfield(params,'htTrCoOutRaTa');
    params = rmfield(params,'htCapRaTa');
    
    %Remove extract product tank related fields
    params = rmfield(params,'htTrCoInExTa');
    params = rmfield(params,'htTrCoOutExTa');
    params = rmfield(params,'htCapExTa');
    
    %Remove heat capacity fields
    params = rmfield(params,'htCapCpC');
    params = rmfield(params,'htCapCvC');
    params = rmfield(params,'htCapSol');            
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%