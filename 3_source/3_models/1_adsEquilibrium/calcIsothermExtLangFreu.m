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
%Code created on       : 2022/11/6/Sunday
%Code last modified on : 2022/11/6/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcIsothermExtLang.m
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

function newStates = calcIsothermExtLangFreu(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermExtLangFreu.m';
    
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    nRows        = params.nRows       ;    
    dimLessKOneC = params.dimLessKOneC;
    dimLessKTwoC = params.dimLessKTwoC; 
    dimLessKThrC = params.dimLessKThrC; 
    dimLessKFouC = params.dimLessKFouC; 
    dimLessKFivC = params.dimLessKFivC; 
    dimLessKSixC = params.dimLessKSixC; 
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
        
        %Grab dimensionless temperatures as fidlds in a struct
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
    dimLessAdsSiteNo = zeros(nRows,nVols*nComs);
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
            = dimLessKOneC(i) ...
            + dimLessKTwoC(i)*tempCstrs;    
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Obtain the temperature dependent dimensionless adsorption affinity
        %constant for the ith species
        
        %Compute the dimensionless adsorption affinity constant for the ith
        %species
        dimLessAdsAffCon(:,n0:nf) ...
            = dimLessKThrC(i) ...
            * exp(dimLessKFouC(i)./tempCstrs);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Obtain the temperature dependent dimensionless adsorption site
        %number constant for the ith species
        
        %Compute the dimensionless adsorption site number constant for the 
        %ith species
        dimLessAdsSiteNo(:,n0:nf) ...
            = dimLessKFivC(i) ...
            + dimLessKSixC(i)./tempCstrs;
        %-----------------------------------------------------------------%
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate adsorption equilibrium (Explicit)
    
    %Check to see if we have a single CSTR
    if nAds == 0

        %Make sure that nAds = 1 so that the indexing will work out
        nAds = 1;

    end

    %Initialize the denominator
    denominator = ones(nRows,nVols);

    %Update the species dependent term in the denominator of the
    %Extended Langmuir expression
    for i = 1 : nComs
        
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
        
        %Obtain the dimensionless adsorption affinity constant for the ith
        %species
        dimLessAdsAffConSpec = dimLessAdsAffCon(:,n0:nf);
        
        %Obtain the dimensionless adsorption site number constant for the
        %ith species
        dimLessAdsSiteNoSpec = dimLessAdsSiteNo(:,n0:nf);        
        %-----------------------------------------------------------------%
                
        
        
        %-----------------------------------------------------------------%
        %Compute the denominator term for the extended Langmuir-Freundlich
        %isotherm model

        %Update the denominator vector
        denominator = denominator ...
                    + (dimLessAdsAffConSpec.*colGasConsSpec.*tempCstrs) ...
                   .^ (dimLessAdsSiteNoSpec);
        %-----------------------------------------------------------------%

    end

    %Evaluate the explicit isotherm (i.e., Extened Langmuir-Freundlich
    %isotherm) and update the corresponding value to the output solution
    for i = 1 : nComs
        
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
        
        %Obtain the dimensionless adsorption site number constant for the
        %ith species
        dimLessAdsSiteNoSpec = dimLessAdsSiteNo(:,n0:nf);        
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Evaluate the adsoption equilibrium loading for the ith species
        
        %Calculate the adsoption equilibrium loading for the ith species
        loading = dimLessSatdConcSpec ...
               .* (dimLessAdsAffConSpec.*colGasConsSpec.*tempCstrs) ...
               .^ (dimLessAdsSiteNoSpec);        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Store the results
        
        %Get the beginning index
        nSt0 = nColStT*(nAds-1) ...
             + nComs+i;

        %Get the final index
        nStf = nColStT*(nAds-1) ...
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