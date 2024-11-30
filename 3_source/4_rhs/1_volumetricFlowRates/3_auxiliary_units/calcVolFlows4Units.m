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
%Code last modified on : 2022/11/5/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4Units.m
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
%Outputs    : vFlUnits     - a nested structure containing all volumetric
%                            flow rates for all relevant auxiliary units.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vFlUnits = calcVolFlows4Units(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4Units.m';
    
    %Unpack params   
    nCols            = params.nCols           ; 
    nVols            = params.nVols           ; 
    nRows            = params.nRows           ;
    sColNums         = params.sColNums        ;        
    pRatAmb          = params.pRatAmb         ;
    tempAmbiNorm     = params.tempAmbiNorm    ;
    gasConsNormEq    = params.gasConsNormEq   ;
    valFeTa2AdsPrEnd = params.valFeTa2AdsPrEnd;
    valFeTa2AdsFeEnd = params.valFeTa2AdsFeEnd;
    valRaTa2AdsPrEnd = params.valRaTa2AdsPrEnd;
    valRaTa2AdsFeEnd = params.valRaTa2AdsFeEnd;
    valExTa2AdsPrEnd = params.valExTa2AdsPrEnd;
    valExTa2AdsFeEnd = params.valExTa2AdsFeEnd;
    valAdsPrEnd2RaTa = params.valAdsPrEnd2RaTa;
    valAdsPrEnd2RaWa = params.valAdsPrEnd2RaWa;
    valAdsFeEnd2ExWa = params.valAdsFeEnd2ExWa;
    valAdsFeEnd2ExTa = params.valAdsFeEnd2ExTa;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                                           
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the numerical solution arrays
    
    %A numeric array for the volumetric flow rates for the feed tank
    vFlFeTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the raffinate 
    %product tank
    vFlRaTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the raffinate waste
    vFlRaWa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the extract product 
    %tank
    vFlExTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the extract waste
    vFlExWa = zeros(nRows,(nCols+1));
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Determine flow rates for all the tanks units (feed, raffinate, and
    %extract)
       
    %Get the total concentration of the tanks at time t    
    feTaTotCon = feTa.n1.gasConsTot;
    raTaTotCon = raTa.n1.gasConsTot;
    exTaTotCon = exTa.n1.gasConsTot;    

    %For a stream associated with ith column,
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Unpack units 
        
        %Get the volumetric flow rates for ith adsorber
        vFlCol = col.(sColNums{i}).volFlRat;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For all streams around the feed tank coming from or going to an
        %adsorption column, assign the volumetric flow rate values. The 
        %volumetric flow rates are evaluated at the tank total 
        %concentration and the flow directions should be defined for the 
        %feed tank.
        
        %The feed tank is interacting with the ith adsorber at the 
        %feed-end. 
        if valFeTa2AdsFeEnd(i,nS) == 1          
                
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,1) ...
                       ./ feTaTotCon;                              

            %Grab a volumetric flow rate from the feed-end of the jth 
            %column
            vFlFeTa(:,i) = vFlCol(:,1) ...
                        .* vFlScaleFac; 
        
        %The feed tank is interacting with the ith adsorber at the 
        %product-end.
        elseif valFeTa2AdsPrEnd(i,nS) == 1       
                
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,nVols) ...
                       ./ feTaTotCon;

            %Grab a volumetric flow rate from the product-end of the jth 
            %column. The flow rate is negated to make the counter-current 
            %flow (negative) to become a positive number.
            vFlFeTa(:,i) = (-1)*vFlCol(:,nVols+1) ...
                        .* vFlScaleFac; 
        
        %The feed tank does not interact with the ith adsorption column
        else
            
            %Nothing to do
            
        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For all streams around the raffinate product tank coming from or 
        %going to an adsorption column, assign the volumetric flow rates.
        %The volumetric flow rates are evaluated at the tank total 
        %concentration and the flow directions should be defined for the 
        %raffinate product tank.
        
        %The raffinate product tank is interacting with the ith adsorber at
        %the feed-end. 
        if valRaTa2AdsFeEnd(i,nS) == 1
            
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,1) ...
                       ./ raTaTotCon;
                   
            %Calcualate the volumetric flow rate from the raffinate product 
            %tank to the ith adsorption column. The flow into the feed-end 
            %of the ith adsorber is in the positive direction. By
            %convention, we consider the flow coming out from the raffinate
            %tank and heading towards an adsorber to be in the negative
            %direction.
            vFlRaTa(:,i) = (-1) ...
                         * vFlCol(:,1) ...
                        .* vFlScaleFac;    
        
        %The flow is from the raffinate product tank to the product-end of
        %the ith adsorber
        elseif valRaTa2AdsPrEnd(i,nS) == 1

            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,nVols) ...
                       ./ raTaTotCon;

            %Calculate the volumetric flow rate from the raffinate product 
            %tank to the ith adsorption column. The flow into the 
            %product-end of the ith adsorber is in the negative direction. 
            %By convention, we consider the flow coming out from the 
            %raffinate tank and heading towards an adsorber to be in the 
            %negative direction.
            vFlRaTa(:,i) = vFlCol(:,nVols+1) ...
                        .* vFlScaleFac;  

        %The flow is from the ith adsorber product-end towards the
        %raffinate product tank or the raffinate waste stream
        elseif valAdsPrEnd2RaTa(i,nS) == 1

            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac1 = col.(sColNums{i}).gasConsTot(:,nVols) ...
                        ./ raTaTotCon;
            vFlScaleFac2 = col.(sColNums{i}).gasConsTot(:,nVols) ...
                        ./ (pRatAmb/(gasConsNormEq*tempAmbiNorm));      
            %c_{amb}/c_{0} = P_{amb}/P_{0} * T_{0}/T_{amb}

            %Grab a volumetric flow rate from the product-end of the jth 
            %column to the product tank
            vFlRaTaVal1 = vFlCol(:,nVols+1) ...
                       .* vFlScaleFac1;   
            vFlRaTaVal2 = vFlCol(:,nVols+1) ...
                       .* vFlScaleFac2;  

            %Update a volumetric flow rate for the stream between the 
            %adsorber and the raffinate product tank       
            vFlRaTa(:,i) = valAdsPrEnd2RaWa(i,nS) ...
                         * vFlRaTaVal1;

            %Update a volumetric flow rate for the waste stream (at the 
            %ambient pressure)
            vFlRaWa(:,i) = (1-valAdsPrEnd2RaWa(i,nS)) ...
                         * vFlRaTaVal2; 
        
        %The raffinate product tank does not interact with the ith 
        %adsorption column
        else
            
            %Nothing to do
                                     
        end        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For all streams around the extract product tank coming from or 
        %going to an adsorption column, assign the volumetric flow rates.
        %The volumetric flow rates are evaluated at the tank total 
        %concentration and the flow directions should be defined for the 
        %extract product tank.
         
        %The flow is from the extract product tank to the feed-end of the
        %ith adsorber
        if valExTa2AdsFeEnd(i,nS) == 1
            
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,1) ...
                       ./ exTaTotCon;

            %Update a volumetric flow rate for the effulent stream from the
            %extract product tank. 
            vFlExTa(:,i) = vFlCol(:,1) ...
                        .* vFlScaleFac;             

        %The flow is from the feed-end of the ith adsorber into the extract
        %product tank or the extract waste stream
        elseif valAdsFeEnd2ExTa(i,nS) == 1
            
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac1 = col.(sColNums{i}).gasConsTot(:,1) ...
                        ./ exTaTotCon;
            vFlScaleFac2 = col.(sColNums{i}).gasConsTot(:,1) ...
                        ./ (pRatAmb/(gasConsNormEq*tempAmbiNorm));      
            %c_{amb}/c_{0} = P_{amb}/P_{0} * T_{0}/T_{amb}

            %Grab a volumetric flow rate from the feed-end of the jth 
            %column to the extract product tank
            vFlExTaVal1 = vFlCol(:,1) ...
                       .* vFlScaleFac1;   
            vFlExTaVal2 = vFlCol(:,1) ...
                       .* vFlScaleFac2;

            %Update a volumetric flow rate for the stream between the 
            %adsorber and the extract product tank
            vFlExTa(:,i) = valAdsFeEnd2ExWa(i,nS) ...
                         * vFlExTaVal1;

            %Update a volumetric flow rate for the waste stream
            vFlExWa(:,i) = (1-valAdsFeEnd2ExWa(i,nS)) ...
                         * vFlExTaVal2;
                 
        %The extract product tank is interacting with the ith adsorber at
        %the product-end. 
        elseif valExTa2AdsPrEnd(i,nS) == 1
           
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{i}).gasConsTot(:,nVols) ...
                       ./ exTaTotCon;

            %Calcualate the volumetric flow rate from the extract product 
            %tank to the jth adsorption column.
            vFlExTa(:,i) = (-1)...
                         * vFlCol(:,nVols+1) ...
                        .* vFlScaleFac;              
                     
        %The extract product tank does not interact with the ith adsorption
        %column
        else
            
            %Nothing to do             
                     
        end        
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Save the results
    
    %Save the computed results to the output data structure
    vFlUnits.feTa = vFlFeTa;
    vFlUnits.raTa = vFlRaTa;
    vFlUnits.raWa = vFlRaWa;
    vFlUnits.exTa = vFlExTa;
    vFlUnits.exWa = vFlExWa;
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%