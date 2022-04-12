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
%Code created on       : 2021/2/16/Tuesday
%Code last modified on : 2022/1/31/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
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
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate performance metrics related calculations
    
    %Get a row vector of moles of species in the total amount of raffinate 
    %product harnessed in a given PSA cycle
    [raffProd,raffWaste] = getRaffMoleCycle(params,sol,nS,nCy);    
    
    %Get a row vector of moles of species in the total amount of extract 
    %product harnessed in a given PSA cycle
    [extrProd,extrWaste] = getExtrMoleCycle(params,sol,nS,nCy);  
    
    %Amount should be a positive quantity
    extrProd  = abs(extrProd) ;
    extrWaste = abs(extrWaste);
    
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
        = raffProd(1) ...
        / prodMolRaffTot;      
    
    %Mole fraction of heavy keys in the extract
    sol.perMet.productPurity(nCy,2:end) ...
        = extrProd(2:end) ...
       ./ prodMolExtrTot;      
          
    %Save the product recovery
    %[=] moles of product/moles of feed
    sol.perMet.productRecovery(nCy,1) ...
        = raffProd(1) ...
       ./ feed(1);  
    sol.perMet.productRecovery(nCy,2:end) ...
        = extrProd(2:end) ...
       ./ feed(2:end);  
    
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
    sol.perMet.energyEfficiency(nCy,1) ...
        = energy ...
        / prodMolRaffTot ...
        / 1000; %Raffinate
    sol.perMet.energyEfficiency(nCy,2) ...
        = energy ...
        / prodMolExtrTot ...
        / 1000; %Extract
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%