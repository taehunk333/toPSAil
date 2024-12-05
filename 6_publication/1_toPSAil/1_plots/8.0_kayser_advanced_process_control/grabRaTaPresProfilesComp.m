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
%Function   : grabRaTaPresProfilesComp.m
%Source     : common
%Description: plot the pressure profile for the raffinate product tank
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : time         - a vector of time points
%             pressure     - a vector of pressure in the raffinate product
%                            tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [time,pressure] = grabRaTaPresProfilesComp(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabRaTaPresProfilesComp';
    
    %Unpack Params
    tiScaleFac   = params.tiScaleFac  ;
    lastStep     = sol.lastStep       ;       
    teScaleFac   = params.teScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    gasCons      = params.gasCons     ;
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
    %Plot the pressure profiles for all tanks for all simulated steps all
    %in one plot
      
    %For each step that was simulated,
    for i = 1 : lastStep              
        
        %Grab dimensional times
        time(nTiPts*(i-1)+1:nTiPts*i)...
            = tiScaleFac ...
            * sol.(append('Step',int2str(i))).timePts;                   

        %Grab total pressure for jth adsorption column in ith step
        pressure(nTiPts*(i-1)+1:nTiPts*i) ...
            = sol.(append('Step',int2str(i))).raTa.n1.gasConsTot ...
           .* gConScaleFac ...
           .* sol.(append('Step',int2str(i))).raTa.n1.temps.cstr ...
           .* teScaleFac ...
           .* gasCons;
 
    end            
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%