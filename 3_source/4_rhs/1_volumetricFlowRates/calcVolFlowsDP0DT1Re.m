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
%Code created on       : 2022/5/9/Monday
%Code last modified on : 2022/5/9/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP0DT1Re.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement either constant
%             pressure DAE model or time varying pressure DAE model, for a
%             given column undergoing a given step in a PSA cycle. The
%             assumption in this model is that there is no pressure drop,
%             i.e., DP = 0, but there is a temperature change, i.e., DT =
%             1.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             nS           - jth step in a given PSA cycle
%Outputs    : vFlPlus      - the vector of positive pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%             vFlMinus     - the vector of negative pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vFlPlus,vFlMinus] = calcVolFlowsDP0DT1Re(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT1Re.m';
    
    %Unpack params   
    nCols        = params.nCols       ; 
    nVols        = params.nVols       ;        
    vFlBo        = params.volFlBo     ;   
    daeModCur    = params.daeModel    ; 
    sColNums     = params.sColNums    ;
    nRows        = params.nRows       ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ;
    cstrHt       = params.cstrHt      ;
    gConsNormCol = params.gConsNormCol;
    htCapCvNorm  = params.htCapCvNorm ;
    htCapCpNorm  = params.htCapCpNorm ; 
    volFlBoFree  = params.volFlBoFree ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays

    %Initialize numeric arrays for the pseudo volumetric flow rates for the
    %adsorption columns
    vFlPlus  = zeros(nRows,nCols*(nVols+1));
    vFlMinus = zeros(nRows,nCols*(nVols+1));
    %---------------------------------------------------------------------% 
                                                
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each column
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%        
        %Compute the shift factor
                
        %We shift (nVols+1) number of columns per adsorber
        shiftFac = (nVols+1)*(i-1);        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If we are dealing with a constant pressure DAE model,
        if daeModCur(i,nS) == 0
           
            %-------------------------------------------------------------%
            %Decide which boundary condition is given
            
            %Check if we have a boundary condition specified at the
            %feed-end of the ith adsorber
            feEndHasBC = volFlBoFree(i,nS) == 1;
            %-------------------------------------------------------------%
            
                        
            
            %-------------------------------------------------------------%                              
            %Get the right hand side vector at a given time point
            
            %Multiply dimensionless total adsorption rates by the 
            %coefficients that are relevant for the step for ith column            
            rhsVec = (-1)*col.(sColNums{i}).volAdsRatTot ...
                   + col.(sColNums{i}).volCorRatTot; 
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Unpack column states
            
            %Unpack the total concentrstion variables
            gasConsTot = col.(sColNums{i}).gasConsTot;
            
            %Unpack the interior temperature variables 
            cstrTemps = col.(sColNums{i}).temps.cstr;
            
            %Define the total concentration variables                
            cNm1 = [col.(sColNums{i}).feEnd.gasConsTot, ...
                    gasConsTot(:,1:nVols-1)];
            cNm0 = gasConsTot(:,1:nVols);  
            cNp1 = [gasConsTot(:,2:nVols), ...
                    col.(sColNums{i}).prEnd.gasConsTot];

            %Define the interior temperature variables                
            Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                    cstrTemps(:,1:nVols-1)];
            Tnm0 = cstrTemps(:,1:nVols);
            Tnp1 = [cstrTemps(:,2:nVols), ...
                    col.(sColNums{i}).prEnd.temps];

            %Unpack the overall heat capacity
            htCOnm0 = col.n1.htCO;                                                  
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Compute the species dependent terms
                
            %Initialize the solution arrays
            termNm1 = zeros(nRows,nVols);
            termNp1 = zeros(nRows,nVols);

            %Compute the temperature ratio
            TratNm1 = Tnm1./Tnm0;
            TratNp1 = Tnp1./Tnm0;

            %Loop over each species
            for j = 1: nComs                                                                        
                
                %Unpack gas species concentration
                gasConsSpec = col.(sColNums{i}).gasCons. ...
                              (sComNums{j});
                
                %Update the nm1 term
                termNm1 = termNm1 ...
                        + (TratNm1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [col.(sColNums{i}).feEnd. ...
                          gasCons.(sComNums{j}), ...
                          gasConsSpec(:,1:nVols-1)];
                      
                %Update the nm1 term
                termNp1 = termNp1 ...
                        + (TratNp1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [gasConsSpec(:,2:nVols), ...
                          col.(sColNums{i}).prEnd. ...
                          gasCons.(sComNums{j})];

            end                                      
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Define the coefficients
            %$\forall n \in \left\{ 1, ..., n_c \right\}$
            
            %Calculate the first time dependent coefficient:
            %$\tilde{alpha}_n^{-} \left(t\right)$
            aMinusNm0 = (-1) ...
                      * ((cNm1./cNm0) ...
                      + gConsNormCol ...
                     .* cstrHt ...
                     ./ htCOnm0 ...
                     .* termNm1);
            
            %Calculate the second time dependent coefficient:
            %$\tilde{alpha}_n \left(t\right)$
            aNoneNm0 = 1 ...
                     + gConsNormCol ...
                    .* cstrHt ...
                    .* cNm0 ...
                    ./ htCOnm0;
            
            %Calculate the third time dependent coefficient:
            %$\tilde{alpha}_n^{+} \left(t\right)$
            aPlusNm0 = (-1) ...
                    .* ((cNp1./cNm0) ...
                     + gConsNormCol ...
                    .* cstrHt ...
                    ./ htCOnm0 ...
                    .* termNp1);       
            %-------------------------------------------------------------%
                
            
            
            %-------------------------------------------------------------%
            %Depending on the boundary conditions, calculate the pseudo 
            %volumetric flow rates

            %If we have a boundary condition at the feed-end
            if feEndHasBC == 1
                
                %---------------------------------------------------------%
                %Get boundary conditions

                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);
                
                %Update the pseudo volumetric flow rate matrices
                vFlPlus(:,shiftFac+1)  = vPlusBo ; 
                vFlMinus(:,shiftFac+1) = vMinusBo; 
                %---------------------------------------------------------%
 
                
                
                %---------------------------------------------------------%
                %Calculate the pseudo volumetric flow rates
                
                %For each CSTR,
                for j = 1 : nVols
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,j) ...
                               - aMinusNm0(:,j) ...
                              .* vFlPlus(:,shiftFac+j) ...
                               - aNoneNm0(:,j) ...
                              .* vFlMinus(:,shiftFac+j);
                      
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,shiftFac+j+1) ...
                        = rhsVecEval ... 
                       ./ aNoneNm0(:,j) ...
                       .* flowDir ;
                    vFlMinus(:,shiftFac+j+1) ...
                        = rhsVecEval ...
                       ./ aPlusNm0(:,j) ...
                       .* (1-flowDir);
                    
                end        
                %---------------------------------------------------------%

            %Else, we have a boundary condition at the product-end
            else
                
                %---------------------------------------------------------%
                %Get boundary conditions
                
                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);
                
                %Update the pseudo volumetric flow rate matrices
                vFlPlus(:,(nVols+1)*i)  = vPlusBo ; 
                vFlMinus(:,(nVols+1)*i) = vMinusBo;
                %---------------------------------------------------------%
                
                

                %---------------------------------------------------------%
                %Calculate the pseudo volumetric flow rates
                                
                %For each CSTR,
                for j = nVols : -1 : 1                                        
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,j) ...
                               - aNoneNm0(:,j) ...
                              .* vFlPlus(:,shiftFac+j+1) ...
                               - aPlusNm0(:,j) ...
                              .* vFlMinus(:,shiftFac+j+1);
                    
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,shiftFac+j) ...
                        = rhsVecEval ...
                       ./ aMinusNm0(:,j) ...
                       .* (1-flowDir) ;
                    vFlMinus(:,shiftFac+j) ...
                        = rhsVecEval ...
                       ./ aNoneNm0(:,j) ...
                       .* flowDir;
                    
                end 
                %---------------------------------------------------------% 

            end
            %-------------------------------------------------------------%

        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If we are dealing with a time varying pressure DAE model,
        elseif daeModCur(i,nS) == 1
            
            %-------------------------------------------------------------%
            %Unpack additional params
            
            %Unpack params
            opts = params.linprog.opts;
            objs = params.linprog.objs;
            lbs  = params.linprog.lbs ;
            ubs  = params.linprog.ubs ;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Unpack states

            %Unpack the total concentrstion variables
            gasConsTot = col.(sColNums{i}).gasConsTot;
            
            %Unpack the interior temperature variables 
            cstrTemps = col.(sColNums{i}).temps.cstr;

            %Define the total concentrstion variables
            cNm2 = [col.(sColNums{i}).feEnd.gasConsTot, ...
                    gasConsTot(:,1:nVols-2)];                  
            cNm1 = gasConsTot(:,1:nVols-1);
            cNm0 = gasConsTot(:,2:nVols);
            cNp1 = [gasConsTot(:,3:nVols), ...
                    col.(sColNums{i}).prEnd.gasConsTot];

            %Define the interior temperature variables 
            Tnm2 = [col.(sColNums{i}).feEnd.temps, ...
                    cstrTemps(:,1:nVols-2)];
            Tnm1 = cstrTemps(:,1:nVols-1);
            Tnm0 = cstrTemps(:,2:nVols);
            Tnp1 = [cstrTemps(:,3:nVols), ...
                    col.(sColNums{i}).prEnd.temps];

            %Unpack the overall heat capacity
            htCOnm1 = col.n1.htCO(:,1:nVols-1);
            htCOnm0 = col.n1.htCO(:,2:nVols)  ;                             
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Compute the species dependent terms

            %Initialize the solution arrays
            termNm2 = zeros(nRows,nVols-1);
            termNm1 = zeros(nRows,nVols-1);
            termNm0 = zeros(nRows,nVols-1);
            termNp1 = zeros(nRows,nVols-1);

            %Compute the temperature ratios
            TratNm2 = Tnm2./Tnm1;
            TratNm1 = Tnm1./Tnm0;
            TratNm0 = Tnm0./Tnm1;
            TratNp1 = Tnp1./Tnm0;

            %Loop over each species
            for j = 1: nComs
            
                %Unpack gas species concentration
                gasConsSpec = col.(sColNums{i}).gasCons. ...
                              (sComNums{j});
                
                %Update the nm2 term
                termNm2 = termNm2 ...
                        + (TratNm2*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [col.(sColNums{i}).feEnd. ...
                          gasCons.(sComNums{j}), ...
                          gasConsSpec(:,1:nVols-2)];                    

                %Update the nm1 term
                termNm1 = termNm1 ...
                        + (TratNm1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* gasConsSpec(:,1:nVols-1);
                      
                %Update the nm0 term
                termNm0 = termNm0 ...
                        + (TratNm0*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* gasConsSpec(:,2:nVols);                    

                %Update the np1 term
                termNp1 = termNp1 ...
                        + (TratNp1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [gasConsSpec(:,3:nVols), ...
                          col.(sColNums{i}).prEnd. ...
                          gasCons.(sComNums{j})];

            end                                                      
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Define the coefficients:
            %$\forall n \in \left\{ 2, ..., n_c \right\}$              
            
            %Calculate the first time dependent coefficient:
            %$\tilde{\phi}_{n,n-1}^{-} \left( t \right)$
            pMinusNm1 = (-1) ...
                      * (cNm2./cNm1./cstrHt(2:nVols) ...
                      + gConsNormCol./htCOnm1.*termNm2);
                        
            %Calculate the second time dependent coefficient:
            %$\tilde{\phi}_{n,n-1} \left( t \right)$
            pNoneNm1 = (1./cstrHt(1:nVols-1) ...
                     + gConsNormCol.*cNm1./htCOnm1);
                        
            %Calculate the third time dependent coefficient:
            %$\tilde{\phi}_{n,n-1}^{+} \left( t \right)$
            pPlusNm1 = (cNm1./cNm0./cstrHt(2:nVols)) ...
                     + gConsNormCol./htCOnm0.*termNm1;
                        
            %Calculate the fourth time dependent coefficient:
            %$\tilde{\phi}_{n,n}^{-} \left( t \right)$
            pMinusNm0 = (-1) ...
                      * (cNm0./cNm1./cstrHt(1:nVols-1) ...
                      + gConsNormCol./htCOnm1.*termNm0);
                        
            %Calculate the fifth time dependent coefficient:
            %$\tilde{\phi}_{n,n} \left( t \right)$
            pNoneNm0 = (-1) ...
                     * (1./cstrHt(2:nVols) ...
                     + gConsNormCol.*cNm0./htCOnm0);
                                    
            %Calculate the sixth time dependent coefficient:
            %$\tilde{\phi}_{n,n}^{+} \left( t \right)$
            pPlusNm0 = (cNp1./cNm0./cstrHt(2:nVols) ...
                     + gConsNormCol./htCOnm0.*termNp1);            
            %-------------------------------------------------------------%                                                                        
            
            
            
            %-------------------------------------------------------------%
            %Define the boundary conditions                                     
            
            %Obtain the boundary condition for the product-end of the ith
            %column under current step in a given PSA cycle           
            vFlBoPr = ones(nRows,1) ...                    
                   .* vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);                        
                       
            %Obtain the boundary condition for the feed-end of the ith
            %column under current step in a given PSA cycle
            vFlBoFe = ones(nRows,1) ...                   
                   .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);           
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------% 
            %Convert the boundary conditions into pseudo volumetric flow
            %rates
               
            %Call the helper function to calculate the pseudo volumetric 
            %flow rates
            [vFlPlusPr,vFlMinusPr] = calcPseudoVolFlows(vFlBoPr); 
            [vFlPlusFe,vFlMinusFe] = calcPseudoVolFlows(vFlBoFe);                         
            %-------------------------------------------------------------% 
            
            
            
            %-------------------------------------------------------------%
            %Obtain the right hand side vector for time varying pressure
            %DAE model
            
            %Initialize the right hand side vector for the current time
            %step, by considering the adsorption as well as the correction
            %for the nonisothermal heat effects
            rhsVec = (1./cstrHt(2:nVols)) ...
                  .* (col.(sColNums{i}).volAdsRatTot(:,2:nVols) ...
                     -col.(sColNums{i}).volCorRatTot(:,2:nVols)) ...
                   - (1./cstrHt(1:nVols-1)) ...
                  .* (col.(sColNums{i}).volAdsRatTot(:,1:nVols-1) ...
                     -col.(sColNums{i}).volCorRatTot(:,1:nVols-1));                 
                     
            %Add the feed-end boundary condition for the ith column in nS
            %step in a given PSA cycle
            rhsVec(:,1) = rhsVec(:,1) ...
                        - pMinusNm1(:,1)...
                       .* vFlPlusFe ...
                        - pNoneNm1(:,1)...
                       .* vFlMinusFe;
                        
            %Add the product-end boundary condition for the ith column in
            %nS step in a given PSA cycle
            rhsVec(:,nVols-1) = rhsVec(:,nVols-1) ...
                              - pNoneNm0(:,nVols-1)...
                             .* vFlPlusPr...
                              - pPlusNm0(:,nVols-1)...
                             .* vFlMinusPr;          
            %-------------------------------------------------------------%
                                    
            

            %-------------------------------------------------------------%
            %Solve for the unknown volumetric flow rates
                        
            %A numeric array for the volumetric flow rates for the 
            %adsorption columns
            vFlPseudo = zeros(nRows,nCols*2*(nVols-1));
                                                        
            %Solve a linear program for each time point
            for t = 1 : nRows
                                
                %---------------------------------------------------------%
                %Define terms required for formulating the linear program 
                %(LP)

                %Define the diagonal entries in the positive tri-diagonal
                %matrix
                diagDownPos = diag(pMinusNm1(t,2:nVols-1),-1)      ;
                diagMidPos  = diag((pNoneNm1(t,:)+pPlusNm1(t,:)),0);
                diagUpPos   = diag(pNoneNm0(t,1:nVols-2),+1)       ;

                %Define the diagonal entries in the negative tri-diagonal
                %matrix
                diagDownNeg = diag(pNoneNm1(t,2:nVols-1),-1)        ;
                diagMidNeg  = diag((pMinusNm0(t,:)+pNoneNm0(t,:)),0);
                diagUpNeg   = diag(pPlusNm0(t,1:nVols-2),+1)        ;

                %Define the positive tri-diagonal matrix
                triDiagPos = diagDownPos ...
                           + diagMidPos ...
                           + diagUpPos;

                %Define the negative tri-diagonal matrix
                triDiagNeg = diagDownNeg ...
                           + diagMidNeg ...
                           + diagUpNeg;

                %Construct the time dependent double tri-diagonal 
                %coefficient matrix by concatenating the two coefficient 
                %matrices.
                dTriDiag = [triDiagPos,triDiagNeg];
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Solve the linear program for the unknown pseudo volumetric
                %flow rates
                
                %Solve the LP using linprog.m
                vFlPseudo(t,2*(nVols-1)*(i-1)+1:2*(nVols-1)*i) ...
                    = linprog(objs, ...
                              [], ...
                              [], ...
                              dTriDiag, ...
                              rhsVec(t,:)', ...
                              lbs, ...
                              ubs, ...
                              opts);
                %---------------------------------------------------------%    
                      
            end
            
            %Define the interior pseudo volumetric flow rates
            vFlPlusIn  = vFlPseudo(:,1:nVols-1)        ;
            vFlMinusIn = vFlPseudo(:,nVols:2*(nVols-1));
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Save the results
            
            %Save the positive pseudo volumetric flow rates
            vFlPlus(:,shiftFac+1:(nVols+1)*i)  ...
                = [vFlPlusFe,vFlPlusIn,vFlPlusPr];
               
            %Save the negative pseudo volumetric flow rates
            vFlMinus(:,shiftFac+1:(nVols+1)*i) ...
                = [vFlMinusFe,vFlMinusIn,vFlMinusPr];
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%