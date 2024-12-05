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
%Code created on       : 2021/1/1/Friday
%Code last modified on : 2022/1/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getExcelParams.m
%Source     : common
%Description: Given a string denoting the folder location, read the excel
%             sheet in the folder and build an ininitial struct called
%             "params" that contains a set of user specified simulation
%             parameters. Other functionalities of the function include:
%                  - Perform tests to make sure that user has specified all
%                    the required parameters for the simulation
%                  - Perform pre-computations to compute useful quantities
%                    for carrying out the simulation
%             simulation to run.
%Inputs     : exFolder     - a string denoting a location of the example
%                            folder
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getExcelParams(exFolder,nameFolder,nameExcelFile)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getExcelParams.m';
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%    
    %Import simulation data from the excel file
    
    %Check if we are on a PC
    if ispc
        
        %Define a string variable denoting the directory path to the Excel 
        %file
        locExcelFile  = append(exFolder,'\',nameFolder,'\',nameExcelFile);

    %Check if we are on a Mac
    elseif ismac

        %Define a string variable denoting the directory path to the Excel 
        %file
        locExcelFile  = append(exFolder,'/',nameFolder,'/',nameExcelFile);

    %Otherwise the platform is not supported
    else

        %Let the user know that the platform is not supported
        error('Platform not supported')

    end
    
    %Import the table containing the data    
    params = readtable(locExcelFile,'Sheet','Data(Transposed)');  
    tests  = readtable(locExcelFile,'Sheet','Data(Test)');  
    
    %Construct a struct from the data
    params = table2struct(params);
    tests  = table2struct(tests);
    %---------------------------------------------------------------------%
    
    

    %---------------------------------------------------------------------%
    %Check the inputs to make sure that we are ready to run simulations
    
    %Initialize the flag
    flag = 0;
    
    %Determine the test logics
    testLogic1 = struct2cell(params);
    testLogic2 = struct2cell(tests) ;
    
    %Name the field inside a struct
    fns = fieldnames(params);
    
    %Test to see if we have all the needed inputs
    for i = 1 : length(testLogic1)  
        
        %If the entry is a string
        if ischar(testLogic1{i})
            
            %do nothing (we have the entry)
            
        %If the entry is NaN and we need the value
        elseif isnan(testLogic1{i}) && testLogic2{i} == 1
            
            %update the error flag
            flag = flag + 1;
            
        %If the entry is NaN and we do not need the value
        elseif isnan(testLogic1{i}) && testLogic2{i} == 0
            
            %remove it from the struct (we don't need it)
            params = rmfield(params,fns(i));
            
        end 
        
    end
    
    %If we did not have the required inputs, terminate the simulation
    if flag ~= 0
        
        %Print an error message and terminate the program
        error('toPSAil: We do not have all the needed inputs.');
    
    %We had the required inputs    
    else
        
        %otherwise, we can continue with the simulation                        
        
    end        
    %---------------------------------------------------------------------%
         
    
    
    %---------------------------------------------------------------------%
    %Vectorize fields inside a struct with similar names
    
    %Grab the names in the params
    fns = fieldnames(params);
    
    %Extract number from the names from the cell array
    fns = regexprep(fns,'\D','');
    
    %Convert cell to a vector
    fns = cellfun(@str2double,fns);
    
    %Convert NaNs in namesNew into a zeros
    fns(isnan(fns)) = 0;             
    
    %Find zero indices (i.e., the fields that are scalars) from fns
    fnsZeros = find(fns==0);
    
    %Get the length of the fns vector (i.e., the total number of fields)
    %and the fnsZeros vector (i.e., the total numer of scalar fields)
    lenFns      = length(fns)     ;
    lenFnsZeros = length(fnsZeros);
    
    %Initialize a column vector to store the field numbers
    store = zeros(lenFns,1);
    
    %Initialize the first entry with the first entry from fns
    store(1) = fns(1);
    
    %Initialize the switch counter
    j = 0;      
    
    %Initialize an empty numericl array
    saveData = [];
    
    %Begin for-loop and update saveData to find out the indices for testing
    %out the redundancy in the field names
    for i = 2 : length(fns)
        
        %Calculate the difference in the two consecutive field numbers
        diffFnsCurr = fns(i) - fns(i-1);
        
        %Consider the case where we are continuously counting the fields to
        %be combined into a single vector (if the last field happens to be
        %combined into a vector, it is treated differently)
        if diffFnsCurr > 0 && fns(i-1) ~= 0 && i ~= lenFns
            
            %The current counter should be obtained form incrementing the
            %previous counter by 1
            store(i) = store(i-1) + 1;        

        %Consider the case where we have the last field in the params to be
        %included inside a vector with some other fields right before the
        %last field
        elseif diffFnsCurr > 0 && fns(i-1) ~= 0 && i == lenFns
            
            %The current field number should be one greater than the one
            %before
            store(i) = store(i-1) + 1;
            
            %Update the switch counter (because we reached the last field)
            j = j + 1;
            
            %Save the count of the current field (because we are at the
            %last field)
            saveData(j,1) = store(i);
            
            %Save the index for the current field (because we are at the
            %last field)
            saveData(j,2) = i; 

        %Consider the case where we have the last field in the params to be
        %include inside a single numeric array of dimension 1 x 1
        elseif fns(i) == 1 && fns(i-1) ~= 0 && i == lenFns

            %The current field number should be one greater than the one
            %before
            store(i) = 1;
            
            %Update the switch counter (because we reached the last field)
            j = j + 1;
            
            %Save the count of the current field (because we are at the
            %last field)
            saveData(j,1) = store(i-1);
            
            %Save the index for the current field (because we are at the
            %last field)
            saveData(j,2) = i-1; 

            %Update the switch counter (because we reached the last field)
            j = j + 1;
            
            %Save the count of the current field (because we are at the
            %last field)
            saveData(j,1) = store(i);
            
            %Save the index for the current field (because we are at the
            %last field)
            saveData(j,2) = i; 
            
        %Consider the case where somewhere along the way of counting
        %field names over and over, we have a start of a new scalar field
        elseif diffFnsCurr < 0 && fns(i) == 0 && fns(i-1) ~= 1
            
            %The current field number is zero because it is a scalar field
            store(i) = 0;
            
            %Update the switch counter
            j = j + 1;
            
            %Save the count of the previous field
            saveData(j,1) = store(i-1);
            
            %Save the index for the previous field
            saveData(j,2) = i-1;
            
        %Consider the case where somewhere along the way of counting
        %repeated field names, we have a start of a new vector in which we
        %intend to combine some of the subsequent fields
        elseif diffFnsCurr < 0 && fns(i) == 1 && fns(i-1) ~= 1 
            
            %The current field number should be one because we want to
            %start counting again
            store(i) = 1;
            
            %Update the switch counter
            j = j + 1;
            
            %Save the count of the previous field
            saveData(j,1) = store(i-1);
            
            %Save the index for the previous field
            saveData(j,2) = i-1;             
            
        %Consider the case where we just started counting fields in a 
        %previous iteration and that we just finished counting fields in 
        %the current iteration and we have a start of a new scalar field
        elseif fns(i) == 0 && fns(i-1) == 1
            
            %Update the switch counter
            j = j + 1;
            
            %Save the count of the previous field
            saveData(j,1) = store(i-1);
            
            %Save the index for the previous field
            saveData(j,2) = i-1;
            
        %Consider the case where we just started counting fields in a
        %previous iteration and that we just finished counting fields in
        %the current iteration and we started counting fields freshly for
        %the next set of fields to be combined into a vector
        elseif fns(i) == 1 && fns(i-1) == 1
            
            %We just started counting fields, so assign 1 for the store 
            store(i) = 1;
            
            %Update the switch counter
            j = j + 1;
            
            %Save the count of the previous field
            saveData(j,1) = store(i-1);
            
            %Save the index for the previous field
            saveData(j,2) = i-1;
            
        %Consider the case where the previous field was a scalar field and 
        %now we are first beginning to collect fields so that we are able
        %to combine the fields into a vector
        elseif fns(i) == 1 && fns(i-1) == 0
            
            %The current field number should be one because we are starting
            %to count the fields again
            store(i) = 1;
            
        %Consider the case where the previous field was a scalar and the 
        %current field is also a scalar that needs not be combined into a
        %vector
        elseif fns(i) == 0 && fns(i-1) == 0
            
            %The current field number should be zero because we have yet
            %another scalar field
            store(i) = 0;
            
        end
        
    end
        
    %Check to see if we counted everything correctly
    if ~isequal(fns,store)
    
        %Print an error message and terminate the program
        error('toPSAil: We do not have all the needed inputs.');
        
    end
    
    %Grab the names in the params (again)
    fns = fieldnames(params);
    
    %Initialize a new struct
    newParams = [];
    
    %Get the dimension of saveData
    [nRows,~] = size(saveData);
    
    %Begin For-Loop for creating a new struct. In this for-loop, we will
    %grab all the field variables that are vectors.
    for i = 1 : nRows
        
        %Determine the name of the vectorized variable
        varName = fns{saveData(i,2)};
        
        %Remove the number from the vectorized variable name
        varName = regexprep(varName,'\d+$','');
        
        %Initialize the counter
        k = 1;
        
        %Initialize saveVar
        saveVar = [];
        
        %Calculate the beginning index
        j0 = saveData(i,2) - saveData(i,1) + 1;
        
        %Calculate the end index
        jf = saveData(i,2);
        
        %Begin inner For-Loop
        for j = j0 : jf
            
            %Grab the string name of the current field variable
            fnsCurr = fns{j};
            
            %If the variable is a string, then, store it as an array
            if ischar(params.(fnsCurr)) == 1
                
                %Access the value of the variable
                saveVar{k} = params.(fnsCurr);
            
            %If the variable is a numerical value    
            else            
                
                %Access the value of the variable
                saveVar(k) = params.(fnsCurr);   
                
            end
            
            %Update the counter
            k = k + 1;
            
        end
        
        %Access the fields in params by indexing and store in newParams
        newParams.(varName) = saveVar'; 
        
    end
    
    %Simply grab the scalar fields from params and save it in newParams
    for i = 1 : lenFnsZeros
        
        %Determine the name of the variable
        varName = fns{fnsZeros(i)};
        
        %Assign scalar fields in params to scalar fields in newParams
        newParams.(varName) = params.(varName); 
        
    end    
    
    %Assign newParams back to params
    params = newParams;    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%