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
%Function   : getPerformanceMetrics.m
%Source     : common
%Description: At the end of the cycle, calculates the performance metrics
%             of a given PSA cycle.
%Inputs     : params       - a struct containing simulation parameters.
%             sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%             nS           - the current step number
%             nCy          - the current cycle number
%Outputs    : sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sol = getPerformanceMetrics(params,sol,nS,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getPerformanceMetrics.m';
    nLKs    = params.nLKs   ;
    nComs   = params.nComs  ;
    numZero = params.numZero;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate performance metrics related calculations
    
    %Get a row vector of moles of species in the total amount of raffinate 
    %product harnessed in a given PSA cycle
    [raffProd,raffWaste] = getRaffMoleCycle(params,sol,nS,nCy);    
    
    %Get a row vector of moles of species in the total amount of extract 
    %product harnessed in a given PSA cycle
    [extrProd,extrWaste] = getExtrMoleCycle(params,sol,nS,nCy);  
    
    %Amounts should be positive quantities
    extrProd  = abs(extrProd) ;
    extrWaste = abs(extrWaste);
    
    %If the amount is tiny, then we should consider them to be zeros
    raffProd(raffProd<numZero)   = 0;
    raffWaste(raffWaste<numZero) = 0;
    extrProd(extrProd<numZero)   = 0;
    extrWaste(extrWaste<numZero) = 0;
    
    %Get a row vector of moles of species in the total amount of feed
    %processed in a given PSA cycle
    feed = getFeedMolCycle(params,sol,nS,nCy);  
    
    %Get the cycle duration
    cycTime = getCycleTime(params,sol,nS,nCy);
    
    %Get the amount of spent energy
    energy = getEnergyUsed(params,sol,nS,nCy);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate any related quantities
    
    %Calculate total moles of raffinate product that was produced
    prodMolRaffTot = sum(raffProd,2);
    
    %Calculate total moles of extract product that was produced
    prodMolExtrTot = sum(extrProd,2);
    %---------------------------------------------------------------------%
    
    
    %---------------------------------------------------------------------%
    %Compute the performance metrics
    
    %Save the cycle product moles 
    %[=] moles of each species in the product
    sol.perMet.productMolesRaff(nCy,:) = raffProd ;
    sol.perMet.productMolesExtr(nCy,:) = extrProd ;
    sol.perMet.wasteMolesRaff(nCy,:)   = raffWaste;
    sol.perMet.wasteMolesExtr(nCy,:)   = extrWaste;
    
    %Save the cycle purity 
    %[=] moles of light key in the product/moles of product
    
    %Mole fraction of light key in the raffinate
    sol.perMet.productPurity(nCy,1) ...
        = sum(raffProd(1:nLKs)) ...
        / prodMolRaffTot;      
    
    %Mole fraction of heavy keys in the extract
    sol.perMet.productPurity(nCy,2) ...
        = sum(extrProd(nLKs+1:nComs)) ...
       ./ prodMolExtrTot;      
          
    %Save the product recovery
    %[=] moles of product/moles of feed
    sol.perMet.productRecovery(nCy,1:nLKs) ...
        = raffProd(1:nLKs) ...
       ./ feed(1:nLKs);  
    sol.perMet.productRecovery(nCy,nLKs+1:nComs) ...
        = extrProd(nLKs+1:nComs) ...
       ./ feed(nLKs+1:nComs);  
    
    %Save the productivity
    %[=] millimoles of product/seconds
    sol.perMet.productivity(nCy,1) ...
        = prodMolRaffTot ...
        / cycTime ...
        * 1000; %Raffinate
    sol.perMet.productivity(nCy,2) ...
        = prodMolExtrTot ...
        / cycTime ...
        * 1000; %Extract
    
    %Save the energy efficiency 
    %[=] Kilo-Joules of energy/mol of product
    %Scale the units from kJ to kWh: 3,600kJ = 1kWh
    sol.perMet.energyEfficiency(nCy,1) ...
        = energy ...
        / prodMolRaffTot ...
        / 1000/3600; %Raffinate
    sol.perMet.energyEfficiency(nCy,2) ...
        = energy ...
        / prodMolExtrTot ...
        / 1000/3600; %Extract
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%