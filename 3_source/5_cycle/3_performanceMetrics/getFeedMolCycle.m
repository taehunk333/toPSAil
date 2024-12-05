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
%Function   : getFeedMolCycle.m
%Source     : common
%Description: At the end of ith cycle, calculates moles of each species
%             processed by a given PSA cycle.
%Inputs     : params       - a struct containing simulation parameters.
%             sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%             nS           - the current step number
%             nCy          - the current cycle number
%Outputs    : feMol        - a row vector containing mole of each species
%                            in the processed feed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function feMol = getFeedMolCycle(params,sol,~,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getFeedMolCycle.m';
    
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
    feMol = zeros(1,nComs);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Keep track of cumulative moles coming out of the feed tank in a
    %given PSA cycle
    
    %For each step in a given PSA cycle,
    for i = stepInit : stepFinal
        
        %Sum the moles of each species in the product produced in a 
        %given step in a given PSA cycle to the current sum
        feMol = feMol ...
              + sol.(append('Step',int2str(i))). ...
                     feTa.n1.cumMol.feed(end,:);
        
    end        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Process the function output
    
    %Dimensionalize the moles
    feMol = feMol.*nScaleFac;
    
    %Make the solution to a row vector
    feMol = feMol(:).';
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%