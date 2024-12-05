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
%Function   : grabRaTaPurityComp.m
%Source     : common
%Description: plot the product purity inside the product tank(s)
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%Outputs    : time         - a vector of time points
%             purity       - a vector of product purity in the raffinate
%                            product tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [time,purity] = grabRaTaPurityComp(params,sol)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabRaTaPurityComp';
    
    %Unpack Params 
    lastStep   = sol.lastStep     ;
    tiScaleFac = params.tiScaleFac;    
    nLKs       = params.nLKs      ;
    sComNums   = params.sComNums  ;
    nTiPts     = params.nTiPts    ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays
    
    %Initialize the time vector 
    time = zeros(nTiPts*lastStep,1);
    
    %Initialize the purity vector
    purity = zeros(nTiPts*lastStep,1);   
    %---------------------------------------------------------------------%
                    
    
    
    %---------------------------------------------------------------------%
    %Plot the gas phase concentration profiles for the last high pressure
    %feed                                
    
    %For each step that was simulated,
    for i = 1 : lastStep
       
        %Grab dimensional times
        time(nTiPts*(i-1)+1:nTiPts*i) ...
            = tiScaleFac ...
            * sol.(append('Step',int2str(i))).timePts;
        
        %Initialize the sum of the light key concentrations
        sumLkConcs = zeros(nTiPts,1);
        
        %Obtain the sum of the light key concentrations
        for j = 1 : nLKs
            
            %Update the currnet sum of the total gas concentration in the
            %raffinate product tank
            sumLkConcs = sumLkConcs ...
                       + sol.(append('Step',int2str(i))). ...
                         raTa.n1.gasCons.(sComNums{j});
            
        end    

        %Grab total pressure for jth adsorption column in ith step
        purity(nTiPts*(i-1)+1:nTiPts*i) ...
            = sumLkConcs ...
           ./ sol.(append('Step',int2str(i))).raTa.n1.gasConsTot;    
  
    end                  
    %---------------------------------------------------------------------%                 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%