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
    flowDir     = params.flowDir    ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Calcualte the pseudo volumetric flow rates associated with adsorption
    %columns
    
    %For each adsorber
    for i = 1 : nCols
    
        %-----------------------------------------------------------------%
        %Obtain the information about the adsorber
        
        %Get the flow direction for (i)th adsorber at (nS)th step       
        flowDirStep = flowDir(i,nS);
        %-----------------------------------------------------------------%
        
        

        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with assumed flow
        %directions

            %-------------------------------------------------------------%
            %If we are dealing with a constant pressure DAE model,
            if daeModCur(i,nS) == 0

                %---------------------------------------------------------%
                %Unpack additional params
                coefMatPlus  = params.coefMat{i,nS}{1};
                coefMatMinus = params.coefMat{i,nS}{2};
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
                rhsVec = (-1) ...
                       * col.(sColNums{i}).volAdsRatTot;                                                     
                %---------------------------------------------------------%                                                 



                %---------------------------------------------------------%
                %Define matrix sparsity pattern and the boundary condition

                %If we have a boundary condition at the feed-end
                if feEndHasBC == 1

                    %-----------------------------------------------------% 
                    %Handle the boundary condition
                    
                    %Take account for the boundary condition on the right 
                    %hand side vector
                    vFlBoFe ...
                        = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                    
                    %Call the helper function to calculate the pseudo 
                    %volumetric flow rates
                    [vFlPlusBoFe,vFlMinusBoFe] ...
                        = calcPseudoVolFlows(vFlBoFe);

                    %Update the right hand side vector
                    rhsVec(:,1) = rhsVec(:,1) ...
                                + vFlPlusBoFe ...
                                - vFlMinusBoFe;
                    %-----------------------------------------------------%  
                    
                    
                    
                    %-----------------------------------------------------%                              
                    %Solve for the unknown volumetric flow rates, depending
                    %on the flow direction
                    
                    %For counter-current flow,
                    if flowDirStep == 1
                        
                        %-------------------------------------------------%
                        %Calculate the pseudo volumetric flwo rates
                        
                        %Set the positive pseudo volumetric flow rates
                        %equal to a zero vector
                        vFlPlusCol = zeros(nRows,nVols+1);
                        
                        %Solve for dimensionless volumetric flow rates 
                        %using a linear solver           
                        vFlMinusCol = mldivide(coefMatMinus,rhsVec');
                        %-------------------------------------------------%
                        
                        
                        
                        %-------------------------------------------------%
                        %Save the results

                        %We are specifying a volumetric flow rate at the 
                        %feed-end
                        vFlMinusCol = [vFlMinusBoFe,vFlMinusCol'];
                        %-------------------------------------------------%
                                                
                    %For co-current flow, 
                    elseif flowDirStep == 0
                        
                        %-------------------------------------------------%
                        %Calculate the pseudo volumetric flwo rates
                        
                        %Set the negative pseudo volumetric flow rates
                        %equal to a zero vector
                        vFlMinusCol = zeros(nRows,nVols+1);
                        
                        %Solve for dimensionless volumetric flow rates 
                        %using a linear solver           
                        vFlPlusCol = mldivide(coefMatPlus,rhsVec');
                        %-------------------------------------------------%

                        
                        
                        %-------------------------------------------------%
                        %Save the results

                        %We are specifying a volumetric flow rate at the 
                        %feed-end
                        vFlPlusCol = [vFlPlusBoFe,vFlPlusCol'];
                        %-------------------------------------------------%
                        
                    end                                                    
                    %-----------------------------------------------------%

                %Else, we have a boundary condition at the product-end
                else

                    %-----------------------------------------------------%  
                    %Handle the boundary condition
                    
                    %Take account for the boundary condition on the right
                    %hand side vector
                    vFlBoPr ...
                        = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                    
                    %Call the helper function to calculate the pseudo 
                    %volumetric flow rates
                    [vFlPlusBoPr,vFlMinusBoPr] ...
                        = calcPseudoVolFlows(vFlBoPr);

                    %Update the right hand side vector
                    rhsVec(:,nVols) = rhsVec(:,nVols)...
                                    - vFlPlusBoPr ...
                                    + vFlMinusBoPr;
                    %-----------------------------------------------------%  
                    
                    
                                
                    %-----------------------------------------------------%                              
                    %Solve for the unknown volumetric flow rates, depending
                    %on the flow direction
                    
                    %For counter-current flow,
                    if flowDirStep == 1
                        
                        %-------------------------------------------------%
                        %Calculate the pseudo volumetric flwo rates
                        
                        %Set the positive pseudo volumetric flow rates
                        %equal to a zero vector
                        vFlPlusCol = zeros(nRows,nVols+1);
                        
                        %Solve for dimensionless volumetric flow rates 
                        %using a linear solver           
                        vFlMinusCol = mldivide(coefMatMinus,rhsVec');
                        %-------------------------------------------------%
                        
                        
                        
                        %-------------------------------------------------%
                        %Save the results

                        %We are specifying a volumetric flow rate at the 
                        %feed-end
                        vFlMinusCol = [vFlMinusCol',vFlMinusBoPr];
                        %-------------------------------------------------%
                                                
                    %For co-current flow, 
                    elseif flowDirStep == 0
                        
                        %-------------------------------------------------%
                        %Calculate the pseudo volumetric flwo rates
                        
                        %Set the negative pseudo volumetric flow rates
                        %equal to a zero vector
                        vFlMinusCol = zeros(nRows,nVols+1);
                        
                        %Solve for dimensionless volumetric flow rates 
                        %using a linear solver           
                        vFlPlusCol = mldivide(coefMatPlus,rhsVec');
                        %-------------------------------------------------%

                        
                        
                        %-------------------------------------------------%
                        %Save the results

                        %We are specifying a volumetric flow rate at the 
                        %feed-end
                        vFlPlusCol = [vFlPlusCol',vFlPlusBoPr];
                        %-------------------------------------------------%
                        
                    end                                                    
                    %-----------------------------------------------------%

                end
                %---------------------------------------------------------%                              

            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %If we are dealing with a time varying pressure DAE model,
            elseif daeModCur(i,nS) == 1

                %---------------------------------------------------------%
                %Unpack additional params
                
                %Depending on the flow direction, unpack the coefficient
                %matrices
                
                %For a counter current,
                if flowDirStep == 1
                    
                    %Obtain the coefficient matrices
                    loTriVaPr ... %Lower triangular matrix
                        = -params.coefMat{i,nS}{1}; 
                    upTriVaPr ... %Upper triangular matrix
                        = -params.coefMat{i,nS}{2}; 
                
                %For a co-current,
                elseif flowDirStep == 0
                    
                    %Obtain the coefficient matrices
                    loTriVaPr ... %Lower triangular matrix
                        = params.coefMat{i,nS}{1}; 
                    upTriVaPr ... %Upper triangular matrix
                        = params.coefMat{i,nS}{2};
                    
                end
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Define the boundary conditions and the pseudo volumetric 
                %flow rates                               

                %Obtain the boundary condition for the product-end of the 
                %ith column under current step in a given PSA cycle           
                vFlBoPr = ones(nRows,1) ...
                       .* vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);   
                   
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vFlPlusBoPr,vFlMinusBoPr] = calcPseudoVolFlows(vFlBoPr);

                %Obtain the boundary condition for the feed-end of the ith
                %column under current step in a given PSA cycle
                vFlBoFe = ones(nRows,1) ...
                       .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);  
                   
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vFlPlusBoFe,vFlMinusBoFe] = calcPseudoVolFlows(vFlBoFe);
                %---------------------------------------------------------% 



                %---------------------------------------------------------%
                %Obtain the right hand side vector for time varying 
                %pressure DAE model

                %Get the first order difference between adjacent columns of
                %the total adsorption rates for the current ith column            
                rhsVec = (1./cstrHt(2:nVols)) ...
                      .* col.(sColNums{i}).volAdsRatTot(:,2:nVols) ...
                       - (1./cstrHt(1:nVols-1)) ...
                      .* col.(sColNums{i}).volAdsRatTot(:,1:nVols-1);

                %Add the feed-end boundary condition for the ith column in 
                %nS step in a given PSA cycle
                rhsVec(:,1) = rhsVec(:,1) ...
                            + (1/cstrHt(1))*vFlPlusBoFe ...
                            - (1/cstrHt(1))*vFlMinusBoFe;

                %Add the product-end boundary condition for the ith column 
                %in nS step in a given PSA cycle
                rhsVec(:,nVols-1) = rhsVec(:,nVols-1) ...
                                  + (1/cstrHt(nVols))*vFlPlusBoPr ...
                                  - (1/cstrHt(nVols))*vFlMinusBoPr;                        
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Calculate the pseudo voluemtric flow rates and save the
                %results
  
                %If we have a co-current
                if flowDirStep == 0
                    
                    %-----------------------------------------------------%
                    %Solve for the unknown volumetric flow rates

                    %Solve L(Ux)=b for y where Ly=b with y = Ux            
                    vFlPlusCol = mldivide(loTriVaPr,rhsVec');

                    %Solve Ux = y for x                                  
                    vFlPlusCol = mldivide(upTriVaPr,vFlPlusCol);
                    
                    %Concatenate the boundary conditions
                    vFlPlusCol ...
                        = [vFlPlusBoFe,vFlPlusCol',vFlPlusBoPr];  
                    
                    %Set the negative pseudo volumetric flow rate equal to
                    %a zero vector
                    vFlMinusCol = zeros(nRows,nVols+1);
                    %-----------------------------------------------------%
                                        
                %If we have a counter-current
                elseif flowDirStep == 1
                                                                                            
                    %-----------------------------------------------------%
                    %Solve for the unknown volumetric flow rates

                    %Solve L(Ux)=b for y where Ly=b with y = Ux            
                    vFlMinusCol = mldivide(loTriVaPr,rhsVec');

                    %Solve Ux = y for x                                  
                    vFlMinusCol = mldivide(upTriVaPr,vFlMinusCol);
                    
                    %Make sure that the negative pseudo voluemtric flow 
                    %rate is positive
                    vFlMinusCol = abs(vFlMinusCol);
                    
                    %Concatenate the boundary conditions
                    vFlMinusCol ...
                        = [vFlMinusBoFe,vFlMinusCol',vFlMinusBoPr];               
                    
                    %Set the positive pseudo volumetric flow rate equal to
                    %a zero vector
                    vFlPlusCol = zeros(nRows,nVols+1);
                    %-----------------------------------------------------%
                  
                end
                %---------------------------------------------------------%

            end
            %-------------------------------------------------------------%

        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with corrected flow
        %directions (when needed)

        %For each time point,
        for t = 1 : nRows
            
            %-------------------------------------------------------------%
            %Check the flow reversal 
            
            %For co-current flow
            if flowDirStep == 0
                
                %Check if the negative pseudo voluemtric flow rate vector 
                %has all nonzeros      
                flowDirCheck = all(vFlMinusCol(t,:));
                
            %For counter-current flow
            elseif flowDirStep == 1
                
                %Check if the positive pseudo voluemtric flow rate vector 
                %has all nonzeros      
                flowDirCheck = all(vFlPlusCol(t,:));
                
            end                        
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Do the recourse measure
            
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
            %-------------------------------------------------------------%
        
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