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
%Code last modified on : 2022/4/13/Wednesday
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
    nCols     = params.nCols     ; 
    nVols     = params.nVols     ;        
    vFlBo     = params.volFlBo   ;   
    daeModCur = params.daeModel  ;
    cstrHt    = params.cstrHt    ; 
    sColNums  = params.sColNums  ;
    nRows     = params.nRows     ;
    valConT   = params.valConT   ;
    
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
            feEndBC = valConT(2*(i-1)+1,nS) == 1 && ...
                      valConT(2*i,nS) ~= 1;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%                              
            %Get the right hand side vector at a given time point
            
            %Multiply dimensionless total adsorption rates by the 
            %coefficients that are relevant for the step for ith column            
            rhsVec = (-1)*col.(sColNums{i}).volAdsRatTot;
            %-------------------------------------------------------------%                                                 

            
            
            %-------------------------------------------------------------%
            %Depending on the boundary conditions, calculate the pseudo 
            %volumetric flow rates

            %If we have a boundary condition at the feed-end
            if feEndBC == 1
                
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
                for t = 1 : nVols
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,t) ...
                               + vFlPlus(:,shiftFac+t) ...
                               - vFlMinus(:,shiftFac+t);
                      
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,shiftFac+t+1) ...
                        = rhsVecEval ... 
                       .* flowDir ;
                    vFlMinus(:,shiftFac+t+1) ...
                        = (-1)*rhsVecEval ...
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
                for t = nVols : -1 : 1                                        
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,t) ...
                               - vFlPlus(:,shiftFac+t+1) ...
                               + vFlMinus(:,shiftFac+t+1);
                    
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,shiftFac+t) ...
                        = (-1)*rhsVecEval ...
                       .* (1-flowDir) ;
                    vFlMinus(:,shiftFac+t) ...
                        = rhsVecEval ...
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
            dTriDiag = params.dTriDiag;
            options  = params.linprog.opts;
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
                          
            %Calculate the volumic adsorption rate terms
            rateNm1 = col.(sColNums{i}).volAdsRatTot(:,1:nVols-1) ...
                   ./ cstrHt(:,1:nVols-1);
            rateNm0 = col.(sColNums{i}).volAdsRatTot(:,2:nVols) ...
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
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Solve for the unknown volumetric flow rates
                        
            %A numeric array for the volumetric flow rates for the 
            %adsorption columns
            vFlPseudo = zeros(nRows,nCols*2*(nVols-1));
                                                        
            %Solve a linear program for each time point
            for t = 1 : nRows
                
                %Solve the LP using linprog.m
                vFlPseudo(t,2*(nVols-1)*(i-1)+1:2*(nVols-1)*i) ...
                    = linprog(ones(1,2*(nVols-1)), ...
                              [], ...
                              [], ...
                              dTriDiag, ...
                              rhsVec(t,:)', ...
                              zeros(1,2*(nVols-1)), ...
                              Inf*ones(1,2*(nVols-1)), ...
                              options);
                          
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