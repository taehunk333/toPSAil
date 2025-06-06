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
%Code last modified on : 2022/12/13/Tuesday
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

function [vFlPlus,vFlMinus] = calcVolFlowsDP0DT1Re(params,nS,nC,nTp)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT1Re.m';
    
    %Unpack params    
    nVols        = params.nVols       ;          
    typeDaeModel = params.typeDaeModel;  
    volFlBoFree  = params.volFlBoFree ;
    
    %Unpack the time dependent at nTp
    alphaPlusN  = params.alphaPlusN(nTp,:) ;
    alphaZeroN  = params.alphaZeroN(nTp,:) ;
    alphaMinusN = params.alphaMinusN(nTp,:);
    
    %Get the right hand side vector at nTp
    rhsVec = params.rhsVec(nTp,:);
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
    if typeDaeModel(nC,nS) == 0

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
            %Get the boundary conditions

            %Unpack the boundary conditions
            vFlPlusBoFe  = params.vFlPlusBoFe ;
            vFlMinusBoFe = params.vFlMinusBoFe;

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(1)  = vFlPlusBoFe(nTp) ; 
            vFlMinus(1) = vFlMinusBoFe(nTp); 
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for i = 1 : nVols

                %Update the right hand side vector
                rhsVecEval = rhsVec(i) ...
                           - alphaPlusN(i) ...
                          .* vFlPlus(i) ...
                           - alphaZeroN(i) ...
                          .* vFlMinus(i);

                %Determine the flow direction
                flowDirCol = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,i+1) ...
                    = rhsVecEval ... 
                   ./ alphaZeroN(:,i) ...
                   .* flowDirCol ;
                vFlMinus(:,i+1) ...
                    = rhsVecEval ...
                   ./ alphaMinusN(:,i) ...
                   .* (1-flowDirCol);

            end        
            %-------------------------------------------------------------%

        %Else, we have a boundary condition at the product-end
        else

            %-------------------------------------------------------------%
            %Get the boundary conditions

            %Unpack the boundary conditions
            vFlPlusBoPr  = params.vFlPlusBoPr ;
            vFlMinusBoPr = params.vFlMinusBoPr;

            %Update the pseudo volumetric flow rate matrices
            vFlPlus(nVols+1)  = vFlPlusBoPr(nTp) ; 
            vFlMinus(nVols+1) = vFlMinusBoPr(nTp);
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the pseudo volumetric flow rates

            %For each CSTR,
            for i = nVols : -1 : 1                                        

                %Update the right hand side vector
                rhsVecEval = rhsVec(i) ...
                           - alphaZeroN(i) ...
                          .* vFlPlus(i+1) ...
                           - alphaMinusN(i) ...
                          .* vFlMinus(i+1);

                %Determine the flow direction
                flowDirCol = (rhsVecEval >= 0);

                %Compute the pseudo volumetric flow rates
                vFlPlus(:,i) ...
                    = rhsVecEval ...
                   ./ alphaPlusN(:,i) ...
                   .* (1-flowDirCol) ;
                vFlMinus(:,i) ...
                    = rhsVecEval ...
                   ./ alphaZeroN(:,i) ...
                   .* flowDirCol;

            end 
            %-------------------------------------------------------------% 

        end
        %-----------------------------------------------------------------%

    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %If we are dealing with a time varying pressure DAE model,
    elseif typeDaeModel(nC,nS) == 1

        %-----------------------------------------------------------------%
        %Unpack additional params

        %Unpack params
        opts = params.linprog.opts;
        objs = params.linprog.objs;
        lbs  = params.linprog.lbs ;
        ubs  = params.linprog.ubs ;
        
        %Unpack coefficient matrices
        coefMatPlus  = params.coefMatPlus3D(:,:,nTp) ;
        coefMatMinus = params.coefMatMinus3D(:,:,nTp);
        %-----------------------------------------------------------------%
       


        %-----------------------------------------------------------------%
        %Get boundary conditions
        
        %Unpack the boundary conditions
        vFlPlusBoFe  = params.vFlPlusBoFe ;
        vFlMinusBoFe = params.vFlMinusBoFe;
        vFlPlusBoPr  = params.vFlPlusBoPr ;
        vFlMinusBoPr = params.vFlMinusBoPr;        
        
        %Update the pseudo volumetric flow rate matrices
        vFlPlus(1)        = vFlPlusBoFe(nTp) ; 
        vFlMinus(1)       = vFlMinusBoFe(nTp);
        vFlPlus(nVols+1)  = vFlPlusBoPr(nTp) ; 
        vFlMinus(nVols+1) = vFlMinusBoPr(nTp);        
        %-----------------------------------------------------------------%


        
        %-----------------------------------------------------------------%
        %Solve for the unknown volumetric flow rates

        %A numeric array for the volumetric flow rates for the 
        %adsorption columns
        vFlPseudo = zeros(1,2*(nVols-1));

        %Solve a linear program

            %-------------------------------------------------------------%
            %Define terms required for formulating the linear program (LP)                              
            
            %Construct the time dependent double tri-diagonal 
            %coefficient matrix by concatenating the two coefficient 
            %matrices.
            dTriDiag = [coefMatPlus,coefMatMinus];
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
        vFlPlus(1,2:nVols) = vFlPlusIn;

        %Save the negative pseudo volumetric flow rates
        vFlMinus(1,2:nVols) = vFlMinusIn;
        %-----------------------------------------------------------------%

    end
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%