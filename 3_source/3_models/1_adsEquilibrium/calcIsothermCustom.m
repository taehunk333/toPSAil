function [newStates] = calcIsothermCustom(params,states,nAds)
    %% Preamble
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    nRows        = params.nRows       ;
    gasCons      = params.gasCons     ;
    
    %Determine the index for the number of adsorbers nAdsInd
    %When we have a single CSTR,
    if nAds == 0
        %Make sure that nAds = 1 so that the indexing will work out
        nAdsInd = 1;
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states);
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states);
        %Locally reset the number of volume parameter
        nVols = 1; 
    %Otherwise, let the index equal to itself                
    else
        %Make sure that nAds = 1 so that the indexing will work out
        nAdsInd = nAds;
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states,nAds);  
        %Grab dimensionless temperatures as fields in a struct
        colTemps = convert2ColTemps(params,states,nAds);
    end
    %Define an output state solution vector/matrix
    newStates = states;
    %Get the current temperature inside the CSTR
    tempCstrs = colTemps.cstr;
    %% Isotherm parameter calculations
    %SOMethingsomething
    nCuPrms = params.nCuPrms;
    for i = 1:nComs
        %Temperature dependant parameters
        cP1 = @(T) A*exp(B./(8.314.*T)); %ARRHENIUS-TYPE EQUATION
        cP2 = @() %INSERT EQUATION HERE;
        %Non-dimensionalization of parameters
        %Dimensionless constants - SELECT APPROPRIATE FACTORS
        aConScaleFac = params.aConScaleFac; %for dimensions [MOL/KG = MMOL/G]
        gConScaleFac = params.gConScaleFac; %for dimensions []
        teScaleFac   = params.teScaleFac  ; %for dimensions []
        pConScaleFac = gConScaleFac*gasCons.*tempCstrs; %for dimensions [1/BAR]
        %
        dimLessCP1 = cP1(tempCstrs)/aConScaleFac ;
        dimLessCP2 = cP2(tempCstrs) ;
    end
    
    %% Calculation of new states
    %Calculate new states for all components
    
