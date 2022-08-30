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
%Code created on       : 2022/8/27/Saturday
%Code last modified on : 2022/8/30/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValSixBpr2ExWa.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             back pressure regulator located at the feed-end of an 
%             adsorption column. The flow direction is from an adsorption 
%             column to the extract waste stream. This is a constant 
%             pressure step at a high pressure of an adsorption column, 
%             i.e., presBeHiFull.
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

function volFlowRat = calcVolFlowValSixBpr2ExWa(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValSixBpr2ExWa.m';      
    
    %Unpack Params    
    pRat            = params.pRat                  ;
    pRatLowSet      = params.pRatLowSet            ;
    pRatLowFull     = params.pRatLowFull           ;
    valFeedColNorm  = params.valFeedColNorm(nCo,nS);
    sColNums        = params.sColNums              ;  
    gasConsNormEq   = params.gasConsNormEq         ;   
    nRows           = params.nRows                 ;
    tempColNorm     = params.tempColNorm           ;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
    
    %Dimensionless total concentration for the Nth CSTR
    gasConTotCol = col.(sColNums{nCo}).gasConsTot(:,1);           
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the last CSTR
    cstrTempCol = col.(sColNums{nCo}).temps.cstr(:,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless pressures
    
    %Calculate the pressure inside the product-end CSTR and the raffinate
    %waste stream
    presTotCol = gasConsNormEq.*gasConTotCol.*cstrTempCol;   
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Compute the function output       

    %Calculate the dimensionless pressure difference term. We assume that
    %the downstream of the back-pressure regulator + check valve is always
    %fixed at a constant pressure at the desired low pressure, whether it
    %may be a vacuum or an ambient pressure.
    deltaPres ...
        = (pRat-pRatLowSet) ...
       ./ (pRatLowFull-pRatLowSet) ...
        * ones(nRows,1);
    
    %Initialize the molar flow rate vector
    molFlFeEnd2ExWa = zeros(nRows,1);   
       
    %For each time point,
    for t = 1 : nRows
        
        %The molar flow rate over the back pressure regulator and check
        %valve is calculated as below
        molFlFeEnd2ExWa(t) ...
            = valFeedColNorm*tempColNorm/1000 ...
            * median([0,deltaPres(t),1]) ...
            * min(0,pRat-presTotCol(t));
                     
    end         
    
    %Calculate the volumetric flow rate coming out from the adsorber at the
    %product-end
    volFlowRat = molFlFeEnd2ExWa ...
              ./ gasConTotCol;
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%