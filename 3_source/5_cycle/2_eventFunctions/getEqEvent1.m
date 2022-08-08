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
%Code last modified on : 2022/8/8/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEqEvent1.m
%Source     : common
%Description: This is the first type of an event function for pressure 
%             equalization between two columns. The event criteria is
%             reaching an intermediate pressure inside the event adsorption 
%             column. the intermediate pressure is computed from a user 
%             specified threshold on the pressure swing of the system. i.e.
%             For pressurization, presInt = presBeHi-thr*presDel, and for
%             depressurization, presInt = presBeLo+thr*presDel, where thr
%             is the user specified threshold on the pressure swing.
%Inputs     : params       - a struct containing simulation parameters.
%             t            - a column vector containing state time points
%             states       - a state solution vector/matrix at a given time
%                            point
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : event        - a value that defines an event to happen when
%                            the function value becomes zero
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] = getEqEvent1(params,~,states,nS,~)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getEqEvent1.m';
    
    %Unpack params
    presDiff   = params.presDiff               ;
    presBeHi   = params.presBeHi               ;
    eveColNo   = params.eveColNo(nS)           ;
    nComs      = params.nComs                  ;
    nColStT    = params.nColStT                ;
    eveEqThr   = params.eveEqThr               ;
    valFeedCol = params.valFeedCol             ;
    valProdCol = params.valProdCol             ;
    flowDirCol = params.flowDirCol(eveColNo,nS);   
    pRat       = params.pRat                   ;
    
    %Convert the states into a row vector
    states = states(:).';
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and obtain necessary quantities
 
    %Compute the total concentration inside the 1st CSTR in the column
    %where the event would take place
    gasConTot1 ...
        = sum(states(:,nColStT*(eveColNo-1)+1:nColStT*(eveColNo-1)+nComs));   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Determine the event termination criteria        
    
    %Is one of the feed-end valves open?
    valFeedOpen = valFeedCol(eveColNo,nS)~=0;

    %Is one of the product-end valves open?
    valProdOpen = valProdCol(eveColNo,nS)~=0;        
    
    %Pressure will increase
    if (valProdOpen && flowDirCol == 1) || ...
       (valFeedOpen && flowDirCol == 0)
        
        %-----------------------------------------------------------------%
        %Get the event criteria
        
        %Calculate the intermediate pressure (dimensionless)
        eveTotConInt = pRat+eveEqThr*presDiff/presBeHi;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Compute the event 

        %Total concentration differnce between the current pressure of the 
        %1st CSTR and the event intermediate pressure
        event = eveTotConInt-gasConTot1;
        %-----------------------------------------------------------------%
                
    %Pressure will decrease
    elseif (valProdOpen && flowDirCol == 0) || ...
           (valFeedOpen && flowDirCol == 1)
        
        %-----------------------------------------------------------------%
        %Get the event criteria
        
        %Calculate the intermediate pressure (dimensionless)
        eveTotConInt = 1 - eveEqThr*presDiff/presBeHi;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Compute the event 

        %Total concentration differnce between the current pressure of the 
        %1st CSTR and the event intermediate pressure
        event = gasConTot1 - eveTotConInt;
        %-----------------------------------------------------------------%
    
    end
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