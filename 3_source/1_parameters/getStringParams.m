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
    if params.bool(13) == 1
    nFeTas     = params.nFeTas    ;
    feTaSeq    = params.feTaSeq   ;
    else
        nFeTas = 1;
        feTaSeq = ['0 0'];
    end
    %---------------------------------------------------------------------%                                                        
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays   
    
    %Initialize a numeric array that stores the flow directions for all
    %columns, for all steps
    flowDir = zeros(nCols,nSteps);

    %Initialize a numeric array that stores the type of the DAE model,
    %i.e., time-varying pressure (1) vs. constant pressure (0)
    typeDaeModel = zeros(nCols,nSteps);

    %Initialize cell arrays that stores differents
    sComNums = cell(nComs,1); %a column vector (nComs x 1)
    sColNums = cell(nCols,1); %a column vector (nComs x 1)
    sFeTaNums = cell(nFeTas,1);
    
    %Initialie cell array for the equalization between adsorption columns
    numAdsEqPrEnd = zeros(nCols,nSteps);
    numAdsEqFeEnd = zeros(nCols,nSteps);
    %---------------------------------------------------------------------%    
        
    
    
    %---------------------------------------------------------------------%    
    %Define strings for accessing elements inside a nested structure
    
    %Define a vector containing each component in a stream
    comSpace = linspace(1,nComs,nComs)';
    
    %Define a vector containing each columns in the system
    colSpace = linspace(1,nCols,nCols)';

    %Define a vector containing each feed tanks in the system
    feTaSpace = linspace(1,nFeTas,nFeTas)';
    
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

    %For each feed tank,
    for i = 1 : nFeTas

        %Assign the feed tank number name for an ith component
        sFeTaNums{i} = append('n',int2str(feTaSpace(i)));

    end
    %---------------------------------------------------------------------%   
    
        
    
    %---------------------------------------------------------------------%
    %Unpack strings and store them as needed
    
    %Split the string variables
    durStep    = split(durStep,' ', 2)   ; %a row vector (1 x nSteps)
    eveVal     = split(eveVal,' ', 2)    ; %a row vector (1 x nSteps)    
    valFeedCol = split(valFeedCol,' ', 2); %a matrix (nCols x nSteps)
    valProdCol = split(valProdCol,' ', 2); %a matrix (nCols x nSteps)
    eveUnit    = split(eveUnit,' ', 2)   ; %a row vector (1 x nSteps)
    eveLoc     = split(eveLoc,' ', 2)    ; %a row vector (1 x nSteps)
    sStepCol   = split(sStepCol,' ', 2)  ; %a matrix (nCols x nSteps)
    sTypeCol   = split(sTypeCol,' ', 2)  ; %a matrix (nCols x nSteps)
    flowDirCol = split(flowDirCol,' ', 2); %a matrix (nCols x nSteps)
    feTaSeq    = split(feTaSeq,' ',2)    ;
    
    %Convert the cell array containing the splitted strings into a
    %numerical array and store it as a row vector
    durStep    = str2double(durStep)   ;
    eveVal     = str2double(eveVal)    ;
    valFeedCol = str2double(valFeedCol); %a matrix (nCols x nSteps)
    valProdCol = str2double(valProdCol); %a matrix (nCols x nSteps)
    feTaSeq    = str2double(feTaSeq)   ;
    %---------------------------------------------------------------------%                                   
        
    
    
    %---------------------------------------------------------------------%                                   
    %Obtain numerical values for the specific information for the PSA
    %cycle for all columns and for all steps, including the flow
    %directions, the types of DAE models used, and the equalizing adsorber
    %pairs
    
    %For each columns,
    for i = 1 : nCols         
        
        %-----------------------------------------------------------------%
        %Get the ith column flow directions for the regular steps
                
        %Get the current flow directions for the adsorbers
        flowDirColCurr = flowDirCol(i,:);                
        
        %Find the indices for the counter-currents
        indNegFlowDir = find(flowDirColCurr=="1_(negative)");                
        
        %Save the flow directions
        flowDir(i,indNegFlowDir) = ones(1,length(indNegFlowDir)); 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Get the column flow directions for the equalization steps                        
        
        %Get the current steps for the adsorbers
        sStepColCurr = sStepCol(i,:);
        
        %Find the indices for the equalizations
        indEqFlowDir = find(flowDirColCurr=="TBD");
                        
        %Get the number of equalization steps for the adsorber
        numEqStep = length(indEqFlowDir);
        
        %Only when there are equalization steps, 
        if numEqStep > 0
        
            %For each equalization step
            for j = 1 : numEqStep
                
                %Get the current index for the flow direction for the
                %equalization
                indEqFlowDirCurr = indEqFlowDir(j);
                
                %Check on which end the equalization is happening
                eqAtPrdEnd ...
                    = contains(sStepColCurr{indEqFlowDirCurr},'APR');
                
                %Grab the next index
                indEqFlowDirPlusOne ...
                    = round(indEqFlowDirCurr+1,nSteps);

                %Check if the next step is repressurization or high
                %pressure feed
                eqNextStepRepr ...
                    = contains(sStepColCurr{indEqFlowDirPlusOne},'RP') ...
                    || contains(sStepColCurr{indEqFlowDirPlusOne},'HP');               

                %When the equalization is happening at the product end
                if eqAtPrdEnd == 1
                    
                    %If repressurizing, then
                    if eqNextStepRepr == 1
                       
                        %Set the flow direction to be countercurrent
                        flowDir(i,indEqFlowDirCurr) = 1;
                        
                    %Otherwise, we are depressurizing
                    else
                        
                        %Nothing to do
                        
                    end
                    
                %When the equalization is heppening at the feed end
                else
                                        
                    %If repressurizing, then
                    if eqNextStepRepr == 1
                       
                        %nothing to do
                        
                    %Otherwise, we are depressurizing
                    else
                        
                        %Set the flow direction to be countercurrent
                        flowDir(i,indEqFlowDirCurr) = 1;
                        
                    end                                        
                    
                end

            end
            
        end
        %-----------------------------------------------------------------%       



        %-----------------------------------------------------------------%
        %Get the ith DAE model type
                
        %Find the indices for the counter-currents
        indDaeVarPres = find(sTypeCol(i,:)=="varying_pressure");                
        
        %Save the flow directions
        typeDaeModel(i,indDaeVarPres) = ones(1,length(indDaeVarPres));        
        %-----------------------------------------------------------------% 
        
    end           
    
    %For each row,
    for i = 1 : nSteps
    
        %-----------------------------------------------------------------%
        %Grab information in each adsorber, specific to the current step
        
        %Grab the ith column of the matrix containing the step names
        %involved in a PSA cycle
        ithColName = sStepCol(:,i);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Obtain the equalization information in the product-end
        
        %Check for any equalization steps happening at the product-end
        eqPrEndInfo = strcmp(ithColName,'EQ-XXX-APR');
        
        %Relate the equalizing columns to their numbers
        eqPrEndInfo = eqPrEndInfo.*linspace(1,nCols,nCols)';
        
        %Remove zeros from the equalizing vector
        eqPrEndInfo = nonzeros(eqPrEndInfo);
        
        %Grab the length of the vector
        numPrEndEqAds = length(eqPrEndInfo);
        
        %If the vector is empty, 
        if numPrEndEqAds == 0
            
            %There are no equalizing steps
            numAdsEqPrEnd(:,i) = 0;
            
        %If we have an odd number of equalizing steps
        elseif rem(numPrEndEqAds,2) ~= 0
            
            %Throw out an error and ask the user to supply an even number
            %of equalizing steps
            msg1 = 'Please provide an even number of equalizing steps '; 
            msg2 = 'for a given PSA cycle';
            msg = append(funcId,': ', msg1,msg2);
            error(msg);
           
        %Otherwise we have an even number of equalizing steps
        else 
            
            %For each pair, swap their indices and save it into another
            %vector
            for j = 1 : numPrEndEqAds/2
                
                %Get the indices
                IndFirst  = eqPrEndInfo(2*(j-1)+1);
                IndSecond = eqPrEndInfo(2*j)      ;
                
                %Update the adsorption column numbers to indicate the
                %equalization going on at the product-end
                numAdsEqPrEnd(IndFirst,i)  = IndSecond;
                numAdsEqPrEnd(IndSecond,i) = IndFirst ;
                
            end
            
        end        
        %-----------------------------------------------------------------%
        
       
        
        %-----------------------------------------------------------------%
        %Obtain the equalization information in the feed-end
        
        %Check for any equalization steps happening at the feed-end
        eqFeEndInfo = strcmp(ithColName,'EQ-AFE-XXX');
        
        %Relate the equalizing columns to their numbers
        eqFeEndInfo = eqFeEndInfo.*linspace(1,nCols,nCols)';
        
        %Remove zeros from the equalizing vector
        eqFeEndInfo = nonzeros(eqFeEndInfo); 
        
        %Grab the length of the vector
        numFeEndEqAds = length(eqFeEndInfo);
        
        %If the vector is empty, 
        if numFeEndEqAds == 0
            
            %There are no equalizing steps
            numAdsEqFeEnd(:,i) = 0;
            
        %If we have an odd number of equalizing steps
        elseif rem(numFeEndEqAds,2) ~= 0
            
            %Throw out an error and ask the user to supply an even number
            %of equalizing steps
            msg1 = 'Please provide an even number of equalizing steps '; 
            msg2 = 'for a given PSA cycle';
            msg = append(funcId,': ', msg1,msg2);
            error(msg);
           
        %Otherwise we have an even number of equalizing steps
        else 
            
            %For each pair, swap their indices and save it into another
            %vector
            for j = 1 : numFeEndEqAds/2
                
                %Get the indices
                IndFirst  = eqFeEndInfo(2*(j-1)+1);
                IndSecond = eqFeEndInfo(2*j)      ;
                
                %Update the adsorption column numbers to indicate the
                %equalization going on at the product-end
                numAdsEqFeEnd(IndFirst,i)  = IndSecond;
                numAdsEqFeEnd(IndSecond,i) = IndFirst ;
                
            end
            
        end 
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
    params.sFeTaNums = sFeTaNums;
    
    %Save the numerical array results
    params.durStep       = durStep      ;
    params.eveVal        = eveVal       ;
    params.valFeedCol    = valFeedCol   ;
    params.valProdCol    = valProdCol   ;
    params.flowDirCol    = flowDir      ;
    params.typeDaeModel  = typeDaeModel ;
    params.numAdsEqPrEnd = numAdsEqPrEnd;
    params.numAdsEqFeEnd = numAdsEqFeEnd;
    params.feTaSeq       = feTaSeq      ;
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