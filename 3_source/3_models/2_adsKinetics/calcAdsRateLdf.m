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
%Code created on       : 2019/2/3/Sunday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcAdsRateLdf.m
%Source     : common
%Description: calculates the dimensionless reaction rates used in the 
%             right hand side function for the sequenced CSTR adsorption 
%             column model
%Inputs     : params       - a struct containing parameters for the
%                            simulation
%             states       - dimensionless state solution matrix.
%                            row dimension    = number of time points
%                            column dimension = a total number of state
%                                               variables
%             nAds         - the adsorption column number on which we want
%                            to evaluate the adsorption rate. For a single
%                            CSTR rate evaluation, make sure that states
%                            are of a single CSTR and toss in nC = [].
%Outputs    : adsRates     - a matrix containing dimensionless rate of 
%                            adsorption for all species.
%                            row dimension    = number of time points
%                            column dimension = nubmer of species 
%                                             * number of CSTRs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function adsRates = calcAdsRateLdf(params,states,nAds)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcAdsRateLdf.m';
    
    %Unpack Params
    nVols    = params.nVols   ;
    nComs    = params.nComs   ;
    sComNums = params.sComNums;     
    damkoNo  = params.damkoNo ;    
    funcIso  = params.funcIso ;
    nRows    = params.nRows   ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and calculate adsorbed phase equilibrium concentrations        
    
    %Given the current states, grab concentrations from adsorbed phase as a
    %struct called adsCon0
    adsCon0 = convert2ColAdsConc(params,states,nAds);   
    
    %Compute the adsorbed phase in equilibrium with the current gas phase
    %compositions and return a new state with the updated adsorbed phase
    %concentrations
    newStates = funcIso(params,states,nAds);
    
    %From the new states, grab concentrations from adsorbed phase as a
    %struct called adsConEq
    adsConEq = convert2ColAdsConc(params,newStates,nAds); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Define a solution array for containing dimensionless adsorption rates
    adsRates = zeros(nRows,nVols*nComs);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate needed quantities
     
    %Compute the dimensionless adsorption rate for all CSTRs for all time
    %points and return it as the function output
    for i = 1 : nComs
        
        %For each component, update the adsorption rates
        adsRates(:,nVols*(i-1)+1:nVols*i) ...
            = damkoNo(i) ...
           .* (adsConEq.(sComNums{i}) ...
              -adsCon0.(sComNums{i}));         
         
    end            
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%