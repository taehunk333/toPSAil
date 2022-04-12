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
%Code created on       : 2021/1/5/Tuesday
%Code last modified on : 2022/3/3/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getDimLessParams.m
%Source     : common
%Description: a function that calculates dimensionless quantities and
%             return them as fields inside a struct
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getDimLessParams(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getDimLessParams.m';
    
    %Unpack params
    tempCol      = params.tempCol     ;
    tempAmbi     = params.tempAmbi    ;
    nVols        = params.nVols       ;
    cstrVol      = params.cstrVol     ;
    colVol       = params.colVol      ;    
    nCols        = params.nCols       ;
    nSteps       = params.nSteps      ;
    gConScaleFac = params.gConScaleFac;    
    tiScaleFac   = params.tiScaleFac  ;
    teScaleFac   = params.teScaleFac  ;
    presBeHi     = params.presBeHi    ;
    aConScaleFac = params.aConScaleFac;
    pellDens     = params.pellDens    ;
    overVoid     = params.overVoid    ; 
    voidFracBed  = params.voidFracBed ;
    ldfMtc       = params.ldfMtc      ;   
    gasCons      = params.gasCons     ;
    valScaleFac  = params.valScaleFac ;
    valCon       = params.valCon      ;
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%                                          
    %Calculate dimensionless system parameters
    
    %Calculate Dimensionless Temperatures
    params.colTempNorm  = tempCol ...
                        / teScaleFac   ;
    params.ambTempNorm  = tempAmbi ...
                        / teScaleFac   ;   
    %---------------------------------------------------------------------%                     
    
    
    
    %---------------------------------------------------------------------%                     
    %Specification of dimensionless parameters related to adsorption column
    
    %Define a row vector containing dimensionless volumes
    params.cstrHt = ones(1,nVols) ...
                  * cstrVol ...
                  / colVol;            
    %---------------------------------------------------------------------%   
    
    
    
    %---------------------------------------------------------------------%           
    %Define important dimensionless groups            

    %Compute distribution coefficient
    partCoefHp = aConScaleFac ...
               / gConScaleFac ...
               * pellDens ...
               * (1-voidFracBed) ...
               / overVoid;

    %Compute Damkohler Numbers for each species
    damkoNo = tiScaleFac*ldfMtc; 
    
    %Define non-dimensionalized version of ideal gas constant for the ideal
    %gas law
    gasConsNormEq = gasCons ...
                  * gConScaleFac ...
                  * teScaleFac ...
                  / presBeHi;
              
    %Define dimensionless valve constants
    valConNorm = valCon ...
              .* valScaleFac;
    
    %Recover the unity values
    valConNorm(valConNorm==valScaleFac) = 1;
    %---------------------------------------------------------------------%           
    

    
    %---------------------------------------------------------------------%   
    %Save computed quantities into a struct
    
    %Pack variables into params
    params.partCoefHp    = partCoefHp   ;    
    params.damkoNo       = damkoNo      ;
    params.gasConsNormEq = gasConsNormEq;
    params.valConNorm    = valConNorm   ;
    %---------------------------------------------------------------------%   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%