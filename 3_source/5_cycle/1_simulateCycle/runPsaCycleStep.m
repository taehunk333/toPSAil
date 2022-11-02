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
%Code last modified on : 2022/10/22/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : runPsaCycleStep.m
%Source     : common
%Description: Given all the information in params, this function simulates
%             a given PSA process by obtainining the solution of the
%             dynamic PSA process model through the usage of
%             state-of-the-art ODE solver(s). The solution technique
%             implemented here is called the method of lines.
%Inputs     : params       - a struct containing simulation parameters.
%             iStates      - an initial state solution row vector
%                            containing the initial condition to the 
%                            simulation.
%             tDom         - a 1 by 2 numerical vector that contains the
%                            initial and terminal time points for the
%                            numerical integration.
%             nCy          - the current PSA cycle
%             nS           - the current step in a given PSA cycle
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
    bool       = params.bool       ;
    numZero    = params.numZero    ;
    
    %Update the data structure with integration specific information for
    %the given step
    params = grabParams4Step(params,nS);              
   
    %Define the right hand side function
    funcRhs = @(t,x) defineRhsFunc(t,x,params);  
    
    %Initialize the original integration; it must be done, to begin with
    orgInt = 1;
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Update the initial condition vector
            
    %If we are doing a flow driven simulation
    if bool(3) == 0
        
        %-----------------------------------------------------------------%
        %Do the pre-integration, if needed
        
        %Let the pressure build up inside the raffinate product tank and/or
        %the extract product tank, if needed
        [sol0,tDom0,preInt] = solvOdes0(params,tDom,iStates,nS);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Update the information for the original numerical integration
        
        %If pre-integration was needed and done,
        if preInt == 1
                 
            %-------------------------------------------------------------%                        
            %Get the terminal time points
            tf  = tDom(2) ;
            tf0 = tDom0(2);                

            %Consider the duration of the pre-integration. If we are pretty
            %much done with the numerical integration for the step, within 
            %the numerical tolerance, then
            if abs(tf-tf0) < numZero
                
                %Update the solution data structure
                sol = sol0;
                
                %We've effectively finished simulating the step, so no need 
                %to do the original integration
                orgInt = 0;

            end
            %-------------------------------------------------------------%
                                            
        %If the pre-integation was not needed
        elseif preInt == 0
            
            %-------------------------------------------------------------%        
            %Update the flag for the pre-integration
            preInt = 0;                                    
            %-------------------------------------------------------------%
            
        end                        
        %-----------------------------------------------------------------%
        
    %If we are doing a pressure driven simulation   
    else
        
        %-----------------------------------------------------------------%    
        %Update the flag for the pre-integration
        preInt = 0;
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %If we still need to do the original integration, then do the 
    %followings
    
    %If we still need to do the original numerical integration,
    if orgInt == 1
    
        %-----------------------------------------------------------------%
        %Define the options for the ODE solver to solver the system of ODEs

        %Get the ode solver option from setOdeSolverOpts.m
        options = setOdeSolverOpts(params,iStates,nS,nCy);
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Simulate the step in a scheduled PSA cycle        

        %If we were to extend the solution
        if preInt == 1
            
            %Perform the numerical integration for the step
            sol = odextend(sol0,funcRhs,tDom(2),[],options);            
            
        %If we are doing the original numerical integration
        else
            
            %Perform the numerical integration for the step
            sol = solvOdes(funcRhs,tDom,iStates,options,numIntSolv);
        
        end
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Print numerical integration summary
        
        %Print out the numerical integration results
        noteNumIntStats(sol,numIntSolv);        
        %-----------------------------------------------------------------% 
                
    end
    %---------------------------------------------------------------------%
      
    
    
    %---------------------------------------------------------------------%
    %Obtain the solutions based on the integration results and the type of
    %the mode of integration (i.e. event vs time).
    
    %If we have the results from event driven numerical integration,
   if isempty(funcEve) ~= 1     
        
        %-----------------------------------------------------------------%
        %Make sure that the event had happened for the original numerical
        %integration
        
        %When the pre-integration triggered an event, i.e., there is a
        %field named 'xe' in the solution structure sol0, 
        if isfield(sol0,'xe') == 1 
        
            %The soluation structure sol for the original integration,
            %following the pre-integration, will surely contain 'xe', 'ye',
            %and 'ie' as it fields. Can we say that the event times from 
            %the pre-integration and the original integration are the same?
            %In other words, if they are the same, then no event has
            %happened for the original integration. Note that the next
            %event is just added to the next element as a vector.
            if length(sol.xe) == 1
                
               %No event has happened for the original integration.
               %Therefore, return empty values for the event related
               %parameters
               sol.xe = [];
               sol.ye = [];
               sol.ie = 0 ;               
                
            end
  
        end
        %-----------------------------------------------------------------%
        
        
        
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
            stTime = linspace(0,sol.xe(end),nTiPts);

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