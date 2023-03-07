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
%Code created on       : 2020/12/14/Monday
%Code last modified on : 2023/3/6/Monday
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

function newStates = calcIsothermExtLang(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermExtLang.m';
    
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    bool         = params.bool        ;
    nRows        = params.nRows       ;    
    dimLessQsatC = params.dimLessQsatC;    
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
        
        %Grab dimensionless temperatures as fidlds in a struct
        colTemps = convert2ColTemps(params,states,nAds);

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
        
        %Unpack additional params
        dimLessBC = params.dimLessBC;

        %Get the affinity parameter matrix at a specified CSTR temperature 
        %for all CSTRs
        dimLessBC = getAdsAffConstant(params,states,nRows,nAds,dimLessBC); 
        
        %Replicate the elements of qSatC
        dimLessQsatC = repelem(dimLessQsatC,nVols)';

        %Calaulate the matrix containing the state dependent dimensionless
        %Henry's constant
        dimLessHenry = (dimLessBC).*(dimLessQsatC);

        %Initialize the denominator
        denominator = ones(nRows,nVols);

        %Update the species dependent term in the denominator of the
        %Extended Langmuir expression
        for i = 1 : nComs

            %Update the denominator vector
            denominator = denominator ...
                        + dimLessBC(nVols*(i-1)+1:nVols*i) ...
                       .* colTemps.cstr ...
                       .* colGasCons.(sComNums{i});

        end
        
        %Evaluate explicit form of linear isotherm (i.e., Extened Langmuir
        %isotherm) and update the corresponding value to the output 
        %solution
        for i = 1 : nComs
            
            %Calculate the adsoption equilibrium loading
            loading = dimLessHenry(:,nVols*(i-1)+1:nVols*i) ...
                   .* colTemps.cstr ...
                   .* colGasCons.(sComNums{i});

            %Get the beginning index
            n0 = nColStT*(nAdsInd-1) ...
               + nComs+i;
            
            %Get the final index
            nf = nColStT*(nAdsInd-1) ...
               + nStates*(nVols-1)+nComs+i;
               
            %For adosrbed concentrations, update with equilibrium 
            %concentrations with the current gas phase compositions
            newStates(:,n0:nStates:nf) = loading ...
                                      ./ denominator;
                      
        end   
    
    %For isothermal operation,
    elseif isNonIsothermal == 0            
        
        %Unpack additional params
        teScaleFac   = params.teScaleFac  ;
        gConScaleFac = params.gConScaleFac;
        bC           = params.bC          ; 
        dimLessQsatC = params.dimLessQsatC;
            
        %Calcualte the dimensionless bC and qSatC
        dimLessBC    = bC*gasCons*teScaleFac*gConScaleFac;            

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

        %Evaluate the explicit isotherm (i.e., Extened Langmuir isotherm) 
        %and update the corresponding value to the output solution
        for i = 1 : nComs
            
            %Calculate the adsoption equilibrium loading
            loading = (dimLessQsatC(i)*dimLessBC(i)) ...
                   .* colTemps.cstr ...
                   .* colGasCons.(sComNums{i});

            %Get the beginning index
            n0 = nColStT*(nAdsInd-1) ...
               + nComs+i;
            
            %Get the final index
            nf = nColStT*(nAdsInd-1) ...
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