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
%Code last modified on : 2022/8/8/Monday
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
    %funcId = 'getStringParams.m';
    
    %Unpack params
    nSteps     = params.nSteps    ;    
    nCols      = params.nCols     ;    
    nComs      = params.nComs     ;
    durStep    = params.durStep   ;
    eveVal     = params.eveVal    ;
    eveUnit    = params.eveUnit   ;
    eveLoc     = params.eveLoc    ;
    sStepCol   = params.sStepCol  ;
    sTypeCol   = params.sTypeCol  ;
    valFeedCol = params.valFeedCol;
    valProdCol = params.valProdCol;
    flowDirCol = params.flowDirCol;
    %---------------------------------------------------------------------%                                                        
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays   
    
    %Initialize a numeric array that stores the flow directions for all
    %columns, for all steps
    flowDir = zeros(nCols,nSteps);

    %Initialize a numeric array that stores the type of the DAE model,
    %i.e., time-varying pressure (1) vs. constant pressure (0)
    typeCol = zeros(nCols,nSteps);

    %Initialize cell arrays that stores differents
    sComNums = cell(nComs,1)     ; %a column vector (nComs x 1)
    sColNums = cell(nCols,1)     ; %a column vector (nComs x 1)
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
    %Unpack strings and store them as needed
    
    %Split the string variables
    durStep    = split(durStep)   ; %a row vector (1 x nSteps)
    eveVal     = split(eveVal)    ; %a row vector (1 x nSteps)    
    valFeedCol = split(valFeedCol); %a matrix (nCols x nSteps)
    valProdCol = split(valProdCol); %a matrix (nCols x nSteps)
    eveUnit    = split(eveUnit)'  ; %a row vector (1 x nSteps)
    eveLoc     = split(eveLoc)'   ; %a row vector (1 x nSteps)
    sStepCol   = split(sStepCol)  ; %a matrix (nCols x nSteps)
    sTypeCol   = split(sTypeCol)  ; %a matrix (nCols x nSteps)
    flowDirCol = split(flowDirCol); %a matrix (nCols x nSteps)
    
    %Convert the cell array containing the splitted strings into a
    %numerical array and store it as a row vector
    durStep    = str2double(durStep)'  ;
    eveVal     = str2double(eveVal)'   ;
    valFeedCol = str2double(valFeedCol); %a matrix (nCols x nSteps)
    valProdCol = str2double(valProdCol); %a matrix (nCols x nSteps)
      
    %For each columns,
    for i = 1 : nCols         
        
        %-----------------------------------------------------------------%
        %Get the ith column flow directions
                
        %Find the indices for the counter-currents
        indNegFlowDir = find(flowDirCol(i,:)=="1_(negative)");                
        
        %Save the flow directions
        flowDir(i,indNegFlowDir) = ones(1,length(indNegFlowDir));        
        %-----------------------------------------------------------------%       



        %-----------------------------------------------------------------%
        %Get the ith DAE model type
                
        %Find the indices for the counter-currents
        indDaeVarPres = find(sTypeCol(i,:)=="varying_pressure");                
        
        %Save the flow directions
        typeCol(i,indDaeVarPres) = ones(1,length(indDaeVarPres));        
        %-----------------------------------------------------------------% 
        
    end           
    %---------------------------------------------------------------------%                                   
    
    
    
    %---------------------------------------------------------------------%
    %Save function outputs 
    
    %Save the string results inside params
    params.sStepCol = sStepCol; 
    params.sComNums = sComNums;
    params.sColNums = sColNums;
    params.eveUnit  = eveUnit ;
    params.eveLoc   = eveLoc  ;
    
    %Save the numerical array results
    params.durStep    = durStep   ;
    params.eveVal     = eveVal    ;
    params.valFeedCol = valFeedCol;
    params.valProdCol = valProdCol;
    params.flowDirCol = flowDir   ;
    params.typeCol    = typeCol   ;
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Review the params and reorganize the data structure as needed

    %Remove any unused params
    params = rmfield(params,'sTypeCol');
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%