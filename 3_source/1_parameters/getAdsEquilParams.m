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
%Code created on       : 2022/1/24/Monday
%Code last modified on : 2022/1/24/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getAdsEquilParams.m
%Source     : common
%Description: given an initial set of parameters, define parameters that
%             are associated with adsorption equilibrium (isotherm)
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getAdsEquilParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getAdsEquilParams.m';
    
    %Unpack params            
    modSp = params.modSp;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Based on the isotherm model, compute any necessary parameters

    %Check the isotherm model
    whichIsotherm = modSp(6);

    %A custom isotherm
    if whichIsotherm == 0
        
        %Currently, no custom isotherm model is supported.
        error("toPSAil: No custom isotherm model is supported.")

    %Henry's law or Extended Langmuir isotherm
    elseif whichIsotherm == 1 || ...
           whichIsotherm == 2

        %Unpack additional params
        gasCons    = params.gasCons   ; 
        tempRefIso = params.tempRefIso;
        isoStHtC   = params.isoStHtC  ;

        %Calculate the constant factor inside the exponent: 
        %(J/mol-L)/(J/mol-L)
        dimLessIsoStHtRef = isoStHtC ...
                         ./ ((gasCons/10)*tempRefIso);
       
    end
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Return the updated structure

    %Update params
    params.dimLessIsoStHtRef = dimLessIsoStHtRef;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%