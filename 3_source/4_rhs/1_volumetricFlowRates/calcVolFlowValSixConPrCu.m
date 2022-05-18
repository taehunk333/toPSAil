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
%Code last modified on : 2022/5/13/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValSixConPrCu.m
%Source     : common
%Description: a function that calculates a volumetric flow rate using a 
%             control law the feed-end of an adsorption column so that
%             the pressure inside the 1st CSTR is maintained at a constant
%             value. The flow direction is from an adsorption column to
%             the raffinate product tank.
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

function volFlowRat = calcVolFlowValSixConPrCu(params,col,~,~,~,~,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValSixConPrCu.m';      
    
    %Unpack Params
    sColNums = params.sColNums;
    sComNums = params.sComNums;                 
    cstrHt   = params.cstrHt  ;
    nComs    = params.nComs   ;
    bool     = params.bool    ;
    
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
    c0 = col.(sColNums{nCo}).feEnd.gasConsTot; %nc-1
    c1 = col.(sColNums{nCo}).gasConsTot(:,1) ; %nc
    c2 = col.(sColNums{nCo}).gasConsTot(:,2) ; %Raffinate tank     
    
    %Dimensionless temperatures
    T0 = col.(sColNums{nCo}).feEnd.temps    ; %nc-1
    T1 = col.(sColNums{nCo}).temps.cstr(:,1); %nc
    T2 = col.(sColNums{nCo}).temps.cstr(:,2); %Raffinate tank 
    
    %Dimensionless volumetric flow rate at 1st stream
    vFl1 = col.vFlInterior(:,1);
    
    %Dimensionless total adsorption rate inside 1st CSTR
    volAdsRatTotNc = col.(sColNums{nCo}).volAdsRatTot(:,1);
    
    %Dimensionless total rate of correction due to nonisothermal system
    volCorRatTotNc = col.(sColNums{nCo}).volCorRatTot(:,1);
    
    %Dimensionless overall heat capacity
    htCOnC = col.(sColNums{nCo}).htCO(:,1);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays
    
    %Initialize the summation for the species dependent terms
    sumTerm2 = 0;
    sumTerm0 = 0;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate necessary quantities
    
    %Get the dimensionless pseudo volumetric flow rates associated with 
    %(nc)th CSTR
    [vFl1Pl,vFl1Mi] = calcPseudoVolFlows(vFl1);
    
    %If non-isothermal
    if bool(5) == 1
        
        %Calculate species dependent terms
        for i = 1 : nComs

            %Get the species concentrations
            gasSpecCon0 = col.(sColNums{nCo}).feEnd. ...
                          gasCons.(sComNums{i});
            gasSpecCon2 = col.(sColNums{nCo}). ...
                          gasCons.(sComNums{i})(:,2);

            %Update the species dependent term for the plus coefficient
            sumTerm2 = sumTerm2 ...
                     + (htCapCpNorm(i).*(T0./T1)-htCapCvNorm(i)) ...
                    .* gasSpecCon0;

            %Update the species dependent term for the negative coefficient
            sumTerm0 = sumTerm0 ...
                     + (htCapCpNorm(i).*(T2./T1)-htCapCvNorm(i)) ...
                    .* gasSpecCon2;

        end

        %Dimensionless time dependent coefficient with a positive 
        %superscript. i.e., $\alpha_{n_c}^{+}$
        alpha1Pl = -( (c0./c1) ...
                    + gConsNormCol.*cstrHt(1)./htCOnC ...
                   .* sumTerm2 );

        %Dimensionless time dependent coefficient with a neutral 
        %superscript. i.e., $\alpha_{n_c}$
        alpha100 = 1 ...
                 + gConsNormCol.*cstrHt(1)./htCOnC ...
                .* c1;

        %Dimensionless time dependent coefficient with a negative 
        %superscript. i.e., $\alpha_{n_c}^{-}$
        alpha1Mi = -( (c2/c1) ...
                    + gConsNormCol.*cstrHt(1)./htCOnC ...
                   .* sumTerm0 ); 
                 
    %If isothermal             
    else
        
        %Dimensionless time dependent coefficient with a positive 
        %superscript. i.e., $\alpha_{n_c}^{+}$
        alpha1Pl = -1;

        %Dimensionless time dependent coefficient with a neutral 
        %superscript. i.e., $\alpha_{n_c}$
        alpha100 = 1;

        %Dimensionless time dependent coefficient with a negative 
        %superscript. i.e., $\alpha_{n_c}^{-}$
        alpha1Mi = -1; 
                
    end
             
    %Compute the right hand side term for (nc)th CSTR
    rhsTermNc = -alpha100.*vFl1Pl ...
              + -alpha1Mi.*vFl1Mi ...
              - volAdsRatTotNc ...
              + volCorRatTotNc;
          
    %Check flow direction
    flowDir = rhsTermNc>=0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the volumetric flow rate after the valve      
    volFlowRat = rhsTermNc ...
              .* ( (1./alpha1Pl) ...
                 + -(1./alpha1Pl + 1./alpha100) ...
                   .*flowDir);
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%