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
%Code created on       : 2022/8/9/Tuesday
%Code last modified on : 2022/8/9/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowEqualProdEnd.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the lower pressure adsorption column
%             of a pair of two adsorption columns undergoing a pressure
%             equalization in the product-end. 
%Inputs     : params       - a struct containing simulation parameters.
%             col          - a struct containing state variables and
%                            calculated quantities associated with
%                            adsorption columns inside the system.
%             feTa         - a struct containing state variables and
%                            calculated quantities associated with feed
%                            tanks inside the system.
%             raTa         - a struct containing state variables and
%                            calculated quantities associated with product
%                            tanks inside the system.
%             exTa         - a struct containing state variables and
%                            calculated quantities associated with extract 
%                            the product tank inside the system.
%             nS           - jth step in a given PSA cycle
%             nCo          - the column number
%Outputs    : volFlowRat   - a volumetric flow rate after the valve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function volFlowRat = calcVolFlowEqualProdEnd(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowEqualProdEnd.m';      
    
    %Unpack Params       
    valProdColNorm = params.valProdColNorm;
    sColNums       = params.sColNums      ;
    funcVal        = params.funcVal       ; 
    numAdsEqPrEnd  = params.numAdsEqPrEnd ;
    
    %Get the index of the equalizing adsorber
    nC2 = numAdsEqPrEnd(nCo,nS);
    
    %Get a dimensionless valve constant value for the product-end 
    %equalization valve (i.e., valve 3). We choose the minimum of the two
    %valve constants associated with the two adsorbers undergoing the
    %pressure equalization.
    val3Con1 = valProdColNorm(nCo,nS);
    val3Con2 = valProdColNorm(nC2,nS);
    val3Con  = min(val3Con1,val3Con2);
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
    
    %Dimensionless total concentration for the Nth CSTR for the other
    %column uncergoing pressure equalization
    gasConTotEqualAds = col.(sColNums{nC2}).gasConsTot(:,end);
    
    %Dimensionless total concentration for the Nth CSTR for the current
    %column uncergoing pressure equalization
    gasConTotCurrAds = col.(sColNums{nCo}).gasConsTot(:,end);           
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the high pressure column
    cstrTempEqualAds = col.(sColNums{nC2}).temps.cstr(:,end);
    
    %Dimensionless temperature for the low pressure column
    cstrTempCurrAds = col.(sColNums{nCo}).temps.cstr(:,end); 
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the molar flow rate after the valve      
    molFlowRat = funcVal(val3Con, ...
                         gasConTotEqualAds, ...
                         gasConTotCurrAds, ...
                         cstrTempEqualAds, ...
                         cstrTempCurrAds);
                     
    %Calculate the volumetric flow rate at the outlet stream of the valve
    volFlowRat = molFlowRat ...
              ./ gasConTotCurrAds;    
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%