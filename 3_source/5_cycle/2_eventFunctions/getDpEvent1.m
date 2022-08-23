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
%Code last modified on : 2022/4/17/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getDpEvent1.m
%Source     : common
%Description: This is the first type of an event function for 
%             depressurization. The event criteria is for the column void
%             pressure to be equal to a low pressure.
%Inputs     : params       - a struct containing simulation parameters.
%             t            - a column vector containing state time points
%             states       - a state solution vector/matrix at a given time
%                            point
%             nS           - jth step in a given PSA cycle
%             nCy          - ith PSA cycle
%Outputs    : event        - a value that defines an event to happen when
%                            the function value becomes zero
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] ...
    = getDpEvent1(params,~,states,nS,~,varargin)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getDpEvent1.m';
    
    %Unpack params
    eveColNo      = params.eveColNo(nS) ;
    nComs         = params.nComs        ;
    nColStT       = params.nColStT      ;
    eveTotPres    = params.eveTotPres   ;
    gasConsNormEq = params.gasConsNormEq;
    
    %Convert the states into a row vector
    states = states(:).';
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Grab the event column number only when needed
    
    %If the event column number is provided by the user, then 
    if ~isempty(varargin)
        
        %Get the event column number from the first varargin input
        eveColNo = varargin{1};
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and obtain necessary quantities
 
    %Compute the total pressure inside the 1st CSTR in the column
    %where the event would take place
    gasTotPres1 ...
        = sum(states(:,nColStT*(eveColNo-1)+1: ...
             nColStT*(eveColNo-1)+nComs)) ...
        * gasConsNormEq ...
        * states(:,nColStT*(eveColNo-1)+1+2*nComs);   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 
    
    %Total pressure differnce between the current pressure of the 1st
    %CSTR vs. the low pressure
    event = gasTotPres1-eveTotPres;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify the event criteria
    
    %Shall we stop the integration after an event triggers?
    isterminal = 1; % Halt integration (1 = true, 0 = false)
    
    %From which side should we approach zero?
    direction = 0; % The zero can be approached from either direction    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%