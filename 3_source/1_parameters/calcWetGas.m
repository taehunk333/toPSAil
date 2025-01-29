function params = calcWetGas(params)
%Unpack params
    nComs       = params.nComs      ;
    sCom        = params.sCom       ;
    yFeC        = params.yFeC       ;
    yFeTwoC     = params.yFeTwoC    ;
    yRaC        = params.yRaC       ;
    yExC        = params.yExC       ;
    molecWtC    = params.molecWtC   ;
    isoStHtC    = params.isoStHtC   ;
    % compFacC    = params.compFacC   ;
    % htCapCpC    = params.htCapCpC   ;
    % htCapCvC    = params.htCapCvC   ;
    % gasCons     = params.gasCons    ;
    tempCol     = params.tempCol    ;
    presColHigh = params.presColHigh;
    RH          = params.relHum     ;

%Calculate initial water partial pressure from RH and T
    A = 8.07131;
    B = 1730.63;
    C = 233.426;
    tempColC = tempCol - 273.15;
    presSat = 10^(A - B / (tempColC + C));
    presSat = presSat * 133.322;
    presH2o = RH * presSat;
    yH2o = presH2o / (presColHigh*1E5) ;
%Modify mole fractions after taking water into account
    modFac = (1-yH2o)/sum(yFeC);
    yFeC = yFeC * modFac;
    % yRaC = yRaC * modFac;

%Add water values to variables    
    nComs = nComs + 1;
    sCom(end+1) = {'H2O'};
    yFeC(end+1) = yH2o;
    yFeTwoC(end+1) = 0;
    yRaC(end+1) = 0;
    yExC(end+1) = 0;
    molecWtC(end+1) = 18;
    isoStHtC(end+1) = 49000;
    % compFacC(end+1) = 1;
    % htCapCpC(end+1) = 34.02;
    % htCapCvC(end+1) = htCapCpC(end) - gasCons/10;

%Rebuild params
    params.nComs = nComs;
    params.sCom = sCom;
    params.yFeC = yFeC;
    params.yFeTwoC = yFeTwoC;
    params.yRaC = yRaC;
    params.yExC = yExC;
    params.molecWtC = molecWtC;
    params.isoStHtC = isoStHtC;
    % params.compFacC = compFacC;
    % params.htCapCpC = htCapCpC;
    % params.htCapCvC = htCapCvC;
end