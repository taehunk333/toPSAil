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
%Function   : noteModelNotReady.m
%Source     : common
%Description: print out a statement and send out error statement when the
%             models under development is selected from the user
%Inputs     : modSpNum     - The number associated with modSp variable set
%                            by the user in the spreadsheet in the exmaple
%                            folder: specifySimulationParameters.xlsm 
%Outputs    : n.a          - n.a.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function noteModelNotReady(modSpNum)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'noteModelNotReady.m';
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Print out the error message
    
    %Print the error message
    msg1 = 'The user-selected model is currently not available. ';
    msg2 = 'Please select an alternate model for the variable "modSp';
    
    %Append the strings of messages
    msg  = append(funcId,': ',msg1,msg2,int2str(modSpNum),'".');
    
    %Print the error message
    error(msg);           
    %---------------------------------------------------------------------%             
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%