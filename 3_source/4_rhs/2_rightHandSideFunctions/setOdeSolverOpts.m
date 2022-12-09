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
%Code last modified on : 2022/12/8/Thursday
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
%             nS           - the current step in a given PSA cycle
%             nCy          - the current PSA cycle
%Outputs    : options      - a struct 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function options = setOdeSolverOpts(params,iStates,nS,~)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'setOdeSolverOpts.m';    
    
    %Unpack params              
    funcEve   = params.funcEve{nS};
    bool      = params.bool       ;
    odeAbsTol = params.odeAbsTol  ;
    odeRelTol = params.odeRelTol  ;
    modSp     = params.modSp      ;
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
                                          
%         %Determine the side of the event function
%         eveSide = getEventSide(params,nS);
%         
%         %Test to see if the event function will even work before solving 
%         %the ODEs
%         if testEventFunc(params,iStates,funcEve,eveSide) == 0
%             
%             %Display the error message
%             msg = 'The event will not work with the current initial state';
%             msg = append(funcId,': ',msg);
%             error(msg);              
%             
%         end    
        
        %Enable the option for an event function
        event = odeset('Events', @(t,states) funcEve(params,t,states));  
        
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
    tols = odeset('RelTol',odeRelTol,'AbsTol',odeAbsTol);
    %---------------------------------------------------------------------%
    
    
                
    %---------------------------------------------------------------------%    
    %Specify information about the Jacobian matrix
    
    %When there is an axial pressure drop, let us spcify the sparsity
    %pattern for the Jacobian matrix, once before the numerical integration
    if bool(3) == 1
                 
        %Call the helper function to obtain the jacobian matrix's 
        %sparsity pattern
        [~,spyPat] = calcJacMatFiniteDiff(0,iStates,params);       

        %Specify the sparsity pattern for the Jacobian matrix
        jacOpts = odeset('JPattern',spyPat);     
    
    %When there is no axial pressure drop, let us specify a function handle
    %for the Jacobian matrix, once before the numerical inetgration
    elseif bool(3) == 0        
        
        %Do not specify anything about the Jacobian matrix
        jacOpts = [];

%         %Define the Jacobian matrix evaluation function
%         funcJacobMat = @(t,x) defineJacobMat(t,x,params);
% 
%         %Specify the Jacobian matrix in the ode solver option
%         jacOpts = odeset('Jacobian',funcJacobMat);
        
    end       
    
    %If we have an implicit isotherm model, 
    if modSp(1) == 3

        %Do not specify anything about the Jacobian matrix
        jacOpts = []; 

    end
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
                     jacOpts, ...
                     stats);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%