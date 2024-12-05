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
%Function   : calcIsothermToth.m
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

function newStates = calcIsothermToth(params,states,nAds)
% calcIsothermExtLangFreu(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermToth.m';
    
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    nRows        = params.nRows       ;    
    dimLessSatdConc0    = params.dimLessSatdConc    ;
    dimLessAdsAffCon0   = params.dimLessAdsAffCon   ; 
    dimLessTotIsoExp0   = params.dimLessTotIsoExp   ; 
    dimLessChi          = params.dimLessChi         ; 
    dimLessTotAlpha     = params.dimLessTotAlpha    ;
    tempRefNorm         = params.tempRefNorm        ;
    
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
    %Check for the single CSTR case

    %If we have a single CSTR,
    if nAds == 0
    
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states);
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states);

        %Locally reset the number of volume parameter
        nVols = 1;        

    %Otherwise, we have an adsorption column number specified by nAds
    else
        
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states,nAds);  
        

        %Grab dimensionless temperatures as fields in a struct
        colTemps = convert2ColTemps(params,states,nAds);

    end
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Define an output state solution vector/matrix
    newStates = states; 
    
    %Initialize a numerical array for the temperature dependent
    %dimensionless saturation constant
    dimLessSatdConc = zeros(nRows,nVols*nComs);
    
    %Initialize a numerical array for the temperature dependent
    %dimensionless adsorption affinity constant
    dimLessAdsAffCon = zeros(nRows,nVols*nComs);
    
    %Initialize a numerical array for the temperature dependent adsorption
    %site number constant
    dimLessTotIsoExp = zeros(nRows,nVols*nComs);
    %---------------------------------------------------------------------%
    

    
    %---------------------------------------------------------------------%
    %Unpack adsorber states

    %Get the current temperature inside the CSTR
    tempCstrs = colTemps.cstr;
    %---------------------------------------------------------------------%
        
        
    
    %---------------------------------------------------------------------%
    %Calculate the temperature dependent isotherm parameters
    
    %For each species
    for i = 1 : nComs
        
        %-----------------------------------------------------------------%
        %Obtain the indices
        
        %Obtain the beginning index
        n0 = nVols*(i-1)+1;
        
        %Obtain the ending index
        nf = nVols*i;
        %-----------------------------------------------------------------%
        
 
        
        %-----------------------------------------------------------------%
        %Obtain the temperature dependent dimensionless saturation constant
        %for the ith species
                        
        %Compute the dimensionless saturation constants for the ith species
        %and save it inside the solution matrix
        dimLessSatdConc(:,n0:nf) ...
            = dimLessSatdConc0(i) ...
            + exp(dimLessChi(i)*(tempRefNorm./tempCstrs - 1));
        %-----------------------------------------------------------------%
        
                                        
        
        %-----------------------------------------------------------------%
        %Obtain the temperature dependent dimensionless adsorption site
        %number constant for the ith species
        
        %Compute the dimensionless Toth isotherm exponent for the 
        %ith species
        dimLessTotIsoExp(:,n0:nf) ...
            = (dimLessTotIsoExp0(i)...
            + dimLessTotAlpha(i).*(1 - tempRefNorm./tempCstrs));
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Obtain the temperature dependent dimensionless adsorption affinity
        %constant for the ith species in ISOTHERMAL case
        if params.bool(5) == 0
            dimLessAdsAffCon(:,n0:nf) = dimLessAdsAffCon0(i);
        
        %Compute the dimensionless adsorption affinity constant for the ith
        %species for NONISOTHERMAL case
        elseif params.bool(5) == 1
            dimLessIsoStHtRef = params.dimLessIsoStHtRef;

            dimLessAdsAffCon(:,n0:nf) ...
                = dimLessAdsAffCon0(i) ...
                .* exp(-dimLessIsoStHtRef(i) - (tempRefNorm./tempCstrs - 1));
        end
        %-----------------------------------------------------------------%
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate adsorption equilibrium (Explicit)

    %Update the species dependent term in the denominator of the
    %Extended Langmuir expression
    for i = 1 : nComs
        
        %Initialize the denominator
        denominator = ones(nRows,nVols);
        
        %-----------------------------------------------------------------%
        %Obtain the indices
        
        %Obtain the beginning index
        n0 = nVols*(i-1)+1;
        
        %Obtain the ending index
        nf = nVols*i;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Unpack the adsorber states and the isotherm parameters for the ith
        %species
        
        %Obtain the current gas phase species concentration
        colGasConsSpec = colGasCons.(sComNums{i});

        %Obtain the dimensionless saturation constant for the ith species
        dimLessSatdConcSpec = dimLessSatdConc(:,n0:nf);
        
        %Obtain the dimensionless adsorption affinity constant for the ith
        %species
        dimLessAdsAffConSpec = dimLessAdsAffCon(:,n0:nf);
        
        %Obtain the dimensionless Toth isotherm exponent for the ith species
        dimLessTotIsoExpSpec = dimLessTotIsoExp(:,n0:nf);        
        %-----------------------------------------------------------------%
                
        
        
        %-----------------------------------------------------------------%
        %Compute the denominator term for the Toth isotherm model

        %Update the denominator vector
        denominator = (denominator ...
                    + sign(dimLessAdsAffConSpec.* colGasConsSpec.*tempCstrs) ...
                   .* (abs(dimLessAdsAffConSpec.* colGasConsSpec.*tempCstrs))...
                   .^ dimLessTotIsoExpSpec)...
                   .^ 1./dimLessTotIsoExpSpec;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Evaluate the adsoption equilibrium loading for the ith species
        
        %Calculate the adsoption equilibrium loading for the ith species
        loading = dimLessSatdConcSpec ...
               .* dimLessAdsAffConSpec ...
               .* (colGasConsSpec.*tempCstrs);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Store the results
        
        %Get the beginning index
        nSt0 = nColStT*(nAdsInd-1) ...
             + nComs+i;

        %Get the final index
        nStf = nColStT*(nAdsInd-1) ...
             + nStates*(nVols-1)+nComs+i;

        %For adosrbed concentrations, update with equilibrium 
        %concentrations with the current gas phase compositions
        newStates(:,nSt0:nStates:nStf) ...
            = loading ...
           ./ denominator;
        %-----------------------------------------------------------------%

    end          
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%