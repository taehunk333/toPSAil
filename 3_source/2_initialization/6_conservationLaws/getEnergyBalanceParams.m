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
%Code last modified on : 2022/2/26/Saturday
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
    gConScaleFac   = params.gConScaleFac  ;
    aConScaleFac   = params.aConScaleFac  ;
    volScaleFac    = params.volScaleFac   ;
    htTrCoInCol    = params.htTrCoInCol   ;
    htTrCoOutCol   = params.htTrCoOutCol  ;
    htTrCoInTa     = params.htTrCoInTa    ;
    htTrCoOutTa    = params.htTrCoOutTa   ; 
    tiScaleFac     = params.tiScaleFac    ;
    crsAreaInCol   = params.crsAreaInCol  ;
    crsAreaOutCol  = params.crsAreaOutCol ;
    crsAreaInTan   = params.crsAreaInTan  ;
    crsAreaOutTan  = params.crsAreaOutTan ;
    teScaleFac     = params.teScaleFac    ;
    waDensCol      = params.waDensCol     ;
    htCapCol       = params.htCapCol      ;
    crsAreaWallCol = params.crsAreaWallCol;
    crsAreaWallTan = params.crsAreaWallTan;
    oneCstrHt      = params.oneCstrHt     ;
    waDensTa       = params.waDensTa      ;
    htCapTa        = params.htCapTa       ;
    heightTa       = params.heightTa      ;
    tempFeed       = params.tempFeed      ;
    tempRefIso     = params.tempRefIso    ;
    tempRaTa       = params.tempRaTa      ;
    tempExTa       = params.tempExTa      ;
    tempFeTa       = params.tempFeTa      ;
    gasCons        = params.gasCons       ;
    htCapCpC       = params.htCapCpC      ;
    htCapCvC       = params.htCapCvC      ;
    htCapSol       = params.htCapSol      ;
    isoStHtC       = params.isoStHtC      ;
    %---------------------------------------------------------------------%                                                          
    
    
    
    %---------------------------------------------------------------------%                                                          
    %Define additional simulation parameters
    
    %Define dimensionless temperature parameters
    params.feedTempNorm = tempFeed ...
                        / teScaleFac;
    params.refTempNorm  = tempRefIso ...
                        / teScaleFac;
    params.raTaTempNorm = tempRaTa ...
                        / teScaleFac;
    params.exTaTempNorm = tempExTa ...
                        / teScaleFac;
    params.feTaTempNorm = tempFeTa ...
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
    params.gasConsNormTan = ((gasCons/10)*gConScaleFac*volScaleFac)...
                          / (htTrCoInTa*crsAreaInTan/10000);               
                   
    %Define the dimensionless heat capacities for the gas phase species
    %Ideal gas constant in [J/mol-K]
    params.htCapCpNorm = htCapCpC ...
                      ./ (gasCons/10);
    params.htCapCvNorm = htCapCvC ...
                      ./ (gasCons/10);
    
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
    params.intHtTrFacTan = (crsAreaInTan/crsAreaWallTan) ...
                         * (htTrCoInTa*tiScaleFac) ...
                         / ((10000)*waDensTa*htCapTa*heightTa);
    
    %Dimensionless heat transfer coefficient (exterior); the factor of 
    %10,000 comes from the area conversion from cm^2 to m^2
    params.extHtTrFacTan = (crsAreaOutTan/crsAreaWallTan) ...
                         * (htTrCoOutTa*tiScaleFac) ...
                         / ((10000)*waDensTa*htCapTa*heightTa);               
    %---------------------------------------------------------------------%                        
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%