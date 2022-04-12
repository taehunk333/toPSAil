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
%Code last modified on : 2022/4/11/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP1ER.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement Ergun's 
%             equation, for a given column undergoing a given step in a PSA
%             cycle. The assumption in this model is that there is an axial
%             pressure drop, i.e., DP = 1, and there is no temperature 
%             change, i.e., DT = 0.
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
    nCols        = params.nCols       ; 
    nVols        = params.nVols       ;        
    vFlBo        = params.volFlBo     ;   
    sColNums     = params.sColNums    ;
    nRows        = params.nRows       ;
    flowDir      = params.flowDir     ;
    coefQuadNorm = params.coefQuadNorm;
    coefLinNorm  = params.coefLinNorm ;
    
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
        %Co-current flow
        if flowDir(i,nS) == 0
                
            %-------------------------------------------------------------%
            %Unpack states

            %Unpack the total concentration variables  

            %We have the down stream total concentration of the column 
            %to be equal to the total concentration in the first CSTR
            cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols-1);                  
            cnp1 = col.(sColNums{i}).gasConsTot(:,2:nVols)  ;

            %Unpack the interior temperature variables
            Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols-1);
            Tnp1 = col.(sColNums{i}).temps.cstr(:,2:nVols)  ;                           
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate needed quantitites

            %Define the dimensionless constant coefficient term, i.e., 
            %$\tilde{e}_n (\tilde{t})$ term for the co-current flow 
            %direction                
            coefConsNorm ...
                = Tnp1.*cnp1 ...
                - Tnm0.*cnm0;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the volumetric flow rates

            %Take the positive root of the quadratic formular in a
            %dimensionless form
            vFl = ((-1)*2*coefConsNorm ...
                  ./(coefLinNorm ...
                  +sqrt(coefLinNorm^2 ...
                  -4*coefQuadNorm ...
                  .*coefConsNorm)));
            %-------------------------------------------------------------%                                                                
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Counter-current flow
        elseif flowDir(i,nS) == 1
        
            %-------------------------------------------------------------%
            %Unpack states

            %Unpack the total concentration variables  

            %We have the down stream total concentration of the column 
            %to be equal to the total concentration in the first CSTR
            cnp1 = col.(sColNums{i}).gasConsTot(:,2:nVols)  ;                  
            cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols-1);

            %Unpack the interior temperature variables
            Tnp1 = col.(sColNums{i}).temps.cstr(:,2:nVols)  ;
            Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols-1);  
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate needed quantitites

            %Define the dimensionless constant coefficient term, i.e., 
            %$\tilde{e}_n (\tilde{t})$ term for the co-current flow 
            %direction                
%             coefConsNorm ...
%                 = Tnm0.*cnm0 ...
%                 - Tnp1.*cnp1;
              coefConsNorm ...
                = 0.0000005*ones(1,nVols-1);
            
%             %Update the coefficients with the length of penetration into an
%             %adsorption column
%             coefQuadNorm ...
%                 = coefQuadNorm ...
%                 * linspace(nVols-1,1,nVols-1);            
%             coefLinNorm ...
%                 = coefLinNorm ...
%                 * linspace(nVols-1,1,nVols-1);
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calculate the volumetric flow rates

            %Take the positive root of the quadratic formular in a
            %dimensionless form; the negative sign was added for the
            %counter-current flow          
            vFl = (-1).*((-1).*2.*coefConsNorm ...
                  ./(coefLinNorm ...
                  +sqrt(coefLinNorm.^2 ...
                  -4.*coefQuadNorm ...
                  .*coefConsNorm)));
            %-------------------------------------------------------------%                                                                       
            
        end
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