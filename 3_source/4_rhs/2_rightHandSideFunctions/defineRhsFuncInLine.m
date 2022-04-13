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
%Code created on       : 2022/3/14/Monday
%Code last modified on : 2022/3/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : defineRhsFuncInLine.m
%Source     : common
%Description: a function that defines the right hand side functions for all
%             steps involved inside a given PSA simulation. This function
%             is inlined to enhance the computational efficiency.
%Inputs     : t            - a scalar value of a current time point 
%             y            - a state solution row vector containing all
%                            the state variables associated with the
%                            current step inside a given PSA cycle.
%             params       - a struct containing simulation parameters.
%Outputs    : yDot         - evaluated values for the right hand side 
%                            function for a given step inside a PSA cycle.
%                            This is a column vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yDot = defineRhsFuncInLine(~,y,params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'defineRhsFuncInLine.m';    
    
    %Unpack params              
    funcVol       = params.funcVol      ;  
    nS            = params.nS           ;
    nCy           = params.nCy          ;   
    nStatesT      = params.nStatesT     ;
    nColStT       = params.nColStT      ;
    nSt           = params.nStates      ;   
    inShFeTa      = params.inShFeTa     ;
    nFeTaStT      = params.nFeTaStT     ;
    inShRaTa      = params.inShRaTa     ;
    nRaTaStT      = params.nRaTaStT     ;
    inShExTa      = params.inShExTa     ;
    nExTaStT      = params.nExTaStT     ;
    nColSt        = params.nColSt       ;
    sCols         = params.sColNums     ;
    sComs         = params.sComNums     ;
    inShComp      = params.inShComp     ;
    inShVac       = params.inShVac      ;
    nVols         = params.nVols        ;
    nCols         = params.nCols        ;
    nComs         = params.nComs        ;
    flowDir       = params.flowDir      ;
    partCoefHp    = params.partCoefHp   ;
    cstrHt        = params.cstrHt       ;    
    sColNums      = params.sColNums     ;
    sComNums      = params.sComNums     ;
    bool          = params.bool         ;
    nRows         = params.nRows        ; 
    colIntActFeed = params.colIntActFeed;
    yFeC          = params.yFeC         ;
    tankScaleFac  = params.tankScaleFac ;
    pRatFe        = params.pRatFe       ; 
    colIntActRaff = params.colIntActRaff;
    valRaTa       = params.valRaTa      ;
    valPurBot     = params.valPurBot    ;
    colIntActExtr = params.colIntActExtr;
    valExTa       = params.valExTa      ;
    valRinTop     = params.valRinTop    ;
    valRinBot     = params.valRinBot    ;
    gamma         = params.htCapRatioFe ;    
    enScaleFac    = params.enScaleFac   ;    
    pRatAmb       = params.pRatAmb      ;
    pRat          = params.pRat         ;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %Check function inputs
      
    %Convert the states to a row vector
    y = y(:).';
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each columns and tanks    
    
    %Create an object for the columns
    col = makeColumns(params,y);
    
    %Create an object for the feed tanks
    feTa = makeFeedTank(params,y);
    
    %Create an object for the raffinate product tanks
    raTa = makeRaffTank(params,y);  
    
    %Create an object for the extract product tanks
    exTa = makeExtrTank(params,y);  
    
    %Update col by including interaction between units down or upstream
    col = makeCol2Interact(params,col,feTa,raTa,exTa,nS);
    %---------------------------------------------------------------------%                      
    
    
    
    %---------------------------------------------------------------------%
    %Calculate associated volumetric flow rates for the currently
    %interacting units in the flow sheet
    
    %Based on the volumetric flow function handle, obtain the corresponding
    %volumetric flow rates associated with the adsorption columns
    [col,feTa,raTa,exTa,raWa,exWa] = ...
        funcVol(params,col,feTa,raTa,exTa,nS,nCy);
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %For the adsorption columns, evaluate the time derivatives of the state
    %variables based on the conservation laws including mole and energy 
    %balance equations

        %-----------------------------------------------------------------%    
        %Do the species mole balance

        %For each column i,
        for i = 1 : nCols

            %-------------------------------------------------------------%    
            %For each species j,
            for j = 1 : nComs                                

                %---------------------------------------------------------%    
                %Do the mole balance for a counter-current flow 

                %For counter-current case,               
                if flowDir(i,nS) == 1

                    %-----------------------------------------------------%
                    %Do the mole balance

                    %Get the concentration of species at the product-end of 
                    %the adsorber
                    gasConSpePrEnd ...
                        = col.(sColNums{i}).prEnd.gasCons.(sComNums{j});                                                     

                    %Get the convective flow in terms
                    flowIn = col.(sColNums{i}). ...
                             gasCons.(sComNums{j})(:,1:nVols) ...
                          .* col.(sColNums{i}).volFlRat(:,1:nVols) ...
                          ./ cstrHt;  

                    %Get the convective flow out terms
                    flowOut = [col.(sColNums{i}). ...
                              gasCons.(sComNums{j})(:,2:nVols), ...
                              gasConSpePrEnd] ...
                           .* col.(sColNums{i}).volFlRat(:,2:nVols+1) ...
                           ./ cstrHt;

                    %Get the rate terms
                    adsorption = partCoefHp ...
                               * col.(sColNums{i}).adsRat.(sComNums{j});

                    %Do the mole balance on the ith column
                    col.(sColNums{i}).moleBal.(sComNums{j}) = flowIn ...
                                                            - flowOut ...
                                                            - adsorption;  
                    %-----------------------------------------------------%

                %---------------------------------------------------------%    



                %---------------------------------------------------------%    
                %Do the mole balance for a co-current flow 

                %For a co-current case,
                elseif flowDir(i,nS) == 0

                    %-----------------------------------------------------%
                    %Do the mole balance

                    %Get the concentration of species at the feed-end of 
                    %the adsorber
                    gasConSpeFeEnd ...
                        = col.(sColNums{i}).feEnd.gasCons.(sComNums{j});

                    %Get the convective flow in terms
                    flowIn = [gasConSpeFeEnd, ...
                             col.(sColNums{i}).gasCons. ...
                             (sComNums{j})(:,1:nVols-1)] ...
                          .* col.(sColNums{i}).volFlRat(:,1:nVols) ...
                          ./ cstrHt;

                    %Get the convective flow out terms
                    flowOut = col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,1:nVols) ...
                           .* col.(sColNums{i}).volFlRat(:,2:nVols+1) ...
                           ./ cstrHt;

                    %Get the rate terms
                    adsorption = partCoefHp ...
                               * col.(sColNums{i}).adsRat.(sComNums{j});

                    %Do the mole balance on the ith column
                    col.(sColNums{i}).moleBal.(sComNums{j}) = flowIn ...
                                                            - flowOut ...
                                                            - adsorption;
                    %-----------------------------------------------------%

                end 
                %---------------------------------------------------------%    

            end
            %-------------------------------------------------------------%    

        end   
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Do the energy balance
        
        %If isothermal model
        if bool(5) == 0
            
            %-------------------------------------------------------------%
            %For each adsorption column,
            for i = 1 : nCols

                %Don't do the energy balance on the columns
                col.(sColNums{i}).cstrEnBal = zeros(1,nVols);            
                col.(sColNums{i}).wallEnBal = zeros(1,nVols);  

            end
            %-------------------------------------------------------------%
            
        %For non-isothermal simulation    
        else
            
            %-------------------------------------------------------------%
            %Define known quantities

            %Unpack additional params                  
            intHtTrFacCol = params.intHtTrFacCol;
            extHtTrFacCol = params.extHtTrFacCol;     
            isoStHtNorm   = params.isoStHtNorm  ;
            gConsNormCol  = params.gConsNormCol ;
            ambTempNorm   = params.ambTempNorm  ;
            htCapCpNorm   = params.htCapCpNorm  ;    
            %-------------------------------------------------------------%              



            %-------------------------------------------------------------%
            %Do the CSTR wall energy balance for all CSTRs for all columns

            %For each column, 
            for i = 1 : nCols

                %---------------------------------------------------------%    
                %Compute the interior heat transfer rates
                dQndt = col.(sColNums{i}).temps.wall ...
                      - col.(sColNums{i}).temps.cstr;

                %Compute the exterior heat transfer rates
                dQnwdt = ambTempNorm*ones(1,nVols) ...
                       - col.(sColNums{i}).temps.wall;    

                %Save the column wall energy balance into the struct
                col.(sColNums{i}).wallEnBal = extHtTrFacCol*dQnwdt ...
                                            - intHtTrFacCol*dQndt;
                %---------------------------------------------------------% 



                %---------------------------------------------------------% 
                %Initialize the right hand side of dimensionless energy 
                %balance
                
                %Save the heat transfer rate to the column wall from CSTR 
                %in the right hand side of the dTn/dt
                col.(sColNums{i}).cstrEnBal = dQndt;              
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Compute the convective flow contribution to the energy
                %balance, depending on the flow direction

                %If we have a co-current flow
                if flowDir(i,nS) == 0

                    %-----------------------------------------------------%
                    %Unpack states

                    %Unpack the total concentration variables  

                    %We have the down stream total concentration of the 
                    %column to be equal to the total concentration in the 
                    %first CSTR
                    cnm1 = [col.(sColNums{i}).gasConsTot(:,1), ...
                            col.(sColNums{i}).gasConsTot(:,1:nVols-1)];                                  
                    cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols)    ;

                    %Unpack the volumetric flow rates
                    vnm1 = col.(sColNums{i}).volFlRat(:,1:nVols)  ;                
                    vnm0 = col.(sColNums{i}).volFlRat(:,2:nVols+1);

                    %Unpack the interior temperature variables
                    Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                            col.(sColNums{i}).temps.cstr(:,1:nVols-1)];
                    Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols)    ;                

                    %Unpack the overall heat capacity                
                    htCOnm0 = col.n1.htCO(:,1:nVols);                                                               
                    %-----------------------------------------------------%



                    %-----------------------------------------------------%
                    %Calcualte the terms in the energy balance equation

                    %Calcualte the vectorized terms
                    presDeltaEner = gConsNormCol ...
                                 .* Tnm0 ...
                                 .* (cnm1.*vnm1 ...
                                    -cnm0.*vnm0);

                    %Initialize the non-vectorized terms
                    adsHeatEner  = zeros(nRows,nVols);
                    convFlowEner = zeros(nRows,nVols);

                    %For each species,
                    for j = 1 : nComs

                        %Update the second summation
                        adsHeatEner ...
                            = adsHeatEner ...
                            + (isoStHtNorm(j)-Tnm0) ...
                           .* col.(sColNums{i}).adsRat.(sComNums{j});                

                        %Update the third summation
                        convFlowEner ...
                            = convFlowEner ...
                            + htCapCpNorm(j) ...
                           .* [col.(sColNums{i}).feEnd. ...
                              gasCons.(sComNums{j}), ...
                              col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,1:nVols-1)];    

                    end

                    %Take account for the pre-factors
                    adsHeatEner = partCoefHp ...
                               .* gConsNormCol ...
                               .* cstrHt ...
                               .* adsHeatEner;
                    convFlowEner = gConsNormCol ...
                                .* vnm1.*(Tnm1-Tnm0) ...
                                .* convFlowEner;
                    %-----------------------------------------------------%



                    %-----------------------------------------------------%    
                    %Update the existing field value

                    %Update the energy balance on all the CSTRs associated
                    %with ith adsorption column
                    col.(sColNums{i}).cstrEnBal ... 
                        = (col.(sColNums{i}).cstrEnBal ...
                          +presDeltaEner ...
                          +adsHeatEner ...
                          +convFlowEner) ...
                       ./ htCOnm0;                       
                    %-----------------------------------------------------%        

                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %If we have a counter-current flow           
                elseif flowDir(i,nS) == 1

                    %-----------------------------------------------------%
                    %Unpack states

                    %Unpack the total concentration variables  

                    %We have the up stream total concentration of the 
                    %column to be equal to the total concentration in the 
                    %last CSTR                                             
                    cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols) ;
                    cnp1 = [col.(sColNums{i}).gasConsTot(:,2:nVols), ...
                            col.(sColNums{i}).gasConsTot(:,nVols)] ; 

                    %Unpack the volumetric flow rates
                    vnm1 = col.(sColNums{i}).volFlRat(:,1:nVols)  ;                
                    vnm0 = col.(sColNums{i}).volFlRat(:,2:nVols+1);

                    %Unpack the interior temperature variables            
                    Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols) ;                
                    Tnp1 = [col.(sColNums{i}).temps.cstr(:,2:nVols), ...
                            col.(sColNums{i}).prEnd.temps]         ;

                    %Unpack the overall heat capacity                
                    htCOnm0 = col.n1.htCO(:,1:nVols);                                                               
                    %-----------------------------------------------------%



                    %-----------------------------------------------------%
                    %Calcualte the terms in the energy balance equation

                    %Calcualte the vectorized terms
                    presDeltaEner ...
                        = gConsNormCol ...
                       .* Tnm0.*(cnm0.*vnm1-cnp1.*vnm0);

                    %Initialize the non-vectorized terms
                    adsHeatEner = zeros(nRows,nVols);
                    convFlowEner = zeros(nRows,nVols);

                    %For each species,
                    for j = 1 : nComs

                        %Update the second summation
                        adsHeatEner ...
                            = adsHeatEner ...
                            + (isoStHtNorm(j)-Tnm0) ...
                           .* col.(sColNums{i}).adsRat.(sComNums{j});                

                        %Update the third summation
                        convFlowEner ...
                            = convFlowEner ...
                            + htCapCpNorm(j) ...
                           .* [col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,2:nVols), ...
                              col.(sColNums{i}).prEnd. ...
                              gasCons.(sComNums{j})];      

                    end

                    %Take account for the pre-factors
                    adsHeatEner = partCoefHp ...
                               .* gConsNormCol ...
                               .* cstrHt ...
                               .* adsHeatEner;
                    convFlowEner = gConsNormCol ...
                                .* vnm0.*(Tnm0-Tnp1) ...
                                .* convFlowEner;
                    %-----------------------------------------------------%



                    %-----------------------------------------------------%    
                    %Update the existing field value

                    %Update the energy balance on all the CSTRs associated
                    %with ith adsorption column
                    col.(sColNums{i}).cstrEnBal ... 
                        = (col.(sColNums{i}).cstrEnBal ...
                          +presDeltaEner ...
                          +adsHeatEner ...
                          +convFlowEner) ...
                       ./ htCOnm0;   
                    %-----------------------------------------------------%

                end
                %---------------------------------------------------------%                

            end                              
            %-------------------------------------------------------------%

        end    
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Do the cumulative mole balance

        %For each column,
        for i = 1 : nCols              

            %-------------------------------------------------------------%               
            %For each component
            for j = 1 : nComs                

                %---------------------------------------------------------%               
                %If the flow direction is a counter-current in ith column
                if flowDir(i,nS) == 1                               

                    %-----------------------------------------------------%
                    %Get the concentration of species at the product-end of
                    %the adsorber
                    gasConSpePrEnd ...
                        = col.(sColNums{i}).prEnd.gasCons.(sComNums{j});

                    %Assign the volumetric flow rate flowing into the 
                    %adsorption column from the extract product tank
                    volFlRatPrEnd ...
                        = col.(sColNums{i}).volFlRat(:,end); 

                    %Assign the right hand side for the cumulative moles
                    %flowing into the adsorption column from the 
                    %product-end
                    col.(sColNums{i}).cumMolBal.prod.(sComNums{j}) ...
                            = gasConSpePrEnd ...
                            * volFlRatPrEnd;                

                    %Assign the right hand side for the cumulative moles
                    %flowing out of the adsorption column from the column 
                    %at the feed-end
                    col.(sColNums{i}).cumMolBal.feed.(sComNums{j}) ...
                        = col.(sColNums{i}).gasCons.(sComNums{j})(:,1) ...
                        * col.(sColNums{i}).volFlRat(:,1);                          
                    %-----------------------------------------------------%

                %---------------------------------------------------------%



                %---------------------------------------------------------%               
                %If the flow direction is a co-current in ith column
                elseif flowDir(i,nS) == 0

                    %Get the concentration of species at the feed-end of
                    %the adsorber
                    gasConSpeFeEnd ...
                        = col.(sColNums{i}).feEnd.gasCons.(sComNums{j});

                    %Assign the volumetric flow rate flowing into the 
                    %adsorption column from the extract product tank
                    volFlRatFeEnd ...
                        = col.(sColNums{i}).volFlRat(:,1);                                

                    %Assign the right hand side for the cumulative moles
                    %flowing into the adosorption column at the feed-end
                    col.(sColNums{i}).cumMolBal.feed.(sComNums{j}) ...
                            = gasConSpeFeEnd ...
                            * volFlRatFeEnd;

                    %Assign the right hand side for the cumulative moles 
                    %flowing out from the adsorption column into the 
                    %raffinate product tank or to the raffinate waste 
                    %stream at the product-end
                    col.(sColNums{i}).cumMolBal.prod.(sComNums{j}) ...
                        = col.(sColNums{i}).gasCons. ...
                          (sComNums{j})(:,end) ...
                        * col.(sColNums{i}).volFlRat(:,end);    

                end            
                %---------------------------------------------------------%               

            end 
            %-------------------------------------------------------------%               

        end                    
        %-----------------------------------------------------------------%
        
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %For the feed tank, evaluate the time derivatives of the state
    %variables based on the conservation laws including mole and energy 
    %balance equations
        
        %-----------------------------------------------------------------%
        %Do the species mole balance
               
            %-------------------------------------------------------------%    
            %Initialize solution arrays

            %Initialize the convective flow after the feed valve (i.e., 
            %valve 2) 
            convOutVal2 = 0;        
            %-------------------------------------------------------------%    



            %-------------------------------------------------------------%    
            %Do the mole balance for each species for all species inside 
            %each feed tank

            %For each species,
            for j = 1 : nComs

                %---------------------------------------------------------%    
                %Account for all flows into/out of feed tank from all 
                %columns                        

                %For each columns,
                for k = 1 : nCols

                    %-----------------------------------------------------%    
                    %Calculate molar flow rates around the feed tank                                

                    %If the interaction b/t kth column and the feed tank
                    %is through valve 2
                    if colIntActFeed(k,nS) == 2

                        %Convective flow out through valve 2 (into kth 
                        %adsorption column). Note that the pressure is 
                        %reduced after the valve to P_high. However, the 
                        %mole fraction of the gas remains the same.
                        convOutVal2 = convOutVal2 ...
                                    + feTa.n1.volFlRat(:,k) ...
                                   .* feTa.n1.gasCons.(sComNums{j});

                    %If there is no interaction with kth column and the ith
                    %feed tank, for nS step,                            
                    else

                        %No need to update anything

                    end
                    %-----------------------------------------------------%    

                end

                %Convective flow into the ith feed tank from the feed 
                %reservoir
                convfromFeRes = feTa.n1.volFlRat(:,end) ...
                              * pRatFe ...
                              * yFeC(j);
                %---------------------------------------------------------%    



                %---------------------------------------------------------%    
                %Save the species j result (acconting for all columns)

                %Do the mole balance on the ith tank for species j
                feTa.n1.moleBal.(sComNums{j}) = tankScaleFac ...
                                             .* (convfromFeRes-convOutVal2);    

                %Initialize the molar flow rates for the next iteration
                convOutVal2 = 0;                     
                %---------------------------------------------------------%                

            end
            %-------------------------------------------------------------%
    
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Do the energy balance
         
        %If isothermal model
        if bool(5) == 0
            
            %-------------------------------------------------------------%
            %Don't do the energy balance on the feed tank
            feTa.n1.cstrEnBal = 0;            
            feTa.n1.wallEnBal = 0;  
            %-------------------------------------------------------------%
            
        %If non-isothermal simulation,
        else
            
            %-------------------------------------------------------------%            
            %Define known quantities

            %Unpack additional params  
            intHtTrFacTan  = params.intHtTrFacTan ;
            extHtTrFacTan  = params.extHtTrFacTan ; 
            ambTempNorm    = params.ambTempNorm   ;
            gasConsNormTan = params.gasConsNormTan;
            htCapCpNorm    = params.htCapCpNorm   ;
            %-------------------------------------------------------------%              



            %-------------------------------------------------------------%    
            %Do the CSTR wall energy balance for the feed tank

            %Compute the interior heat transfer rates
            dQndt = feTa.n1.temps.wall ...
                  - feTa.n1.temps.cstr;

            %Compute the exterior heat transfer rates
            dQnwdt = ambTempNorm ... 
                   - feTa.n1.temps.wall;    

            %Save ith feed tank wall energy balance into the struct
            feTa.n1.wallEnBal = extHtTrFacTan*dQnwdt ...
                              - intHtTrFacTan*dQndt;
            %-------------------------------------------------------------%    



            %-------------------------------------------------------------%                                       
            %Initialize the right hand side of dimensionless energy balance

            %Save the heat transfer rate to the column wall from CSTR in 
            %the right hand side of the dTn/dt
            feTa.n1.cstrEnBal = dQndt;              
            %-------------------------------------------------------------%               



            %-------------------------------------------------------------%               
            %Unpack states    

            %Unpack the volumetric flow rates
            vnm1 = feTa.n1.volFlRat(:,end) ;                

            %Unpack the interior temperature variables

            %Assume that the temperature of the compressed feed remains the
            %same
            Tnm1 = ambTempNorm; 

            %Get the current temperature of the feed tank
            Tnm0 = feTa.n1.temps.cstr;                

            %Unpack the overall heat capacity                
            htCOnm0 = feTa.n1.htCO;                                                               
            %-------------------------------------------------------------% 



            %-------------------------------------------------------------%
            %Evaluate species dependent term

            %Initialize the convective energy flow term
            convFlowEner = 0;

            %For each species
            for j = 1 : nComs

                %Update the first term
                convFlowEner = convFlowEner ...
                             + htCapCpNorm(j) ...
                             * (pRatFe*yFeC(j));    

            end            

            %Update the term with the prefactors
            convFlowEner = gasConsNormTan ...
                         * vnm1*(Tnm1-Tnm0) ...
                         * convFlowEner;    
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%           
            %Calculate the right hand side of dimensionless energy balance 
            %for the feed tank. We assume that the flow is always in 
            %co-current direction for the feed tank; this is because the 
            %feed tank by definition should be maintained and the highest 
            %pressure in the system.

            %Evaluate the right hand side for the interior temperature for
            %the feed tank by accounting for the flow term
            feTa.n1.cstrEnBal = (feTa.n1.cstrEnBal ...
                                +convFlowEner) ...
                              / htCOnm0;
            %-------------------------------------------------------------% 

        end    
        %-----------------------------------------------------------------%
     
        
                
        %-----------------------------------------------------------------%
        %Do the cumulative mole balance

        %For each component
        for j = 1 : nComs

            %Assign the right hand side for the cumulative moles flowing 
            %into the feed tank
            feTa.n1.cumMolBal.feed.(sComs{j}) ...
                = pRatFe ...
                * yFeC(j) ...
                * feTa.n1.volFlRat(:,end);

        end  
        %-----------------------------------------------------------------%   
                        
    %---------------------------------------------------------------------%
        
        
    
    %---------------------------------------------------------------------%
    %For the raffinate product tank, evaluate the time derivatives of the 
    %state variables based on the conservation laws including mole and 
    %energy balance equations
    
        %-----------------------------------------------------------------%
        %Do the species mole balance

            %-------------------------------------------------------------%    
            %Initialize solution arrays

            %Initialize the molar flow rate after the product valve (i.e.,
            %valve 1) 
            convInVal1 = 0;

            %Initialize the molar flow rate after the feed/purge/rinse 
            %valve (i.e., valve 2)
            convOutVal2 = 0; 

            %Initialize the molar flow rate after the purge/pressurization 
            %valve (i.e., valve 5)
            convOutVal5 = 0; 
            %-------------------------------------------------------------%    



            %-------------------------------------------------------------%    
            %Do the mole balance for each species for all species inside 
            %each product tank

            %For each species,
            for j = 1 : nComs

                %---------------------------------------------------------%    
                %Account for all flows into/out of product tank from all 
                %columns                        

                %For each columns,
                for k = 1 : nCols

                    %-----------------------------------------------------%    
                    %Calculate molar flow rates around the raffinate 
                    %product tank (The balance is done over product tank + 
                    %valve 1)

                    %If the interaction b/t kth column and the ith product 
                    %tank is through valve 1 
                    if colIntActRaff(k,nS) == 1

                        %Convective flow in through valve 1
                        convInVal1 = convInVal1 ...
                                   + valRaTa(nS) ...
                                   * col.(sColNums{k}).volFlRat(:,end) ...
                                  .* col.(sColNums{k}).gasCons. ...
                                     (sComNums{j})(:,end);                   

                    %If the interaction b/t kth column and the ith product 
                    %tank is through valve 2
                    elseif colIntActRaff(k,nS) == 2

                        %Convective flow out through valve 2
                        convOutVal2 = convOutVal2 ...
                                    + valPurBot(nS) ...
                                    * raTa.n1.volFlRat(:,k) ...
                                   .* raTa.n1.gasCons.(sComNums{j});

                    %If the interaction b/t kth column and the ith product 
                    %tank is through valve 5 
                    elseif colIntActRaff(k,nS) == 5

                        %Convective flow out through valve 5 (must have a 
                        %negative value because the flow is a 
                        %counter-current flow)
                        convOutVal5 = convOutVal5 ...
                                    + raTa.n1.volFlRat(:,k) ...
                                   .* raTa.n1.gasCons.(sComNums{j});  

                    %If there is no interaction with kth column and the ith
                    %product tank, for nS step,                            
                    else

                        %No need to update anything

                    end
                    %-----------------------------------------------------%    

                end

                %Convective flow out to the product reservoir
                convOutRfRes = raTa.n1.volFlRat(:,end) ...
                            .* raTa.n1.gasCons.(sComNums{j});
                %---------------------------------------------------------%    



                %---------------------------------------------------------%    
                %Save the species j result (acconting for all columns)

                %Do the mole balance on the ith tank for species j
                raTa.n1.moleBal.(sComNums{j}) = tankScaleFac ...
                                             .* (convInVal1 ...
                                              + convOutVal2 ...
                                              + convOutVal5 ...
                                              - convOutRfRes);    

                %Initialize the molar flow rates for the next iteration
                convInVal1  = 0;
                convOutVal2 = 0; 
                convOutVal5 = 0;                 
                %---------------------------------------------------------%                

            end  
            %-------------------------------------------------------------%                
            
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Do the energy balance        

        %If isothermal model
        if bool(5) == 0

            %-------------------------------------------------------------%
            %Don't do the energy balance on the feed tank
            raTa.n1.cstrEnBal = 0;            
            raTa.n1.wallEnBal = 0;
            %-------------------------------------------------------------%

        %For non-isothermal simulation,
        else

            %-------------------------------------------------------------%
            %Define known quantities

            %Unpack additional params         
            htCapCpNorm    = params.htCapCpNorm   ;
            intHtTrFacTan  = params.intHtTrFacTan ;
            extHtTrFacTan  = params.extHtTrFacTan ;    
            ambTempNorm    = params.ambTempNorm   ;                                                                          
            gasConsNormTan = params.gasConsNormTan;
            %-------------------------------------------------------------%                                                  



            %-------------------------------------------------------------%    
            %Do the CSTR wall energy balance for the feed tank

            %Compute the interior heat transfer rates
            dQndt = raTa.n1.temps.wall ...
                  - raTa.n1.temps.cstr;

            %Compute the exterior heat transfer rates
            dQnwdt = ambTempNorm ...
                   - raTa.n1.temps.wall;    

            %Save ith feed tank wall energy balance into the struct
            raTa.n1.wallEnBal = extHtTrFacTan*dQnwdt ...
                              - intHtTrFacTan*dQndt;
            %-------------------------------------------------------------%  



            %-------------------------------------------------------------%  
            %Initialize the right hand side of dimensionless energy balance

            %Save the heat transfer to the column wall from the feed tank 
            %in the right hand side of the dTn/dt
            raTa.n1.cstrEnBal = dQndt;    
            %-------------------------------------------------------------%  



            %-------------------------------------------------------------%           
            %Do the CSTR interior energy balance for the feed tank

            %Initialize the convective flow energy term
            convFlowEner = 0;

            %Initialize the net molar flow in the raffinate product tank
            netMolarFlow = 0;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Evaluate the species dependent terms, based on the flow 
            %direction and the interacting boundary

            %For all each column,
            for i = 1 : nCols

                %If we have a counter-current flow in the current adsorber 
                %(i.e., we are doing a purge or pressurization at the 
                %product end)
                if flowDir(i,nS) == 1 

                    %Update the net molar flow (since the flow is in a 
                    %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 + raTa.n1.volFlRat(i) ...
                                 * raTa.n1.gasConsTot;

                    %There is no convective flow-in contribution when there 
                    %is counter-current purge going on.                     

                %If we have a co-current flow in the current adosrber and 
                %we are doing co-current purge or co-current pressurization
                elseif flowDir(i,nS) == 0 && valPurBot(nS) == 1

                    %Update the net molar flow (since the flow is in a
                    %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 + raTa.n1.volFlRat(i) ...
                                 * raTa.n1.gasConsTot;

                    %There is no convective flow-in contribution when there
                    %is co-current purge going on.   

                %If we have a co-current flow in the current adsorber and 
                %we are collecting the raffinate product
                elseif flowDir(i,nS) == 0 && valRaTa(nS) == 1

                    %Update the net molar flow (since the flow is in a 
                    %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 + col.(sColNums{i}).volFlRat(:,nVols) ...
                                 * col.(sColNums{i}).gasConsTot(:,nVols);

                    %Evaluate the species dependent terms
                    for j = 1 : nComs

                       %Update the summation term for the product of the 
                       %component heat capacity and the species 
                       %concentration in the gas %phase
                       convFlowEner = convFlowEner ...
                                    + htCapCpNorm(j) ...
                                    * col.(sColNums{i}).gasCons. ...
                                      (sComNums{j})(:,nVols);

                    end

                    %Multiply the updated term with the volumetric flow 
                    %rate and the temperature difference
                    convFlowEner ...
                        = col.(sColNums{i}).volFlRat(:,nVols) ...
                        * (col.(sColNums{i}).temps.cstr(:,nVols)...
                          -raTa.n1.temps.cstr) ...
                        * convFlowEner;

                %Otherwise, we don't have to do anything as there is no 
                %interaction with the raffinate product tank
                else

                    %Do nothing

                end

                %Scale the terms with the relevant pre-factors
                presDeltaEner = gasConsNormTan ...
                              * raTa.n1.temps.cstr ...
                              * netMolarFlow;
                convFlowEner = gasConsNormTan ...
                             * convFlowEner;

            end            
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%           
            %Do the energy balance for the raffinate product tank

            %Update the existing field
            raTa.n1.cstrEnBal = (raTa.n1.cstrEnBal ...
                                +presDeltaEner ...
                                +convFlowEner) ...
                              / raTa.n1.htCO;        
            %-------------------------------------------------------------%

        end                        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Do the cumulative mole balance
        
            %-------------------------------------------------------------%    
            %Do the cumulative mole balance for each species for all 
            %species inside the raffinate product tank

            %For each component
            for j = 1 : nComs

                %Assign the right hand side for the cumulative moles 
                %flowing out of the product tank
                raTa.n1.cumMolBal.prod.(sComs{j}) ...
                    = raTa.n1.gasCons.(sComs{j}) ...
                    * raTa.n1.volFlRat(:,end);

            end
            %-------------------------------------------------------------%

            
            
            %-------------------------------------------------------------%              
            %Do the cumulative mole balance for each species for all 
            %species inside the raffinate product tank

            %For each component
            for j = 1 : nComs

                %Initialize the right hand side expression
                raWa.n1.cumMolBal.waste.(sComs{j}) = 0;

                %For each column
                for i = 1 : nCols

                    %Assign the right hand side for the cumulative moles 
                    %flowing out as the raffinate waste
                    raWa.n1.cumMolBal.waste.(sComs{j}) ...
                        = raWa.n1.cumMolBal.waste.(sComs{j}) ...
                        + col.(sCols{i}).gasCons.(sComs{j})(:,end) ...
                        * col.(sCols{i}).volFlRat(:,end) ...
                        * (1-valRaTa(nS));

                end

            end
            %-------------------------------------------------------------%
        
        %-----------------------------------------------------------------%
        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For the extract product tank, evaluate the time derivatives of the 
    %state variables based on the conservation laws including mole and 
    %energy balance equations
        
        %-----------------------------------------------------------------%
        %Do the species mole balance
                      
            %-------------------------------------------------------------%    
            %Initialize solution arrays

            %Initialize the convective flow in and out of the extract 
            %stream valve (i.e., %valve 6)
            convInVal6  = 0; 
            convOutVal2 = 0;
            convOutVal5 = 0;
            %-------------------------------------------------------------%    



            %-------------------------------------------------------------%    
            %Do the mole balance for each species for all species inside 
            %each product tank

            %For each species,
            for j = 1 : nComs

                %---------------------------------------------------------%    
                %Account for all flows into/out of product tank from all 
                %columns                        

                %For each columns,
                for k = 1 : nCols

                    %-----------------------------------------------------%    
                    %Calculate molar flow rates around the extract product 
                    %tank (The balance is done over product tank + valve 1)

                    %If the interaction b/t kth column and the extract 
                    %product tank is through valve 6, and the flow (inside 
                    %the adsorber) is counter-current, i.e., exiting the 
                    %adsorber and heading towards either the exteact waste
                    %stream of the extract product tank, we have the 
                    %following:
                    if colIntActExtr(k,nS) == 6 

                        %Convective flow in through valve 6; the negative 
                        %sign is needed because the flow direction switches
                        %from counter-current (exiting the column) to 
                        %co-current (entering the extract feed tank)
                        convInVal6 ...
                            = convInVal6 ...
                            + valExTa(nS) ...
                            * (-1)*col.(sColNums{k}).volFlRat(:,1) ...
                           .* col.(sColNums{k}).gasCons.(sComNums{j})(:,1);                   

                    %If the interaction b/t kth column and the extract 
                    %product tank is through valve 2, and the flow (inside
                    %the adsorber) is co-current, i.e., exiting the extract
                    %product tank and entering the adsorber at the 
                    %bottom-end of the column, we have the following:
                    elseif colIntActExtr(k,nS) == 2

                        %Get the total concentration of the extract product
                        %tank
                        gasConTotFeEnd ...
                            = exTa.n1.gasConsTot;

                        %Get the upstream species concentration
                        gasConSpec ...
                            = exTa.n1.gasCons.(sComNums{j});

                        %Get the current total concentration of the Nth 
                        %CSTR in the ith adsorption column
                        gasConTotCstr ...
                            = col.(sColNums{k}).gasConsTot(:,1);               

                        %Convective flow in through valve 2
                        convOutVal2 ...
                            = convOutVal2 ...
                            + valRinBot(nS) ...
                            * col.(sColNums{k}).volFlRat(:,1) ...
                           .* (gasConSpec/gasConTotFeEnd) ...
                            * gasConTotCstr;                             

                    %If the interaction b/t kth column and the extract 
                    %product tank is through valve 5, and the flow (inside
                    %the adsorber) is counter-current, i.e., exiting the 
                    %extract product tank and entering the adsorber at the
                    %top-end of the column, we have the following:
                    elseif colIntActExtr(k,nS) == 5         

                        %Get the total concentration of the extract product 
                        %tank
                        gasConTotPrEnd ...
                            = exTa.n1.gasConsTot;

                        %Get the upstream species concentration
                        gasConSpec ...
                            = exTa.n1.gasCons.(sComNums{j});

                        %Get the current total concentration of the Nth 
                        %CSTR in the ith adsorption column
                        gasConTotCstr ...
                            = col.(sColNums{k}).gasConsTot(:,end);

                        %Convective flow in through valve 5
                        convOutVal5 ...
                            = convOutVal5 ...
                            + valRinTop(nS) ...
                            * col.(sColNums{k}).volFlRat(:,end) ...
                           .* (gasConSpec/gasConTotPrEnd) ...
                            * gasConTotCstr;

                    %If there is no interaction with kth column and the ith
                    %product tank, for nS step,                            
                    else

                        %No need to update anything

                    end
                    %-----------------------------------------------------%    

                end

                %Convective flow out to the product reservoir
                convOutExRes = exTa.n1.volFlRat(:,end) ...
                            .* exTa.n1.gasCons.(sComNums{j});
                %---------------------------------------------------------%    



                %---------------------------------------------------------%    
                %Save the species j result (accounting for all columns)

                %Do the mole balance on the ith tank for species j
                exTa.n1.moleBal.(sComNums{j}) ...
                    = tankScaleFac ...
                   .* (convInVal6 ...  %counter-current
                      -convOutVal2 ... %co-current
                      +convOutVal5 ... %counter-current
                     -convOutExRes);  %co-current

                %Initialize the molar flow rates for the next iteration
                convInVal6  = 0; 
                convOutVal2 = 0;
                convOutVal5 = 0;
                %---------------------------------------------------------%                

            end
            %-------------------------------------------------------------%
                
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Do the energy balance                       

        %If isothermal model
        if bool(5) == 0
                
            %-------------------------------------------------------------%
            %Don't do the energy balance on the feed tank
            exTa.n1.cstrEnBal = 0;            
            exTa.n1.wallEnBal = 0;  
            %-------------------------------------------------------------%
            
        %Non-isothermal simulation
        else
            
            %-------------------------------------------------------------%           
            %Define known quantities

            %Unpack additional params              
            intHtTrFacTan  = params.intHtTrFacTan ;
            extHtTrFacTan  = params.extHtTrFacTan ;    
            ambTempNorm    = params.ambTempNorm   ;       
            gasConsNormTan = params.gasConsNormTan;
            htCapCpNorm    = params.htCapCpNorm   ;
            %-------------------------------------------------------------%                                                 



            %-------------------------------------------------------------%    
            %Do the CSTR wall energy balance for the feed tank

            %Compute the interior heat transfer rates
            dQndt = exTa.n1.temps.wall ...
                  - exTa.n1.temps.cstr;

            %Compute the exterior heat transfer rates
            dQnwdt = ambTempNorm ...
                   - exTa.n1.temps.wall;    

            %Save ith feed tank wall energy balance into the struct
            exTa.n1.wallEnBal = extHtTrFacTan*dQnwdt ...
                              - intHtTrFacTan*dQndt;
            %-------------------------------------------------------------%  



            %-------------------------------------------------------------%  
            %Initialize the right hand side of dimensionless energy balance

            %Save the heat transfer to the column wall from the feed tank 
            %in the right hand side of the dTn/dt
            exTa.n1.cstrEnBal = dQndt;
            %-------------------------------------------------------------%  



            %-------------------------------------------------------------%           
            %Do the CSTR interior energy balance for the feed tank

            %Initialize the convective flow energy term
            convFlowEner = 0;

            %Initialize the net molar flow in the raffinate product tank
            netMolarFlow = 0;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Evaluate the species dependent terms, based on the flow 
            %direction and the interacting boundary

            %For all each column,
            for i = 1 : nCols

                %If we have a counter-current flow and no rinse step is 
                %going on, we may be pressurizing the extract product tank
                %with the extract product stream from the column
                if flowDir(i,nS) == 1 && ...
                   valRinTop(nS) == 0 && ...
                   valRinBot(nS) == 0

                    %Update the net molar flow (since the flow is in a 
                    %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 + col.(sColNums{i}).volFlRat(:,1) ...
                                 * col.(sColNums{i}).gasConsTot(:,1);

                    %Evaluate the species dependent terms
                    for j = 1 : nComs

                       %Update the summation term for the product of the
                       %component heat capacity and the species 
                       %concentration in the gas phase
                       convFlowEner = convFlowEner ...
                                    + htCapCpNorm(j) ...
                                    * col.(sColNums{i}).gasCons. ...
                                      (sComNums{j})(:,1);

                    end

                    %Multiply the updated term with the volumetric flow 
                    %rate and the temperature difference
                    convFlowEner = col.(sColNums{i}).volFlRat(:,1) ...
                                 * (col.(sColNums{i}).temps.cstr(:,1)...
                                   -exTa.n1.temps.cstr) ...
                                 * convFlowEner;

                %If we have a counter-current flow, we can have a rinse 
                %going on from the top-end of the adsorption column
                elseif flowDir(i,nS) == 1 && ...
                       valRinTop(nS) == 1

                    %Update the net molar flow (since the flow is in a 
                    %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 - exTa.n1.volFlRat(i) ...
                                 * exTa.n1.gasConsTot;           

                %If we have a co-current flow, we can have a rinse going on
                %form the bottom-end of the adsorption column
                elseif flowDir(i,nS) == 0 && ...
                       valRinBot(nS) == 1

                   %Update the net molar flow (since the flow is in a 
                   %negative direction, the voluemtric flow is negative)
                    netMolarFlow = netMolarFlow ...
                                 - exTa.n1.volFlRat(i) ...
                                 * exTa.n1.gasConsTot;             

               %Otherwise, we don't have to do anything as there is no 
               %interaction with the extract product tank
                else 

                    %Do nothing

                end

                %Scale the terms with the relevant pre-factors
                presDeltaEner = gasConsNormTan ...
                              * exTa.n1.temps.cstr ...
                              * netMolarFlow;
                convFlowEner = gasConsNormTan ...
                             * convFlowEner;

            end                                                                   
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%           
            %Do the energy balance for the extract product tank

            %Update the existing field
            exTa.n1.cstrEnBal = (exTa.n1.cstrEnBal ...
                                +presDeltaEner ...
                                +convFlowEner) ...
                              / exTa.n1.htCO;        
            %-------------------------------------------------------------%

        end    
        %-----------------------------------------------------------------%


        
        %-----------------------------------------------------------------%
        %Do the cumulative mole balance
                            
            %-------------------------------------------------------------%    
            %Do the cumulative mole balance for each species for all 
            %species inside each product tank

            %For each component
            for j = 1 : nComs

                %Assign the right hand side for the cumulative moles 
                %flowing out of the product tank
                exTa.n1.cumMolBal.prod.(sComs{j}) ...
                    = exTa.n1.gasCons.(sComs{j}) ...
                    * exTa.n1.volFlRat(:,end);

            end
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%                    
            %Do the cumulative mole balance for each species for all 
            %species inside each product tank

            %For each component
            for j = 1 : nComs

                %Initialize the right hand side expression
                exWa.n1.cumMolBal.waste.(sComs{j}) = 0;

                %For each column
                for i = 1 : nCols

                    %Assign the right hand side for the cumulative moles 
                    %flowing out as the raffinate waste
                    exWa.n1.cumMolBal.waste.(sComs{j}) ...
                        = exWa.n1.cumMolBal.waste.(sComs{j}) ...
                        + col.(sCols{i}).gasCons.(sComs{j})(:,1) ...
                        * col.(sCols{i}).volFlRat(:,1) ...
                        * (1-valExTa(nS)) ...
                        * flowDir(nS);

                end

            end
            %-------------------------------------------------------------%
        
        %-----------------------------------------------------------------%                           
        
    %---------------------------------------------------------------------%   
    
    
    
    %---------------------------------------------------------------------%
    %For the auxiliary units, evaluate the time derivatives of the state
    %variables based on the conservation laws including mole and energy 
    %balance equations
        
        %-----------------------------------------------------------------%
        %For the compressor
            
            %-------------------------------------------------------------%
            %For a co-current flow into the compressor and out to the feed 
            %tank, calculate the necessary terms and evaluate the work rate 
            %expression for the compressor.

            %Get the dimensionless tank pressure (i.e., dimensionless total
            %concentration)
            presOut = feTa.n1.gasConsTot;

            %Get inlet pressure
            presIn = pRatAmb;

            %Get the inlet volumetric flow rate to the compressor
            molFlIn = presOut ...
                    * feTa.n1.volFlRat(:,end);

            %Compute the driving force for the compression
            drivingForce = (presOut/presIn) ...
                         ^ ((gamma-1)/gamma) ...
                         - 1;

            %Evaluate the work rate and store it inside the struct
            comp.n1.workRat = enScaleFac ...
                            * molFlIn ...
                            * drivingForce;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%                            
            %For a counter-current flow out of the vacuum pump into the 
            %extract product tank, calculate the necessary terms and 
            %evaluate the work rate expression for the compressor.

            %Get the dimensionless extract product tank pressure (i.e., 
            %dimensionless total concentration)
            presOut = exTa.n1.gasConsTot;

            %Get the dimensionless extract stream pressure
            presIn = pRat;

            %Initialize the total molar flow rate into the extract product
            %tank
            molFlIn = 0;

            %For each adsorption column,
            for i = 1 : nCols

                %Get the sum of the volumetric flow rates; the individual
                %volumetric flow rates come from each adsorption column and
                %after the compressor, all streams are at the same 
                %pressure. The flow is counter-current, so we need the 
                %absolute value function to take the positive flow rate. 
                %Also, compression is needed only when we collect extract 
                %product as well.
                molFlIn = molFlIn ...
                        + abs(col.(sColNums{i}).volFlRat(:,1)) ...
                        * col.(sColNums{i}).gasConsTot(:,1);

            end

            %Compute the driving force for the compression
            drivingForce = (presOut/presIn) ...
                         ^ ((gamma-1)/gamma) ...
                         - 1;

            %Evaluate the work rate and store it inside the struct
            comp.n2.workRat = enScaleFac ...
                            * molFlIn ...
                            * drivingForce;
            %-------------------------------------------------------------%            
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For the vacuum Pump
        
            %-------------------------------------------------------------%                                       
            %Initialize solution arrays

            %Initialize the rate of change in the cumulative energy 
            %incurred
            cumEnerRhs = 0;    
            %-------------------------------------------------------------%                            



            %-------------------------------------------------------------%                            
            %Evaluate the work rate expression for the pump

            %For each adsorption column, 
            for i = 1 : nCols

                %Get the outlet pressure; we assume that the pump will do 
                %work to pull down the outlet pressure to the lowest 
                %pressure (specified) in an adsorption column
                presOut = pRat;

                %Get the adsorption column pressure from the bottom CSTR
                presIn = col.(sColNums{i}).gasConsTot(:,1);

                %Get the absolute value of the inlet volumetric flow rate 
                %to the compressor; we take an absolute value of the 
                %volumetric flow rate because we care about the magnitude 
                %of the work rate.
                molFlIn = presIn ...
                        * abs(col.(sColNums{i}).volFlRat(:,1)) ...
                        * flowDir(i,nS);            

                %Compute the driving force for the compression
                drivingForce = (presOut/(presIn)) ...
                             ^ ((gamma-1)/gamma) ...
                             - 1;

                %Evaluate the work rate and store it inside the struct
                cumEnerRhs = cumEnerRhs ...
                           + enScaleFac ...
                           * molFlIn ...
                           * drivingForce;

            end

            %Evaluate the work rate and store it inside the struct
            pump.n1.workRat = cumEnerRhs;              
            %-------------------------------------------------------------%
            
        %-----------------------------------------------------------------%                               
        
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Return the right hand side function values containing the time
    %derivatives of the state variables associated with the system                                            

        %-----------------------------------------------------------------%
        %Initialize solution array

        %Initialize a numeric array (a column vector) to hold the state 
        %rate of changes for the right hand side function output
        yDot = zeros(nStatesT,1);    
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%                            
        %Add all evaluated right hand side values associated with adsorption
        %columns

        %For each columns
        for i = 1 : nCols

            %-------------------------------------------------------------%
            %Calculate shift indices

            %Shift index for each column
            s = 2*nComs*(i-1);                        
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %For each species
            for j = 1 : nComs

                %Grab the gas phase mole balances
                yDot(s+nColSt*(i-1)+j:nSt:s+nColSt*i-nSt+j) ...
                    = col.(sCols{i}).moleBal.(sComs{j});

                %Grab the adsorbed phase mole balances
                yDot(s+nColSt*(i-1)+nComs+j:nSt:s+nColSt*i-nSt+nComs+j) ...
                    = col.(sCols{i}).adsRat.(sComs{j}); 

                %Grab the cumulative mole balances for species j at the
                %feed-end            
                yDot(nColStT*i-2*nComs+j) ...
                    = col.(sCols{i}).cumMolBal.feed.(sComs{j}); 

                %Grab the cumulative mole balances for species j at the
                %product-end            
                yDot(nColStT*i-nComs+j) ...
                    = col.(sCols{i}).cumMolBal.prod.(sComs{j}); 

            end
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %For each temperatures

            %Grab the energy balances for the CSTRs
            yDot(s+nColSt*(i-1)+2*nComs+1:nSt:s+nColSt*i-nSt+2*nComs+1) ...
                = col.(sCols{i}).cstrEnBal;


            %Grab the energy balances for the CSTR walls
            yDot(s+nColSt*(i-1)+2*nComs+2:nSt:s+nColSt*i-nSt+2*nComs+2) ...
                = col.(sCols{i}).wallEnBal;
            %-------------------------------------------------------------%

        end        
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%                            
        %Add all evaluated right hand side values associated with the feed 
        %tank

        %For each species
        for j = 1 : nComs

            %Grab the gas phase mole balances            
            yDot(inShFeTa+j) ...
                = feTa.n1.moleBal.(sComs{j});

            %Grab the cumulative mole balance for a species leaving the 
            %feed tank
            yDot(inShFeTa+nFeTaStT-nComs+j) ...
                = feTa.n1.cumMolBal.feed.(sComs{j});

        end

        %For each temperatures

        %Grab the energy balances for the CSTRs
        yDot(inShFeTa+nComs+1) = feTa.n1.cstrEnBal;

        %Grab the energy balances for the CSTR walls
        yDot(inShFeTa+nComs+2) = feTa.n1.wallEnBal;
        %-----------------------------------------------------------------% 



        %-----------------------------------------------------------------%                            
        %Add all evaluated right hand side values associated with the 
        %raffinate tank

        %For each species
        for j = 1 : nComs

            %Grab the gas phase mole balances
            yDot(inShRaTa+j) ...
                = raTa.n1.moleBal.(sComs{j});

            %Grab the cumulative mole balance for a species leaving the 
            %raffinate product tank
            yDot(inShRaTa+nRaTaStT-2*nComs+j) ...
                = raTa.n1.cumMolBal.prod.(sComs{j});

            %Grab the cumulative mole balance for a species leaving as a
            %raffinate waste
            yDot(inShRaTa+nRaTaStT-nComs+j) ...
                = raWa.n1.cumMolBal.waste.(sComs{j});

        end

        %For each temperatures

        %Grab the energy balances for the CSTRs
        yDot(inShRaTa+nComs+1) = raTa.n1.cstrEnBal;

        %Grab the energy balances for the CSTR walls
        yDot(inShRaTa+nComs+2) = raTa.n1.wallEnBal;  
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%                            
        %Add all evaluated right hand side values associated with the 
        %extract tank

        %For each species
        for j = 1 : nComs

            %Grab the gas phase mole balances
            yDot(inShExTa+j) ...
                = exTa.n1.moleBal.(sComs{j});

            %Grab the cumulative mole balance for a speceis leaving the 
            %extract product tank
            yDot(inShExTa+nExTaStT-2*nComs+j) ...
                = exTa.n1.cumMolBal.prod.(sComs{j});

            %Grab the cumulative mole balance for a species leaving as an 
            %extract waste
            yDot(inShExTa+nExTaStT-nComs+j) ...
                = exWa.n1.cumMolBal.waste.(sComs{j});

        end

        %For each temperatures

        %Grab the energy balances for the CSTRs
        yDot(inShExTa+nComs+1) = exTa.n1.cstrEnBal;

        %Grab the energy balances for the CSTR walls
        yDot(inShExTa+nComs+2) = exTa.n1.wallEnBal;  
        %-----------------------------------------------------------------% 



        %-----------------------------------------------------------------%                            
        %Add all evaluated right hand side values associated with the 
        %energy expenditure from compression of the feed and the vacuum 
        %during depressurization

        %Grab the work rate of the compression of the feed gas
        yDot(inShComp+1) = comp.n1.workRat;
        yDot(inShComp+2) = comp.n2.workRat;

        %Grab the work rate of the ith vacuum pump
        yDot(inShVac+1) = pump.n1.workRat;                        
        %-----------------------------------------------------------------%
    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%