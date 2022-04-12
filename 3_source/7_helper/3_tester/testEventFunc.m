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
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2021/1/18/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : testEventFunc.m
%Source     : common
%Description: checks to see if the event function starts from the correct 
%             side of zero. 
%Inputs     : params       - a struct containing simulation parameters
%             states       - a dimensionless initial condition state vector
%             func         - a chosen event function to be used in 
%                            evaluating the initial value.
%             side         - a scalar input to determine on which 
%                            side of zero the event function would start. A
%                            positive number will define the positive side 
%                            as the expected side of zero and vice versa 
%                            for a negative number. 
%                            expectedSideOfZero=1 means that you expect the
%                            event function's threshold comparison to yield
%                            a positive result.    
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : event        - a logic value of true or false. If true, 
%                            the event function will work with the given 
%                            initial condition. If false, the event 
%                            function will not work.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function event = testEventFunc(params,states,func,side,nS,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'testEventFunc.m';      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check function inputs
    
    %Check if the input states is indeed a vector
    if ~isvector(states) 
        %Write a string of message
        string = '. Initial condition satate vector is a wrong size.';
        %Display the error message
        disp(['ERROR in ',funcId,string]); 
        %Return to the invoking function.
        return;
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate needed quantities
    
    %Evaluate the initial value of the chosen event function which is an
    %initial condition for a given step in the PSA Cycle.
    [initVal,~,~] = func(params,0,states,nS,nCy);
    
    %Compute the decision variable
    decision = (side/initVal);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check to see if the event will happen from the correct side of zero
    
    %If your requested side of zero matches the actual side of zero that
    %the event function computes, then the result of division will always
    %be positive.
    if decision < 0
        event = false;
    %If the ratio is greater than 0 (i.e. positive value) the evaluated 
    %value of the event funtion has to start from the positive side
    else 
        event = true ; 
    end
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%