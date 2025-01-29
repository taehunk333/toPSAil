%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%Austrian Marshall Plan Foundation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,
%Georgia Institute of Technology,
%311 Ferst Drive NW, Atlanta, GA 30332-0100.
%Scott Research Group
%https://www.jkscottresearchgroup.com/
%Institute of Chemical, Environmental and Biomolecular Engineering
%Technische Universitat Wien
%Getreidemarkt 9/166, Wien, 1060, Austria
%Thermal Process Engineering Group
%https://www.cfd.at/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project title :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcIsothermWaterGab.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) and 
%             returns the corresponding adsorbed phase concentration of
%             water in equilibrium with the saturation pressure at the
%             current temperature. This function is intended for DAC
%             applications with amin-functionized sorbent. Other
%             applications were not verified.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             nAds         - the adsober number where we will evaluate the
%                            adsorption equilibrium
%Outputs    : newStates    - a dimensionless state solution of the same
%                            dimension as states but adsorbed phase
%                            concentrations are now in equilibrium with the
%                            gas phase concentrations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newStates] = calcIsothermWaterGab(params,states,tempCstrs,nAds,i)
    %%Unpack parameters
    gConScaleFac    = params.gConScaleFac   ;
    teScaleFac      = params.teScaleFac     ;
    gasCons         = params.gasCons        ;
    nComs           = params.nComs          ;
    nVols           = params.nVols          ;
    %RH              = params.relHum         ;
    if nAds == 0
        nVols = 1;
        nAdsInd = 1;
    else
        nAdsInd = nAds;
    end
    %Dimensionalize temperature for the calculations
    tempCstrsK = tempCstrs*teScaleFac;
    %Find water indexes
    nStates = params.nStates;
    nColStT = params.nColStT;
    nSt0 = nColStT*(nAdsInd-1) + nComs+i;
    nStf = nColStT*(nAdsInd-1) + nStates*(nVols-1)+nComs+i;    

    %---------------------------------------------------------------------%
    %%Get saturation pressure and new relative humidity
    A = 8.07131 ;
    B = 1730.63 ;
    C = 233.426 ;
    tempCstrsC = tempCstrsK - 273.15 ;
    presSat = 10.^(A - B ./ (tempCstrsC + C))    ; %[Hgmm]
    presSat = presSat * 133.322 / 1E5            ; %[bar]
    presH2o = states(:,nSt0-nComs:nStates:nStf-nComs) ...
        *gConScaleFac*gasCons.*tempCstrsK ;
    
    RH = presH2o./presSat ;
    %RH = min(presH2o./presSat,1);
    params.relHum = RH;

    %---------------------------------------------------------------------%
    %%GAB Isotherm Parameters
    % beta      = 1540  ; %[K]
    % CG0       = 6.86  ; %[-]
    % deltaHC   = -4120 ; %[kJ/kmol]
    % Kads0     = 2.27  ; %[-]
    % deltaHK   = -2530 ; %[kJ/kmol]
    monoCap     = @(T) 2.08E-5*exp(1540./T)         ; %[kmol/kg]
    adsAffConC  = @(T) 6.86*exp(-4120./(8.314.*T))  ; %[-]
    adsAffConK  = @(T) 2.27*exp(-2530./(8.314.*T))  ; %[-]

    aConScaleFac = 1;
    dimlessMonoCap = monoCap(tempCstrsK)/aConScaleFac;
    dimlessAdsAffConC = adsAffConC(tempCstrsK);
    dimlessAdsAffConK = adsAffConK(tempCstrsK);

    %Calculate new states for adsorbed water and mol fractions based on RH
    newStates = states;
    loading = dimlessMonoCap.*dimlessAdsAffConC.*dimlessAdsAffConK.*RH ;
    denominator = (1-dimlessAdsAffConK.*RH)...
        .*(1+(dimlessAdsAffConC-1).*dimlessAdsAffConK.*RH) ;
    
    %Upgrade state vector
    newStates(:,nSt0:nStates:nStf) = loading./denominator ;
    %---------------------------------------------------------------------%
end