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
%Code created on       : 2022/3/12/Saturday
%Code last modified on : 2022/11/24/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP1ER.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement Ergun's 
%             equation, for a given column undergoing a given step in a PSA
%             cycle. The assumption in this model is that there is an axial
%             pressure drop, i.e., DP = 1.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlowsDP1ER(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP1ER.m';
    
    %Unpack params   
    nCols        = params.nCols                 ; 
    nVols        = params.nVols                 ;        
    vFlBo        = params.volFlBo               ;    
    sColNums     = params.sColNums              ;
    nRows        = params.nRows                 ;
    coefLinNorm  = params.coefLinNorm(1:nVols-1);
    funcVolUnits = params.funcVolUnits          ;
            
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
    %---------------------------------------------------------------------% 
                                                
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each column
    for i = 1 : nCols
                                                       
        %-----------------------------------------------------------------%
        %Unpack states
        
        %Unpack the total concentra tion variables
        gasConsTot = col.(sColNums{i}).gasConsTot;                 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate state dependent quantities
                
        %Calculate the dimensionless pressure
        presCol = gasConsTot.*cstrTemps;            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate the volumetric flow rates
        
        %For each time point t
        for t = 1 : nRows
        
            %Unpack quadratic coefficient for ith adsorber for the 1st 
            %through (n_c-1)th CSTRs
            coefQuadNorm = col.(sColNums{i}).quadCoeff(t,1:nVols-1);
                        
            %Compute the product of the total concentrations with the 
            %interior temperature
            coefConNorm = -(presCol(t,1:nVols-1)-presCol(t,2:nVols));        
    
            %Evaluate the quadratic dependence of the pressure and compute
            %the volumetric flow rates         
            vFlInterior ...
                = -2 ...
               .* coefConNorm ...
               ./ (coefLinNorm ...
                + sqrt(coefLinNorm.^2 ...
                + 4.*coefQuadNorm ...
               .* abs(coefConNorm)));            
            %-------------------------------------------------------------%


            
            %-------------------------------------------------------------%
            %Save the results for the interior volumetric flow rates

            %Save the volumetric flow rate calculation results
            vFlCol(t,(nVols+1)*(i-1)+2:(nVols+1)*i-1) = vFlInterior;
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Save the interior volumetric flow rates to be used in the boundary
        %condition calculations
        
        %Save the interior volumetric flow rates to be used in the boundary
        %condition calculations
        col.vFlInterior = vFlCol(:,(nVols+1)*(i-1)+2:(nVols+1)*i-1);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Define the boundary conditions                                                         

        %Obtain the boundary condition for the product-end of the 
        %ith column under current step in a given PSA cycle
        vFlBoPr = ones(nRows,1) ...                   
               .* vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i); 

        %Obtain the boundary condition for the feed-end of the ith
        %column under current step in a given PSA cycle
        vFlBoFe = ones(nRows,1) ...                   
               .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Save the results for the boundary conditions

        %Save the volumetric flow rate calculation results
        vFlCol(:,(nVols+1)*(i-1)+1) = vFlBoFe;
        vFlCol(:,(nVols+1)*i)       = vFlBoPr;
        %-----------------------------------------------------------------%
               
    end
    %---------------------------------------------------------------------% 
    

    
    %---------------------------------------------------------------------% 
    %Compute the pseudo volumetric flow rates
        
    %Get the current set of volumetric flow rates for ith adsorber
    vFlColCurr = vFlCol(:,(nVols+1)*(i-1)+1:(nVols+1)*i);
    
    %Call the helper function to calculate the pseudo volumetric flow rates
    [vFlPlusColCurr,vFlMinusColCurr] = calcPseudoVolFlows(vFlColCurr); 
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Save the results to units.col

    %Save the pseudo volumetric flow rates
    units.col.(sColNums{i}).volFlPlus  = vFlPlusColCurr ;
    units.col.(sColNums{i}).volFlMinus = vFlMinusColCurr;

    %Save the volumetric flow rates to a struct
    units.col.(sColNums{i}).volFlRat = vFlColCurr;                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Determine the volumetric flow rates for the rest of the process flow
    %diagram

    %Grab the unknown volumetric flow rates from the calculated volumetric
    %flow rates from the adsorption columns
    units = funcVolUnits(params,units,nS);
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%