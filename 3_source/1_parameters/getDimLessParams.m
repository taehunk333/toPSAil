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
%Code last modified on : 2022/8/8/Monday
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
    nVols        = params.nVols       ;
    cstrVol      = params.cstrVol     ;
    colVol       = params.colVol      ;    
    gConScaleFac = params.gConScaleFac;    
    tiScaleFac   = params.tiScaleFac  ;
    teScaleFac   = params.teScaleFac  ;
    presColHigh  = params.presColHigh ;
    aConScaleFac = params.aConScaleFac;
    pellDens     = params.pellDens    ;
    overVoid     = params.overVoid    ; 
    voidFracBed  = params.voidFracBed ;
    ldfMtc       = params.ldfMtc      ;   
    gasCons      = params.gasCons     ;
    valScaleFac  = params.valScaleFac ;
    valFeedCol   = params.valFeedCol  ;
    valProdCol   = params.valProdCol  ;    
    modSp        = params.modSp       ;
    bool         = params.bool        ;

    %When there is axial pressure drop
    if bool(3) == 1
        
        %Set additional valve constants for the product tanks
        valRaTaFull  = params.valRaTaFull ;
        valExTaFull  = params.valExTaFull ;

    end
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
                  / presColHigh;
              
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
    %Get dimensionless isotherm parameters

    %Determine to see if we have an isothermal case or not
    isNonIsothermal = bool(5);

    %Determine which isotherm model we have
    whichIsotherm = modSp(1);

    %If we have a custom isotherm
    if whichIsotherm == 0

        %Currently, no custom isotherm model is supported.
        error("toPSAil: No custom isotherm model is supported.")

    %If we have the Henry's law,
    elseif whichIsotherm == 1
                
        %When we have an isothermal case
        if isNonIsothermal == 0

            %Unpack additional params
            bC    = params.bC   ;
            qSatC = params.qSatC;

            %Define dimensionless Henry's constants
            dimLessHenry = (qSatC.*bC) ...
                         * (gConScaleFac/aConScaleFac);

            %Remove unnecessary fields
            params = rmfield(params,'bC')   ; 
            params = rmfield(params,'qSatC'); 

            %Save to params
            params.dimLessHenry = dimLessHenry;

        end

    %If we have the Extended Langmuir Isotherm,
    elseif whichIsotherm == 2

        %When we have an isothermal case
        if isNonIsothermal == 0

            %Unpack additional params
            bC    = params.bC   ;
            qSatC = params.qSatC;
    
            %Obtain dimensionless isotherm paramters
            bCDimLess   = bC / gConScaleFac   ;
            qSatDimLess = qSatC / aConScaleFac;

            %Remove unnecessary fields
            params = rmfield(params,'bC')   ; 
            params = rmfield(params,'qSatC'); 

            %Save to params
            params.bCDimLess   = bCDimLess  ;
            params.qSatDimLess = qSatDimLess;

        end

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