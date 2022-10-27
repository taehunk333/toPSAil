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
%Code created on       : 2022/10/26/Wednesday
%Code last modified on : 2022/10/27/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getAdsConstPreExpFac.m
%Source     : common
%Description: takes in all CSTR temperature values for the CSTRs associated
%             with a given adsorption column and updates a temperature
%             dependent adsorption prefactor using exponential of the ratio
%             of the isosteric heat capacity and the temperatures.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             preExpFacIn  - the pre-exponential factor before accounting
%                            for the temperature dependence
%             nRows        - the number of rows in the state matrix; if the
%                            state matrix is a vector, nRows = 1.
%             nAds         - the adsober number where we will evaluate the
%                            adsorption equilibrium
%Outputs    : bCNew        - a vector or matrix of affinity constants 
%                            for all species updated with a current 
%                            temperature of the system.
%             preExpFacOut - the pre-exponential factor after accounting
%                            for the temperature dependence
%                            out_t ...
%                               = [comp1_cstr_1, ..., comp_n_s_cstr_1 ...,
%                                  ..., ..., ...
%                                  comp1_cstr_n_c, ..., comp_n_s_cstr_n_c];
%                            preExpFacOut ...
%                               = [out_1 ; ... ; out_nRows];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function preExpFacOut ...
    = getAdsConstPreExpFac(params,states,preExpFacIn,nRows,nAds)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getAdsConstPreExpFac.m';
    
    %Unpack params
    nVols             = params.nVols            ;
    nComs             = params.nComs            ;              
    dimLessIsoStHtRef = params.dimLessIsoStHtRef;        
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
    preExpFacOut = zeros(nRows,nVols*nComs);
    %---------------------------------------------------------------------%


    
    %---------------------------------------------------------------------%
    %Update the adsorption affinity constant for all species
    
    %For each species
    for i = 1 : nComs
                
        %Update the affinity constant at the current CSTR temperatures
        preExpFacOut(:,i:nComs:nComs*(nVols-1)+i) ...
            = preExpFacIn(i) ...
           .* exp(dimLessIsoStHtRef(i) ...
           ./ temps.cstr);
                
    end            
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%