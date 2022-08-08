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
%Code last modified on : 2022/3/3/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValRaEqCu.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the lower pressure adsorption column
%             of a pair of two adsorption columns undergoing a pressure
%             equalization in the product-end. This function should be used
%             for a counter-current flow direction.
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

function volFlowRat = calcVolFlowValRaEqCu(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValRaEqCu.m';      
    
    %Unpack Params       
    valProdCol   = params.valProdCol  ;
    nAdsVals     = params.nAdsVals    ;
    colIntActTop = params.colIntActTop;
    sColNums     = params.sColNums    ;
    funcVal      = params.funcVal     ;
    
    %Find the corresponding valve constant for the other adsorption column
    nC2 = colIntActTop(nCo,nS);    
    
    %Get the valve constant associated with the current adsorption column
    valConCurr = valProdCol(nCo,nS);
    
    %For an open valve, grab a corresponding valve constant from the other
    %interacting column 
    if valConCurr == 1
        
        %Get the corresponding valve constant
        valConCurr = valConNorm(nAdsVals*(nC2-1)+3,nS);                
        
    end
    
    %Get a dimensionless valve constant value for the product-end 
    %equalization valve (i.e., valve 3)    
    val3Con = valConCurr;
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
    
    %Dimensionless total concentration for the Nth CSTR for the other
    %column uncergoing pressure equalization
    gasConTotHiPr = col.(sColNums{nC2}).gasConsTot(:,end);
    
    %Dimensionless total concentration for the Nth CSTR for the current
    %column uncergoing pressure equalization
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
    volFlowRat = -funcVal(val3Con, ...
                          gasConTotLoPr, ...
                          gasConTotHiPr, ...
                          cstrTempLoPr, ...
                          cstrTempHiPr);
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%