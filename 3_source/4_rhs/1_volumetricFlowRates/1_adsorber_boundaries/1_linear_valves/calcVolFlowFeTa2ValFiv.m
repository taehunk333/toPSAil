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
%Code created on       : 2022/2/10/Thursday
%Code last modified on : 2022/8/9/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowFeTa2ValFiv.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the product-end of an adsorption
%             column. The flow direction is from the feed tank to an
%             adsorption column.
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

function volFlowRat = calcVolFlowFeTa2ValFiv(params,col,feTa,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowFeTa2ValFiv.m';      
    
    %Unpack Params           
    valProdColNorm = params.valProdColNorm;
    sColNums       = params.sColNums      ;
    funcVal        = params.funcVal       ;
    
    %Get a dimensionless valve constant value for the purge/pressurization
    %valve (i.e., valve 5)
    val5Con = valProdColNorm(nCo,nS);
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
        
    %Dimensionless total concentration for the Nth CSTR
    gasConTotCol = col.(sColNums{nCo}).gasConsTot(:,end);
    
    %Dimensionless total concentration for the product tank
    gasConTotFeTa = feTa.n1.gasConsTot;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the last CSTR
    cstrTempCol = col.(sColNums{nCo}).temps.cstr(:,end);
    
    %Dimensionless temperature for the feed tank
    cstrTempFeTa = feTa.n1.temps.cstr;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the molar flow rate after the valve      
    molFlowRat = funcVal(val5Con, ...                         
                         gasConTotFeTa, ...
                         gasConTotCol, ...                         
                         cstrTempFeTa, ...
                         cstrTempCol);
                      
    %Calculate the volumetric flow rate at the valve outlet
    volFlowRat = molFlowRat ./ gasConTotCol;
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%