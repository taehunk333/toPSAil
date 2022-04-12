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
%Code created on       : 2022/2/18/Friday
%Code last modified on : 2022/4/12/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP0DT1.m
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

function units = calcVolFlowsDP0DT1(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT1.m';
    
    %Unpack params   
    nCols     = params.nCols   ; 
    nVols     = params.nVols   ;        
    vFlBo     = params.volFlBo ;   
    daeModCur = params.daeModel; 
    sColNums  = params.sColNums;
    nRows     = params.nRows   ;
    flowDir   = params.flowDir ;
    valConT   = params.valConT ;
    nComs     = params.nComs   ;
    sComNums  = params.sComNums;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %A numeric array for the volumetric flow rates for the adsorption
    %columns
    vFlCol = zeros(nRows,nCols*(nVols+1));    
    
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
        %If we are dealing with a constant pressure DAE model,
        if daeModCur(i,nS) == 0
            
            %-------------------------------------------------------------%
            %Define needed quantities
            
            %Unpack additional params
            cstrHt         = params.cstrHt        ;
            gasConsNormCol = params.gasConsNormCol;
            htCapCvNorm    = params.htCapCvNorm   ;
            htCapCpNorm    = params.htCapCpNorm   ;                                    
            %-------------------------------------------------------------%
            
            
           
            %-------------------------------------------------------------%
            %Decide which boundary condition is given
            
            %Check if we have a boundary condition specified at the
            %feed-end of the ith adsorber
            feEndBC = valConT(2*(i-1)+1,nS) == 1 && ...
                      valConT(2*i,nS) ~= 1;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Define the coefficients
            
            %For a co-current flow,
            if flowDir(i,nS) == 0  
                
                %---------------------------------------------------------%
                %Unpack states
                
                %Unpack the total concentration variables  
                
                %We have the down stream total concentration of the column 
                %to be equal to the total concentration in the first CSTR                
                cnm1 = [col.(sColNums{i}).feEnd.gasConsTot, ...
                       col.(sColNums{i}).gasConsTot(:,1:nVols-1)];
                cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols)   ;
                
                %Unpack the interior temperature variables                
                Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                       col.(sColNums{i}).temps.cstr(:,1:nVols-1)];
                Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols)   ;
                
                %Unpack the overall heat capacity
                htCOnm0 = col.n1.htCO;                               
                %---------------------------------------------------------%
                
                
                                
                %---------------------------------------------------------%
                %Compute the species dependent terms
                
                %Initialize the solution arrays
                termnm1 = zeros(nRows,nVols);
                
                %Compute the temperature ratio
                Tratnm1 = Tnm1./Tnm0;
                
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
                                        
                end                            
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Get the diagonal entries for the both coefficients
                
                %Get the diagonal entries
                coefnm1 = (-1) ...
                        * ((cnm1./cnm0) ...
                        + gasConsNormCol ...
                       .* cstrHt ...
                       ./ htCOnm0 ...
                       .* termnm1);                                    
                
                %Get the diagonal entries
                coefnm0 = 1 ...
                        + gasConsNormCol ...
                       .* cstrHt ...
                       .* cnm0 ...
                       ./ htCOnm0;                                                                 
                %---------------------------------------------------------%                                                
                
            %For a counter-current flow,
            elseif flowDir(i,nS) == 1         
                
                %---------------------------------------------------------%
                %Unpack states
                
                %Unpack the total concentration variables  
                
                %We have the up stream total concentration of the column 
                %to be equal to the total concentration in the last CSTR                                
                cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols);
                cnp1 = [col.(sColNums{i}).gasConsTot(:,2:nVols), ...
                        col.(sColNums{i}).prEnd.gasConsTot];
                
                %Unpack the interior temperature variables                                
                Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols);
                Tnp1 = [col.(sColNums{i}).temps.cstr(:,2:nVols), ...
                        col.(sColNums{i}).prEnd.temps];
                
                %Unpack the overall heat capacity
                htCOnm0 = col.n1.htCO;                               
                %---------------------------------------------------------%
                
                
                                
                %---------------------------------------------------------%
                %Compute the species dependent terms
                
                %Initialize the solution arrays
                termnp1 = zeros(nRows,nVols);
                
                %Compute the temperature ratio
                Tratnp1 = Tnp1./Tnm0;
                
                %Loop over each species
                for j = 1: nComs                                                                        
                    
                    %Update the nm1 term
                    termnp1 = termnp1 ...
                            + (Tratnp1*htCapCpNorm(j) ...
                              -htCapCvNorm(j)) ...
                           .* [col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,2:nVols), ...
                              col.(sColNums{i}).prEnd. ...
                              gasCons.(sComNums{j})];
                                        
                end                            
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Get the diagonal entries
                
                %Get the diagonal entries
                coefnm1 = (-1) ...
                        * (1+gasConsNormCol ...
                       .*  cstrHt ...
                       .*  cnm0 ...
                       ./  htCOnm0);                                    
                
                %Get the diagonal entries
                coefnm0 = ((cnp1./cnm0) ...
                        + gasConsNormCol ...
                       .* cstrHt ...
                       ./ htCOnm0 ...
                       .* termnp1);                                                                 
                %---------------------------------------------------------%
                                                
            end
            %-------------------------------------------------------------%                        
            
            
            
            %-------------------------------------------------------------%                              
            %Get the right hand side vector at a given time point
            
            %Multiply dimensionless total adsorption rates by the 
            %coefficients that are relevant for the step for ith column            
            rhsVec = (-1) ...
                   * col.(sColNums{i}).volAdsRatTot ...
                   + col.(sColNums{i}).volCorRatTot;                                                     
            %-------------------------------------------------------------%                                                
            
            
            
            %-------------------------------------------------------------%
            %Define matrix sparsity pattern and the boundary condition

            %If we have a boundary condition at the feed-end
            if feEndBC == 1

                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);                               
                
                %Update the right hand side vector
                rhsVec(:,1) = rhsVec(:,1) ...
                            - coefnm1(:,1) ...
                           .* vFlBoRhs;
            
            %Else, we have a boundary condition at the product-end
            else
                
                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Update the right hand side vector
                rhsVec(:,nVols) = rhsVec(:,nVols) ...
                                - coefnm0(:,nVols) ...
                               .* vFlBoRhs;
                
            end
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------% 
            %Loop over each time point and compute the volumetric flow
            %rates around each adsorption column
            
            %For each time point
            for t = 1 : nRows
                
                %---------------------------------------------------------% 
                %Define the coefficient matrix

                %For a given boundary condition at the feed-end
                if feEndBC == 1

                    %Combine the main and the off diagonal entries
                    coefMat = diag(coefnm1(t,2:nVols),-1) ...
                            + diag(coefnm0(t,:),0);             

                %For a given boundary condition at the product-end
                elseif feEndBC == 0                    

                    %Combine the main and the off diagonal entries
                    coefMat = diag(coefnm0(t,1:nVols-1),+1) ...
                            + diag(coefnm1(t,:),0);

                end                        
                %---------------------------------------------------------% 



                %---------------------------------------------------------%                              
                %Solve for the unknown volumetric flow rates 

                %Solve for dimensionless volumetric flow rates using a 
                %linear solver           
                vFl = mldivide(coefMat, rhsVec(t,:)');            
                %---------------------------------------------------------%                              



                %---------------------------------------------------------%                              
                %Save the results

                %Concatenate the boundary conditions

                %If we have a boundary condition at the feed end 
                if feEndBC == 1

                    %We are specifying a volumetric flow rate at the 
                    %feed-end
                    vFl = [vFlBoRhs(t), vFl'];

                %Else, we have a boundary condition at the product end     
                else

                    %We are specifying a volumetric flow rate at the 
                    %product-end
                    vFl = [vFl', vFlBoRhs(t)];

                end

                %Save the volumetric flow rate calculated results
                vFlCol(t,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl;
                
                %Call the helper function to calculate the pseudo volumetric 
                %flow rates
                [vPlus,vMinus] = calcPseudoVolFlows(vFlCol); 

                %Save the pseudo volumetric flow rates
                vFlPlus(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus ;
                vFlMinus(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus;
                %---------------------------------------------------------%                                    
            
            end
            %-------------------------------------------------------------%                                                                              
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If we are dealing with a time varying pressure DAE model,
        elseif daeModCur(i,nS) == 1

            %-------------------------------------------------------------%
            %Define needed quantities
            
            %Unpack additional params
            cstrHt         = params.cstrHt        ;
            gasConsNormCol = params.gasConsNormCol;
            htCapCvNorm    = params.htCapCvNorm   ;
            htCapCpNorm    = params.htCapCpNorm   ;                                    
            %-------------------------------------------------------------%

                        
            
            %-------------------------------------------------------------%
            %Define the coefficients                   
            
            %For a co-current flow,
            if flowDir(i,nS) == 0  
                
                %---------------------------------------------------------%
                %Unpack states
                
                %Unpack the total concentration variables  
                
                %We have the down stream total concentration of the column 
                %to be equal to the total concentration in the first CSTR
                cnm2 = [col.(sColNums{i}).feEnd.gasConsTot, ...
                        col.(sColNums{i}).gasConsTot(:,1:nVols-2)];                  
                cnm1 = col.(sColNums{i}).gasConsTot(:,1:nVols-1)  ;
                cnm0 = col.(sColNums{i}).gasConsTot(:,2:nVols)    ;
                
                %Unpack the interior temperature variables
                Tnm2 = [col.(sColNums{i}).feEnd.temps, ...
                        col.(sColNums{i}).temps.cstr(:,1:nVols-2)];
                Tnm1 = col.(sColNums{i}).temps.cstr(:,1:nVols-1)  ;
                Tnm0 = col.(sColNums{i}).temps.cstr(:,2:nVols)    ;
                
                %Unpack the overall heat capacity
                htCOnm1 = col.n1.htCO(:,1:nVols-1);
                htCOnm0 = col.n1.htCO(:,2:nVols)  ;                               
                %---------------------------------------------------------%
                
                
                                
                %---------------------------------------------------------%
                %Compute the species dependent terms
                
                %Initialize the solution arrays
                termnm2 = zeros(nRows,nVols-1);
                termnm1 = zeros(nRows,nVols-1);
                
                %Compute the temperature ratios
                Tratnm2 = Tnm2./Tnm1;
                Tratnm1 = Tnm1./Tnm0;
                
                %Loop over each species
                for j = 1: nComs
                                                        
                    %Update the nm2 term
                    termnm2 = termnm2 ...
                            + (Tratnm2*htCapCpNorm(j) ...
                              -htCapCvNorm(j)) ...
                           .* [col.(sColNums{i}).feEnd. ...
                              gasCons.(sComNums{j}), ...
                              col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,1:nVols-2)];                    
                    
                    %Update the nm1 term
                    termnm1 = termnm1 ...
                            + (Tratnm1*htCapCpNorm(j) ...
                              -htCapCvNorm(j)) ...
                           .* col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,1:nVols-1);
                                        
                end                            
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Get the diagonal entries
                
                %Get the -1 diagonal entries
                coefnm2 = (-1) ...
                        * (cnm2./cnm1./cstrHt(2:nVols) ...
                        + gasConsNormCol./htCOnm0.*termnm2);                                    
                
                %Get the diagonal entries
                coefnm1 = (cnm1./cnm0./cstrHt(2:nVols) ...
                        + 1./cstrHt(1:nVols-1) ...
                        + gasConsNormCol.*cnm1./htCOnm1 ...
                        + gasConsNormCol./htCOnm0.*termnm1);                                    
                
                %Get the +1 diagonal entries
                coefnm0 = (-1) ...
                        * (1./cstrHt(2:nVols) ...
                        +  gasConsNormCol.*cnm0./htCOnm0);                               
                %---------------------------------------------------------%                                                             

            %For a counter-current flow,
            elseif flowDir(i,nS) == 1
                
                %---------------------------------------------------------%
                %Unpack states
                
                %Unpack the total concentration variables  
                
                %We have the up stream total concentration of the column 
                %to be equal to the total concentration in the last CSTR                                  
                cnm1 = col.(sColNums{i}).gasConsTot(:,1:nVols-1)   ;
                cnm0 = col.(sColNums{i}).gasConsTot(:,2:nVols)     ;
                cnp1 = [col.(sColNums{i}).gasConsTot(:,3:nVols), ...
                        col.(sColNums{i}).prEnd.gasConsTot]        ;
                
                %Unpack the interior temperature variables                
                Tnm1 = col.(sColNums{i}).temps.cstr(:,1:nVols-1)     ;
                Tnm0 = col.(sColNums{i}).temps.cstr(:,2:nVols)       ;
                Tnp1 = [col.(sColNums{i}).temps.cstr(:,3:nVols), ...
                        col.(sColNums{i}).prEnd.temps];
                
                %Unpack the overall heat capacity
                htCOnm1 = col.n1.htCO(:,1:nVols-1);
                htCOnm0 = col.n1.htCO(:,2:nVols)  ;                               
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Compute the species dependent terms
                
                %Initialize the solution arrays
                termnm0 = zeros(nRows,nVols-1);
                termnp1 = zeros(nRows,nVols-1);
                
                %Compute the temperature ratios
                Tratnm0 = Tnm0./Tnm1;
                Tratnp1 = Tnp1./Tnm0;
                
                %Loop over each species
                for j = 1: nComs
                                                        
                    %Update the nm0 term
                    termnm0 = termnm0 ...
                            + (Tratnm0*htCapCpNorm(j) ...
                              -htCapCvNorm(j)) ...
                           .* col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,2:nVols);                    
                    
                    %Update the np1 term
                    termnp1 = termnp1 ...
                            + (Tratnp1*htCapCpNorm(j) ...
                              -htCapCvNorm(j)) ...
                           .* [col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,3:nVols), ...
                              col.(sColNums{i}).prEnd. ...
                              gasCons.(sComNums{j})];
                                        
                end                            
                %---------------------------------------------------------% 
                
                
                
                %---------------------------------------------------------%
                %Get the diagonal entries
                
                %Get the -1 diagonal entries
                coefnm2 = (-1) ...
                        * (1./cstrHt(1:nVols-1) ...
                        + gasConsNormCol.*cnm1./htCOnm1);                                    
                
                %Get the diagonal entries
                coefnm1 = (1./cstrHt(2:nVols) ...
                        + cnm0./cnm1./cstrHt(1:nVols-1) ...
                        + gasConsNormCol.*cnm0./htCOnm0 ...
                        + gasConsNormCol./htCOnm1.*termnm0);                                    
                
                %Get the +1 diagonal entries
                coefnm0 = (-1) ...
                        * (cnp1./cnm0./cstrHt(2:nVols) ...
                        + gasConsNormCol./htCOnm0.*termnp1);                               
                %---------------------------------------------------------% 
                
            end
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
                        - coefnm2(:,1) ...
                       .* vFlBoFe;
                        
            %Add the product-end boundary condition for the ith column in
            %nS step in a given PSA cycle
            rhsVec(:,end) = rhsVec(:,end) ...
                          - coefnm0(:,end) ...
                         .* vFlBoPr;                       
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------% 
            %Loop over each time point and compute the volumetric flow
            %rates around each adsorption column
            
            %For each time point
            for t = 1 : nRows
                
                %---------------------------------------------------------%
                %Define the coefficient matrix

                %Combine the main and the off diagonal entries
                coefMat = diag(coefnm2(t,2:end),-1) ...
                        + diag(coefnm1(t,:),0) ...
                        + diag(coefnm0(t,1:end-1),+1);                                   
                %---------------------------------------------------------%                                   



                %---------------------------------------------------------%
                %Solve for the unknown volumetric flow rates

                %Solve the liner system          
                vFl = mldivide(coefMat,rhsVec(t,:)');
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Save the results

                %Concateante the results
                vFl = [vFlBoFe(t),vFl',vFlBoPr(t)];

                %Save the volumetric flow rate calculated results
                vFlCol(t,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl;
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vPlus,vMinus] = calcPseudoVolFlows(vFlCol); 

                %Save the pseudo volumetric flow rates
                vFlPlus(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus ;
                vFlMinus(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus;
                %---------------------------------------------------------%                
                
            end                                    
            %-------------------------------------------------------------%                        
            
        end
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%                               
    
    
    
    %---------------------------------------------------------------------% 
    %Determine the volumetric flow rates for the rest of the process flow
    %diagram

    %Grab the unknown volumetric flow rates from the calculated volumetric
    %flow rates from the adsorption columns
    units = calcVolFlows4PFD(params,units,vFlPlus,vFlMinus,nS);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%