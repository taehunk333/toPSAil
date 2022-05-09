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
%Code created on       : 2021/1/24/Sunday
%Code last modified on : 2022/5/9/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP0DT0.m
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
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlowsDP0DT0(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT0.m';
    
    %Unpack params   
    nCols       = params.nCols      ; 
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
    vFlPlus  = zeros(nRows,nCols*(nVols+1));
    vFlMinus = zeros(nRows,nCols*(nVols+1));        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte the pseudo volumetric flow rates associated with adsorption
    %columns
    
    %For each adsorber
    for i = 1 : nCols
    
        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with assumed flow
        %directions

            %-------------------------------------------------------------%
            %If we are dealing with a constant pressure DAE model,
            if daeModCur(i,nS) == 0

                %---------------------------------------------------------%
                %Unpack additional params
                coefMat    = params.coefMat{i,nS}{1};
                partCoefHp = params.partCoefHp      ;
                %---------------------------------------------------------%                        



                %---------------------------------------------------------%
                %Decide which boundary condition is given

                %Check if we have a boundary condition specified at the
                %feed-end of the ith adsorber
                feEndHasBC = volFlBoFree(i,nS) == 1;
                %---------------------------------------------------------%



                %---------------------------------------------------------%                              
                %Get the right hand side vector at a given time point

                %Multiply dimensionless total adsorption rates by the 
                %coefficients that are relevant for the step for ith column            
                rhsVec = -partCoefHp*cstrHt ...
                      ./ col.(sColNums{i}).gasConsTot ...
                      .* col.(sColNums{i}).adsRatSum;                                                     
                %---------------------------------------------------------%                                                 



                %---------------------------------------------------------%
                %Define matrix sparsity pattern and the boundary condition

                %If we have a boundary condition at the feed-end
                if feEndHasBC == 1

                    %Take account for the boundary condition on the right 
                    %hand side vector
                    vFlBoRhs ...
                        = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);

                    %Update the right hand side vector
                    rhsVec(:,1) ...
                        = vFlBoRhs + rhsVec(:,1);

                %Else, we have a boundary condition at the product-end
                else

                    %Take account for the boundary condition on the right
                    %hand side vector
                    vFlBoRhs ...
                        = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);

                    %Update the right hand side vector
                    rhsVec(:,nVols) ...
                        = -vFlBoRhs + rhsVec(:,nVols);

                end
                %---------------------------------------------------------%                              



                %---------------------------------------------------------%                              
                %Solve for the unknown volumetric flow rates 

                %Solve for dimensionless volumetric flow rates using a 
                %linear solver           
                vFlCol = mldivide(coefMat, rhsVec');            
                %---------------------------------------------------------%                              



                %---------------------------------------------------------%                              
                %Save the results

                %Concatenate the boundary conditions

                %If we have a boundary condition at the feed end 
                if feEndHasBC == 1

                    %We are specifying a volumetric flow rate at the 
                    %feed-end
                    vFlCol = [vFlBoRhs, vFlCol'];

                %Else, we have a boundary condition at the product end     
                else

                    %We are specifying a volumetric flow rate at the 
                    %product-end
                    vFlCol = [vFlCol', vFlBoRhs];

                end
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vFlPlusCol,vFlMinusCol] = calcPseudoVolFlows(vFlCol); 
                %---------------------------------------------------------%

            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %If we are dealing with a time varying pressure DAE model,
            elseif daeModCur(i,nS) == 1

                %---------------------------------------------------------%
                %Unpack additional params
                coefMatLo ...
                    = params.coefMat{i,nS}{1}; %Lower triangular matrix
                coefMatUp ...
                    = params.coefMat{i,nS}{2}; %Upper triangular matrix
                partCoefHp = params.partCoefHp;
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Define the boundary conditions                                     

                %Obtain the boundary condition for the product-end of the 
                %ith column under current step in a given PSA cycle           
                vFlBoPr = ones(nRows,1) ...
                       .* vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);                        

                %Obtain the boundary condition for the feed-end of the ith
                %column under current step in a given PSA cycle
                vFlBoFe = ones(nRows,1) ...
                       .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);           
                %---------------------------------------------------------% 



                %---------------------------------------------------------%
                %Obtain the right hand side vector for time varying 
                %pressure DAE model

                %Get the first order difference between adjacent columns of
                %the total adsorption rates for the current ith column            
                rhsVec = -partCoefHp ...
                      ./ col.(sColNums{i}).gasConsTot(:,2:nVols) ...
                      .* diff(col.(sColNums{i}).adsRatSum,1,2);

                %Add the feed-end boundary condition for the ith column in 
                %nS step in a given PSA cycle
                rhsVec(:,1) = ...
                            + rhsVec(:,1) ...
                            - vFlBoFe/cstrHt(1);

                %Add the product-end boundary condition for the ith column 
                %in nS step in a given PSA cycle
                rhsVec(:,end) = ...
                              + rhsVec(:,end) ...
                              - vFlBoPr/cstrHt(end);                        
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Solve for the unknown volumetric flow rates

                %Solve L(Ux)=b for y where Ly=b with y = Ux            
                vFlCol = mldivide(coefMatLo,rhsVec');

                %Solve Ux = y for x                                  
                vFlCol = mldivide(coefMatUp,vFlCol);
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Save the results

                %Concateante the results
                vFlCol = [vFlBoFe,vFlCol',vFlBoPr];
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vFlPlusCol,vFlMinusCol] = calcPseudoVolFlows(vFlCol); 
                %---------------------------------------------------------%

            end
            %-------------------------------------------------------------%

        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with corrected flow
        %directions (when needed)

        %For each time point,
        for t = 1 : nRows
            
            %Check if a vector has all nonzeros
            vFlPlusZero  = all(vFlPlus(t,:)) ;
            vFlMinusZero = all(vFlMinus(t,:));

            %Check flow reverasl: if both of the pseudo volumetric flow 
            %rate vectors are nonzero, then we have a flow reversal       
            flowDirCheck = vFlPlusZero && ...
                           vFlMinusZero;

            %If flow reversed, then,
            if flowDirCheck == 1
                
                %Save nRows 
                nRowsSave = nRows;
                
                %Iterate for a given time point
                params.nRows = 1;
                
                %Calculate the volumetric flow rates but compute the flow 
                %direction on the fly
                [vFlPlusCol(t,:),vFlMinusCol(t,:)] ...
                    = calcVolFlowsDP0DT0Re(params,units,nS,i);
                
                %Restore the number of rows
                params.nRows = nRowsSave;

            end    
        
        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Save the results to units.col
                                
        %Save the pseudo volumetric flow rates
        units.col.(sColNums{i}).volFlPlus  = vFlPlusCol;
        units.col.(sColNums{i}).volFlMinus = vFlMinusCol;
        
        %Save the volumetric flow rates to a struct
        units.col.(sColNums{i}).volFlRat = vFlPlusCol ...
                                         - vFlMinusCol;                
        %-----------------------------------------------------------------%
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %------------------------------ --------------------------------------% 
    %Determine the volumetric flow rates for the rest of the process flow
    %diagram

    %Grab the unknown volumetric flow rates from the calculated volumetric
    %flow rates from the adsorption columns
    units = calcVolFlows4PFD(params,units,nS);
    %---------------------------------------------------------------------%                                   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%