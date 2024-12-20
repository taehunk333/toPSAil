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
%Function   : getColMoleBal0.m
%Source     : common
%Description: a function that evaluates the mole balance right hand side
%             relationship for the current time point for all adsorption
%             columns.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getColMoleBal(params,units)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColMoleBal.m';
    
    %Unpack params
    nVols      = params.nVols     ;
    nCols      = params.nCols     ;
    nComs      = params.nComs     ;
    partCoefHp = params.partCoefHp;
    cstrHt     = params.cstrHt    ;    
    sColNums   = params.sColNums  ;
    sComNums   = params.sComNums  ;
    
    %Unpack units
    col = units.col;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%    
    %Do the mole balance
    
    %For each column i,
    for i = 1 : nCols
                
        %-----------------------------------------------------------------%    
        %For each species j,
        for j = 1 : nComs                                
                  
            %-------------------------------------------------------------%    
            %Unpack units
            
            %Unpack pseudo volumetric flow rates
            volFlPlus  = col.(sColNums{i}).volFlPlus ;
            volFlMinus = col.(sColNums{i}).volFlMinus;
            
            %Unpack the total concentrstion variables
            gasConsSpec = col.(sColNums{i}).gasCons.(sComNums{j});
            
            %Get the pseudo volumetric flow rates
            vPlNm1 = volFlPlus(:,1:nVols)   ;
            vMiNm1 = volFlMinus(:,1:nVols)  ;
            vPlNm0 = volFlPlus(:,2:nVols+1) ;
            vMiNm0 = volFlMinus(:,2:nVols+1);
            
            %Get the concentration of species at the boundaries
            gasConsSpecPr = col.(sColNums{i}).prEnd.gasCons.(sComNums{j}); 
            gasConsSpecFe = col.(sColNums{i}).feEnd.gasCons.(sComNums{j});
            
            %Get the gas phase species concentrations
            gSpecNm1 = [gasConsSpecFe,gasConsSpec(:,1:nVols-1)];
            gSpecNm0 = gasConsSpec(:,1:nVols)                  ;
            gSpecNp1 = [gasConsSpec(:,2:nVols),gasConsSpecPr]  ;                        
            %-------------------------------------------------------------%    
            
            
            
            %-------------------------------------------------------------%    
            %Do the mole balance 
                                                                
            %Get the convective flow in from below term
            flowInBelow = vPlNm1.*gSpecNm1;  

            %Get the convective flow out term
            flowOut = (vMiNm1+vPlNm0).*gSpecNm0;
               
            %Get the convective flow in from above term
            flowInAbove = vMiNm0.*gSpecNp1;

            %Get the adsorption rate term
            adsorption = partCoefHp ...
                       * col.(sColNums{i}).adsRat.(sComNums{j});
        
            %Do the mole balance on the ith column
            col.(sColNums{i}).moleBal.(sComNums{j}) ...
                = (1./cstrHt) ...
               .* (flowInBelow-flowOut+flowInAbove) ...
                - adsorption;              
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