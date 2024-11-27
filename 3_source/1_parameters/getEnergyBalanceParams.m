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
%Code last modified on : 2022/10/29/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEnergyBalanceParams.m
%Source     : common
%Description: given a user specified simulation parameters inside params,
%             calculates important dimensionless groups and dimensionless
%             functions that are relevant for the computations required in
%             energy balance of the system.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getEnergyBalanceParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getEnergyBalanceParams.m';
    
    %Unpack params    
    gConScaleFac    = params.gConScaleFac   ;
    aConScaleFac    = params.aConScaleFac   ;
    volScaleFac     = params.volScaleFac    ;
    htTrCoInCol     = params.htTrCoInCol    ;
    htTrCoOutCol    = params.htTrCoOutCol   ;
    htTrCoInFeTa    = params.htTrCoInFeTa   ;
    htTrCoInRaTa    = params.htTrCoInRaTa   ;
    htTrCoInExTa    = params.htTrCoInExTa   ;
    htTrCoOutFeTa   = params.htTrCoOutFeTa  ; 
    htTrCoOutRaTa   = params.htTrCoOutRaTa  ; 
    htTrCoOutExTa   = params.htTrCoOutExTa  ; 
    tiScaleFac      = params.tiScaleFac     ;
    crsAreaInCol    = params.crsAreaInCol   ;
    crsAreaOutCol   = params.crsAreaOutCol  ;
    crsAreaInFeTa   = params.crsAreaInFeTa  ;
    crsAreaInRaTa   = params.crsAreaInRaTa  ;
    crsAreaInExTa   = params.crsAreaInExTa  ;
    crsAreaOutFeTa  = params.crsAreaOutFeTa ;
    crsAreaOutRaTa  = params.crsAreaOutRaTa ;
    crsAreaOutExTa  = params.crsAreaOutExTa ;
    teScaleFac      = params.teScaleFac     ;
    waDensCol       = params.waDensCol      ;
    htCapCol        = params.htCapCol       ;
    crsAreaWallCol  = params.crsAreaWallCol ;
    crsAreaWallFeTa = params.crsAreaWallFeTa;
    crsAreaWallRaTa = params.crsAreaWallRaTa;
    crsAreaWallExTa = params.crsAreaWallExTa;
    oneCstrHt       = params.oneCstrHt      ;
    waDensFeTa      = params.waDensFeTa     ;
    waDensRaTa      = params.waDensRaTa     ;
    waDensExTa      = params.waDensExTa     ;
    htCapFeTa       = params.htCapFeTa      ;
    htCapRaTa       = params.htCapRaTa      ;
    htCapExTa       = params.htCapExTa      ;
    heightFeTa      = params.heightFeTa     ;
    heightRaTa      = params.heightRaTa     ;
    heightExTa      = params.heightExTa     ;
    tempFeed        = params.tempFeed       ;
    tempRaTa        = params.tempRaTa       ;
    tempExTa        = params.tempExTa       ;
    tempFeTa        = params.tempFeTa       ;
    tempAmbi        = params.tempAmbi       ;
    gasCons         = params.gasCons        ;
    htCapCpC        = params.htCapCpC       ;
    htCapCvC        = params.htCapCvC       ;
    htCapSol        = params.htCapSol       ;
    isoStHtC        = params.isoStHtC       ;
    %---------------------------------------------------------------------%                                                          
    
    
    
    %---------------------------------------------------------------------%                                                          
    %Define additional simulation parameters
    
    %Define dimensionless temperature parameters
    params.tempFeedNorm = tempFeed ...
                        / teScaleFac;    
    params.tempRaTaNorm = tempRaTa ...
                        / teScaleFac;
    params.tempAmbiNorm = tempAmbi ...
                        / teScaleFac;
    params.tempExTaNorm = tempExTa ...
                        / teScaleFac;
    params.tempFeTaNorm = tempFeTa ...
                        / teScaleFac;
    %---------------------------------------------------------------------%

    
        
    %---------------------------------------------------------------------%
    %Define dimensionless parameters
    
    %Define the dimensionless ideal gas constant for an adsorption column
    %Ideal gas constant in [J/mol-K]. Since the area is in cm^2, we convert
    %it into m^2 by using the factor of 10,000.
    params.gConsNormCol = ((gasCons/10)*gConScaleFac*volScaleFac)...
                        / (htTrCoInCol*crsAreaInCol/10000);
                   
    %Define the dimensionless ideal gas constant for an adsorption column
    %Ideal gas constant in [J/mol-K]. Since the area is in cm^2, we convert
    %it into m^2 by using the factor of 10,000.
    params.gConsNormFeTa = ((gasCons/10)*gConScaleFac*volScaleFac)...
                         / (htTrCoInFeTa*crsAreaInFeTa/10000);            
    params.gConsNormRaTa = ((gasCons/10)*gConScaleFac*volScaleFac)...
                         / (htTrCoInRaTa*crsAreaInRaTa/10000);   
    params.gConsNormExTa = ((gasCons/10)*gConScaleFac*volScaleFac)...
                         / (htTrCoInExTa*crsAreaInExTa/10000);                          
    
    %Define the dimensionless solid adsorbent heat capacity
    %Ideal gas constant in [J/mol-K]
    params.htCapSolNorm = htCapSol ...
                        / ((gasCons/10)*aConScaleFac);
                    
    %Define the dimensionless isosteric heat of adsorption for the gas
    %phase species
    %Ideal gas constant in [J/mol-K]
    params.isoStHtNorm = isoStHtC ...
                      ./ ((gasCons/10)*teScaleFac);
    %---------------------------------------------------------------------%                                                            
    
    
    
    %---------------------------------------------------------------------%
    %Normalization constant for heat transfer rates inside adsorption
    %column  
    
    %Dimensionless heat transfer coefficient (interior) times the ratio of  
    %the dimensionless areas; the factor of 10,000 comes from the area 
    %conversion from cm^2 to m^2.
    params.intHtTrFacCol = (crsAreaInCol/crsAreaWallCol) ...
                         * (htTrCoInCol*tiScaleFac) ...
                         / ((10000)*waDensCol*htCapCol*oneCstrHt);
    
    %Dimensionless heat transfer coefficient (exterior) times the ratio of  
    %the dimensionless areas; the factor of 10,000 comes from the area 
    %conversion from cm^2 to m^2.
    params.extHtTrFacCol = (crsAreaOutCol/crsAreaWallCol) ...
                         * (htTrCoOutCol*tiScaleFac) ...
                         / ((10000)*waDensCol*htCapCol*oneCstrHt);               
    %---------------------------------------------------------------------%          
    
    
    
    %---------------------------------------------------------------------%
    %Normalization constant for heat transfer rates inside a tank
    
    %Dimensionless heat transfer coefficient (interior); the factor of 
    %10,000 comes from the area conversion from cm^2 to m^2
    params.intHtTrFacFeTa = (crsAreaInFeTa/crsAreaWallFeTa) ...
                          * (htTrCoInFeTa*tiScaleFac) ...
                          / ((10000)*waDensFeTa*htCapFeTa*heightFeTa);
    params.intHtTrFacRaTa = (crsAreaInRaTa/crsAreaWallRaTa) ...
                          * (htTrCoInRaTa*tiScaleFac) ...
                          / ((10000)*waDensRaTa*htCapRaTa*heightRaTa);
    params.intHtTrFacExTa = (crsAreaInExTa/crsAreaWallExTa) ...
                          * (htTrCoInExTa*tiScaleFac) ...
                          / ((10000)*waDensExTa*htCapExTa*heightExTa);
    
    %Dimensionless heat transfer coefficient (exterior); the factor of 
    %10,000 comes from the area conversion from cm^2 to m^2
    params.extHtTrFacFeTa = (crsAreaOutFeTa/crsAreaWallFeTa) ...
                          * (htTrCoOutFeTa*tiScaleFac) ...
                          / ((10000)*waDensFeTa*htCapFeTa*heightFeTa); 
    params.extHtTrFacRaTa = (crsAreaOutRaTa/crsAreaWallRaTa) ...
                          * (htTrCoOutRaTa*tiScaleFac) ...
                          / ((10000)*waDensRaTa*htCapRaTa*heightRaTa); 
    params.extHtTrFacExTa = (crsAreaOutExTa/crsAreaWallExTa) ...
                          * (htTrCoOutExTa*tiScaleFac) ...
                          / ((10000)*waDensExTa*htCapExTa*heightExTa); 
    %---------------------------------------------------------------------%                        
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%