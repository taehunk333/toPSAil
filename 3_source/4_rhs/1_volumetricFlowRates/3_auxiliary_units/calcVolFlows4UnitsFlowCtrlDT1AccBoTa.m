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
%Code created on       : 2022/10/22/Saturday
%Code last modified on : 2025/04/25/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4UnitsFlowCtrlDT1AccBoTa.m
%Source     : common
%Description: This function calculates volumetric flow rates for the rest
%             of the process flow diagram, based on the calcualted and thus
%             became known volumetric flow rates in the adsorbers. We let
%             the pressure inside the raffinate and extract product tanks
%             to accumulate.
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

function units = calcVolFlows4UnitsFlowCtrlDT1AccBoTa(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4UnitsFlowCtrlDT1AccBoTa.m';
    
    %Unpack params   
    nCols            = params.nCols           ; 
    gasConsNormEq    = params.gasConsNormEq   ;
    feTaVolNorm      = params.feTaVolNorm     ;
    tempFeedNorm     = params.tempFeedNorm    ;
    htCapCpNorm      = params.htCapCpNorm     ;
    pRatFe           = params.pRatFe          ;
    yFeC             = params.yFeC            ;
    gasConsNormFeTa  = params.gasConsNormFeTa ;
    
    %Unpack units
    feTa = units.feTa;
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
    
        %-----------------------------------------------------------------%
        %Unpack feed tank states variables
        
        %Unpack feTa tank overall heat capacity
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
        feedConTot = pRatFe/(gasConsNormEq*tempFeedNorm);

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
        molarEnergyCurr = feedConTot*sum(htCapCpNorm.*yFeC);
        
        %Calculate the time dependent coefficient for the feed stream
        phiPlusFeed = (1+phiCommon).*(feedConTot./feTaConTot) ...
                    + (feTaVolNorm*gasConsNormFeTa./feTaHtCO) ...
                   .* (tempFeedNorm./feTaTempCstr-1) ...
                    * molarEnergyCurr;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Save the results

        %Save the feed volumetric flow rate to maintain a constant pressure
        %inside the feed tank
        vFlFeTa(:,nCols+1) = max(0,-(1./phiPlusFeed) ...
                          .*(vFlFeedSum+feTaBeta));
        %-----------------------------------------------------------------%

    %---------------------------------------------------------------------%       
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the raffinate product
    %tank unit.
    
    %Nothing to do here. We let the pressure to accumulate.    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the extract product
    %tank unit.
    
    %Nothing to do here. We let the pressure to accumulate.    
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