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
%Code created on       : 2022/2/2/Wednesday
%Code last modified on : 2022/2/2/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getPresRats.m
%Source     : common
%Description: define dimensionless pressure values.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getPresRats(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getPresRats.m';
    
    %Unpack params
    presFeTa        = params.presFeTa       ;
    presRaTa        = params.presRaTa       ;
    presExTa        = params.presExTa       ;
    presAmbi        = params.presAmbi       ;
    presColLow      = params.presColLow     ;
    presColLowSet   = params.presColLowSet  ;
    presColLowFull  = params.presColLowFull ;
    presColHigh     = params.presColHigh    ;
    presColHighSet  = params.presColHighSet ;
    presColHighFull = params.presColHighFull;
    presExTaFull    = params.presExTaFull   ;
    presExTaSet     = params.presExTaSet    ;
    presRaTaFull    = params.presRaTaFull   ;
    presRaTaSet     = params.presRaTaSet    ;    
    %---------------------------------------------------------------------% 
      
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values related to the adsorption columns         
    
    %Calculate the pressure ratio. i.e. (low-pressure)/(high-pressure)
    params.pRat = presColLow ...
                / presColHigh;    
    
    %Calculate the pressure ratio of a set value of high pressure
    params.pRatHighSet  = presColHighSet ...
                        / presColHigh;
    params.pRatHighFull = presColHighFull ...
                        / presColHigh;
    
    %Calculate the pressure ratio of a set value of low pressure
    params.pRatLowSet  = presColLowSet ...
                       / presColHigh;
    params.pRatLowFull = presColLowFull ...
                       / presColHigh;

    %Calculate pressure swing
    presDiff = presColHigh-presColLow;
                
    %Calcualte the pressure difference ratio
    params.pDiffRat = presDiff/presColHigh;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values related to the tanks       
    
    %Calculate the pressure ratio for the feed tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatFe = (presFeTa/presColHigh);    
    
    %Calculate the pressure ratio for the raffinate product tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatRa = (presRaTa/presColHigh); 
    
    %Calculate the pressure ratio for the extract product tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatEx = (presExTa/presColHigh); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values associated with the streams         
    
    %Calculate the ambient pressure ratio, i.e., 
    %(ambient pressure)/(high-pressure)
    params.pRatAmb = (presAmbi/presColHigh);
    
    %Calculate the downstream pressure ratio, i.e., 
    %(vacuum pressure)/(high-pressure)
    params.pRatDoSt = (presColLow/presColHigh);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the pressure ratios for the pressure regulators for the
    %product tanks
    
    %Get the dimensionless pressure for the raffinate tank pressure
    %regulator valve
    params.pRatRaTaFull = (presRaTaFull/presColHigh);
    params.pRatRaTaSet  = (presRaTaSet/presColHigh) ;
    
    %Get the dimensionless pressure for the extract tank pressure regulator
    %valve
    params.pRatExTaFull = (presExTaFull/presColHigh);
    params.pRatExTaSet  = (presExTaSet/presColHigh) ;
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%