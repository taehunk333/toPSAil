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
%Code last modified on : 2022/4/18/Monday
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
    nCols       = params.nCols      ; 
    nVols       = params.nVols      ;        
    vFlBo       = params.volFlBo    ;   
    sColNums    = params.sColNums   ;
    nRows       = params.nRows      ;
    coefLinNorm = params.coefLinNorm;
            
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
    
    %A numeric array for the linear coefficients in the Ergun equation
    coefLinNorm = coefLinNorm ...
                * ones(nRows,(nVols-1));
    %---------------------------------------------------------------------% 
                                                
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each column
    for i = 1 : nCols
        
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
        %Unpack states
        
        %Unpack the total concentrstion variables
        gasConsTot = col.(sColNums{i}).gasConsTot;

        %Unpack the interior temperature variables 
        cstrTemps = col.(sColNums{i}).temps.cstr;
        
        %Define the total concentration variables from the 1st CSTR to
        %(nVols-1)th CSTR
        cNm0 = gasConsTot(:,1:nVols-1);
        cNp1 = gasConsTot(:,2:nVols)  ;
        
        %Define the interior temperature variables from the 1st CSTR to
        %(nVols-1)th CSTR       
        Tnm0 = cstrTemps(:,1:nVols-1);        
        Tnp1 = cstrTemps(:,2:nVols)  ;   
        
        %Unpack quadratic coefficient for ith adsorber for the 1st through
        %n_c-1 CSTRs
        coefQuadNorm = col.(sColNums{i}).quadCoeff(1:nVols-1);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate the volumetric flow rates
        
        %Compute the product of the total concentrations with the interior
        %temperature
        coefConNorm = cNm0.*Tnm0 ...
                    - cNp1.*Tnp1;        

        %Determine the sign of the volumetric flows in the interior of the
        %CIS model
        flowDir = sign(-coefConNorm);
        
        %Take the absolute value and negate deltaP
        coefConNorm = -abs(coefConNorm);
           
        %Evaluate the quadratic dependence of the pressure and compute the 
        %volumetric flow rates         
        vFl = flowDir ...
            * 2 ...
           .* coefConNorm ...
           ./ (coefLinNorm.^2 ...
            + sqrt(coefLinNorm.^2 ...
            - 4*coefQuadNorm ...
           .* coefConNorm));
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Save the results

        %For each time point
        for t = 1 : nRows

            %Save the volumetric flow rate calculated results
            vFlCol(t,(nVols+1)*(i-1)+1:(nVols+1)*i) ...
                = [vFlBoFe(t),vFl(t,:),vFlBoPr(t)];

        end
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------% 
    

    
    %---------------------------------------------------------------------% 
    %Compute the pseudo volumetric flow rates
    
    %Call the helper function to calculate the pseudo volumetric flow rates
    [vFlPlus,vFlMinus] = calcPseudoVolFlows(vFlCol); 
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