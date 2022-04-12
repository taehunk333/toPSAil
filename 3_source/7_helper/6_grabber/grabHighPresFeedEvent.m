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
%Code created on       : 2022/2/18/Friday
%Code last modified on : 2022/2/18/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : grabHighPresFeedEvent.m
%Source     : common
%Description: given the current cycle and the number of steps in a given
%             PSA cycle, returns the initial and final step numbers
%Inputs     : params       - a data structure containing all the
%                            simulation parameters
%             sol          - a data structure containing all the solutions
%                            from the numerical simulation of the system 
%             colNum       - the current adsorption column number
%Outputs    : indHpEnd     - a numerical vector containing the indices for
%                            all high pressure feed steps with their events 
%                            triggered in the current adsorption column 
%                            during a PSA cycle.
%             eveCount     - a numerical vector containing the boolean
%                            variables of the event for each identified
%                            high pressure feed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [indHpEnd,eveCount] = grabHighPresFeedEvent(params,sol,colNum)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabHighPresFeedEvent.m';
    
    %Unpack params
    lastStep = sol.lastStep   ;
    sStep    = params.sStep   ;
    nSteps   = params.nSteps  ;  
    eveColNo = params.eveColNo;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Grab the high pressure feed step
    
    %Find the high pressure step
    indHp = find(sStep(colNum,:)=="HP");
         
    %Get the nubmer of remaining high pressure feed
    lenHp = length(indHp);
    
    %Get the event counter
    eveCount = zeros(1,lenHp);
    
    %Initialize the event high pressure step counter
    indHpEnd = zeros(1,lenHp);

    %For each high pressure feed
    for i = 1 : lenHp

        %If the event happened in the current Hp step
        if eveColNo(indHp(i)) == colNum

            %Find the last high pressure step with the event
            indHpEnd(i) = lastStep ...
                        - nSteps ...
                        + indHp(i);     
            
            %Update the event counter
            eveCount(i) = 1;

        end

    end   
    
    %Remove any zeros from the vector
    indHpEnd = indHpEnd(indHpEnd~=0);
    %---------------------------------------------------------------------%             
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%