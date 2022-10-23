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
%Function   : solvOdes.m
%Source     : common
%Description: a .m function that selects the proper ODE solver and
%             numerically integrates the copled system of nonlinear ODEs,
%             describing the particular step in a PSA cycle.
%Inputs     : funcRhs      - a function handle for the right-hand side for
%                            the nonlinear coupled system of ODEs
%             tDom         - the time span for the numerical integration of
%                            the ODEs
%             iStates      - an initial condition vector for the state
%                            variables in the system of ODEs
%             options      - an option for the numerical integration
%             numIntSolv   - the string name of the numerical integrator
%                            for the ODEs
%Outputs    : sol          - a data structure containing the solution
%                            outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sol = solvOdes(funcRhs,tDom,iStates,options,numIntSolv)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'solvOdes.m';
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Simulate all the steps in a scheduled PSA cycle        
          
    %Nonstiff and medium accuracy: Most of the time. This should be the 
    %first solver you try.
    if numIntSolv == "ode45"
    
        %Call the solver
        sol = ode45(funcRhs,tDom,iStates',options);                    
    
    %Nonstiff and low accuracy: If using crude error tolerances or solving 
    %moderately stiff problems.
    elseif numIntSolv == "ode23" 
    
        %Call the solver
        sol = ode23(funcRhs,tDom,iStates',options);   
                       
    %Nonstiff and low to high accuracy: If using stringent error tolerances
    %or solving a computationally intensive ODE file.
    elseif numIntSolv == "ode113"
        
        %Call the solver
        sol = ode113(funcRhs,tDom,iStates',options);
    
    %Stiff and low to medium accuracy: If ode45 is slow because the problem
    %is stiff.
    elseif numIntSolv == "ode15s"
    
        %Call the solver
        sol = ode15s(funcRhs,tDom,iStates',options);  
    
    %Stiff and low accuracy: If using crude error tolerances to solve stiff
    %systems and the mass matrix is constant.
    elseif numIntSolv == "ode23s"
        
        %Call the solver
        sol = ode23s(funcRhs,tDom,iStates',options); 
    
    %Moderately stiff and low accuracy: If the problem is only moderately 
    %stiff and you need a solution without numerical damping.
    elseif numIntSolv == "ode23t"
        
        %Call the solver
        sol = ode23t(funcRhs,tDom,iStates',options); 
    
    %Stiff and low accuracy: If using crude error tolerances to solve stiff
    %systems.
    elseif numIntSolv == "ode23tb"
        
        %Call the solver
        sol = ode23tb(funcRhs,tDom,iStates',options); 
    
    end
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%