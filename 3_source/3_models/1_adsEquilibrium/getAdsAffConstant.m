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
%Code created on       : 2021/1/29/Friday
%Code last modified on : 2022/3/1/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getAdsAffConstant.m
%Source     : common
%Description: takes in all CSTR temperature values for the CSTRs associated
%             with a given adsorption column and updates a temperature
%             dependent adsorption affinity constants for all species in
%             the system.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             nRows        - the number of rows in the state matrix; if the
%                            state matrix is a vector, nRows = 1.
%             nAds         - the adsober number where we will evaluate the
%                            adsorption equilibrium
%Outputs    : bC           - a vector or matrix of affinity constants 
%                            for all species updated with a current 
%                            temperature of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bC = getAdsAffConstant(params,states,nRows,nAds)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getAdsAffConstant.m';
    
    %Unpack params
    nVols      = params.nVols     ;
    bC         = params.bC        ;
    isoStHtC   = params.isoStHtC  ;
    gasCons    = params.gasCons   ;
    tempAmbi   = params.tempAmbi  ;
    tempRefIso = params.tempRefIso;
    nComs      = params.nComs     ;    
    
    %Calculate needed quantities
    scaleGasCons = gasCons/10*tempRefIso;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Get a row vector for isoStHtC
    isoStHtC = transpose(isoStHtC);
    
    %Initialze a numeric array for holding initial adsorption affinity
    %constants for all species for all CSTRs
    affConsMat = ones(nRows,nVols*nComs);  
    
    %Initialze a numeric array for holding isosteric heat of adsorption
    %constants for all species for all CSTRs
    isoStHtMat = ones(nRows,nVols*nComs);   
    
    %For each species
    for i = 1 : nComs
        
        %Update block of the matrix with ith species affinity constant
        affConsMat(:,nVols*(i-1)+1:nVols*i) ...
            = bC(i) ...
           .* affConsMat(:,nVols*(i-1)+1:nVols*i);
       
        %Update block of the matrix with ith species isosteric heat of
        %adsorption
        isoStHtMat(:,nVols*(i-1)+1:nVols*i) ...
            = isoStHtC(i) ...
           .* isoStHtMat(:,nVols*(i-1)+1:nVols*i);
                      
    end        
    
    %Initialize a numeric array for holding reference temperatures
    refTempNorm = (tempRefIso/tempAmbi) ...
                * ones(nRows,nVols);
    
    %Initialize the solution output
    bC = zeros(nRows,nVols*nComs);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states
   
    %Grab dimensionless CSTR temperatures from the struct
    temps = convert2ColTemps(params,states,nAds);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Update the adsorption affinity constant for all species
    
    %For each species
    for i = 1 : nComs
                
        %Update the affinity constant at the current CSTR temperatures
        bC(:,nVols*(i-1)+1:nVols*i) ...
            = affConsMat(:,nVols*(i-1)+1:nVols*i) ...
           .* exp(-isoStHtMat(:,nVols*(i-1)+1:nVols*i) ...
           ./ scaleGasCons ...
           .* (1-refTempNorm./temps.cstr));
                
    end            
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%