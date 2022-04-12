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
%Code created on       : 2021/1/7/Thursday
%Code last modified on : 2022/2/18/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getCycleOrg.m
%Source     : common
%Description: a function that defines parameters associated with cycle
%             organization of a specified PSA cycle.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getCycleOrg(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getCycleOrg.m';
    
    %Unpack Params
    nSteps      = params.nSteps     ;  
    sStep       = params.sStep      ;
    nCols       = params.nCols      ;
    nAdsVals    = params.nAdsVals   ;    
    valConNorm  = params.valConNorm ;
    maxEqColNum = params.maxEqColNum;
    valRinTop   = params.valRinTop  ;
    valRinBot   = params.valRinBot  ;
    valPurBot   = params.valPurBot  ;
    valRaTa     = params.valRaTa    ;
    valExTa     = params.valExTa    ;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Interaction matrix for the column interactions with product end
    %interactions
    colIntActTop = zeros(nCols,nSteps);                            
    
    %Interaction matrix for the column interactions with feed end
    %interactions
    colIntActBot = zeros(nCols,nSteps);                           
    
    %Interaction matrix for the column interactions with the raffinate 
    %product stream interactions; the stream will be diverted either to the
    %waste or to the product tank    
    colIntActRaff = zeros(nCols,nSteps);   
    
    %Interaction matrix for the column interactions with feed stream
    %interactions ; theres is only a single feed stream where we are 
    %introducing the feed into the PSA process network
    colIntActFeed = zeros(nCols,nSteps);   
    
    %Interaction matrix for the column interactions with extract product 
    %stream interactions; the stream will be diverted either to the
    %waste or to the product tank
    colIntActExtr = zeros(nCols,nSteps);        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Decide which DAE models to be used for a given step for all step: for
    %now, 0 = constant pressure DAE model, 1 = time varying pressure DAE
    %model
    
    %For each column, 
    for i = 1 : nCols
        
        %For each step,
        for j = 1 : nSteps
            
            %For re-pressurization, depressurization, equalization, and
            %rest, use time varying pressure DAE model
            if sStep{i,j}=="RP" || ...
               sStep{i,j}=="DP" || ...
               sStep{i,j}=="EQ" || ...
               sStep{i,j}=="RT"
                
                %Assign the DAE model
                params.daeModel(i,j) = 1;       
  
            %For high pressure feed, low pressure purge, and rinse, use a
            %constant pressure DAE model
            elseif sStep{i,j}=="HP" || ...
                   sStep{i,j}=="LP" || ...
                   sStep{i,j}=="RN"
                
                %Assign the DAE model
                params.daeModel(i,j) = 0;
                
            end
            
        end
        
    end
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%           
    %Find out if there are any interactions between columns
            
    %For a given step,         
    for i = 1 : nSteps

        %-----------------------------------------------------------------%
        %Check for columns that do/do not have interactions through 
        %product-end equalization

        %For each column, we will put an index of the other that column
        %it is interacting with for a given step

        %We are interested in valve 3
        valNo = 3;

        %Get the valve 3 values for all columns
        valNoThr = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);

        %Find all the columns with valve 3 not closed (i.e., interacting)
        indVal3YeInt = find(valNoThr~=0);

        %Update the top column interaction matrix: assign numeric values 
        %(flipped) for each pair of two columns for their interactions
        for j = 1 : maxEqColNum : length(indVal3YeInt)

            %Grab the jth pair of indices
            indPair = indVal3YeInt(j:j+1);                                

            %Flip them and store them
            colIntActTop(indPair,i) = flip(indPair);      

        end                        
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Check for columns that do/do not have interactions through 
        %feed-end equalization

        %For each column, we will put an index of the other that column
        %it is interacting with for a given step

        %We are interested in valve 4
        valNo = 4;

        %Get the valve 4 values for all columns
        valNoFou = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);

        %Find all the columns with valve 4 not closed (i.e.
        %interacting)
        indVal4YeInt = find(valNoFou~=0);

        %Update the bottom column interaction matrix: assign numeric
        %values (flipped) for each pair of two columns for their
        %interactions
        for j = 1 : maxEqColNum : length(indVal4YeInt)

            %Grab the jth pair of indices
            indPair = indVal4YeInt(j:j+1);                                

            %Flip them and store them
            colIntActBot(indPair,i) = flip(indPair);      

        end      
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Check for columns that do/do not have interactions with the
        %raffinate product tank

        %We check to see if valve 1, 2, 5 are all closed for a given 
        %column. If one of them is open, this indicates that there is an 
        %interaction with the product tank. 

        %We are interested in valve 1
        valNo = 1;

        %Get the valve 1 values for all columns
        valNoOne = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);
        
        %We are interested in valve 5
        valNo = 5;

        %Get the valve 5 values for all columns
        valNoFiv = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);   
        
        %We are interested in valve 2
        valNo = 2;

        %Get the valve 2 values for all columns
        valNoTwo = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);

        %Update the raffinate product tank interaction matrix: assign ones 
        %for the columns interacting with the raffinate product tank
        %through valve 1
        if valPurBot(i) == 0
            
            %The raffinate tank interacts with the column through valve 1
            colIntActRaff(valNoOne~=0,i) = 1*valRaTa(i);                                                   

        %Update the raffinate product tank interaction matrix: assign ones 
        %for the columns interacting with the raffinate product tank
        %through valve 2. valPurBot(i) == 1 means we are doing a co-current 
        %purge with the raffinate product. valPurBot(i) == 0 means we are
        %doing a co-current feed from the feed tank.
        elseif valPurBot(i) == 1
            
            %The raffinate tank interacts with the column through valve 2
            colIntActRaff(valNoTwo~=0,i) = 2*valPurBot(i);
            
        %Update the raffinate product tank interaction matrix: assign ones 
        %for the columns interacting with the raffinate product tank
        %through valve 5      
        elseif valRinTop(i) == 0
            
            %The raffinate tank interacts with the column through valve 5
            colIntActRaff(valNoFiv~=0,i) = 5;
            
        end
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Check for columns that do/do not have interactions with the
        %feed tank            

        %We check to see if valve 2 is closed for a given column. If valve 
        %2 is open, this indicates there is an interaction either with the
        %feed tank or the raffinate product tank or the extract produc
        %tank.

        %Update the feed tank interaction matrix as well as the extract 
        %product tank interaction matrix: assign twos for the columns 
        %interacting with the feed tank or extract product tank through 
        %valve 2
        colIntActFeed(valNoTwo~=0,i) = 2*(1-valRinBot(i));
        colIntActExtr(valNoTwo~=0,i) = 2*valRinBot(i)    ;
        
        %We also check to see if valve 5 is closed for a given column. If 
        %valve 5 is open, this indicates there is an interaction either 
        %with the raffinate product tank or the extract product tank.

        %Update the feed tank interaction matrix as well as the extract 
        %product tank interaction matrix: assign twos for the columns 
        %interacting with the feed tank or extract product tank through 
        %valve 5
        colIntActRaff(valNoFiv~=0,i) = 5*(1-valRinTop(i));
        colIntActExtr(valNoFiv~=0,i) = 5*valRinTop(i)    ;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Check for columns that do/do not have interactions with the
        %extract stream

        %We check to see if valve 6 is closed for a given column. If 
        %one of them is open, this indicates there can be an interaction
        %with the feed stream

        %We are interested in valve 6
        valNo = 6;

        %Get the valve 6 values for all columns
        valNoSix = valConNorm(valNo:nAdsVals:nAdsVals*(nCols-1)+valNo,i);                                   

        %Update the extract stream interaction matrix: assign zeros for the
        %columns without any interactions with extract stream
        colIntActExtr(valNoSix~=0,i) = 6*valExTa(i);                                                   
        %-----------------------------------------------------------------%

    end                
    %---------------------------------------------------------------------%                                                                                 

    
    
    %---------------------------------------------------------------------%
    %Save the results into a struct named params

    %Store the information on interaction
    params.colIntActTop   = colIntActTop ; %filled with column numbers
    params.colIntActBot   = colIntActBot ; %filled with column numbers
    params.colIntActRaff  = colIntActRaff; %filled with valve numbers
    params.colIntActFeed  = colIntActFeed; %filled with valve numbers
    params.colIntActExtr  = colIntActExtr; %filled with valve numbers
    
    %Transform into boolean matrix
    colIntActRaff(colIntActRaff~=0) = 1;
    colIntActFeed(colIntActFeed~=0) = 1;
    colIntActExtr(colIntActExtr~=0) = 1;
    
    %Store additional information for interaction
    params.colIntActRaffB = colIntActRaff;
    params.colIntActFeedB = colIntActFeed;
    params.colIntActExtrB = colIntActExtr;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%