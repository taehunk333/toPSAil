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
%Code created on       : 2022/6/6/Monday
%Code last modified on : 2022/6/6/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValOne2RaTa.m
%Source     : common
%Description: This is test function that builds a set of initial condition
%             vectors and compute the corresponding pseudo volumetric flow
%             rates by solving the proposed linear program in our work. We
%             note that the initial states has axiailly constant pressure
%             distribution with positive concentration and temperature
%             variables that are randomly generated.
%Inputs     : x            - a state solution row vector containing all the
%                            state variables associated with the current 
%                            step inside a given PSA cycle.
%             params       - a struct containing simulation parameters.
%Outputs    : flag         - 0 indices that a correct set of volumetric
%                            flow rate has been calculated. 1 means the set
%                            of calculated volumetric flow rates is
%                            incorrect, i.e., for some n, both positive and
%                            negative sudo volumetric flow rates are
%                            positive.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testLinProgExample(x,params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'testLinProgExample.m';      
    
    %Unpack params
    nCols    = params.nCols   ;
    nColSt   = params.nColSt  ;
    nColStT  = params.nColStT ;  
    nComs    = params.nComs   ;
    nStates  = params.nStates ;
    nVols    = params.nVols   ;
    nTemp    = params.nTemp   ;
    nStatesT = params.nStatesT;
    nS       = params.nS      ;
    sColNums = params.sColNums;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%                
    %Define key parameters not in params
    
    %Define the number of random states
    numRandPts = 100;
    
    %Define the center of the random number
    lowerBoundRandGasCon = 1  ;
    lowerBoundRandAdsCon = 1  ;  
    lowerBoundRandInTemp = 0.5  ;
    lowerBoundRandWaTemp = 0.5  ;   
    lowerBoundRandPres   = 0.1;
    
    %Define the spread of the random number
    spreadRandGasCon = 0.25;    
    spreadRandAdsCon = 0.25; 
    spreadRandInTemp = 1.00; 
    spreadRandWaTemp = 1.00; 
    spreadRandPres   = 0.25;
    
    %Define the rank 1 update of the state row vector
    stMat = repmat(x,numRandPts,1);
    
    %Should we have the constant axial pressure condition imposed?
    constAxPres = 0;
    %---------------------------------------------------------------------%                

 
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the random state matrix
    randStMat = ones(numRandPts,nColSt*nCols);  
    
    %Initialize the total concentration matrix
    gasConTotMat = zeros(numRandPts,nVols*nCols);
    
    %Initialize the flag
    flag = zeros(numRandPts,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Generate a random state matrix of a designated number of time points
    %from an old state vector
    
    %For each adsorber
    for i = 1 : nCols
        
        %Calculate the shift factor
        shiftFac  = nColStT*(i-1);
        shiftFac2 = nVols*(i-1)  ;
        
        %Get a random pressure for each row state vector
        randPres = rand(numRandPts,1) ...
                 * spreadRandPres ...
                 + lowerBoundRandPres;
             
        %Get a copy of the randPres matrix for the number of total gas
        %concentration variables
        randPres = repmat(randPres,1,nVols);
            
        %For each species 
        for k = 1 : nComs 

            %Perturb the adsorbed phase states
            randStMat(:,(shiftFac+nComs+k) ...
                     :nStates ...
                     :(shiftFac+(nVols-1)*nStates+nComs+k)) ...
                     = (rand(numRandPts,nVols) ...
                     * spreadRandAdsCon ...
                     + lowerBoundRandAdsCon) ...
                    .* stMat(:,(shiftFac+nComs+k) ...
                            :nStates ...
                            :(shiftFac+(nVols-1)*nStates+nComs+k)); 

            %Perturb the gas phase states
            randStMat(:,(shiftFac+k) ...
                     :nStates ...
                     :(shiftFac+(nVols-1)*nStates+k)) ...
                     = (rand(numRandPts,nVols) ...
                     * spreadRandGasCon ...
                     + lowerBoundRandGasCon) ...
                    .* stMat(:,(shiftFac+k) ...
                            :nStates ...
                            :(shiftFac+(nVols-1)*nStates+k));     

            %Calculate the sum of the concentration variables
            gasConTotMat(:,(shiftFac2+1:shiftFac2+nVols)) ...
                    = gasConTotMat(:,(shiftFac2+1:shiftFac2+nVols)) ...
                                  + randStMat(:,(shiftFac+k) ...
                                             :nStates ...
                                             :(shiftFac+(nVols-1) ...
                                             *nStates+k));

        end                            

        %If we would like to impose the constant axial pressure condition
        if constAxPres == 1
        
            %Obtain the interior CSTR temperature states to maintain the
            %constant pressure assumption
            randStMat(:,(shiftFac+2*nComs+1) ...
                     :nStates ...
                     :(shiftFac+nColSt-1)) ...
                     = randPres ...
                    ./ gasConTotMat; 
                
        %If we want to not maintain the constant pressure in the axial
        %direction
        elseif constAxPres == 0

        %Perturb the interior temperature states
        randStMat(:,(shiftFac+2*nComs+1) ...
                 :nStates ...
                 :(shiftFac+nColSt-1)) ...
                 = (rand(numRandPts,nVols) ...
                 * spreadRandInTemp ...
                 + lowerBoundRandInTemp) ...
                .* stMat(:,(shiftFac+2*nComs+1) ...
                        :nStates ...
                        :(shiftFac+nColSt-1));
                    
        end

        %Perturb the wall temperature states
        randStMat(:,(shiftFac+2*nComs+nTemp) ...
                 :nStates ...
                 :(shiftFac+nColSt)) ...
                 = (rand(numRandPts,nVols) ...
                 * spreadRandWaTemp ...
                 + lowerBoundRandWaTemp) ...
                .* stMat(:,(shiftFac+2*nComs+nTemp) ...
                        :nStates ...
                        :(shiftFac+nColSt)); 
        
    end
    
    %Augment randStMat with the rest of the state variables 
    randStMat = [randStMat,stMat(:,nColSt+1:nStatesT)];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the pseudo volumetric flow rates with corrected flow
    %directions
    
        %-----------------------------------------------------------------%
        %Unpack the states solutions

        %Grab the number of time points
        params.nRows = numRandPts;

        %Create an object for the columns
        units.col = makeColumns(params,randStMat);

        %Create an object for the feed tank
        units.feTa = makeFeedTank(params,randStMat);

        %Create an object for the raffinate product tank
        units.raTa = makeRaffTank(params,randStMat);

        %Create an object for the extract roduct tank
        units.exTa = makeExtrTank(params,randStMat);

        %Make the columns to interact
        units = makeCol2Interact(params,units,nS);
        %-----------------------------------------------------------------%

    %Calculate all the associated volumetric flow rates
    units = calcVolFlowsDP0DT1Test(params,units,nS);    
    
    %For each adsorption column
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%  
        %Unpack the pseudo volumetric flow rate matrices for ith column
        
        %Unpack the results from units.col  
        vFlPlusCol  = units.col.(sColNums{i}).volFlPlus ;
        vFlMinusCol = units.col.(sColNums{i}).volFlMinus;                
        %-----------------------------------------------------------------%  
        
        
        
        %-----------------------------------------------------------------%  
        %Check for the correctness of the calculated pseudo voluemtric flow
        %rates
        
        %For each state
        for j = 1 : numRandPts
            
            %Get the pseudo volumetric flow rates for a given state
            vFlPlusColSt  = vFlPlusCol(j,:) ;
            vFlMinusColSt = vFlMinusCol(j,:);
            
            %Determine if we have a positive pseudo volumetric flow rates
            vFlPlusPositive  = vFlPlusColSt>0;
            vFlMinusPositive = vFlMinusColSt>0;                      
            
            %Add the boolean vectors for the pseudo volumetric flow rates
            %to see if there had been a pair of pseudo voluemtric flow rate
            %that contains both positive pseudo voluemtric flow rates
            vFlPlusCheck = (vFlMinusPositive+vFlPlusPositive);
            
            %See if any of the entries are equal to 2
            vFlPlusCheck = length(find(vFlPlusCheck==2));
                                          
            %Get the number of negative entries in each matrix
            countNegPlus  ...
                = length(nonzeros(vFlPlusColSt(vFlPlusColSt<0)))  ;
            countNegMinus ...
                = length(nonzeros(vFlMinusColSt(vFlMinusColSt<0)));                       

            %When we have any negative pseudo volumetric flow rates, the 
            %solutions are incorrect
            if countNegPlus~=0 || ...
               countNegMinus~=0

                %Update the flag
                flag(j) = 1;

            %When we have both positive pseudo volumetric flow rates, i.e., 
            %one of the matrices isn't the zero matrix of the right 
            %dimension, the solutions are incorrect
            elseif vFlPlusCheck == 1
                
                %Update the flag
                flag(j) = 1;
                
            %Otherwise, the volumetric flow rates are correctly computed
            else

                %Update the flag
                flag(j) = 0;

            end
            
        end
        %-----------------------------------------------------------------% 
        
    end
    %---------------------------------------------------------------------%                                 
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%