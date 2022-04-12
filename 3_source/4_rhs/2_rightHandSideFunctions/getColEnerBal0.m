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
%Code created on       : 2021/1/28/Thursday
%Code last modified on : 2022/3/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getColEnerBal0.m
%Source     : common
%Description: a function that evaluates the energy balance right hand side
%             relationship for the current time point for all adsorption
%             columns.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getColEnerBal0(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Check to see if we need an energy balance
    
    %Unpack minimal number of params
    sColNums = params.sColNums;
    bool     = params.bool    ;
    nVols    = params.nVols   ;
    nCols    = params.nCols   ;
    
    %Unpack units
    col = units.col;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %For each adsorption column,
        for i = 1 : nCols
        
            %Don't do the energy balance on the columns
            col.(sColNums{i}).cstrEnBal = zeros(1,nVols);            
            col.(sColNums{i}).wallEnBal = zeros(1,nVols);  
            
        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                          
        %Return the updated structure for the units

        %Pack units
        units.col = col;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Skip the non-isothermal simulation
        
        %Return to the invoking function 
        return;
        %-----------------------------------------------------------------%
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColEnerBal0.m';
    
    %Unpack params    
    nCols          = params.nCols         ;
    nRows          = params.nRows         ;
    nComs          = params.nComs         ;    
    intHtTrFacCol  = params.intHtTrFacCol ;
    extHtTrFacCol  = params.extHtTrFacCol ;
    nVols          = params.nVols         ;     
    isoStHtNorm    = params.isoStHtNorm   ;
    partCoefHp     = params.partCoefHp    ;
    gasConsNormCol = params.gasConsNormCol;
    flowDir        = params.flowDir       ;
    ambTempNorm    = params.ambTempNorm   ;
    sColNums       = params.sColNums      ; 
    sComNums       = params.sComNums      ;
    cstrHt         = params.cstrHt        ;
    htCapCpNorm    = params.htCapCpNorm   ;    
    %---------------------------------------------------------------------%              
    
 
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for all CSTRs for all columns
    
    %For each column, 
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%    
        %Compute the interior heat transfer rates
        dQndt = col.(sColNums{i}).temps.wall ...
              - col.(sColNums{i}).temps.cstr;
                            
        %Compute the exterior heat transfer rates
        dQnwdt = ambTempNorm*ones(1,nVols) ...
               - col.(sColNums{i}).temps.wall;    
        
        %Save the column wall energy balance into the struct
        col.(sColNums{i}).wallEnBal = extHtTrFacCol*dQnwdt ...
                                    - intHtTrFacCol*dQndt;
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%                                       
        %Initialize the right hand side of dimensionless energy balance
        
        %Save the heat transfer rate to the column wall from CSTR in the 
        %right hand side of the dTn/dt
        col.(sColNums{i}).cstrEnBal = dQndt;              
        %-----------------------------------------------------------------%    
        
       

        %-----------------------------------------------------------------%
        %Compute the convective flow contribution to the energy
        %balance, depending on the flow direction

        %If we have a co-current flow
        if flowDir(i,nS) == 0

            %-------------------------------------------------------------%
            %Unpack states

            %Unpack the total concentration variables  

            %We have the down stream total concentration of the column 
            %to be equal to the total concentration in the first CSTR
            cnm1 = [col.(sColNums{i}).gasConsTot(:,1), ...
                    col.(sColNums{i}).gasConsTot(:,1:nVols-1)];                                  
            cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols)    ;

            %Unpack the volumetric flow rates
            vnm1 = col.(sColNums{i}).volFlRat(:,1:nVols)  ;                
            vnm0 = col.(sColNums{i}).volFlRat(:,2:nVols+1);

            %Unpack the interior temperature variables
            Tnm1 = [col.(sColNums{i}).feEnd.temps, ...
                    col.(sColNums{i}).temps.cstr(:,1:nVols-1)];
            Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols)    ;                

            %Unpack the overall heat capacity                
            htCOnm0 = col.(sColNums{i}).htCO(:,1:nVols);                                                               
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calcualte the terms in the energy balance equation
            
            %Calcualte the vectorized terms
            presDeltaEner = gasConsNormCol ...
                         .* Tnm0 ...
                         .* (cnm1.*vnm1 ...
                            -cnm0.*vnm0);
                        
            %Initialize the non-vectorized terms
            adsHeatEner  = zeros(nRows,nVols);
            convFlowEner = zeros(nRows,nVols);

            %For each species,
            for j = 1 : nComs
                
                %Update the second summation
                adsHeatEner = adsHeatEner ...
                            + (isoStHtNorm(j)-Tnm0) ...
                           .* col.(sColNums{i}).adsRat.(sComNums{j});                
                
                %Update the third summation
                convFlowEner = convFlowEner ...
                             + htCapCpNorm(j) ...
                            .* [col.(sColNums{i}).feEnd. ...
                               gasCons.(sComNums{j}), ...
                               col.(sColNums{i}).gasCons. ...
                               (sComNums{j})(:,1:nVols-1)];    
                                  
            end
            
            %Take account for the pre-factors
            adsHeatEner = partCoefHp ...
                       .* gasConsNormCol ...
                       .* cstrHt ...
                       .* adsHeatEner;
            convFlowEner = gasConsNormCol ...
                        .* vnm1.*(Tnm1-Tnm0) ...
                        .* convFlowEner;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%    
            %Update the existing field value

            %Update the energy balance on all the CSTRs associated with ith
            %adsorption column
            col.(sColNums{i}).cstrEnBal ... 
                = (col.(sColNums{i}).cstrEnBal ...
                  +presDeltaEner ...
                  +adsHeatEner ...
                  +convFlowEner) ...
               ./ htCOnm0;                       
            %-------------------------------------------------------------%        

        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %If we have a counter-current flow           
        elseif flowDir(i,nS) == 1

            %-------------------------------------------------------------%
            %Unpack states

            %Unpack the total concentration variables  

            %We have the up stream total concentration of the column 
            %to be equal to the total concentration in the last CSTR                                             
            cnm0 = col.(sColNums{i}).gasConsTot(:,1:nVols) ;
            cnp1 = [col.(sColNums{i}).gasConsTot(:,2:nVols), ...
                    col.(sColNums{i}).gasConsTot(:,nVols)] ; 

            %Unpack the volumetric flow rates
            vnm1 = col.(sColNums{i}).volFlRat(:,1:nVols)  ;                
            vnm0 = col.(sColNums{i}).volFlRat(:,2:nVols+1);

            %Unpack the interior temperature variables            
            Tnm0 = col.(sColNums{i}).temps.cstr(:,1:nVols) ;                
            Tnp1 = [col.(sColNums{i}).temps.cstr(:,2:nVols), ...
                    col.(sColNums{i}).prEnd.temps]         ;

            %Unpack the overall heat capacity                
            htCOnm0 = col.(sColNums{i}).htCO(:,1:nVols);                                                               
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %Calcualte the terms in the energy balance equation
            
            %Calcualte the vectorized terms
            presDeltaEner ...
                = gasConsNormCol ...
               .* Tnm0.*(cnm0.*vnm1-cnp1.*vnm0);
                        
            %Initialize the non-vectorized terms
            adsHeatEner = zeros(nRows,nVols);
            convFlowEner = zeros(nRows,nVols);

            %For each species,
            for j = 1 : nComs
                
                %Update the second summation
                adsHeatEner = adsHeatEner ...
                            + (isoStHtNorm(j)-Tnm0) ...
                           .* col.(sColNums{i}).adsRat.(sComNums{j});                
                 
                %Update the third summation
                convFlowEner = convFlowEner ...
                             + htCapCpNorm(j) ...
                            .* [col.(sColNums{i}).gasCons. ...
                               (sComNums{j})(:,2:nVols), ...
                               col.(sColNums{i}).prEnd. ...
                               gasCons.(sComNums{j})]    ;      
                                
            end
            
            %Take account for the pre-factors
            adsHeatEner = partCoefHp ...
                       .* gasConsNormCol ...
                       .* cstrHt ...
                       .* adsHeatEner;
            convFlowEner = gasConsNormCol ...
                        .* vnm0.*(Tnm0-Tnp1) ...
                        .* convFlowEner;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%    
            %Update the existing field value

            %Update the energy balance on all the CSTRs associated with ith
            %adsorption column
            col.(sColNums{i}).cstrEnBal ... 
                = (col.(sColNums{i}).cstrEnBal ...
                  +presDeltaEner ...
                  +adsHeatEner ...
                  +convFlowEner) ...
               ./ htCOnm0;   
            %-------------------------------------------------------------%
                 
        end
        %-----------------------------------------------------------------%                
        
    end                              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.col = col;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%