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
%Code created on       : 2022/5/3/Tuesday
%Code last modified on : 2022/5/3/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValOneConPrCo.m
%Source     : common
%Description: a function that calculates a volumetric flow rate using a 
%             control law the product-end of an adsorption column so that
%             the pressure inside the (nc)th CSTR is maintained at a 
%             constant value. The flow direction is from an adsorption 
%             column to the raffinate product tank.
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

function volFlowRat ...
    = calcVolFlowValOneConPrCo(params,col,~,raTa,~,~,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValOneConPrCo.m';      
    
    %Unpack Params
    sColNums = params.sColNums;
    sComNums = params.sComNums;                 
    cstrHt   = params.cstrHt  ;
    nComs    = params.nComs   ;
    nVols    = params.nVols   ;
    bool     = params.bool    ;
    nRows    = params.nRows   ;
    
    %Unpack only if non-isothermal
    if bool(5) == 1
        
        %Unpack additional params
        gConsNormCol = params.gConsNormCol;
        htCapCvNorm  = params.htCapCvNorm ;
        htCapCpNorm  = params.htCapCpNorm ;
        
    end
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Unpack units
    
    %Dimensionless total concentrations     
    cNcM1 = col.(sColNums{nCo}).gasConsTot(:,nVols-1); %nc-1
    cNcM0 = col.(sColNums{nCo}).gasConsTot(:,nVols)  ; %nc
    cNcP1 = raTa.n1.gasConsTot                       ; %Raffinate tank     
    
    %Dimensionless temperatures
    TnCm1 = col.(sColNums{nCo}).temps.cstr(:,nVols-1); %nc-1
    TnCm0 = col.(sColNums{nCo}).temps.cstr(:,nVols)  ; %nc
    TnCp1 = raTa.n1.temps.cstr                       ; %Raffinate tank 
    
    %Dimensionless volumetric flow rate at (nc-1)th stream
    vFlNcM1 = col.vFl(:,nVols-1);
    
    %Dimensionless total adsorption rate inside (nc)th CSTR
    volAdsRatTotNc = col.(sColNums{nCo}).volAdsRatTot(:,nVols);
    
    %Dimensionless total rate of correction due to nonisothermal system
    volCorRatTotNc = col.(sColNums{nCo}).volCorRatTot(:,nVols);
    
    %Dimensionless overall heat capacity
    htCOnC = col.(sColNums{nCo}).htCO(:,nVols);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays
    
    %Initialize the summation for the species dependent terms
    sumTermNcPl = 0;
    sumTermNcMi = 0;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate necessary quantities
    
    %Get the dimensionless pseudo volumetric flow rates associated with 
    %(nc)th CSTR
    [vFlNcM1Pl,vFlNcM1Mi] = calcPseudoVolFlows(vFlNcM1);
    
    %If non-isothermal
    if bool(5) == 1
        
        %Calculate species dependent terms
        for i = 1 : nComs

            %Get the species concentrations
            gasSpecConNcM1 = col.(sColNums{nCo}). ...
                             gasCons.(sComNums{i})(:,nVols-1);
            gasSpecConNcP1 = raTa.n1.gasCons.(sComNums{i});

            %Update the species dependent term for the plus coefficient
            sumTermNcPl = sumTermNcPl ...
                        + (htCapCpNorm(i).*(TnCm1./TnCm0) ...
                          -htCapCvNorm(i)) ...
                       .* gasSpecConNcM1;

            %Update the species dependent term for the negative coefficient
            sumTermNcMi = sumTermNcMi ...
                        + (htCapCpNorm(i)*(TnCp1./TnCm0) ...
                          -htCapCvNorm(i)) ...
                       .* gasSpecConNcP1;

        end

        %Dimensionless time dependent coefficient with a positive 
        %superscript. i.e., $\alpha_{n_c}^{+}$
        alphaNcPl = -( (cNcM1./cNcM0) ...
                     + gConsNormCol.*cstrHt(nVols)./htCOnC ...
                    .* sumTermNcPl );

        %Dimensionless time dependent coefficient with a neutral 
        %superscript. i.e., $\alpha_{n_c}$
        alphaNc00 = 1 ...
                  + gConsNormCol.*cstrHt(nVols)./htCOnC ...
                 .* cNcM0;

        %Dimensionless time dependent coefficient with a negative 
        %superscript. i.e., $\alpha_{n_c}^{-}$
        alphaNcMi = -( (cNcP1./cNcM0) ...
                     + gConsNormCol.*cstrHt(nVols)./htCOnC ...
                    .* sumTermNcMi ); 
                 
    %If isothermal,           
    else
        
        %Dimensionless time dependent coefficient with a positive 
        %superscript. i.e., $\alpha_{n_c}^{+}$
        alphaNcPl = -1*ones(nRows,1);

        %Dimensionless time dependent coefficient with a neutral 
        %superscript. i.e., $\alpha_{n_c}$
        alphaNc00 = 1*ones(nRows,1);

        %Dimensionless time dependent coefficient with a negative 
        %superscript. i.e., $\alpha_{n_c}^{-}$
        alphaNcMi = -1*ones(nRows,1); 
                
    end
             
    %Compute the right hand side term for (nc)th CSTR
    rhsTermNc = -alphaNcPl.*vFlNcM1Pl ...
              + -alphaNc00.*vFlNcM1Mi ...
              - volAdsRatTotNc ...
              + volCorRatTotNc;
          
    %Check flow direction
    flowDir = rhsTermNc>=0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the volumetric flow rate after the valve      
    volFlowRat = rhsTermNc ...
              .* ( -(1./alphaNcMi) ...
                 + (1./alphaNc00 + 1./alphaNcMi) ...
                .* flowDir);
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%