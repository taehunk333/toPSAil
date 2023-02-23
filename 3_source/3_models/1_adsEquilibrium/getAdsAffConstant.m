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
%Code last modified on : 2023/2/23/Thursday
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
%Outputs    : bCNew        - a vector or matrix of affinity constants 
%                            for all species updated with a current 
%                            temperature of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bCNew = getAdsAffConstant(params,states,nRows,nAds)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getAdsAffConstant.m';
    
    %Unpack params
    nVols             = params.nVols            ;
    tempRefNorm       = params.tempRefNorm      ;
    nComs             = params.nComs            ;                                                    
    dimLessIsoStHtRef = params.dimLessIsoStHtRef;
    dimLessBC         = params.dimLessBC        ;
    %---------------------------------------------------------------------%
    
       
    
    %---------------------------------------------------------------------%
    %Unpack states
   
    %If we have a single CSTR,
    if nAds == 0
    
        %Grab dimensionless CSTR temperatures from the struct
        temps = convert2ColTemps(params,states);  
    
        %Locally reset the number of volume parameter
        nVols = 1;
    
    %Otherwise, we have an adsorption column number specified by nAds
    else
        
        %Grab dimensionless CSTR temperatures from the struct
        temps = convert2ColTemps(params,states,nAds); 
        
    end
    %---------------------------------------------------------------------%
    
          
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the solution output
    bCNew = zeros(nRows,nVols*nComs);
    %---------------------------------------------------------------------%


    
    %---------------------------------------------------------------------%
    %Update the adsorption affinity constant for all species
    
    %For each species
    for i = 1 : nComs
                
        %Update the affinity constant at the current CSTR temperatures
        bCNew(:,nVols*(i-1)+1:nVols*i) ...
            = dimLessBC(i) ...
           .* exp(-dimLessIsoStHtRef(i) ...
           .* (1/tempRefNorm-1./temps.cstr));
                
    end            
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%