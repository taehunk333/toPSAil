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
%Code created on       : 2022/5/12/Thursday
%Code last modified on : 2022/5/12/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : setOdeSolverOpts.m
%Source     : common
%Description: a function that sets up the optin structure for the ode 
%             solver.
%Inputs     : params       - a struct containing simulation parameters.
%             iStates      - an initial state solution row vector
%                            containing the initial condition to the 
%                            simulation.
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : options      - a struct 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = setOdeSolverOpts(params,iStates,nS,nCy)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'setOdeSolverOpts.m';    
    
    %Unpack params              
    funcEve = params.funcEve{nS};
    %---------------------------------------------------------------------%                            
   
    
    
    %---------------------------------------------------------------------%
    %For the case where there is an event, define additional options for
    %the numerical integrator for solving ODEs
    
    %Check to see if an event is needed for a given step using a logical 
    %statement value for seeing if the event containing cell array is an 
    %empty array or not
    needEvent = ~isempty(funcEve);
    
    %When we have a specified event, i.e., the cell containing the event
    %function handle is not an empty cell,
    if needEvent == 1
                                                                        
        %Test to see if the event function will even work before solving 
        %the ODEs
        if testEventFunc(params,iStates,funcEve,1,nS,nCy) == 0
            
            %Display the error message
            msg = 'The event will not work with the current initial state';
            msg = append(funcId,': ',msg);
            error(msg);              
            
        end    
        
        %Enable the option for an event function
        event = odeset('Events',@(t,states) ...
                        funcEve(params,t,states,nS,nCy));  
        
    %When we don't have a specified event, no options are needed
    elseif needEvent == 0
               
        %Save the options
        event = [];
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define a structure for the output function to carry out specific tests
    %after a successfully integrated step taken by the ode solver
    
    %Assign an output function
    output = [];
%     output = odeset('OutputFcn', ...
%                     @(time,states,flag) ...
%                     testDaeConst(time,states,flag,params,nS,nCy));
%     output = odeset('OutputFcn', ...
%                     @(time,states,flag) ...
%                     testFlowReversal(time,states,flag,params,nS,nCy));
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define a structure for the ode solver tolerance values
    
    %Assign the tolerance values
    tols = odeset('RelTol',1e-3,'AbsTol',1e-6);
    %---------------------------------------------------------------------%
    
    
                
    %---------------------------------------------------------------------%    
    %Specify information about the Jacobian matrix
    
%     %Evaluate the right hand side function at the initial condition
%     rhsEval = defineRhsFunc(0,iStates,params);
%     
%     %Define options for the Jacobian
%     jacOpts = struct('diffvar', 2, ...
%                       'vectvars', [], ...
%                       'thresh', 1e-8, ...
%                       'fac', []);
%     
%     %Get the jacobian matrix at the initial condition
%     jacMat = odenumjac(@defineRhsFunc, ...
%                        {0 iStates' params}, ...
%                        rhsEval, ...
%                        jacOpts); 
%     
%     %Get the sparsity pattern for the Jacobian matrix for the right hand
%     %side function
%     spyPat = sparse(jacMat~=0.0);
%     
%     %Specify the sparsity pattern for the Jacobian matrix
%     spy = odeset('JPattern',spyPat);

%     %Do not specify anything about the Jacobian matrix
%     spy = [];

    %Define the Jacobian matrix evaluation function
    funcJacobMat = @(t,x) getJacobianMatrix(t,x,params);
    
    %Specify the Jacobian matrix in the ode solver option
    spy = odeset('Jacobian',funcJacobMat);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Set the solver stats
    
    %Let us print the solver statistics
%     stats = odeset('Stats','on');
    stats = [];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the different options into one struct
    
    %Save the final options
    options = odeset(event, ...
                     output, ...
                     tols, ...
                     spy, ...
                     stats);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%