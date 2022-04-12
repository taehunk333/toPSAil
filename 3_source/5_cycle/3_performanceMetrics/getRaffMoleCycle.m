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
%Code last modified on : 2022/1/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getRaffMoleCycle.m
%Source     : common
%Description: At the end of ith cycle, calculates moles of each species
%             in the raffinate stream harnessed at the end of a given PSA 
%             cycle.
%Inputs     : params       - a struct containing simulation parameters.
%             sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%             nS           - the current step number
%             nCy          - the current cycle number
%Outputs    : raffProd     - a row vector containing moles of each species
%                            in the harnessed product
%             raffWaste    - a row vector containing moles of each species
%                            in the raffinate waste 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [raffProd,raffWaste] = getRaffMoleCycle(params,sol,~,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaffMoleCycle.m';
    
    %Unpack params
    nSteps    = params.nSteps   ;
    nComs     = params.nComs    ;
    nScaleFac = params.nScaleFac;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Identify the steps in volved in the current cycle
    
    %Grab the initial and final steps
    [stepInit,stepFinal] = grabSteps(nCy,nSteps);     
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the row vector holding moles of each species harnessed from
    %a given PSA cycle
    raffProd  = zeros(1,nComs);  
    raffWaste = zeros(1,nComs);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Keep track of cumulative moles coming out of the raffinate product 
    %tank in a given PSA cycle
    
    %For each step in a given PSA cycle,
    for i = stepInit : stepFinal
             
        %Sum the moles of each species in the product produced in a 
        %given step in a given PSA cycle to the current sum
        raffProd = raffProd ...
                 + sol.(append('Step',int2str(i))). ...
                   raTa.n1.cumMol.prod(end,:);
               
        %Sum the moles of each species in the raffinate waste stream in a
        %given step in a given PSA cycle to the current sum
        raffWaste = raffWaste ...
                  + sol.(append('Step',int2str(i))). ...
                    raWa.n1.cumMol.waste(end,:);
        
    end        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Process the function output
    
    %Dimensionalize the moles
    raffProd  = raffProd.*nScaleFac ;
    raffWaste = raffWaste.*nScaleFac;
    
    %Make the solution to a row vector
    raffProd  = raffProd(:).' ;
    raffWaste = raffWaste(:).';
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%