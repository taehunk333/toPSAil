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
%Function   : calcVolFlowsDP0DT0Re.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement either constant
%             pressure DAE model or time varying pressure DAE model, for a
%             given column undergoing a given step in a PSA cycle. The
%             assumption in this model is that there is no pressure drop,
%             i.e., DP = 0, and there is no temperature change, i.e., DT =
%             0.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             nS           - jth step in a given PSA cycle
%             nC           - the current adsorption column index
%Outputs    : vFlPlus      - the vector of positive pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%             vFlMinus     - the vector of negative pseudo volumetric flow
%                            rates. Rows represent the numeber of time
%                            points, column represents the pseudo
%                            volumetric flwo rates for all adsorbers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vFlPlus,vFlMinus] = calcVolFlowsDP0DT0Re(params,units,nS,nC)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT0Re.m';
    
    %Unpack params    
    nVols       = params.nVols      ;        
    vFlBo       = params.volFlBo    ;   
    daeModCur   = params.daeModel   ;
    cstrHt      = params.cstrHt     ; 
    sColNums    = params.sColNums   ;
    nRows       = params.nRows      ;
    volFlBoFree = params.volFlBoFree;
    
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
    vFlPlus  = zeros(nRows,(nVols+1));
    vFlMinus = zeros(nRows,(nVols+1));
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
        %Get the right hand side vector at a given time point

        %Multiply dimensionless total adsorption rates by the 
        %coefficients that are relevant for the step for ith column            
        rhsVec = (-1)*col.(sColNums{nC}).volAdsRatTot;
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
            vFlBoRhs = vFlBo{2,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);

            %Call the helper function to calculate the pseudo 
            %volumetric flow rates
            [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(:,1)  = vPlusBo ; 
            vFlMinus(:,1) = vMinusBo; 
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for i = 1 : nVols

                %Update the right hand side vector
                rhsVecEval = rhsVec(:,i) ...
                           + vFlPlus(:,i) ...
                           - vFlMinus(:,i);

                %Determine the flow direction
                flowDir = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,i+1) ...
                    = rhsVecEval ... 
                   .* flowDir ;
                vFlMinus(:,i+1) ...
                    = (-1)*rhsVecEval ...
                   .* (1-flowDir);

            end        
            %-------------------------------------------------------------%

        %Else, we have a boundary condition at the product-end
        else

            %-------------------------------------------------------------%
            %Get boundary conditions

            %Take account for the boundary condition on the right hand 
            %side vector
            vFlBoRhs = vFlBo{1,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);

            %Call the helper function to calculate the pseudo 
            %volumetric flow rates
            [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(:,(nVols+1))  = vPlusBo ; 
            vFlMinus(:,(nVols+1)) = vMinusBo;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for i = nVols : -1 : 1                                        

                %Update the right hand side vector
                rhsVecEval = rhsVec(:,i) ...
                           - vFlPlus(:,i+1) ...
                           + vFlMinus(:,i+1);

                %Determine the flow direction
                flowDir = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,i) ...
                    = (-1)*rhsVecEval ...
                   .* (1-flowDir) ;
                vFlMinus(:,i) ...
                    = rhsVecEval ...
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
        dTriDiag = params.dTriDiag    ;
        opts     = params.linprog.opts;            
        objs     = params.linprog.objs;
        lbs      = params.linprog.lbs ;
        ubs      = params.linprog.ubs ;
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Define the boundary conditions                                     

        %Obtain the boundary condition for the product-end of the ith
        %column under current step in a given PSA cycle           
        vFlBoPr = ones(nRows,1) ...
               .* vFlBo{1,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);                        

        %Obtain the boundary condition for the feed-end of the ith
        %column under current step in a given PSA cycle
        vFlBoFe = ones(nRows,1) ...
               .* vFlBo{2,nC,nS}(params,col,feTa,raTa,exTa,nS,nC);   
        %-----------------------------------------------------------------% 



        %-----------------------------------------------------------------% 
        %Convert the boundary conditions into pseudo volumetric flow
        %rates

        %Call the helper function to calculate the pseudo volumetric 
        %flow rates
        [vFlPlusPr,vFlMinusPr] = calcPseudoVolFlows(vFlBoPr); 
        [vFlPlusFe,vFlMinusFe] = calcPseudoVolFlows(vFlBoFe);                         
        %-----------------------------------------------------------------% 



        %-----------------------------------------------------------------%
        %Obtain the right hand side vector for time varying pressure
        %DAE model

        %Calculate the volumic adsorption rate terms
        rateNm1 = col.(sColNums{nC}).volAdsRatTot(:,1:nVols-1) ...
               ./ cstrHt(:,1:nVols-1);
        rateNm0 = col.(sColNums{nC}).volAdsRatTot(:,2:nVols) ...
               ./ cstrHt(:,2:nVols);

        %Get the first order difference between adjacent columns of the
        %total adsorption rates for the current ith column            
        rhsVec = rateNm0-rateNm1;

        %Add the feed-end boundary condition for the ith column in nS
        %step in a given PSA cycle
        rhsVec(:,1) = rhsVec(:,1) ...
                    + (vFlPlusFe-vFlMinusFe) ...
                    / cstrHt(1);

        %Add the product-end boundary condition for the ith column in
        %nS step in a given PSA cycle
        rhsVec(:,nVols-1) = rhsVec(:,end) ...
                          + (vFlPlusPr-vFlMinusPr) ...
                          / cstrHt(nVols-1);
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Solve for the unknown volumetric flow rates

        %A numeric array for the volumetric flow rates for the 
        %adsorption columns
        vFlPseudo = zeros(nRows,2*(nVols-1));

        %Solve a linear program for each time point
        for t = 1 : nRows

            %Solve the LP using linprog.m
            vFlPseudo(t,:) ...
                = linprog(objs, ...
                          [], ...
                          [], ...
                          dTriDiag, ...
                          rhsVec(t,:)', ...
                          lbs, ...
                          ubs, ...
                          opts);

        end

        %Define the interior pseudo volumetric flow rates
        vFlPlusIn  = vFlPseudo(:,1:nVols-1)        ;
        vFlMinusIn = vFlPseudo(:,nVols:2*(nVols-1));
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