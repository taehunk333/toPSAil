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
%Code created on       : 2022/10/22/Saturday
%Code last modified on : 2022/10/22/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : noteNumIntStats.m
%Source     : common
%Description: TBD
%Inputs     : sol          - a data structure containing the solution
%                            outputs
%             numIntSolv   - the string name of the numerical integrator
%Outputs    : The print statements in the Command Window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function noteNumIntStats(sol,numIntSolv)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'noteNumIntStats.m';
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Print out the statistics for the numerical integration      
          
    %Print a divider line
    fprintf("\n*******************************************\n")           ;
    fprintf("Numerical Integration Summary. \n")                         ;
    fprintf("*Solver                         : %s \n",numIntSolv)        ;
    fprintf("*Number of Successful Steps     : %d \n",sol.stats.nsteps)  ;
    fprintf("*Number of Failed Steps         : %d \n",sol.stats.nfailed) ;
    fprintf("*Number of Function Evaluations : %d \n",sol.stats.nfevals) ;
    
    %When using an implicit solver, print additional statistics
    if numIntSolv ~= "ode45" && ...
       numIntSolv ~= "ode23" && ...
       numIntSolv ~= "ode113"
        fprintf("*Number of Jacobian Evaluations : %d \n", ...
                sol.stats.npds);
        fprintf("*Number of LU Decompositions    : %d \n", ...
                sol.stats.ndecomps);
        fprintf("*Number of Linear Solves        : %d \n", ...
                sol.stats.nsolves);
    end
    
    %Print a divider line
    fprintf("*******************************************\n");
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%