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
%Code created on       : 2023/2/24/Friday
%Code last modified on : 2023/7/6/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcIsothermDecDuSiLangFreu.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) and 
%             returns the corresponding adsorbed phase concentration in 
%             equilibrium with bulk gas composition for the following:
%             Components   - $i \in \left\{ 1, ..., params.nComs \right\}$
%             CSTRs        - $n \in \left\{ 1, ..., params.nVols \right\}$
%             time points  - $t \in \left\{ 1, ..., nTimePts \right\}$ 
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             nAds         - the adsober number where we will evaluate the
%                            adsorption equilibrium
%Outputs    : newStates    - a dimensionless state solution of the same
%                            dimension as states but adsorbed phase
%                            concentrations are now in equilibrium with the
%                            gas phase concentrations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newStates = calcIsothermDecDuSiLangFreu(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermDecDuSiLangFreu.m';
    
    %Unpack params
    nStates      = params.nStates            ;
    nColStT      = params.nColStT            ;
    nComs        = params.nComs              ;
    sComNums     = params.sComNums           ; 
    nVols        = params.nVols              ;
    bool         = params.bool               ;   
    qSatSiteOneC = params.dimLessqSatSiteOneC;
    qSatSiteTwoC = params.dimLessqSatSiteTwoC;
    bSiteOneC    = params.dimLessbSiteOneC   ;
    bSiteTwoC    = params.dimLessbSiteTwoC   ;
    nSiteOneC    = params.nSiteOneC          ;
    nSiteTwoC    = params.nSiteTwoC          ; 
    nRows        = params.nRows              ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Determine the index for the number of adsorbers nAdsInd
        
    %When we have a single CSTR,
    if nAds == 0

        %Make sure that nAds = 1 so that the indexing will work out
        nAdsInd = 1;

    %Otherwise, let the index equal to itself                
    else

        %Make sure that nAds = 1 so that the indexing will work out
        nAdsInd = nAds;

    end  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for hysteresis
    
    %If we have a hystersis
    if bool(12) == 1
        
        %Unpack additional params
        hys = params.hys;                 
        
        %Determine the curve (adsorption vs. desorption) for the current
        %adsorber
        hysCurve = hys(nAdsInd);
        
        %Grab the right set of adsorption isotherm parameters
        qSatSiteOneC = qSatSiteOneC(:,hysCurve);
        qSatSiteTwoC = qSatSiteTwoC(:,hysCurve);
        bSiteOneC    = bSiteOneC   (:,hysCurve);
        bSiteTwoC    = bSiteTwoC   (:,hysCurve);
        nSiteOneC    = nSiteOneC   (:,hysCurve);
        nSiteTwoC    = nSiteTwoC   (:,hysCurve);     
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for the single CSTR case

    %If we have a single CSTR,
    if nAds == 0
        
        %-----------------------------------------------------------------%
        %Unpack the states
        
        %Grab dimensionless gas phase concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states); 
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Update a few quantities, depending on the calculations needed
        
        %Locally reset the number of volume parameter and the adsorbers
        nVols = 1;  
        %-----------------------------------------------------------------%
                
    %Otherwise, we have an adsorption column number specified by nAds
    else
        
        %-----------------------------------------------------------------%
        %Unpack the states
        
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states,nAds);  
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states,nAds);
        %-----------------------------------------------------------------%        

    end
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Define an output state solution vector/matrix
    newStates = states; 
    %---------------------------------------------------------------------%
    

    
    %---------------------------------------------------------------------%
    %Calculate adsorption equilibrium (Explicit)

    %Check if the simulation is an isothermal simulation
    isNonIsothermal = bool(5);

    %If non-isothermal operation,
    if isNonIsothermal == 1

        %Get the affinity parameter matrix at a specified CSTR temperature 
        %for all CSTRs
        bSiteOneC = getAdsAffConstant(params,states,nRows,nAds,bSiteOneC); 
        bSiteTwoC = getAdsAffConstant(params,states,nRows,nAds,bSiteTwoC);         
                        
    %For isothermal operation,
    elseif isNonIsothermal == 0            

        %Return time-invariant vectors
        bSiteOneC = repelem(bSiteOneC,nVols)';
        bSiteTwoC = repelem(bSiteTwoC,nVols)';

    end    
                    
    %Evaluate the explicit isotherm and update the corresponding value 
    %to the output solution
    for i = 1 : nComs

        %Get the common terms
        comTerm1 = (bSiteOneC(nVols*(i-1)+1:nVols*i) ...
                .* colTemps.cstr ...
                .* colGasCons.(sComNums{i})).^(nSiteOneC(i));
        comTerm2 = (bSiteTwoC(nVols*(i-1)+1:nVols*i) ...
                .* colTemps.cstr ...
                .* colGasCons.(sComNums{i})).^(nSiteTwoC(i));            

        %Update the denominator vector for the first site
        denominator1 = 1 + comTerm1;

        %Update the denominator vector for the second site
        denominator2 = 1 + comTerm2;

        %Calculate the adsoption equilibrium loadings for the sites
        loading1  = qSatSiteOneC(i)*comTerm1;
        loading2  = qSatSiteTwoC(i)*comTerm2;     

        %Get the beginning index
        n0 = nColStT*(nAdsInd-1) ...
           + nComs+i;

        %Get the final index
        nf = nColStT*(nAdsInd-1) ...
           + nStates*(nVols-1)+nComs+i;

        %For adosrbed concentrations, update with equilibrium 
        %concentrations with the current gas phase compositions
        newStates(:,n0:nStates:nf) ...
            = (loading1./denominator1) ... 
            + (loading2./denominator2);

    end          
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%