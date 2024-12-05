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
%Function   : getTempRats.m
%Source     : common
%Description: define dimensionless temperature values.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getTempRats(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getPresRats.m';
    
    %Unpack params
    tempAmbi   = params.tempAmbi  ;
    tempCol    = params.tempCol   ;
    tempFeed   = params.tempFeed  ;
    tempRefIso = params.tempRefIso;
    %---------------------------------------------------------------------% 
      
    
    
    %---------------------------------------------------------------------%    
    %Calculate dimensionless temperature values    
    
    %Calculate the pressure ratio. i.e., T_{amb}/T_{amb} = 1
    params.tempAmbiNorm = tempAmbi ...
                        / tempAmbi;
    params.tempRefNorm  = tempRefIso ...
                        / tempAmbi;
    params.tempColNorm  = tempCol ...
                        / tempAmbi;
    params.tempFeedNorm = tempFeed ...
                        / tempAmbi;
    params.tempColNorm  = tempCol ...
                        / tempAmbi;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%