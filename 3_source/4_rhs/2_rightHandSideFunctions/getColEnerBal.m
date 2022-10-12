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
%Code created on       : 2022/4/11/Monday
%Code last modified on : 2022/10/12/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getColEnerBal.m
%Source     : common
%Description: a function that evaluates the energy balance right hand side
%             relationship for the current time point for all adsorption
%             columns.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getColEnerBal(params,units)
    
    %---------------------------------------------------------------------%
    %Check to see if we need an energy balance
    
    %Unpack minimal number of params
    sColNums = params.sColNums;
    bool     = params.bool    ;
    nVols    = params.nVols   ;
    nCols    = params.nCols   ;
    
    %Unpack units
    col = units.col;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %For each adsorption column,
        for i = 1 : nCols
        
            %Don't do the energy balance on the columns
            units.col.(sColNums{i}).cstrEnBal = zeros(1,nVols);            
            units.col.(sColNums{i}).wallEnBal = zeros(1,nVols);  
            
        end
        %-----------------------------------------------------------------%
    
        
        
        %-----------------------------------------------------------------%
        %Skip the non-isothermal simulation
        
        %Return to the invoking function 
        return;
        %-----------------------------------------------------------------%
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColEnerBal.m';
    
    %Unpack params    
    nCols         = params.nCols        ;
    nRows         = params.nRows        ;
    nComs         = params.nComs        ;    
    intHtTrFacCol = params.intHtTrFacCol;
    extHtTrFacCol = params.extHtTrFacCol;
    nVols         = params.nVols        ;     
    isoStHtNorm   = params.isoStHtNorm  ;
    partCoefHp    = params.partCoefHp   ;
    gConsNormCol  = params.gConsNormCol ;
    tempAmbiNorm  = params.tempAmbiNorm ;
    sColNums      = params.sColNums     ; 
    sComNums      = params.sComNums     ;
    cstrHt        = params.cstrHt       ;
    htCapCpNorm   = params.htCapCpNorm  ;    
    %---------------------------------------------------------------------%              
    
 
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for all CSTRs for all columns
    
    %For each column, 
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%    
        %Compute the interior heat transfer rates
        dQndt = col.(sColNums{i}).temps.wall ...
              - col.(sColNums{i}).temps.cstr;
                            
        %Compute the exterior heat transfer rates
        dQnwdt = tempAmbiNorm*ones(1,nVols) ...
               - col.(sColNums{i}).temps.wall;    
        
        %Save the column wall energy balance into the struct
        col.(sColNums{i}).wallEnBal ...
            = extHtTrFacCol*dQnwdt ...
            - intHtTrFacCol*dQndt;
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%                                       
        %Initialize the right hand side of dimensionless energy balance
        
        %Save the heat transfer rate to the column wall from CSTR in the 
        %right hand side of the dTn/dt
        col.(sColNums{i}).cstrEnBal = dQndt;              
        %-----------------------------------------------------------------%    
        
       

        %-----------------------------------------------------------------%
        %Unpack units

        %Unpack the interior temperature variables 
        cstrTemps = col.(sColNums{i}).temps.cstr;
        
        %Unpack the pseudo volumetric flow rates
        vPlNm1 = col.(sColNums{i}).volFlPlus(:,1:nVols)   ;
        vMiNm0 = col.(sColNums{i}).volFlMinus(:,2:nVols+1);

        %Unpack the interior temperature variables
        Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                cstrTemps(:,1:nVols-1)];
        Tnm0 = cstrTemps(:,1:nVols);
        Tnp1 = [cstrTemps(:,2:nVols), ...
                col.(sColNums{i}).prEnd.temps];

        %Unpack the overall heat capacity                
        htCOnm0 = col.(sColNums{i}).htCO(:,1:nVols);                                                               
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Calcualte the summation terms in the energy balance equation

        %Initialize the non-vectorized terms
        adsHeatGen   = zeros(nRows,nVols);
        flEnerAbove  = zeros(nRows,nVols);
        flEnerBelow  = zeros(nRows,nVols);
        totGasConRhs = zeros(nRows,nVols);
        
        %For each species,
        for j = 1 : nComs
                                                           
            %-------------------------------------------------------------%
            %Get the contribution from jth species on the heat generated
            %from adsorption
            
            %Update the term for the energy generated from adsorption
            adsHeatGen = adsHeatGen ...
                       + isoStHtNorm(j) ...
                      .* col.(sColNums{i}). ...
                         adsRat.(sComNums{j});     
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Unpack Concentrations associated with jth species
            
            %Unpack gas species concentration
            gasConsSpec = col.(sColNums{i}).gasCons. ...
                          (sComNums{j});
            
            %Get the species concentration vector including the feed-end
            %species concentration
            gasConsSpecNm1 = [col.(sColNums{i}).feEnd. ...
                             gasCons.(sComNums{j}), ...
                             gasConsSpec(:,1:nVols-1)];
            
            %Get the species concentration vector including the product-end
            %species concentration
            gasConsSpecNp1 = [gasConsSpec(:,2:nVols), ...
                             col.(sColNums{i}).prEnd. ...
                             gasCons.(sComNums{j})];             
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Get the contribution from jth species on the convective energy
            %flow terms
            
            %Update the convective flow in of energy from above
            flEnerAbove = flEnerAbove ...
                        + htCapCpNorm(j) ...
                       .* gasConsSpecNp1;    
            
            %Update the convective flow in of energy from below
            flEnerBelow = flEnerBelow ...
                        + htCapCpNorm(j) ...
                       .* gasConsSpecNm1;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Get the contribution from jth species on the species mole
            %balance
            
            %Get the right hand side of species i mole balance
            totGasConRhs = totGasConRhs ...
                         + col.(sColNums{i}). ...
                           moleBal.(sComNums{j});
            %-------------------------------------------------------------%

        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Take account for the pre-factors
        
        %Multiply the pre-factors for the adsorption heat term
        adsHeatGen = adsHeatGen ...
                  .* partCoefHp ...
                  .* cstrHt;
               
        %Multiply the pre-factors for the convective enthalpy flow in from
        %above term
        flEnerAbove = flEnerAbove ...
                   .* vMiNm0.*(Tnp1-Tnm0);
        
        %Multiply the pre-factors for the convective enthalpy flow in from
        %bottom term
        flEnerBelow = flEnerBelow ...
                   .* vPlNm1.*(Tnm1-Tnm0);
        
        %Multiply the pre-factors for the energy change due to the pressure
        %change in the CSTRs
        totGasConRhs = totGasConRhs ...
                    .* cstrHt ...
                    .* Tnm0;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%    
        %Do the energy balance for the interior CSTRs for a given adsorber

        %Update the energy balance on all the CSTRs associated with ith
        %adsorption column
        col.(sColNums{i}).cstrEnBal ... 
            = (col.(sColNums{i}).cstrEnBal ...
            + gConsNormCol ...
            * (adsHeatGen ...
            + flEnerAbove ...
            + flEnerBelow ...
            + totGasConRhs)) ...
           ./ htCOnm0;                                   
        %-----------------------------------------------------------------%                
        
    end                              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.col = col;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%