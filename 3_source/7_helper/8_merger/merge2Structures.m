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
%Function   : merge2Structures.m
%Source     : common
%Description: This .m function merges two structures to get a single
%             structure. Only a single field will be used in the final 
%             structure if the field was present in both structures, before
%             merging.
%Inputs     : params       - The overall structure where we will merge all
%                            the subsequent structures.
%             currParams   - An extra structure that needs to be merged
%                            with params.
%Outputs    : params       - The overall structure where we will merge all
%                            the subsequent structures.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = merge2Structures(params,currParams)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'merge2Structures.m';
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Check the inputs
    
    %If any one of the structures are empty, then we simply need not merge
    %any structures but return the non-empty one
    
    %Check if any of the structures are empty
    structEmptyParams     = isempty(params)    ; 
    structEmptyCurrParams = isempty(currParams);
            
    %If both structures are empty, then
    if structEmptyCurrParams == 1 && ...
       structEmptyParams == 1
          
        %Print an error message and terminate the program
        error('%s: Two structures being merged are both empty.',funcId);
        
    %If params is empty and currParams is not empty
    elseif structEmptyCurrParams == 0 && ...
           structEmptyParams == 1
       
       %Set params equal to currParams
       params = currParams;
       
       %Return to the invoking function
       return;
                    
    %If currParams is empty and params is not empty
    elseif structEmptyCurrParams == 1 && ...
           structEmptyParams == 0
        
       %Just return
       return;
        
    end
    %---------------------------------------------------------------------%             
    
    
        
    %---------------------------------------------------------------------%             
    %Start adding fields to params from currParams one by one
    
    %Get the name of the fields in the structures
    fnsCurrParams = fieldnames(currParams);
    
    %Get the number of the fields in the structures
    numCurrParams = length(fnsCurrParams);
    
    %For each field in currParams
    for i = 1 : numCurrParams
    
        %Get the current field name
        fieldCurr = fnsCurrParams{i};
        
        %Check to see if the field that we are about to add to params
        %from currParams already exists in params
        alreadyField = isfield(params,fieldCurr);
        
        %If we already have the field, then we skip
        if alreadyField == 1
            
            % Nothing to do here            
            
        %If we don't have the field, 
        else
            
            %We add the field to params
            params.(fieldCurr) = currParams.(fieldCurr);
            
        end                   
    
    end
    %---------------------------------------------------------------------%             
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%