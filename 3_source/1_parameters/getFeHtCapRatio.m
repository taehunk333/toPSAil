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
%Code created on       : 2021/2/19/Friday
%Code last modified on : 2022/10/29/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getFeHtCapRatio.m
%Source     : common
%Description: based on the feed mole fraction, constant volume and constant
%             pressure heat capacities, compute the ratio of the overall
%             heat capacity of the feed mixture
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getFeHtCapRatio(params)  
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getFeHtCapRatio.m';
    
    %Unpack params
    yFeC     = params.yFeC    ;
    htCapCpC = params.htCapCpC;
    htCapCvC = params.htCapCvC;
    gasCons  = params.gasCons ;
    nFeTas   = params.nFeTas  ;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Get molar averaged mixture heat capacity ratio
    
    %Get molar averaged mixture properties
    htCapCpAvg = calcMolAvgProp(yFeC,htCapCpC);  
    htCapCvAvg = calcMolAvgProp(yFeC,htCapCvC);  
    
    %Take the ratio of the heat capacities (avg(Cp)/avg(Cv))
    params.htCapRatioFe = htCapCpAvg ...
                        / htCapCvAvg;
                    
    %Define the dimensionless heat capacities for the gas phase species
    %Ideal gas constant in [J/mol-K]
    params.htCapCpNorm = htCapCpC ...
                      ./ (gasCons/10);
    params.htCapCvNorm = htCapCvC ...
                      ./ (gasCons/10);
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%