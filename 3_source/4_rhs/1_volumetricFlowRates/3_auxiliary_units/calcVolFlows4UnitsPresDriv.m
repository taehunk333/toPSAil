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
%Code created on       : 2022/8/13/Saturday
%Code last modified on : 2022/10/6/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4UnitsPresDriv.m
%Source     : common
%Description: This function calculates the volumetric flow rates for the 
%             rest of the process flow diagram, based on the calcualted 
%             volumetric flow rates in the adsorbers. For the outlet of
%             each product tank, its corresponding volumetric flow rate is
%             obtained by a backpressure regulator + check valve equation.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             vFlPlus      - a vector containing all the positive pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             vFlMinus     - a vector containing all the negative pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlows4UnitsPresDriv(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4UnitsPresDriv.m';
    
    %Unpack params   
    nCols           = params.nCols          ;  
    nRows           = params.nRows          ;
    valRaTaFullNorm = params.valRaTaFullNorm;
    valExTaFullNorm = params.valExTaFullNorm;
    pRatExTaFull    = params.pRatExTaFull   ; 
    pRatExTaSet     = params.pRatExTaSet    ;
    pRatRaTaFull    = params.pRatRaTaFull   ;
    pRatRaTaSet     = params.pRatRaTaSet    ;
    gasConsNormEq   = params.gasConsNormEq  ;
    pRatRa          = params.pRatRa         ;
    pRatEx          = params.pRatEx         ;
    tempColNorm     = params.tempColNorm    ;
    bool            = params.bool           ;
    tempFeedNorm    = params.tempFeedNorm   ;
    feTaVolNorm     = params.feTaVolNorm    ;
    gasConsNormFeTa = params.gasConsNormFeTa;
    htCapCpNorm     = params.htCapCpNorm    ;
    pRatFe          = params.pRatFe         ;
    yFeC            = params.yFeC           ;
    
    %Unpack units
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                                           
                
    
    
    %---------------------------------------------------------------------%
    %Obtain the volumetric flow rates associated with auxiliary units on
    %the process flow diagram.
    
    %Get the volumetric flow rates between the tanks and the adsorbers
    vFlUnits = calcVolFlows4Units(params,units,nS);
    
    %A numeric array for the volumetric flow rates for the feed tank
    vFlFeTa = vFlUnits.feTa;
    
    %A numeric array for the volumetric flow rates for the raffinate 
    %product tank
    vFlRaTa = vFlUnits.raTa;
    
    %A numeric array for the volumetric flow rates for the raffinate waste
    vFlRaWa = vFlUnits.raWa;
    
    %A numeric array for the volumetric flow rates for the extract product 
    %tank
    vFlExTa = vFlUnits.exTa;
    
    %A numeric array for the volumetric flow rates for the extract waste
    vFlExWa = vFlUnits.exWa;
    %---------------------------------------------------------------------%
              
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the feed tank unit
        
    %When the feed tank is isothermal, 
    if bool(5) == 0

        %The entering valve to the feed tank is always controlled to 
        %maintain a constant pressure inside the feed tank. Therefore, we 
        %can control the volumetric flow rate so that a constant pressure 
        %is maintained inside the feed tank.
        vFlFeTa(:,(nCols+1)) = sum(vFlFeTa(:,1:nCols),2); 

    %When the feed tank is non-isothermal,   
    elseif bool(5) == 1
   
        %-----------------------------------------------------------------%
        %Unpack feed tank states variables
        
        %Unpack feTa tank overall heat capacity at time t
        feTaHtCO = feTa.n1.htCO;
    
        %Unpack the temperature variables for the feed tank
        feTaTempCstr = feTa.n1.temps.cstr;
        feTaTempWall = feTa.n1.temps.wall;
    
        %Unpack the feed tank total concentration
        feTaConTot = feTa.n1.gasConsTot;        
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Obtain the time dependent terms.
        
        %Evaluate the feed stream tototal concentration
        feedConTot = pRatFe*gasConsNormEq*tempFeedNorm;

        %Evaluate a common term for the time dependent coefficients
        phiCommon = (feTaVolNorm*gasConsNormFeTa./feTaHtCO).*feTaConTot;

        %Obtain the time dependent coefficients for the ith column        
        phiZeroFeed = -(1+phiCommon);
    
        %Obtain the sum of the products of the volumetric flow rates and
        %the state dependent coefficient (vectorized)
        vFlFeedSum = phiZeroFeed ...
                  .* sum(vFlFeTa(:,1:nCols),2);         
    
        %Calculate the heat transfer correction term
        feTaBeta = (feTaVolNorm/feTaHtCO) ...
                 * (feTaTempWall./feTaTempCstr-1);
    
        %Calculate the molar energy term (vectorized)
        molarEnergy = feedConTot*sum(htCapCpNorm.*yFeC);
        
        %Calculate the time dependent coefficient for the feed stream
        phiPlusFeed = (1+phiCommon).*(feedConTot./feTaConTot) ...
                    + (feTaVolNorm*gasConsNormFeTa./feTaHtCO) ...
                   .* (tempFeedNorm./feTaTempCstr-1) ...
                    * molarEnergy;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Save the results

        %Save the feed volumetric flow rate to maintain a constant pressure
        %inside the feed tank
        vFlFeTa(:,nCols+1) = -(1./phiPlusFeed).*(vFlFeedSum+feTaBeta);
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%       
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the raffinate product
    %tank unit
    
    %Get the total concentration of the raffinate product tank at time t
    gasConTotRaTa = raTa.n1.gasConsTot;
    
    %Get the interior temperature of the raffinate product tank at time t
    cstrTempRaTa = raTa.n1.temps.cstr;
    
    %Calculate the dimensionless pressure difference term
    deltaPres ...
        = (gasConsNormEq.*gasConTotRaTa.*cstrTempRaTa-pRatRaTaSet) ...
       ./ (pRatRaTaFull-pRatRaTaSet);
    
    %Initialize the molar flow rate vector
    molFlRaTa2Res = zeros(nRows,1);
   
    %For each time point,
    for t = 1 : nRows
    
        %The exit valve for the raffinate product tank is opened only when 
        %the tank pressure equals the initial product tank pressure 
        molFlRaTa2Res(t) ...
            = valRaTaFullNorm*gasConsNormEq*tempColNorm/1000 ...
            * median([0,deltaPres(t),1]) ...
            * min(0,gasConTotRaTa(t).*cstrTempRaTa(t) ...
                 -pRatRa/gasConsNormEq);
                     
    end
    
    %The exit valve for the raffinate product tank is opened only when the
    %tank pressure equals the initial product tank pressure 
    vFlRaTa(:,(nCols+1)) = molFlRaTa2Res ...
                        ./ gasConTotRaTa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the extract product 
    %tank unit. We use the check valve + back pressure regulator equation.
    
    %Get the total concentration of the raffinate product tank at time t
    gasConTotExTa = exTa.n1.gasConsTot;
    
    %Get the interior temperature of the raffinate product tank at time t
    cstrTempExTa = exTa.n1.temps.cstr;
    
    %Calculate the dimensionless pressure difference term
    deltaPres ...
        = (gasConsNormEq.*gasConTotExTa.*cstrTempExTa-pRatExTaSet) ...
       ./ (pRatExTaFull-pRatExTaSet);
    
    %Initialize the molar flow rate vector
    molFlExTa2Res = zeros(nRows,1);   
       
    %For each time point,
    for t = 1 : nRows
        
        %The exit valve for the raffinate product tank is opened only when
        %the tank pressure equals the initial product tank pressure 
        molFlExTa2Res ...
            = valExTaFullNorm*gasConsNormEq*tempColNorm/1000 ...
            * median([0,deltaPres(t),1]) ...
            * min(0,gasConTotExTa(t).*cstrTempExTa(t) ...
                 -pRatEx/gasConsNormEq);
                     
    end         
                            
    %The exit valve for the raffinate product tank is opened only when the
    %tank pressure equals the initial product tank pressure 
    vFlExTa(:,(nCols+1)) = molFlExTa2Res ...
                        ./ gasConTotExTa;
    %---------------------------------------------------------------------%
    
    
              
    %---------------------------------------------------------------------% 
    %Save the results to the structs: assign the volumetric flow rates to 
    %the struct holding tank properties
                              
    %Save the volumetric flow rates to a struct
    units.raTa.n1.volFlRat = vFlRaTa;  
    
    %Save the volumetric flow rates to a struct
    units.exTa.n1.volFlRat = vFlExTa;
    
    %Save the volumetric flow rates to a struct
    units.raWa.n1.volFlRat = vFlRaWa;  
    
    %Save the volumetric flow rates to a struct
    units.exWa.n1.volFlRat = vFlExWa;
    
    %Save the volumetric flow rates to a struct
    units.feTa.n1.volFlRat = vFlFeTa;         
    %---------------------------------------------------------------------%     
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%