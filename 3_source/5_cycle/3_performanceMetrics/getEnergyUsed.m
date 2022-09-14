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
%Code created on       : 2021/2/20/Saturday
%Code last modified on : 2022/6/9/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEnergyUsed.m
%Source     : common
%Description: At the end of ith cycle, calculates the total amount of
%             energy consumed by the compressor for feed compression and
%             the pump for the column evacuation.
%Inputs     : params       - a struct containing simulation parameters.
%             sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%             nS           - the current step number
%             nCy          - the current cycle number
%Outputs    : energy       - a scalar quantity denoting the total energy
%                            used to either compress or evacuate gas in the
%                            system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function energy = getEnergyUsed(params,sol,~,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getEnergyUsed.m';
    
    %Unpack params
    nSteps     = params.nSteps    ;    
    enScaleFac = params.enScaleFac;
    bool       = params.bool      ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Identify the steps in volved in the current cycle
    
    %Grab the initial and final steps
    [stepInit,stepFinal] = grabSteps(nCy,nSteps);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the energy for the compressors
    enerComp1 = 0;
    enerComp2 = 0;
    
    %Initialize the energy for the pump
    enerPump = 0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Keep track of energy expenditure by the compressor(s) and the vacuum
    %pump(s)
    
    %For each step in a given PSA cycle,
    for i = stepInit : stepFinal
        
            %Sum the energy cost for compression of the feed in a given 
            %step in a given PSA cycle to the current sum
            enerComp1 = enerComp1 ...
                     + sol.(append('Step',int2str(i))). ...
                       comp.n1.ener(end,:);
            enerComp2 = enerComp2 ...                     
                     + sol.(append('Step',int2str(i))). ...
                       comp.n2.ener(end,:);
                   
    end   
    
    %For each step in a given PSA cycle,
    for i = stepInit : stepFinal
        
            %Sum the energy cost for evacuation in a given step in a given 
            %PSA cycle to the current sum
            enerPump = enerPump ...
                     + sol.(append('Step',int2str(i))). ...
                            pump.n1.ener(end,:);
        
    end 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the overall energy cost of the cycle
    
    %Calculate the overall energy consumption
    energy = (abs(enerComp1)*bool(9) ...
             +abs(enerComp2)*bool(10) ... 
             +abs(enerPump)) ...
           * enScaleFac;        
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%