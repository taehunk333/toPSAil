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
%Code last modified on : 2022/12/3/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4UnitsFlowCtrlDT1AccRaTa.m
%Source     : common
%Description: This function calculates volumetric flow rates for the rest
%             of the process flow diagram, based on the calcualted and thus
%             became known volumetric flow rates in the adsorbers. We let
%             the pressure inside the raffinate product tank to accumulate.
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

function units = calcVolFlows4UnitsFlowCtrlDT1AccRaTa(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4UnitsFlowCtrlDT1AccRaTa.m';
    
    %Unpack params   
    nCols            = params.nCols           ; 
    nComs            = params.nComs           ;
    nRows            = params.nRows           ;
    gasConsNormEq    = params.gasConsNormEq   ;
    feTaVolNorm      = params.feTaVolNorm     ;
    exTaVolNorm      = params.exTaVolNorm     ;
    tempFeedNorm     = params.tempFeedNorm    ;
    htCapCpNorm      = params.htCapCpNorm     ;
    pRatFe           = params.pRatFe          ;
    yFeC             = params.yFeC            ;
    gasConsNormFeTa  = params.gasConsNormFeTa ;
    gasConsNormExTa  = params.gasConsNormExTa ; 
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;
    valAdsFeEnd2ExTa = params.valAdsFeEnd2ExTa;
    bool             = params.bool            ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
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
    %tank unit. When the raffinate product tank pressure is greater than 
    %equal to the feed product pressure and there is a net flow out, 
    %maintain it!
    
        %-----------------------------------------------------------------%
        %Unpack Extract tank states
        
        %Unpack exTa tank overall heat capacity
        exTaHtCO = exTa.n1.htCO;                     
    
        %Unpack the temperature variables for the extract product tank
        exTaTempCstr = exTa.n1.temps.cstr;
        exTaTempWall = exTa.n1.temps.wall;

        %Unpack the total concentration of the extract product tank
        exTaConTot = exTa.n1.gasConsTot; 

        %Unpack the volumetric flow rates in between the extract tank and
        %the feed-ends of the adsorbers
        vFlCol2ExTa = vFlExTa(:,1:nCols);
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Obtain the time dependent terms for the extract product tank, as
        %well as the adsorbers

        %Evaluate a common term for the time dependent coefficients
        phiCommon = (exTaVolNorm*gasConsNormExTa./exTaHtCO).*exTaConTot;
        
        %Obtain the time dependent coefficients for the ith column        
        phiZeroExtr = -(1+phiCommon);         
    
        %Calculate the heat transfer correction term
        exTaBeta = (exTaVolNorm./exTaHtCO) ...
                .* (exTaTempWall./exTaTempCstr-1);                
        
        %Initialize the sum of the volumetric flow rate term
        vFlExtrSum = zeros(nRows,1);

        %For each adsorber,
        for i = 1 : nCols

            %Get the positive pseudo volumetric flow rate
            vFlExTaIn  = -min(col.(sColNums{i}).volFlRat(:,1),0) ...
                       * valAdsFeEnd2ExTa(i,nS)                    ;
            vFlExTaOut = max(vFlCol2ExTa(:,i),0)                   ;            

            %Initialize the molar energy term 
            molarEnergyCurr = zeros(nRows,1);

            %For each species,
            for j = 1 : nComs

                %Update the molar energy term for the current adsorber at
                %the feed end
                molarEnergyCurr ...
                    = molarEnergyCurr ...
                    + htCapCpNorm(j) ...
                   .* col.(sColNums{i}).gasCons.(sComNums{j})(:,1);

            end
            
            %Get the feed end total concentration of the ith adsorber
            colConTotCurr = col.(sColNums{i}).gasConsTot(:,1);

            %Get the interior temperature for the ith adsorber (feed end)
            colTempCurr = col.(sColNums{i}).temps.cstr(:,1);

            %Calculate the time dependent coefficient for the raffinate
            %product tank ith inlet stream
            phiPlusAdsCurr = (1+phiCommon).*(colConTotCurr./exTaConTot) ...
                           + (exTaVolNorm*gasConsNormExTa./exTaHtCO) ...
                          .* (colTempCurr./exTaTempCstr-1) ...
                          .* molarEnergyCurr;
            
            %Update the term including the sum of the product of the state
            %dependent coefficients and the pseudo volumetric flow rates
            vFlExtrSum = vFlExtrSum ...
                       + (phiPlusAdsCurr.*vFlExTaIn) ...
                       + (phiZeroExtr.*vFlExTaOut);

        end
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Calculate the volumateric flow rate for the extract product
        %stream        
        
        %When we are also recovering the extract product
        if bool(10) ~= 0
            
            %Save the extract product volumetric flow rate to maintain a 
            %constant pressure inside the extract product tank
            vFlExTa(:,(nCols+1)) = max(0,-(1./phiZeroExtr) ...
                                .* (vFlExtrSum+exTaBeta));
                            
        end
        %-----------------------------------------------------------------%
    
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