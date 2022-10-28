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
%Code created on       : 2020/10/26/Wednesday
%Code last modified on : 2022/10/28/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
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
    qSatC        = params.qSatC       ;
    aC           = params.aC          ;
    dimLessKC    = params.dimLessKC   ;
    aConScaleFac = params.aConScaleFac;
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
                               'FunValCheck','on', ... %complex # show error
                               'Display','iter'); %Turn off the display
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

    %Check if the simulation is an isothermal simulation
    isNonIsothermal = bool(5);

    %If non-isothermal operation,
    if isNonIsothermal == 1
        
        %Replicate the elements of qSatC
        qSatC = repmat(qSatC',1,nVols);

        %Nondimensionalize qSatC
        qSatC = (qSatC/aConScaleFac);
        
        %Obtain the temperature dependent pre-exponential factors
        dimLessKC ...
            = getAdsConstPreExpFac(params,states,dimLessKC,nRows,nAds);
                                       
        %For each species,
        for i = 1 : nComs
        
            %Update the initial guess vector
            thetaGuess(:,i:nComs:nComs*(nVols-1)+i) ...
                = colAdsCons.(sComNums{i}) ...
               ./ qSatC(i:nComs:nComs*(nVols-1)+i);
        
        end

        %For each time point
        for i = 1 : nRows
                        
            %Unpack the column temperature (CSTR)
            colTempCstrCurr = colTemps.cstr(i,:);
            
            %Get the current pre-exponential factor
            KCurr = dimLessKC(i,:);
            
            %Define a function-handle for the coupled system of nonlinear
            %equations
            resFunc ...
                = @(qEqC) funcMultiSiteLang(qEqC,KCurr,aC, ...
                                            colGasCons, ...
                                            colTempCstrCurr, ...
                                            nVols,nComs,sComNums,i); 
                           
            %Call fsolve.m to solve the coupled implicit system of 
            %nonlinear equations
            [theta,~,EXITFLAG] ...
                = fsolve(resFunc,thetaGuess(i,:),options);            
            
            %Update the site fractions theta by the saturation capacities
            adsConsEq = theta.*qSatC(i,:);            
            
            %Check the function output
            if EXITFLAG ~= 1
               
                %Get the message
                message = "possibly no solution to the implicit isotherm.";
                
                %Print warning
                warning("%s: ",funcId,message);
                
            end
            
            %For the single CSTR case, 
            if nAds == 0
               
                %update nAds to be 1, temporarily
                nAds = 1;
                
            end
            
            %Save the solutions to the struct       
            for j = 1 : nComs
            
                %Get the beginning index
                n0 = nColStT*(nAds-1) ...
                   + nComs+j;

                %Get the final index
                nf = nColStT*(nAds-1) ...
                   + nStates*(nVols-1)+nComs+j;

                %For adosrbed concentrations, update with equilibrium 
                %concentrations with the current gas phase compositions
                newStates(i,n0:nStates:nf) ...
                    = adsConsEq(i,j:nComs:nComs*(nVols-1)+j);
                      
            end   

        end                
    
    %For isothermal operation,
    elseif isNonIsothermal == 0            
        
        %Unpack additional params
        teScaleFac   = params.teScaleFac  ;
        gConScaleFac = params.gConScaleFac;
        bC           = params.bC          ; 
        qSatC        = params.qSatC       ;
        aConScaleFac = params.aConScaleFac;
            
        %Calcualte the dimensionless bC and qSatC
        dimLessBC    = bC*gasCons*teScaleFac*gConScaleFac;
        dimLessQsatC = qSatC/aConScaleFac                ;               

        %Check to see if we have a singel CSTR
        if nAds == 0

            %Make sure that nAds = 1 so that the indexing will work out
            nAds = 1;

        end

        %Initialize the denominator
        denominator = ones(nRows,nVols);

        %Update the species dependent term in the denominator of the
        %Extended Langmuir expression
        for i = 1 : nComs

            %Update the denominator vector
            denominator = denominator ...
                        + dimLessBC(i) ...
                       .* colTemps.cstr ...
                       .* colGasCons.(sComNums{i});

        end

        %Evaluate explicit form of linear isotherm (i.e., Extened Langmuir
        %isotherm) and update the corresponding value to the output 
        %solution
        for i = 1 : nComs
            
            %Calculate the adsoption equilibrium loading
            loading = (dimLessQsatC(i)*dimLessBC(i)) ...
                   .* colTemps.cstr ...
                   .* colGasCons.(sComNums{i});

            %Get the beginning index
            n0 = nColStT*(nAds-1) ...
               + nComs+i;
            
            %Get the final index
            nf = nColStT*(nAds-1) ...
               + nStates*(nVols-1)+nComs+i;
               
            %For adosrbed concentrations, update with equilibrium 
            %concentrations with the current gas phase compositions
            newStates(:,n0:nStates:nf) = loading ...
                                      ./ denominator;
                      
        end    

    end      
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%