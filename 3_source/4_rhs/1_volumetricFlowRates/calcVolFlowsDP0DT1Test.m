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
%Function   : calcVolFlowsDP0DT1Test.m
%Source     : common
%Description: This function always calculates volumetric flow rates by
%             using the methods for computing the pseudo volumetric flow
%             rates along with the directions on-the-fly.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             nS           - jth step in a given PSA cycle
%Outputs    : col          - a struct containing state variables and
%                            calculated quantities associated with
%                            adsorption columns inside the system.
%             feTa         - a struct containing state variables and
%                            calculated quantities associated with feed
%                            tanks inside the system.
%             raTa         - a struct containing state variables and
%                            calculated quantities associated with product
%                            tanks inside the system.
%             exTa         - a struct containing state variables and
%                            calculated quantities associated with extract 
%                            the product tank inside the system 
%             raWa         - a struct containing volumetric flow rate for
%                            the raffinate waste stream 
%             exWa         - a struct containing volumetric flow rate for
%                            the extract waste stream 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlowsDP0DT1Test(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT1.m';
    
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
    flowDir      = params.flowDir     ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
                                                
    
    
    %---------------------------------------------------------------------%                                                               
    %Initialize solution arrays
    
    %Initialize numerical solution array
    vFlPlusCol  = zeros(nRows,nVols+1);
    vFlMinusCol = zeros(nRows,nVols+1);
    %---------------------------------------------------------------------%                                                               
    
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each adsorber
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Obtain the information about the adsorber
        
        %Get the flow direction for (i)th adsorber at (nS)th step       
        flowDirStep = flowDir(i,nS);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Unpack states and calculate time dependent coefficients

            %-------------------------------------------------------------%
            %Unpack states
            
            %We have the down stream total concentration of the 
            %column to be equal to the total concentration in the 
            %first CSTR                
            cnm1 = [col.(sColNums{i}).feEnd.gasConsTot, ...
                    col.(sColNums{i}).gasConsTot(:,1:nVols-1)];
            cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols)   ;
            cnp1 = [col.(sColNums{i}).gasConsTot(:,2:nVols), ...
                        col.(sColNums{i}).prEnd.gasConsTot]  ;

            %Unpack the interior temperature variables                
            Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                    col.(sColNums{i}).temps.cstr(:,1:nVols-1)];
            Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols)   ;
            Tnp1 = [col.(sColNums{i}).temps.cstr(:,2:nVols), ...
                    col.(sColNums{i}).prEnd.temps]           ;

            %Unpack the overall heat capacity
            htCOnm0 = col.n1.htCO;                               
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Compute the species dependent terms

            %Initialize the solution arrays
            termnm1 = zeros(nRows,nVols);
            termnp1 = zeros(nRows,nVols);                                    

            %Compute the temperature ratio
            Tratnm1 = Tnm1./Tnm0;
            Tratnp1 = Tnp1./Tnm0;

            %Loop over each species
            for j = 1: nComs                                                                        

                %Update the nm1 term
                termnm1 = termnm1 ...
                        + (Tratnm1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [col.(sColNums{i}).feEnd. ...
                          gasCons.(sComNums{j}), ...
                          col.(sColNums{i}).gasCons. ...
                          (sComNums{j})(:,1:nVols-1)];

                %Update the np1 term
                termnp1 = termnp1 ...
                        + (Tratnp1*htCapCpNorm(j) ...
                          -htCapCvNorm(j)) ...
                       .* [col.(sColNums{i}).gasCons. ...
                          (sComNums{j})(:,2:nVols), ...
                          col.(sColNums{i}).prEnd. ...
                          gasCons.(sComNums{j})];

            end                            
            %-------------------------------------------------------------%

            
            
            %-------------------------------------------------------------%
            %Get the diagonal entries for the coefficient matrices

            %Get the time dependent coefficient:
            %$\tilde{\alpha}_{n}^{+}$
            alphaPlusN = (-1) ...
                       * ((cnm1./cnm0) ...
                       + gConsNormCol ...
                      .* cstrHt ...
                      ./ htCOnm0 ...
                      .* termnm1); 

            %Get the time dependent coefficient:
            %$\tilde{\alpha}_{n}$
            alphaZeroN = 1 ...
                       + gConsNormCol ...
                      .* cstrHt ...
                      .* cnm0 ...
                      ./ htCOnm0;

            %Get the time dependent coefficient:
            %$\tilde{\alpha}_{n}^{-}$
            alphaMinusN = (-1) ...
                        * ((cnp1./cnm0) ...
                        + gConsNormCol ...
                       .* cstrHt ...
                       ./ htCOnm0 ...
                       .* termnp1);                            
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Save the values of the alphas
            
            %Save the alpha values into params
            params.alphaPlusN  = alphaPlusN ;
            params.alphaZeroN  = alphaZeroN ;
            params.alphaMinusN = alphaMinusN;
            %-------------------------------------------------------------%
           
        %-----------------------------------------------------------------%        
        
        
        
        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with assumed flow
        %directions

            %-------------------------------------------------------------%
            %If we are dealing with a constant pressure DAE model,
            if daeModCur(i,nS) == 0
                
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
                       * col.(sColNums{i}).volAdsRatTot ...
                       + col.(sColNums{i}).volCorRatTot;     
                   
                %Save rhsVec inside the params
                params.rhsVec = rhsVec;
                %---------------------------------------------------------%                                                



                %---------------------------------------------------------%
                %Calculate the pseudo volumetric flow rates

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
                    
                    %Save the boundary conditions
                    params.vFlPlusBoFe  = vFlPlusBoFe ;
                    params.vFlMinusBoFe = vFlMinusBoFe;
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
                    
                    %Save the boundary conditions
                    params.vFlPlusBoPr  = vFlPlusBoPr ;
                    params.vFlMinusBoPr = vFlMinusBoPr;                               
                    %-----------------------------------------------------%
                    
                end
                %---------------------------------------------------------%

            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %If we are dealing with a time varying pressure DAE model,
            elseif daeModCur(i,nS) == 1                        
                
                %---------------------------------------------------------%
                %Initialize solution arrays
                
                %Define numerical arrays for the coefficient matrices
                coefMatPlus3D  = zeros(nVols-1,nVols-1,nRows); 
                coefMatMinus3D = zeros(nVols-1,nVols-1,nRows); 
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
                
                %Save the boundary conditions
                params.vFlPlusBoPr  = vFlPlusBoPr ;
                params.vFlMinusBoPr = vFlMinusBoPr;
                                    
                %Obtain the boundary condition for the feed-end of the ith
                %column under current step in a given PSA cycle
                vFlBoFe = ones(nRows,1) ...                   
                       .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);     
                   
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vFlPlusBoFe,vFlMinusBoFe] = calcPseudoVolFlows(vFlBoFe); 
                
                %Save the boundary conditions
                params.vFlPlusBoFe  = vFlPlusBoFe ;
                params.vFlMinusBoFe = vFlMinusBoFe;
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Obtain the right hand side vector for time varying 
                %pressure DAE model

                %Initialize the right hand side vector for the current time
                %step, by considering the adsorption as well as the 
                %correction for the nonisothermal heat effects
                rhsVec = (1./cstrHt(2:nVols)) ...
                      .* col.(sColNums{i}).volAdsRatTot(:,2:nVols) ...
                       - (1./cstrHt(1:nVols-1)) ...
                      .* col.(sColNums{i}).volAdsRatTot(:,1:nVols-1) ...
                       + (1./cstrHt(1:nVols-1)) ...
                      .* col.(sColNums{i}).volCorRatTot(:,1:nVols-1) ...
                       - (1./cstrHt(2:nVols)) ...
                      .* col.(sColNums{i}).volCorRatTot(:,2:nVols);

                %Add the feed-end boundary condition for the ith column in 
                %nS step in a given PSA cycle
                rhsVec(:,1) ...
                    = rhsVec(:,1) ...
                    - (alphaPlusN(:,1)/cstrHt(1)).*vFlPlusBoFe ...
                    - (alphaZeroN(:,1)/cstrHt(1)).*vFlMinusBoFe;

                %Add the product-end boundary condition for the ith column 
                %in nS step in a given PSA cycle
                rhsVec(:,nVols-1) ...
                    = rhsVec(:,nVols-1) ...
                    + (alphaZeroN(:,nVols)/cstrHt(nVols)).*vFlPlusBoPr ...
                    + (alphaMinusN(:,nVols)/cstrHt(nVols)).*vFlMinusBoPr;                     

                %Save rhsVec in params
                params.rhsVec = rhsVec;                
                %---------------------------------------------------------%
                
                
        
                %---------------------------------------------------------%
                %Calculate the pseudo voluemtric flow rates and save the
                %results

                %If we have a co-current
                if flowDirStep == 0

                    %For each time step t,
                    for t = 1 : nRows

                        %-------------------------------------------------%
                        %Define the coefficient matrix

                        %Define the positive coefficient matrix
                        coefMatPlus = diag(alphaZeroN(t,1:nVols-1) ...
                                         ./cstrHt(1:nVols-1) ...
                                          -alphaPlusN(t,2:nVols) ...
                                         ./cstrHt(2:nVols) ...
                                         ,0) ...
                                    + diag(alphaPlusN(t,2:nVols-1) ...
                                         ./cstrHt(2:nVols-1) ...
                                         ,-1) ...
                                    + diag(-alphaZeroN(t,2:nVols-1) ...
                                         ./cstrHt(2:nVols-1) ...
                                         ,+1);
                                     
                        %Save the coefficient matrix
                        coefMatPlus3D(:,:,t) = coefMatPlus;
                        %-------------------------------------------------%

                    end

                %If we have a counter-current
                elseif flowDirStep == 1

                    %For each time step t,
                    for t = 1 : nRows

                        %-------------------------------------------------%
                        %Define the coefficient matrix

                        %Define the negative coefficient matrix
                        coefMatMinus = diag(alphaMinusN(t,1:nVols-1) ...
                                          ./cstrHt(1:nVols-1)  ...
                                           -alphaZeroN(t,2:nVols) ...
                                          ./cstrHt(2:nVols) ...
                                          ,0) ...                              
                                     + diag(alphaZeroN(t,2:nVols-1) ...
                                          ./cstrHt(2:nVols-1) ...
                                          ,-1) ...
                                     + diag(-alphaMinusN(t,2:nVols-1) ...
                                          ./cstrHt(2:nVols-1) ...
                                          ,+1); 
                                      
                        %Save the coefficient matrix
                        coefMatMinus3D(:,:,t) = coefMatMinus;
                        %-------------------------------------------------%

                    end
                    %-----------------------------------------------------% 

                end
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Save the coefficient matrices for the recourse
                %calculations
                
                %Save the coefficient matrices into params
                params.coefMatPlus3D  = coefMatPlus3D ;
                params.coefMatMinus3D = coefMatMinus3D;
                %---------------------------------------------------------%
                                       
            end
            %-------------------------------------------------------------%
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates with corrected flow
        %directions (when needed)

            %For each time point,
            for t = 1 : nRows

                %---------------------------------------------------------%
                %Do the recourse measure                              
 
                %Save nRows 
                nRowsSave = nRows;

                %Iterate for a given time point
                params.nRows = 1;

                %Calculate the volumetric flow rates but compute the 
                %flow direction on the fly
                [vFlPlusCol(t,:),vFlMinusCol(t,:)] ...
                    = calcVolFlowsDP0DT1Re(params,nS,i,t);

                %Restore the number of rows
                params.nRows = nRowsSave;
                %---------------------------------------------------------%

            end
            %-------------------------------------------------------------%    
            
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
    

    
    %---------------------------------------------------------------------% 
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