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
    nVols         = params.nVols        ;
    cstrVol       = params.cstrVol      ;
    colVol        = params.colVol       ; 
    gConScaleFac  = params.gConScaleFac ;    
    tiScaleFac    = params.tiScaleFac   ;
    teScaleFac    = params.teScaleFac   ;
    presColHigh   = params.presColHigh  ;
    aConScaleFac  = params.aConScaleFac ;
    pellDens      = params.pellDens     ;
    overVoid      = params.overVoid     ; 
    voidFracBed   = params.voidFracBed  ;
    ldfMtc        = params.ldfMtc       ;   
    gasCons       = params.gasCons      ;
    volScaleFac   = params.volScaleFac  ;
    valScaleFac   = params.valScaleFac  ;
    valFeedCol    = params.valFeedCol   ;
    valProdCol    = params.valProdCol   ;    
    bool          = params.bool         ;
    feTaVol       = params.feTaVol      ;
    raTaVol       = params.raTaVol      ;
    exTaVol       = params.exTaVol      ;      
    crsAreaInFeTa = params.crsAreaInFeTa;
    crsAreaInRaTa = params.crsAreaInFeTa;
    crsAreaInExTa = params.crsAreaInFeTa;

    %When there is axial pressure drop
    if bool(3) == 1
        
        %Set additional valve constants for the product tanks
        valRaTaFull  = params.valRaTaFull ;
        valExTaFull  = params.valExTaFull ;

    end
    %---------------------------------------------------------------------%    
    
   
    
    %---------------------------------------------------------------------%                     
    %Specification of dimensionless parameters related to the adsorption
    %columns and the tanks
    
    %Define a row vector containing dimensionless volumes
    params.cstrHt = ones(1,nVols) ...
                  * cstrVol ...
                  / colVol;     
              
    %Define scaling factor for volume for tanks [-]; actually this is the
    %inverse of the tank scale factor derived in the derivation.
    params.feTaVolNorm = feTaVol ...
                       / (overVoid*colVol);
    params.raTaVolNorm = raTaVol ...
                       / (overVoid*colVol);
    params.exTaVolNorm = exTaVol ...
                       / (overVoid*colVol);
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
    %---------------------------------------------------------------------%           



    %---------------------------------------------------------------------%           
    %Define dimensionless gas constants

    %Define non-dimensionalized version of ideal gas constant for the ideal
    %gas law
    gasConsNormEq = gasCons ...
                  * gConScaleFac ...
                  * teScaleFac ...
                  / presColHigh;

    %When nonisothermal,
    if bool(5) == 1       
        
        %Unpack additional params
        htTrCoInFeTa  = params.htTrCoInFeTa ;
        htTrCoInRaTa  = params.htTrCoInRaTa ;
        htTrCoInExTa  = params.htTrCoInExTa ;
              
        %Define dimensionless gas constants for the tank units:
        %(J/mol-k*mol/cc*cc/sec)/(J/m^2-sec*m^2)
        gasConsNormFeTa = ((gasCons/10)*gConScaleFac*volScaleFac) ...
                        / (htTrCoInFeTa*crsAreaInFeTa/10000);
        gasConsNormRaTa = ((gasCons/10)*gConScaleFac*volScaleFac) ...
                        / (htTrCoInRaTa*crsAreaInRaTa/10000);
        gasConsNormExTa = ((gasCons/10)*gConScaleFac*volScaleFac) ...
                        / (htTrCoInExTa*crsAreaInExTa/10000);
                    
    end
    %---------------------------------------------------------------------%           



    %---------------------------------------------------------------------%           
    %Define dimensionless valve constants

    %Define dimensionless valve constants (replaced valConNorm)
    valFeedColNorm  = valFeedCol ...
                   .* valScaleFac;
    valProdColNorm  = valProdCol ...
                   .* valScaleFac;

    %When there is axial pressure drop
    if bool(3) == 1

        %Compute additional dimensionless valve constants
        valRaTaFullNorm = valRaTaFull ...
                       .* valScaleFac;
        valExTaFullNorm = valExTaFull ...
                       .* valScaleFac;

    end
    %---------------------------------------------------------------------%             



    %---------------------------------------------------------------------%   
    %Save computed quantities into a struct
    
    %Pack variables into params
    params.partCoefHp      = partCoefHp     ;    
    params.damkoNo         = damkoNo        ;
    params.gasConsNormEq   = gasConsNormEq  ;
    params.valFeedColNorm  = valFeedColNorm ;
    params.valProdColNorm  = valProdColNorm ;
    
    %When nonisothermal
    if bool(5) == 1
    
        %Save the relevant parameters
        params.gasConsNormFeTa = gasConsNormFeTa;
        params.gasConsNormRaTa = gasConsNormRaTa;
        params.gasConsNormExTa = gasConsNormExTa;
        
    end
    
    %When there is axial pressure drop
    if bool(3) == 1
        
        %Save the results inside the struct
        params.valRaTaFullNorm = valRaTaFullNorm;
        params.valExTaFullNorm = valExTaFullNorm;  

    end
    %---------------------------------------------------------------------%   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%