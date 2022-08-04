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
%Code last modified on : 2020/12/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcIsothermLinear.m
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

function newStates = calcIsothermLinear(params,states,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcIsothermLinear.m';
    
    %Unpack params
    qSatC        = params.qSatC       ;
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ;
    gConScaleFac = params.gConScaleFac;
    aConScaleFac = params.aConScaleFac;   
    nVols        = params.nVols       ;
    bool         = params.bool        ;
    nRows        = params.nRows       ;
    bC0          = params.bC0         ;

    %Calculate needed quantities
    conScaleFacRat = gConScaleFac/aConScaleFac;   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Determine the states to be used in adsorption equilibrium calculation
    
    %If we are requested to just compute adsorbed phase concentrations for 
    %a single CSTR
    if nAds == 0    
        
        %Update the row vector of adsorption affinity constants at a
        %constant temperature T
        bC0 = [bC0(1,1),bC0(1,nVols+1)];
        
        %We have a single CSTR
        nVols = 1;
        
    end
    %---------------------------------------------------------------------%
   
     
    
    %---------------------------------------------------------------------%
    %Obtain the adsorption affinity constant matrix
    
    %If non-isothermal operation,
    if bool(5) == 1
                       
        %Get the affinity parameter matrix at a specified CSTR temperature 
        %for all CSTRs
        bC = getAdsAffConstant(params,states,nRows,nAds);               
        
    %For non-isothermal operation,
    else
                
        %Duplicate bC0 into nR rows to get bC
        bC = repmat(bC0,nRows,1);
        
    end      
    
    %Define an output state solution vector/matrix
    newStates = states;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and save as dimensionless gas phase concentrations              
    
    %Grab dimensionless gas phases concentrations as fields in a struct
    colGasCons = convert2ColGasConc(params,states,nAds);        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate adsorption equilibrium (Explicit)
    
    %If we are calculating a state for a single CSTR,
    if nAds == 0 
        
        %For the indexing, let nAds = 1
        nAds = 1;
        
    end
    
    %Evaluate explicit form of linear isotherm (i.e., Henry's law) and
    %update the corresponding value to the output solution
    for i = 1 : nComs
        
        %Calculate the adsoption equilibrium loading
        loading = (bC(:,nVols*(i-1)+1:nVols*i) ...
                * qSatC(i) ...
                * conScaleFacRat) ...
               .* colGasCons.(sComNums{i});
        
        %Get the beginning index
        n0 = nColStT*(nAds-1) ...
           + nComs+i;
        
        %Get the final index
        nf = nColStT*(nAds-1) ...
           + nStates*(nVols-1)+nComs+i;
           
        %For adosrbed concentrations, update with equilibrium 
        %concentrations with the current gas phase compositions
        newStates(:,n0:nStates:nf) = loading;
                  
    end        
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%