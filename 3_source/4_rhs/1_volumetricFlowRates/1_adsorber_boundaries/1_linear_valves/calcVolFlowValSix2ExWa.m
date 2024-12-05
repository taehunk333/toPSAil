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
%Function   : calcVolFlowValSix2ExWa.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the feed-end of an adsorption
%             column. The flow direction is from an adsorption colum down
%             to the waste stream.
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

function volFlowRat = calcVolFlowValSix2ExWa(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValSix2ExWa.m';      
    
    %Unpack Params    
    valFeedColNorm = params.valFeedColNorm;
    pRatDoSt       = params.pRatDoSt      ;
    sColNums       = params.sColNums      ;
    funcVal        = params.funcVal       ;
    tempAmbiNorm   = params.tempAmbiNorm  ;
            
    %Get a dimensionless valve constant value for the waste valve (i.e. 
    %valve 6)
    val6Con = valFeedColNorm(nCo,nS);        
    %---------------------------------------------------------------------%                
      
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
        
    %Dimensionless total concentration for the 1st CSTR
    gasConTotCol = col.(sColNums{nCo}).gasConsTot(:,1);
    
    %Dimensionless total concentration for the waste stream
    gasConTotExWa = pRatDoSt;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the 1st CSTR
    cstrTempCol = col.(sColNums{nCo}).temps.cstr(:,1);
    
    %Dimensionless temperature for the product tank
    cstrTempExWa = tempAmbiNorm;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the molar flow rate after the valve      
    molFlowRat = funcVal(val6Con, ...                          
                         gasConTotCol, ...
                         gasConTotExWa, ...                          
                         cstrTempCol, ...
                         cstrTempExWa);
    
    %Calculate the volumetric flow rate coming out from the adsorber
    volFlowRat = molFlowRat ./ gasConTotCol;
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%