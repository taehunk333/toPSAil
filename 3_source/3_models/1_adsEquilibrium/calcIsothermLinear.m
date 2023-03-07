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
%Code created on       : 2020/12/12/Saturday
%Code last modified on : 2023/3/6/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcIsothermLinear.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) and 
%             returns the corresponding adsorbed phase concentration in 
%             equilibrium with bulk gas composition for the following:
%             Components   - $i \in \left\{ 1, ..., params.nComs \right\}$
%             CSTRs        - $n \in \left\{ 1, ..., params.nVols \right\}$
%             time points  - $t \in \left\{ 1, ..., nTimePts \right\}$.
%             Note that this function is written in the dimensionless form.
%             To use this function in dimensional form, please go ahead and
%             use dimensional states, along with aConScaleFac = 1 and
%             gConScaleFac = 1.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             nAds         - the adsober number where we will evaluate the
%                            adsorption equilibrium. For a single CSTR,
%                            specified value of nAds should be a zero.
%Outputs    : newStates    - a dimensionless state solution of the same
%                            dimension as states but adsorbed phase
%                            concentrations are now in equilibrium with the
%                            gas phase concentrations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newStates = calcIsothermLinear(params,states,nAds)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermLinear.m';
    
    %Unpack params
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ; 
    nVols        = params.nVols       ;
    bool         = params.bool        ;
    nRows        = params.nRows       ; 
    dimLessHenry = params.dimLessHenry;
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
                       
        %Take account for the exponential temperature dependence
        dimLessHenry ...
            = getAdsConstPreExpFac(params,colTemps.cstr, ...
                                   dimLessHenry,nRows);               
        
        %Evaluate explicit form of linear isotherm (i.e., Henry's law) and
        %update the corresponding value to the output solution
        for i = 1 : nComs
            
            %Calculate the adsoption equilibrium loading
            loading = dimLessHenry(:,i:nComs:nComs*(nVols-1)+i) ...
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
            newStates(:,n0:nStates:nf) = loading;
                      
        end  
    
    %For isothermal operation,
    elseif isNonIsothermal == 0                    

        %Evaluate explicit form of linear isotherm (i.e., Henry's law) and
        %update the corresponding value to the output solution
        for i = 1 : nComs
            
            %Calculate the adsoption equilibrium loading
            loading = dimLessHenry(i) ...
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
            newStates(:,n0:nStates:nf) = loading;
                      
        end    

    end      
    %---------------------------------------------------------------------%       
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%