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
%Code created on       : 2021/1/22/Friday
%Code last modified on : 2022/1/31/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getStringParams.m
%Source     : common
%Description: a function that unpacks string params and convert them into
%             relevant numerics or arrays.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getStringParams(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getStringParams.m';
    
    %Unpack params
    valOneCol  = params.valOneCol ;
    valTwoCol  = params.valTwoCol ;
    valThrCol  = params.valThrCol ;
    valFouCol  = params.valFouCol ;
    valFivCol  = params.valFivCol ;
    valSixCol  = params.valSixCol ;    
    eveColNo   = params.eveColNo  ;
    nSteps     = params.nSteps    ;    
    nCols      = params.nCols     ;
    sStepCol   = params.sStepCol  ;
    flowDirCol = params.flowDirCol;
    nAdsValsT  = params.nAdsValsT ;    
    nAdsVals   = params.nAdsVals  ;
    maxNoBC    = params.maxNoBC   ; 
    nComs      = params.nComs     ;
    valRaTa    = params.valRaTa   ;
    valExTa    = params.valExTa   ;
    valRinTop  = params.valRinTop ;
    valRinBot  = params.valRinBot ;
    valPurBot  = params.valPurBot ;
    valFeeTop  = params.valFeeTop ;
    %---------------------------------------------------------------------%                                                        
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize a string array that stores step names
    sStep = strings(nCols,nSteps);      
    
    %Initialize a numeric array that stores flow directions
    flowDir = zeros(nCols,nSteps);
    
    %Initialize a numeric array that stores the valve constant values. The
    %first 6*nCols columns represent constant valve values.
    valConVals = zeros(nAdsValsT,nSteps);        
    
    %Initialize a numeric array that is smaller than valConVals because we
    %added valve constants for 1, 3, and 5 and 2, 4, and 6
    valConValsT = zeros(maxNoBC*nCols,nSteps); 
    
    %Intialize a cell array for holding the name of chemical species in the
    %system
    sComNums = cell(nComs,1);
    
    %Intialize a cell array for holding the name of the adsorption columns
    %inside the system
    sColNums = cell(nCols,1);        
    %---------------------------------------------------------------------%    
        
    
    
    %---------------------------------------------------------------------%    
    %Define strings for accessing elements inside a nested structure
    
    %Define a vector containing each component in a stream
    comSpace = linspace(1,nComs,nComs)';
    
    %Define a vector containing each columns in the system
    colSpace = linspace(1,nCols,nCols)';
    
    %For each component,
    for i = 1 : nComs
        
        %Assign the component number name for an ith component
        sComNums{i} = append('C',int2str(comSpace(i)));
        
    end    
    
    %For each column,
    for i = 1 : nCols
        
        %Assign the component number name for an ith component
        sColNums{i} = append('n',int2str(colSpace(i)));
        
    end 
    %---------------------------------------------------------------------%   
    
        
    
    %---------------------------------------------------------------------%
    %Unpack strings related to cycle information and store them as needed
    
    %Splite the string variable containing the tank interaction boolean
    %variables
    valRaTa   = split(valRaTa)  ;
    valExTa   = split(valExTa)  ;
    valRinTop = split(valRinTop);
    valRinBot = split(valRinBot);
    valPurBot = split(valPurBot);
    valFeeTop = split(valFeeTop);
    
    %Convert the cell array containing the splitted strings into a
    %numerical array and store it as a row vector
    valRaTa   = str2double(valRaTa)'  ;
    valExTa   = str2double(valExTa)'  ;   
    valRinTop = str2double(valRinTop)';
    valRinBot = str2double(valRinBot)';
    valPurBot = str2double(valPurBot)';
    valFeeTop = str2double(valFeeTop)';
    
    %For each columns,
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Get the ith column step names
        
        %Access the strings for step names in the ith column, split the 
        %strings, and save it in ith row of sStep
        sStep(i,:) = split(sStepCol{i})';        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Get the ith column flow directions
        
        %For the string containing the flow directions and break it up.
        testVal = split(flowDirCol{i})';
        
        %Find the indices for the counter-currents
        indCou = find(testVal=="1");                
        
        %Save the flow directions
        flowDir(i,indCou) = ones(1,length(indCou));        
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------% 
        %From the user defined inputs, obtain valve constant values inside
        %numerical arrays
        
        %Obtain the valve constant values for all steps and store them in       
        %the row corresponding for aa 6 valves
        val1ColVals = str2double(split(valOneCol{i}))';
        val2ColVals = str2double(split(valTwoCol{i}))';
        val3ColVals = str2double(split(valThrCol{i}))';
        val4ColVals = str2double(split(valFouCol{i}))';
        val5ColVals = str2double(split(valFivCol{i}))';
        val6ColVals = str2double(split(valSixCol{i}))';
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------% 
        %Check for any user input errors
        
        %Check to see if the user has specified a right number of valve
        %constant values for a given valve
        if nSteps ~= length(val1ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 1 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i);   
            
        elseif nSteps ~= length(val2ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 2 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i)                                             ; 
            
        elseif nSteps ~= length(val3ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 3 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i)                                             ; 
            
        elseif nSteps ~= length(val4ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 4 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i)                                             ;  
            
        elseif nSteps ~= length(val5ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 5 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i)                                             ;  
            
        elseif nSteps ~= length(val6ColVals)
            
            %Print the error message
            msg1 = 'Please provide a right number of valve constants';
            msg2 = ' for valve 6 in column %d.'                      ;
            msg3 = 'i.e. equal to the number of the steps.'          ;
            msg  = append(funcId,': ',msg1,msg2,msg3)                ;
            error(msg,i)                                             ; 
            
        end
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------% 
        %Save the results to the numeric array;
        
        %Save the valve constants for linear valves
        valConVals(nAdsVals*(i-1)+1,:) = val1ColVals;
        valConVals(nAdsVals*(i-1)+2,:) = val2ColVals;
        valConVals(nAdsVals*(i-1)+3,:) = val3ColVals;
        valConVals(nAdsVals*(i-1)+4,:) = val4ColVals;
        valConVals(nAdsVals*(i-1)+5,:) = val5ColVals;
        valConVals(nAdsVals*i,:)       = val6ColVals;
        %-----------------------------------------------------------------% 
        
    end
    
    %For each column, combine the valve constants for the product end and
    %respectively for the feed end; we can do this because, at the most, 
    %one valve per one end is active at any given step in a given PSA cycle
    for i = 1 : nCols
        
        %-----------------------------------------------------------------% 
        %Get relevant indices
        
        %Get the original indices for the current column product-end
        indOrgPr = nAdsVals*(i-1)+1:2:nAdsVals*(i)-1;
        
        %Get the original indices for the current column feed-end
        indOrgFe = nAdsVals*(i-1)+2:2:nAdsVals*(i);
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------% 
        %Calculate the sum of the valves for the respective ends and store
        %the values; for an ith column
        
        %Product-end valve values for the ith column
        valConValsT(maxNoBC*(i-1)+1,:) = sum(valConVals(indOrgPr,:),1);
        
        %Feed-end valve values for the ith column
        valConValsT(maxNoBC*i,:) = sum(valConVals(indOrgFe,:),1);
        %-----------------------------------------------------------------% 
                
    end
    
    %For each step, identify the columns on which an event would work on
    eveColNo = str2double(split(eveColNo))';                
    %---------------------------------------------------------------------%                                   
    
    
    
    %---------------------------------------------------------------------%
    %Save function outputs 
    
    %Save inside params
    params.sStep     = sStep      ;         
    params.flowDir   = flowDir    ;  
    params.eveColNo  = eveColNo   ;
    params.valCon    = valConVals ;
    params.valConT   = valConValsT;   
    params.sComNums  = sComNums   ;
    params.sColNums  = sColNums   ;
    params.valRaTa   = valRaTa    ;
    params.valExTa   = valExTa    ;
    params.valRinTop = valRinTop  ;
    params.valRinBot = valRinBot  ;
    params.valPurBot = valPurBot  ;
    params.valFeeTop = valFeeTop  ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove any unused fields
    
    %Remove the strings that are no longer needed
    params = rmfield(params,"sStepCol")  ;
    params = rmfield(params,"flowDirCol");
    params = rmfield(params,"valOneCol") ;
    params = rmfield(params,"valTwoCol") ;
    params = rmfield(params,"valThrCol") ;
    params = rmfield(params,"valFouCol") ;
    params = rmfield(params,"valFivCol") ;
    params = rmfield(params,"valSixCol") ;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%