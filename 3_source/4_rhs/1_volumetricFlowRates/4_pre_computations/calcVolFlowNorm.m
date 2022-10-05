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
%Code created on       : 2021/1/3/Sunday
%Code last modified on : 2022/8/24/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowNorm.m
%Source     : common
%Description: a function that calculates a constant volumetric flow rate at
%             the feed end of an adsorption column at a high pressure.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : volFlowNorm  - a constant volumetric flow rate for 
%                            normalizing the volumetric flow rates. For the 
%                            case when we sepcify a valve constant at the 
%                            feed end, we compute the feed volumetric flow 
%                            rate for the high pressure feed. For the case
%                            when we are specifying the product valve
%                            constant, specify a product volumetric flow 
%                            rate for the high pressure feed. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function volFlowNorm = calcVolFlowNorm(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'calcVolFlowNorm.m';
    
    %Unpack Params
    sStepCol    = params.sStepCol   ;   
    valFeedCol  = params.valFeedCol ;
    valProdCol  = params.valProdCol ;
    funcVal     = params.funcVal    ;
    funcEos     = params.funcEos    ;
    tempAmbi    = params.tempAmbi   ;
    presColHigh = params.presColHigh;
    presFeTa    = params.presFeTa   ;  
    presRaTa    = params.presRaTa   ;
    gasCons     = params.gasCons    ;
    numZero     = params.numZero    ;
    tempColNorm = params.tempColNorm;
    tempFeTa    = params.tempFeTa   ;
    gasConT     = params.gasConT    ;
    
    %Define scale factors for using valve equation in a dimensional form
    valScaleFac = 1000 ...
                * gasCons ...
                * tempAmbi;    
    
    %Define a test volume for computing a total concentration
    testVol = 1;
    %---------------------------------------------------------------------%    
    
    
                         
    %---------------------------------------------------------------------%
    %Find the information for high pressure feed step from the first
    %adsorption column (by default)
    
    %Compare the strings inside a string array that contains the names of
    %the steps in a given PSA cycle; Just look at the first column. We can
    %look for the feed entering from the feed-end and exiting either to the
    %raffinate tank or to the atmosphere. And also look for the feed
    %entering form the product end and exiting to the atmosphere.
    findHp1 = strcmp(sStepCol(1,:),"HP-FEE-RAF");
    findHp2 = strcmp(sStepCol(1,:),"HP-FEE-ATM");    
    findHp3 = strcmp(sStepCol(1,:),"HP-ATM-FEE");    

    %Add the indices
    findHp = findHp1 + findHp2 + findHp3;
    
    %Set the nonzero indices equal to ones
    findHp(1,findHp>0) = 1;
    
    %Find an index of the high pressure step; note that we are getting the
    %index for the first column
    findHp = find(findHp,1);
    
    %If there is no high pressure feed, we print the error message
    if isempty(findHp) == 1
        
        %Print out the message
        msg1 = 'We do not have a high pressure feed step ';
        msg2 = 'in the first adsorber.';
        msg = append(funcId,': ',msg1, msg2);
        error(msg);     
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Determine the valve constant associated with the high pressure feed in
    %"adsorption column 1"
    
    %logical statement for checking a valve-constant at the feed-end
    hasCvFeedEnd = sum(findHp1) ~= 0 || sum(findHp2) ~= 0;
    
    %logical statement for checking a valve-constant at the product-end
    hasCvProdEnd = sum(findHp3) ~= 0;
    
    %If we have a valve constant specified at the feed-end, 
    if hasCvFeedEnd
    
        %Calculate the dimensionless valve constant; note that the feed 
        %valve for the first column is always valve 1
        valConHp = valFeedCol(1,findHp) ...
                 * valScaleFac;
    
    %If we have a valve constant specified at the product-end,
    elseif hasCvProdEnd
        
        %Calculate the dimensionless valve constant; note that the feed 
        %valve for the first column is always valve 1
        valConHp = valProdCol(1,findHp) ...
                 * valScaleFac;
    
    %Otherwise, prompt the user to specify the valve constant correctly    
    else
        
        %Print out the message
        msg = 'Please provide a valve constant for high pressure feed.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate total concentrations downstream and upstream of the valve
    
    %If we have a valve constant at the feed-end, 
    if hasCvFeedEnd
    
        %Calculate moles in the void at upstream pressure (i.e. the feed
        %tank pressure)
        [~,~,~,voidMolUp] ...
            = funcEos(params,presFeTa,testVol,tempAmbi,0);

        %Calculate moles in the void at downstream pressure (i.e. the high
        %pressure in the void space of an adsorption column)
        [~,~,~,voidMolDo] ...
            = funcEos(params,presColHigh,testVol,tempAmbi,0);    
        
    %If we have a valve constant at the product-end,
    elseif hasCvProdEnd
    
        %Calculate moles in the void at upstream pressure (i.e. the initial
        %product tank pressure)
        voidMolUp = funcEos(params,presRaTa,testVol,tempAmbi,0);

        %Calculate moles in the void at downstream pressure (i.e. the high
        %pressure in the void space of an adsorption column)
        voidMolDo = funcEos(params,presColHigh,testVol,tempAmbi,0); 
        
        %Check for the difference in the total moles
        diffTotMol = (voidMolUp-voidMolDo);
        
        %If we have the difference smaller than our numerical zero value,
        %then,
        if abs(diffTotMol) <= numZero
                
            %Print warnings
            msg1 = 'Please provide product tank pressure less than ';
            msg2 = 'equal to the high pressure of an adsorption column.';
            msg = append(funcId,': ',msg1,msg2);
            error(msg);   
            
        end
        
    end
        
    %Calculate upstream total concentration
    gasConsTotUp = voidMolUp ...
                 / testVol;
    
    %Calculate downstream total concentration
    gasConsTotDo = voidMolDo ...
                 / testVol;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate necessary volumetric flow rates from valve constants and the
    %total concentrations below and above the valve
    
    %Calculate feed-end or product-end volumetric flow rate (we are using a 
    %dimensionless version of the function but getting dimensional values 
    %out)
    volFlowNorm = funcVal(valConHp, ...
                          gasConsTotDo/gasConT, ...
                          gasConsTotUp/gasConT, ...
                          tempFeTa/tempAmbi, ...
                          tempColNorm);         
    %---------------------------------------------------------------------%              
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%