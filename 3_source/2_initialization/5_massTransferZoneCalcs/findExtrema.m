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
%Code created on       : 2020/1/21/Tuesday
%Code last modified on : 2020/12/16/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : findExtrema.m
%Source     : common
%Description: based on the identified modified complementary error 
%             function, determine the location of extrema in 
%             z \in \left[ -0.5, 0.5 \right].
%Inputs     : mcerfMin     - a function handle for the second derivative of
%                            the modified complementary error function to 
%                            be used for finding the minimum.
%             mcerfMax     - a function handle for the second derivative of
%                            the negated modified complementary error 
%                            function to be used for finding the maximum.
%             axSpan       - a 2 by 1 column vector that holds the lower 
%                            and upper bound on the closed domain of a 
%                            single variable function in z.
%Outputs    : loBoundIn    - the lower bound of the mass transfer zone 
%                            (MTZ) within the domain specified by the 
%                            entries in vec_x_span.
%             upBoundIn    - the upper bound of the mass transfer zone 
%                            (MTZ) within the domain specified by the 
%                            entries in vec_x_span.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [loBoundIn,upBoundIn] = findExtrema(mcerfMin,mcerfMax,axSpan)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'findExtrema.m';
    
    %Unpack the upper and the lower bounds
    axLoBound = axSpan(1);
    axUpBound = axSpan(2);       
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Find the exterma for the second derivative of modified and negated
    %motifited error functions
    
    %Set solver option for finding a minimum
    options = optimset('Display','off');

    %Find the minimum of the function or i.e. the lower bound
    [loBoundIn,~,exitFlagMin] = ...
                             fminbnd(mcerfMin,axLoBound,axUpBound,options);

    %Find the maximum of the function or i.e. the upper bound
    [upBoundIn,~,exitFlagMax] = ... 
                             fminbnd(mcerfMax,axLoBound,axUpBound,options);    
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%    
    %Check exitFlagMin and exitFlagMax and see if the second derivative
    %tests failed or not
    
    if exitFlagMin ~= 1
        msg = 'The second derivative test failed to find a minimum';
        msg = append(funcId,': ',msg);
        error(msg);  
    elseif exitFlagMax ~=1
        msg = 'The second derivative test failed to find a maximum';
        msg = append(funcId,': ',msg);
        error(msg);          
    end
    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%