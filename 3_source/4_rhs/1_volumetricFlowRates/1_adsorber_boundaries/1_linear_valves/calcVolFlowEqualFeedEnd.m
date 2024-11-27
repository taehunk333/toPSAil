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
%Function   : calcVolFlowEqualFeedEnd.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the lower pressure adsorption column
%             of a pair of two adsorption columns undergoing a pressure
%             equalization in the feed-end. 
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

function volFlowRat = calcVolFlowEqualFeedEnd(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowEqualFeedEnd.m';      
    
    %Unpack Params        
    valFeedColNorm = params.valFeedColNorm;
    sColNums       = params.sColNums      ;
    funcVal        = params.funcVal       ;
    numAdsEqFeEnd  = params.numAdsEqFeEnd ;
    
    %Get the index of the equalizing adsorber
    nC2 = numAdsEqFeEnd(nCo,nS);  
       
    %Get a dimensionless valve constant value for the feed-end equalization
    %valve (i.e., valve 4). We choose the minimum of the two
    %valve constants associated with the two adsorbers undergoing the
    %pressure equalization.
    val4Con1 = valFeedColNorm(nCo,nS);
    val4Con2 = valFeedColNorm(nC2,nS);
    val4Con  = min(val4Con1,val4Con2);
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Get total concentrations
    
    %Dimensionless total concentration for the 1st CSTR for the other
    %column undergoing equalization
    gasConTotEqualAds = col.(sColNums{nC2}).gasConsTot(:,1);
    
    %Dimensionless total concentration for the 1st CSTR for the current
    %column undergoing equalization
    gasConTotCurrAds = col.(sColNums{nCo}).gasConsTot(:,1);            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the high pressure column
    cstrTempEqualAds = col.(sColNums{nC2}).temps.cstr(:,1);
    
    %Dimensionless temperature for the low pressure column
    cstrTempCurrAds = col.(sColNums{nCo}).temps.cstr(:,1); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the molar flow rate after the valve      
    molFlowRat = funcVal(val4Con, ...
                         gasConTotCurrAds, ...
                         gasConTotEqualAds, ...
                         cstrTempCurrAds, ...
                         cstrTempEqualAds); 
                     
    %Calculate the volumetric flow rate at the outlet stream of the valve
    volFlowRat = molFlowRat ...
              ./ gasConTotCurrAds;    
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%