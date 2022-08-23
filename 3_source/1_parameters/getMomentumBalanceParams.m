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
%Code created on       : 2021/1/13/Wednesday
%Code last modified on : 2022/3/12/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getMomentumBalanceParams.m
%Source     : common
%Description: given a user specified simulation parameters inside params,
%             calculates important dimensionless groups and dimensionless
%             functions that are relevant for the computations required in
%             momentum balance of the system.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getMomentumBalanceParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getMomentumBalanceParams.m';
    
    %Unpack params 
    viscFeGas    = params.viscFeGas   ;
    diamPellet   = params.diamPellet  ;
    modSp        = params.modSp       ;
    volScaleFac  = params.volScaleFac ;
    gasCons      = params.gasCons     ;
    teScaleFac   = params.teScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    crsAreaInCol = params.crsAreaInCol;
    voidFracBed  = params.voidFracBed ;
    cstrHt       = params.cstrHt      ;
    heightCol    = params.heightCol   ;
    %---------------------------------------------------------------------%                                                          
    
    
        
    %---------------------------------------------------------------------%                                                          
    %Define relevant parameters for the momentum balance equation
    
    %Check the momentum balance specification
    if modSp(6) == 0
        
        %Print error message to select a momentum drop equation
        msg = 'No axial pressure drop equation was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
    
    %For using Kozeny-Carman equation
    elseif modSp(6) == 1    
        
        %Define the dimensionless pre-factor for the discretized 
        %Kozeny-Carman equation for CIS model
        params.preFacLinFlow ...
            = (1.50*10^(3)) ...
            * (diamPellet^2/viscFeGas) ...
            * (gasCons*crsAreaInCol)./(cstrHt*heightCol) ...            
            * (gConScaleFac*teScaleFac)/volScaleFac ...
            * voidFracBed^(3)/(1-voidFracBed)^(2);   
    
    %For using Ergun equation
    elseif modSp(6) == 2
        
        %Define the dimensional coefficient for the quadratic term in the
        %dimensionless quadratic equation for the volumetric flow rate
        %calculation; we must multiply by the gas density at a given time
        %point to obtain the dimensionless pre-factor
        params.coefQuadPre ...
            = 1.75*10^(-6) ...            
           .* (cstrHt*heightCol)/diamPellet ...            
            * (volScaleFac/crsAreaInCol)^(2)/(gasCons*teScaleFac) ...            
            * (1-voidFracBed)/voidFracBed^3;

        %Define the dimensionless coefficient for the linear term in the
        %dimensionless quadratic equation for the volumetric flow rate
        %calculation        
        params.coefLinNorm ...
            = 1.50*10^(-3) ...
            * (viscFeGas*volScaleFac*(cstrHt*heightCol)) ...                            
            / (diamPellet^2*crsAreaInCol*gasCons ...
              *teScaleFac*gConScaleFac) ...            
            * (1-voidFracBed)^(2)/voidFracBed^(3);
        
    %Under development
    else
        
        %Model under development
        noteModelNotReady(6);
    
    end
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%