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
%Function   : calcIsothermMultiSiteLang.m
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

function newStates = calcIsothermMultiSiteLang(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'calcIsothermMultiSiteLang.m';
    
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    bool         = params.bool        ;
    nRows        = params.nRows       ;    
    aC           = params.aC          ;
    dimLessKC    = params.dimLessKC   ;
    dimLessQsatC = params.dimLessQsatC;
    numZero      = params.numZero     ;
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
        
        %-----------------------------------------------------------------%
        %Unpack the states
        
        %Grab dimensionless gas phase concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states); 
        
        %Grab dimensionless adsorbed phase concentrations as fields in a 
        %struct
        colAdsCons = convert2ColAdsConc(params,states); 
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Update a few quantities, depending on the calculations needed
        
        %Locally reset the number of volume parameter and the adsorbers
        nVols = 1;  
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Specify the option for fsolve.m for a single CSTR isotherm
        %calculation
        
        %Set options for fsolve.m; no need to specify the pattern for the
        %Jacobian matrix in this case
        options = optimoptions('fsolve', ...
                               'Algorithm','trust-region', ...
                               'FunValCheck','on', ... %complex # = error
                               'Display','off'); %'iter' to turn on
        %-----------------------------------------------------------------%
        
    %Otherwise, we have an adsorption column number specified by nAds
    else
        
        %-----------------------------------------------------------------%
        %Unpack the states
        
        %Grab dimensionless gas phases concentrations as fields in a struct
        colGasCons = convert2ColGasConc(params,states,nAds);  
        
        %Grab dimensionless adsorbed phases concentrations as fields in a 
        %struct
        colAdsCons = convert2ColAdsConc(params,states,nAds);  
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states,nAds);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Specify the options for fsolve.m
        
        %Unpack the solver option for fsolve.m, including the specification
        %of the pattern for the Jacobian matrix; the structure is stored
        %inside params
        options = params.fsolve.opts;        
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Define an output state solution vector/matrix
    newStates = states; 

    %Initialize the initial guess vector
    thetaGuess = zeros(nRows,nVols*nComs);
    %---------------------------------------------------------------------%
    

    
    %---------------------------------------------------------------------%
    %Calculate adsorption equilibrium (Implicit)

    %Replicate the elements of qSatC
    dimLessQsatC = repmat(dimLessQsatC',1,nVols);
    
    %For each species,
    for i = 1 : nComs

        %Update the initial guess vector
        thetaGuess(:,i:nComs:nComs*(nVols-1)+i) ...
            = colAdsCons.(sComNums{i}) ...
           ./ dimLessQsatC(i:nComs:nComs*(nVols-1)+i);

    end 
        
    %Check if the simulation is an isothermal simulation
    isNonIsothermal = bool(5);

    %If non-isothermal operation,
    if isNonIsothermal == 1                        
        
        %Obtain the temperature dependent pre-exponential factors
        dimLessKC ...
            = getAdsConstPreExpFac(params,colTemps.cstr, ...
                                   dimLessKC,nRows);
                                                                        
    %For isothermal operation,
    elseif isNonIsothermal == 0            
        
        %Replicate the pre-exponential factors
        dimLessKC = repmat(dimLessKC',nRows,nVols);

    end   
            
    %For each time point
    for i = 1 : nRows

        %Unpack the column temperature (CSTR)
        tempCstrCurr = colTemps.cstr(i,:);

        %Get the current pre-exponential factor
        KCurr = dimLessKC(i,:);

        %Define a function-handle for the coupled system of nonlinear
        %equations
        resFunc ...
            = @(theta) funcMultiSiteLang(theta,KCurr,aC, ...
                                         colGasCons, ...
                                         tempCstrCurr, ...
                                         nVols,nComs,sComNums,i); 

        %Call fsolve.m to solve the coupled implicit system of 
        %nonlinear equations
        [theta,~,EXITFLAG] ...
            = fsolve(resFunc,thetaGuess(i,:),options);            

        %Get the real component of the solution
        thetaReal = real(theta);
        
        %Make sure that we have no number smaller than numerical zero
        thetaReal(abs(thetaReal)<eps) = 0;

        %Update the site fractions theta by the saturation capacities
        adsConsEq = thetaReal.*dimLessQsatC;          

        %Calculate the minimum element in theta
        thetaRealMin = min(thetaReal);

        %Check the function output
        if EXITFLAG <= 0 && ... %Solution is not found
           thetaRealMin < 0 && ... %Make sure no entries are negative
           abs(thetaRealMin) > numZero %Make sure the negative entry is 
                                       %actually a large number

            %Get the message
            message = "No solution to the multisite Langmuir isotherm.";

            %Print warning
            warning("%s: ",funcId,message);

        end

        %Save the solutions to the struct       
        for j = 1 : nComs

            %Get the beginning index
            n0 = nColStT*(nAdsInd-1) ...
               + nComs+j;

            %Get the final index
            nf = nColStT*(nAdsInd-1) ...
               + nStates*(nVols-1)+nComs+j;

            %For the adsorbed concentrations, update with equilibrium 
            %concentrations with the current gas phase compositions
            newStates(i,n0:nStates:nf) ...
                = adsConsEq(j:nComs:nComs*(nVols-1)+j);

        end   

    end  
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%