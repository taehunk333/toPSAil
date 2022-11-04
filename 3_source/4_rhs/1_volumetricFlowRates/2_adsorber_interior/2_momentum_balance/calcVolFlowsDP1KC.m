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
%Code created on       : 2022/4/17/Sunday
%Code last modified on : 2022/10/22/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP1KC.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement Kozeny-Carman 
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

function units = calcVolFlowsDP1KC(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP1KC.m';
    
    %Unpack params   
    nCols         = params.nCols                     ; 
    nVols         = params.nVols                     ;        
    vFlBo         = params.volFlBo                   ;   
    sColNums      = params.sColNums                  ;
    nRows         = params.nRows                     ;
    preFacLinFlow = params.preFacLinFlow(1,1:nVols-1);
    funcVolUnits  = params.funcVolUnits              ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
    
      
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each column
    for i = 1 : nCols
        
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
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate the volumetric flow rates
        
        %Compute the product of the total concentrations with the interior
        %temperature
        deltaP = cNm0.*Tnm0 ...
               - cNp1.*Tnp1;        

%         pDown = cNm0.*Tnm0;
%         pUp   = cNp1.*Tnp1;
%         
%         deltaP = (pDown.^2)./(pDown+pUp) ...
%                - (pUp.^2)./(pDown+pUp); 

%         deltaP = repmat(linspace(1e-1,1e-3,nVols-1),nRows,1);

%         deltaP = (1e-1)*ones(nRows,nVols-1);

        %Evaluate the linear difference in the pressure and compute the 
        %volumetric flow rates         
        vFlInterior = preFacLinFlow ...
                   .* deltaP;                             

        %Save the interior volumetric flow rates
        col.vFlInterior = vFlInterior;
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
        vFlCol = [vFlBoFe,vFlInterior,vFlBoPr];
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------% 
        %Compute the pseudo volumetric flow rates        
        
        %Call the helper function to calculate the pseudo volumetric flow 
        %rates
        
        [vFlPlusCol,vFlMinusCol] = calcPseudoVolFlows(vFlCol); 
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------%
        %Save the results to units.col

        %Save the pseudo volumetric flow rates
        units.col.(sColNums{i}).volFlPlus  = vFlPlusCol ;
        units.col.(sColNums{i}).volFlMinus = vFlMinusCol;

        %Save the volumetric flow rates to a struct
        units.col.(sColNums{i}).volFlRat = vFlCol;                
        %-----------------------------------------------------------------%
        
    end
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