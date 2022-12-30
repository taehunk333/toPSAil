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
%Code created on       : 2022/12/19/Monday
%Code last modified on : 2022/12/19/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : grabColPresProfilesComp.m
%Source     : common
%Description: plot the pressure profile for all columns
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             nAds         - the adsorber number
%Outputs    : time         - a vector of time points
%             pressure     - a vector of pressure in the raffinate product
%                            tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [time,pressure] = grabColPresProfilesComp(params,sol,nAds)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabColPresProfilesComp';
    
    %Unpack Params
    tiScaleFac   = params.tiScaleFac  ;
    lastStep     = sol.lastStep       ;
    nVols        = params.nVols       ;
    gasCons      = params.gasCons     ;
    teScaleFac   = params.teScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    nTiPts       = params.nTiPts      ;
    %---------------------------------------------------------------------%

  
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays
    
    %Initialize the time vector 
    time = zeros(nTiPts*lastStep,1);
    
    %Initialize the purity vector
    pressure = zeros(nTiPts*lastStep,1);   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the pressure profiles for all columns for all simulated steps all
    %in one plot
              
    %For each step that was simulated,
    for i = 1 : lastStep
       
        %Grab dimensional times
        time(nTiPts*(i-1)+1:nTiPts*i) ...
            = tiScaleFac*sol.(append('Step',int2str(i))).timePts;
                                             
        %Grab total pressure for jth adsorption column in ith step
        %(For the sake of computational efforts, just plot the average
        %CSTR pressure)
        pressure(nTiPts*(i-1)+1:nTiPts*i) ...
            = sum(sol.(append('Step',int2str(i))). ...
                  col.(append('n',int2str(nAds))).gasConsTot,2) ...
           ./ nVols ...
           .* gConScaleFac ...
           .* gasCons ...
           .* sum(sol.(append('Step',int2str(i))). ...
                  col.(append('n',int2str(nAds))).temps.cstr,2) ...
           ./ nVols ...
           .* teScaleFac;                                                                               
                
    end     
    %---------------------------------------------------------------------%               
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%