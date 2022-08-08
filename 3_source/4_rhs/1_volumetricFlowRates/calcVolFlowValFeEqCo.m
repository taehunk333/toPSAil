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
%Code created on       : 2021/1/26/Tuesday
%Code last modified on : 2022/8/8/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValFeEqCo.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the lower pressure adsorption column
%             of a pair of two adsorption columns undergoing a pressure
%             equalization in the feed-end. This function should be used 
%             for a co-current flow direction.
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

function volFlowRat = calcVolFlowValFeEqCo(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValFeEqCo.m';      
    
    %Unpack Params        
    valFeedCol   = params.valFeedCol  ;
    nAdsVals     = params.nAdsVals    ;
    colIntActBot = params.colIntActBot;
    sColNums     = params.sColNums    ;
    funcVal      = params.funcVal     ;
    
    %Find the corresponding valve constant for the other adsorption column
    nC2 = colIntActBot(nCo,nS);    
    
    %Get the valve constant associated with the current adsorption column
    valConCurr = valFeedCol(nCo,nS);
    
    %For an open valve, grab a corresponding valve constant from the other
    %interacting column 
    if valConCurr == 1
        
        %Get the corresponding valve constant
        valConCurr = valConNorm(nAdsVals*(nC2-1)+4,nS);                
        
    end
    
    %Get a dimensionless valve constant value for the feed-end equalization
    %valve (i.e., valve 4)    
    val4Con = valConCurr;
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Get total concentrations
    
    %Dimensionless total concentration for the 0th CSTR for the other
    %column undergoing equalization
    gasConTotHiPr = col.(sColNums{nC2}).gasConsTot(:,end);
    
    %Dimensionless total concentration for the 0th CSTR for the current
    %column undergoing equalization
    gasConTotLoPr = col.(sColNums{nCo}).gasConsTot(:,end);            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the high pressure column
    cstrTempHiPr = col.(sColNums{nC2}).temps.cstr(:,end);
    
    %Dimensionless temperature for the low pressure column
    cstrTempLoPr = col.(sColNums{nCo}).temps.cstr(:,end); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the volumetric flow rate after the valve      
    volFlowRat = funcVal(val4Con, ...
                         gasConTotLoPr, ...
                         gasConTotHiPr, ...
                         cstrTempLoPr, ...
                         cstrTempHiPr); 
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%