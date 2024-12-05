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
%Function   : calcVolFlowValOneBpr2RaTa.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             back pressure regulator located at the product-end of an 
%             adsorption column. The flow direction is from an adsorption 
%             column to the raffinate product tank. Therefore, this is a
%             constant pressure step at a high pressure of an adsorption
%             column, i.e., presBeHiFull.
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

function volFlowRat = calcVolFlowValOneBpr2RaTa(params,col,~,raTa,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValOneBpr2RaTa.m';      
    
    %Unpack Params    
    pRatHighSet    = params.pRatHighSet           ;
    pRatHighFull   = params.pRatHighFull          ;
    valProdColNorm = params.valProdColNorm(nCo,nS);
    sColNums       = params.sColNums              ;   
    gasConsNormEq  = params.gasConsNormEq         ;
    nVols          = params.nVols                 ;
    nRows          = params.nRows                 ;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
    
    %Dimensionless total concentration for the Nth CSTR
    gasConTotCol = col.(sColNums{nCo}).gasConsTot(:,nVols);
    
    %Dimensionless total concentration for the raffinate product tank
    gasConTotRaTa = raTa.n1.gasConsTot;            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the last CSTR
    cstrTempCol = col.(sColNums{nCo}).temps.cstr(:,nVols);
    
    %Dimensionless temperature for the product tank
    cstrTempRaTa = raTa.n1.temps.cstr;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless pressures
    
    %Calculate the pressure inside the product-end CSTR and the raffinate
    %product tank
    presTotCol = gasConTotCol.*cstrTempCol  ;
    presRaTa   = gasConTotRaTa.*cstrTempRaTa;    
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Compute the function output       

    %Calculate the dimensionless pressure difference term
    deltaPres ...
        = (gasConsNormEq*presTotCol-pRatHighSet) ...
       ./ (pRatHighFull-pRatHighSet);
   
    %Initialize the molar flow rate vector
    molFlPrEnd2RaTa = zeros(nRows,1);   
       
    %For each time point,
    for t = 1 : nRows
        
        %The molar flow rate over the back pressure regulator and check
        %valve is calculated as below
        molFlPrEnd2RaTa(t) ...
            = valProdColNorm ...
            * median([0,deltaPres(t),1]) ...
            * max(0,presTotCol(t)-presRaTa(t));
                     
    end         
    
    %Calculate the volumetric flow rate coming out from the adsorber at the
    %product-end
    volFlowRat = molFlPrEnd2RaTa ...
              ./ gasConTotCol;
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%