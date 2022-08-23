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
    presFeTa     = params.presFeTa    ;
    presRaTa     = params.presRaTa    ;
    presExTa     = params.presExTa    ;
    presAmbi     = params.presAmbi    ;
    presBeLo     = params.presBeLo    ;
    presBeHi     = params.presBeHi    ;
    presExTaFull = params.presExTaFull;
    presExTaSet  = params.presExTaSet ;
    presRaTaFull = params.presRaTaFull;
    presRaTaSet  = params.presRaTaSet ;
    %---------------------------------------------------------------------% 
      
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values related to the adsorption columns         
    
    %Calculate the pressure ratio. i.e. (low-pressure)/(high-pressure)
    params.pRat = presBeLo ...
                / presBeHi;    
    
    %Calculate pressure swing
    presDiff = presBeHi-presBeLo;
                
    %Calcualte the pressure difference ratio
    params.pDiffRat = presDiff/presBeHi;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values related to the tanks       
    
    %Calculate the pressure ratio for the feed tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatFe = (presFeTa/presBeHi);    
    
    %Calculate the pressure ratio for the raffinate product tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatRa = (presRaTa/presBeHi); 
    
    %Calculate the pressure ratio for the extract product tank, i.e., 
    %(tank pressure)/(high-pressure)        
    params.pRatEx = (presExTa/presBeHi); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Calculate pressure values associated with the streams         
    
    %Calculate the ambient pressure ratio, i.e., 
    %(ambient pressure)/(high-pressure)
    params.pRatAmb = (presAmbi/presBeHi);
    
    %Calculate the downstream pressure ratio, i.e., 
    %(vacuum pressure)/(high-pressure)
    params.pRatDoSt = (presBeLo/presBeHi);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the pressure ratios for the pressure regulators for the
    %product tanks
    
    %Get the dimensionless pressure for the raffinate tank pressure
    %regulator valve
    params.pRatRaTaFull = (presRaTaFull/presBeHi);
    params.pRatRaTaSet  = (presRaTaSet/presBeHi) ;
    
    %Get the dimensionless pressure for the extract tank pressure regulator
    %valve
    params.pRatExTaFull = (presExTaFull/presBeHi);
    params.pRatExTaSet  = (presExTaSet/presBeHi) ;
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%