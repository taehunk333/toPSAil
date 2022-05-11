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
%Code last modified on : 2022/5/11/Wednesday
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
%             nC           - the current adsorption column index
%             nTp          - the current number of time point
%Outputs    : vFlPlus      - the vector of positive pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%             vFlMinus     - the vector of negative pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vFlPlus,vFlMinus] = calcVolFlowsDP0DT1Re(params,units,nS,nC,nTp)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT1Re.m';
    
    %Unpack params    
    nVols        = params.nVols       ;        
    vFlBo        = params.volFlBo     ;   
    daeModCur    = params.daeModel    ; 
    sColNums     = params.sColNums    ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ;
    cstrHt       = params.cstrHt      ;
    gConsNormCol = params.gConsNormCol;
    htCapCvNorm  = params.htCapCvNorm ;
    htCapCpNorm  = params.htCapCpNorm ; 
    volFlBoFree  = params.volFlBoFree ;
    
    %Unpack the time dependent at nTp
    alphaPlusN  = params.alphaPlusN(nTp,:) ;
    alphaZeroN  = params.alphaZeroN(nTp,:) ;
    alphaMinusN = params.alphaMinusN(nTp,:);
    
    %Get the right hand side vector at nTp
    rhsVec = params.rhsVec(nTp,:);
    
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
    vFlPlus  = zeros(1,(nVols+1));
    vFlMinus = zeros(1,(nVols+1));
    %---------------------------------------------------------------------% 
                                                
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %If we are dealing with a constant pressure DAE model,
    if daeModCur(nC,nS) == 0

        %-----------------------------------------------------------------%
        %Decide which boundary condition is given

        %Check if we have a boundary condition specified at the
        %feed-end of the ith adsorber
        feEndHasBC = volFlBoFree(nC,nS) == 1;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Depending on the boundary conditions, calculate the pseudo 
        %volumetric flow rates

        %If we have a boundary condition at the feed-end
        if feEndHasBC == 1

            %-------------------------------------------------------------%
            %Get boundary conditions

            %Take account for the boundary condition on the right hand 
            %side vector
            vFlBoFe ...
                = vFlBo{2,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);

            %Call the helper function to calculate the pseudo 
            %volumetric flow rates
            [vFlPlusBoFe,vFlMinusBoFe] ...
                = calcPseudoVolFlows(vFlBoFe);

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(1)  = vFlPlusBoFe(nTp) ; 
            vFlMinus(1) = vFlMinusBoFe(nTp); 
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for j = 1 : nVols

                %Update the right hand side vector
                rhsVecEval = rhsVec(j) ...
                           - alphaPlusN(j) ...
                          .* vFlPlus(j) ...
                           - alphaZeroN(j) ...
                          .* vFlMinus(j);

                %Determine the flow direction
                flowDir = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,j+1) ...
                    = rhsVecEval ... 
                   ./ alphaZeroN(:,j) ...
                   .* flowDir ;
                vFlMinus(:,j+1) ...
                    = rhsVecEval ...
                   ./ alphaMinusN(:,j) ...
                   .* (1-flowDir);

            end        
            %-------------------------------------------------------------%

        %Else, we have a boundary condition at the product-end
        else

            %-------------------------------------------------------------%
            %Get boundary conditions

            %Take account for the boundary condition on the right hand 
            %side vector
            vFlBoPr ...
                = vFlBo{1,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);

            %Call the helper function to calculate the pseudo 
            %volumetric flow rates
            [vFlPlusBoPr,vFlMinusBoPr] ...
                = calcPseudoVolFlows(vFlBoPr);

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(nVols+1)  = vFlPlusBoPr(nTp) ; 
            vFlMinus(nVols+1) = vFlMinusBoPr(nTp);
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for j = nVols : -1 : 1                                        

                %Update the right hand side vector
                rhsVecEval = rhsVec(j) ...
                           - alphaZeroN(j) ...
                          .* vFlPlus(j+1) ...
                           - alphaMinusN(j) ...
                          .* vFlMinus(j+1);

                %Determine the flow direction
                flowDir = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,j) ...
                    = rhsVecEval ...
                   ./ alphaPlusN(:,j) ...
                   .* (1-flowDir) ;
                vFlMinus(:,j) ...
                    = rhsVecEval ...
                   ./ alphaZeroN(:,j) ...
                   .* flowDir;

            end 
            %-------------------------------------------------------------% 

        end
        %-----------------------------------------------------------------%

    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %If we are dealing with a time varying pressure DAE model,
    elseif daeModCur(nC,nS) == 1

        %-----------------------------------------------------------------%
        %Unpack additional params

        %Unpack params
        opts = params.linprog.opts;
        objs = params.linprog.objs;
        lbs  = params.linprog.lbs ;
        ubs  = params.linprog.ubs ;
        %-----------------------------------------------------------------%
       


        %-----------------------------------------------------------------%
        %Define the boundary conditions                                     

        %Obtain the boundary condition for the product-end of the ith
        %column under current step in a given PSA cycle           
        vFlBoPr = vFlBo{1,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);                        

        %Obtain the boundary condition for the feed-end of the ith
        %column under current step in a given PSA cycle
        vFlBoFe = vFlBo{2,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);           
        %-------------------------------------------------------------%



        %-------------------------------------------------------------% 
        %Convert the boundary conditions into pseudo volumetric flow
        %rates

        %Call the helper function to calculate the pseudo volumetric 
        %flow rates
        [vFlPlusPr,vFlMinusPr] = calcPseudoVolFlows(vFlBoPr); 
        [vFlPlusFe,vFlMinusFe] = calcPseudoVolFlows(vFlBoFe);         
        
        %Update the pseudo volumetric flow rate matrices
        vFlPlusPr  = vFlPlusPr(nTp) ;
        vFlMinusPr = vFlMinusPr(nTp); 
        vFlPlusFe  = vFlPlusFe(nTp) ;
        vFlMinusFe = vFlMinusFe(nTp); 
        %-----------------------------------------------------------------% 



        %-----------------------------------------------------------------%
        %Obtain the right hand side vector for time varying pressure
        %DAE model

        %Initialize the right hand side vector for the current time
        %step, by considering the adsorption as well as the correction
        %for the nonisothermal heat effects
        rhsVec = (1./cstrHt(2:nVols)) ...
              .* (col.(sColNums{nC}).volAdsRatTot(nTp,2:nVols) ...
                 -col.(sColNums{nC}).volCorRatTot(nTp,2:nVols)) ...
               - (1./cstrHt(1:nVols-1)) ...
              .* (col.(sColNums{nC}).volAdsRatTot(nTp,1:nVols-1) ...
                 -col.(sColNums{nC}).volCorRatTot(nTp,1:nVols-1));                 

        %Add the feed-end boundary condition for the ith column in nS
        %step in a given PSA cycle
        rhsVec(1) = rhsVec(1) ...
                  - pMinusNm1(1)...
                 .* vFlPlusFe ...
                  - pNoneNm1(1)...
                 .* vFlMinusFe;

        %Add the product-end boundary condition for the ith column in
        %nS step in a given PSA cycle
        rhsVec(nVols-1) = rhsVec(nVols-1) ...
                        - pNoneNm0(nVols-1)...
                       .* vFlPlusPr...
                        - pPlusNm0(nVols-1)...
                       .* vFlMinusPr;          
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Solve for the unknown volumetric flow rates

        %A numeric array for the volumetric flow rates for the 
        %adsorption columns
        vFlPseudo = zeros(1,2*(nVols-1));

        %Solve a linear program

            %-------------------------------------------------------------%
            %Define terms required for formulating the linear program (LP)

            %Define the diagonal entries in the positive tri-diagonal
            %matrix
            diagDownPos = diag(pMinusNm1(2:nVols-1),-1);
            diagMidPos  = diag((pNoneNm1+pPlusNm1),0)  ;
            diagUpPos   = diag(pNoneNm0(1:nVols-2),+1) ;

            %Define the diagonal entries in the negative tri-diagonal
            %matrix
            diagDownNeg = diag(pNoneNm1(2:nVols-1),-1);
            diagMidNeg  = diag((pMinusNm0+pNoneNm0),0);
            diagUpNeg   = diag(pPlusNm0(1:nVols-2),+1);

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
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Solve the linear program for the unknown pseudo volumetric
            %flow rates

            %Solve the LP using linprog.m
            vFlPseudo(1,:) ...
                = linprog(objs, ...
                          [], ...
                          [], ...
                          dTriDiag, ...
                          rhsVec', ...
                          lbs, ...
                          ubs, ...
                          opts);
            
            %Define the interior pseudo volumetric flow rates
            vFlPlusIn  = vFlPseudo(1,1:nVols-1)        ;
            vFlMinusIn = vFlPseudo(1,nVols:2*(nVols-1));
            %-------------------------------------------------------------%    

        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Save the results

        %Save the positive pseudo volumetric flow rates
        vFlPlus = [vFlPlusFe,vFlPlusIn,vFlPlusPr];

        %Save the negative pseudo volumetric flow rates
        vFlMinus = [vFlMinusFe,vFlMinusIn,vFlMinusPr];
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%