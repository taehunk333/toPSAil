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
%Code created on       : 2021/1/18/Monday
%Code last modified on : 2021/1/18/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : runPsaCycleStep.m
%Source     : common
%Description: Given all the information in params, this function simulates
%             a given PSA process by obtainining the solution of the
%             dynamic PSA process model through the usage of
%             state-of-the-art ODE solver(s). The solution technique
%             implemented here is called the method of lines.
%Inputs     : params       - a struct containing simulation parameters.
%             iStates      - an initial state solution row vector containin
%                            the initial condition to the simulation.
%             tDom         - a 1 by 2 numerical vector that contains the
%                            initial and terminal time points for the
%                            numerical integration.
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : stTime       - a column vector containing state time points
%             stStates     - a solution matrix containing the time
%                            evolution of the state solutions for all the
%                            state variables coming from the numerical
%                            integration of the system of ODEs
%             flags        - a struct containing any numerical flags
%                            resulting from error messages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stTime,stStates,flags] ...
    = runPsaCycleStep(params,iStates,tDom,nS,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    funcId = 'runPsaCycleStep.m';
    
    %Unpack params
    nTiPts     = params.nTiPts     ;
    numIntSolv = params.numIntSolv ;
    funcEve    = params.funcEve{nS};
    
    %Update the data structure with integration specific information
    params.nRows = 1  ;
    params.nS    = nS ; 

    %Define the right hand side function
    funcRhs = @(t,y) defineRhsFunc(t,y,params);
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Check to see if an event is needed for a given step
    
    %Logical statement value for seeing if the event containing cell array
    %is an empty array or not
    needEvent = ~isempty(params.funcEve{nS});
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For the case where there is an event, define additional options for
    %the numerical integrator for solving ODEs
    
    %When we have a specified event, i.e. the cell containing the event
    %function handle is not an empty cell,
    if needEvent == 1
        
        %Enable the option for an event function
        event = odeset('Events',@(t,states) ...
                         funcEve(params,t,states,nS,nCy));
                     
        %Assign an output function (For testing)
        output = odeset('OutputFcn', ...
                        @(time,states,flag) ...
                        testDaeConst(time,states,flag,params,nS,nCy));
                     
        %Save the final options (For testing)
        %options = odeset(event,output);
        options = odeset(event);
        
        %Test to see if the event function will even work before solving 
        %the ODEs
        if testEventFunc(params,iStates,funcEve,1,nS,nCy) == 0
            
            %Display the error message
            msg = 'The event will not work with the current initial state';
            msg = append(funcId,': ',msg);
            error(msg);              
            
        end    
        
    %When we don't have a specified event, no options are needed
    elseif needEvent == 0
        
        %Assign an output function (For testing)
        output = odeset('OutputFcn', ...
                        @(time,states,flag) ...
                        testDaeConst(time,states,flag,params,nS,nCy));
        
        %Save the final options (For testing)
        %options = odeset(output);
        options = [];
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Simulate all the steps in a scheduled PSA cycle        
      
    %Nonstiff and medium accuracy: Most of the time. This should be the 
    %first solver you try.
    if numIntSolv == "ode45"
    
        %Call the solver
        sol = ode45(funcRhs,tDom,iStates,options);                    
    
    %Nonstiff and low accuracy: If using crude error tolerances or solving 
    %moderately stiff problems.
    elseif numIntSolv == "ode23" 
    
        %Call the solver
        sol = ode23(funcRhs,tDom,iStates,options);   
                       
    %Nonstiff and low to high accuracy: If using stringent error tolerances
    %or solving a computationally intensive ODE file.
    elseif numIntSolv == "ode113"
        
        %Call the solver
        sol = ode113(funcRhs,tDom,iStates,options);
    
    %Stiff and low to medium accuracy: If ode45 is slow because the problem
    %is stiff.
    elseif numIntSolv == "ode15s"
    
        %Call the solver
        sol = ode15s(funcRhs,tDom,iStates,options);  
    
    %Stiff and low accuracy: If using crude error tolerances to solve stiff
    %systems and the mass matrix is constant.
    elseif numIntSolv == "ode23s"
        
        %Call the solver
        sol = ode23s(funcRhs,tDom,iStates,options); 
    
    %Moderately stiff and low accuracy: If the problem is only moderately 
    %stiff and you need a solution without numerical damping.
    elseif numIntSolv == "ode23t"
        
        %Call the solver
        sol = ode23t(funcRhs,tDom,iStates,options); 
    
    %Stiff and low accuracy: If using crude error tolerances to solve stiff
    %systems.
    elseif numIntSolv == "ode23tb"
        
        %Call the solver
        sol = ode23tb(funcRhs,tDom,iStates,options); 
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Obtain the solutions based on the integration results and the type of
    %the mode of integration (i.e. event vs time).
    
    %If we have the results from event driven numerical integration,
    if isempty(funcEve) ~= 1     
        
        %-----------------------------------------------------------------%
        %Test to see if the event function is what caused the integration 
        %to stop
        if isempty(sol.xe) == 1
            
            %-------------------------------------------------------------%
            %Flag the event
            
            %Flag to indicate that an event did not happen
            flags.event = 0;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%                
            %Interpolate to obtain a desired number of solutions within a 
            %newly defined subdomain of the dimensionless time

            %Determine the range of the solution time points as a subset of
            %the domain of the time points used for the numerical 
            %integration. Since no event is used, an upperbound would be 
            %the final time. Also, we want nTimePts number of time points 
            %from the solution.
            stTime = linspace(0,tDom(2),nTiPts);

            %Use deval to evaluate the solution of a differential equation 
            %problem.
            stStates = transpose(deval(sol,stTime));                       
            %-------------------------------------------------------------%
            
        else
            
            %-------------------------------------------------------------%                
            %Flag the event
            
            %Flag to indicate that an event did happen
            flags.event = 1;
            %-------------------------------------------------------------%
                        
            
            
            %-------------------------------------------------------------%                
            %Interpolate to obtain a desired number of solutions within a 
            %newly defined subdomain of the dimensionless time

            %Determine the range of the solution time points as a subset of
            %the domain of the time points used for the numerical 
            %integration. Since the event is used, an upperbound would be 
            %the event time. Also, we want nTimePts number of time points 
            %from the solution.
            stTime = linspace(0,sol.xe,nTiPts);

            %Use deval to evaluate the solution of a differential equation 
            %problem.
            stStates = transpose(deval(sol,stTime));                       
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%                                
                
    %If we have the results from time driven numerical integration,    
    elseif isempty(funcEve) == 1
        
        %-----------------------------------------------------------------%                
        %Update the flag
        
        %Flag to indicate that an event did not happen
        flags.event = 0;
        %-----------------------------------------------------------------%                
        
        
        
        %-----------------------------------------------------------------%                
        %Interpolate to obtain a desired number of solutions within a newly
        %defined subdomain of the dimensionless time
        
        %Determine the range of the solution time points as a subset of the
        %domain of the time points used for the numerical integration.
        %Since no event is used, an upperbound would be the final time.
        %Also, we want nTimePts number of time points from the solution.
        stTime = linspace(0,tDom(2),nTiPts);
        
        %Use deval to evaluate the solution of a differential equation 
        %problem.
        stStates = transpose(deval(sol,stTime));                       
        %-----------------------------------------------------------------% 
        
    end        
    %---------------------------------------------------------------------%            
    
    
    
    %---------------------------------------------------------------------%            
    %Check the solution output
    
    %Throw out a warning if the solution is not of the right length
    if length(stTime) < nTiPts
        
        %Print out the error message
        msg = 'Did not obtain enough number of time points as a solution';
        msg = append(funcId,': ',msg);
        error(msg); 
        
    end        
    %---------------------------------------------------------------------%     
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%