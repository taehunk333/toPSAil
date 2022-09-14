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
%Code created on       : 2021/1/17/Sunday
%Code last modified on : 2022/2/27/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : makeColumns.m
%Source     : common
%Description: given an overall state vector or matrix, constructs a column
%             object with associated properties by returning a struct.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution vector or
%                            matrix containing all the state variables
%Outputs    : col          - a nested structure containing all the column
%                            properties such as gas concentrations,
%                            adsorbed phase concentrations, CSTR
%                            temperatures, wall temperatures, and rate of
%                            adsorption in the column.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function col = makeColumns(params,states)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'makeColumns.m';
    
    %Unpack params       
    nCols      = params.nCols     ;
    funcRat    = params.funcRat   ;
    nComs      = params.nComs     ;
    nVols      = params.nVols     ;
    sColNums   = params.sColNums  ;
    sComNums   = params.sComNums  ;
    nR         = params.nRows     ;
    bool       = params.bool      ;
    cstrHt     = params.cstrHt    ;
    partCoefHp = params.partCoefHp;
    modSp      = params.modSp     ;
    %---------------------------------------------------------------------%           

        
    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each columns    
    
    %For all columns, for each column, unpack states.
    for i = 1 : nCols    
        
        %Fetch the gas phase concentrations as a struct
        col.(sColNums{i}).gasCons = convert2ColGasConc(params,states,i);
        
        %Fetch the adsorbed phase concentrations as a struct
        col.(sColNums{i}).adsCons = convert2ColAdsConc(params,states,i);
        
        %Fetch the temperatures as a struct
        col.(sColNums{i}).temps = convert2ColTemps(params,states,i);  
                                     
    end
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Calculate adsorption rates for all CSTRs associated with all columns
    
    %Loop through each columns and save the rates to a struct
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%          
        %Calculate the adsorption rates
        
        %Calculate the adsorption rates of the species associated with the
        %sequenced CSTRs for all CSTRs in ith column
        adsRat = funcRat(params,states,i);
        %-----------------------------------------------------------------%          
        
        
        
        %-----------------------------------------------------------------%          
        %Initialize soltion arrays
        
        %A numeric array for adsorption column total concentrations 
        col.(sColNums{i}).gasConsTot = zeros(nR,nVols);  
        
        %A numeric array for adsorption column total concentrations 
        col.(sColNums{i}).adsRatSum = zeros(nR,nVols);
        %-----------------------------------------------------------------%          
        
        
        
        %-----------------------------------------------------------------%          
        %Save results to the column properties
        
        %For each species,
        for j = 1 : nComs
        
            %Save adsorption rates into column properties
            col.(sColNums{i}).adsRat.(sComNums{j}) ...
                = adsRat(:,nVols*(j-1)+1:nVols*j);
            
            %Assign the value of the sum of the adsorption rates into a
            %struct
            col.(sColNums{i}).adsRatSum ...
                = col.(sColNums{i}).adsRatSum ...
                + col.(sColNums{i}).adsRat.(sComNums{j});
            
            %Assign the value of the total concentrations into a struct
            col.(sColNums{i}).gasConsTot ...
                = col.(sColNums{i}).gasConsTot ...
                + col.(sColNums{i}).gasCons.(sComNums{j});
            
        end  
                
        %Compute the total volumic adsorption rate, r_n \ti
        col.(sColNums{i}).volAdsRatTot ...
            = partCoefHp ...
           .* cstrHt ...
           ./ col.(sColNums{i}).gasConsTot ...
           .* col.(sColNums{i}).adsRatSum; 
        %-----------------------------------------------------------------% 
        
        
                
        %-----------------------------------------------------------------% 
        %Calculate relevant quantities for non-isothermal system

        %Calculate the quantities, only when the system is non-isothermal
        if bool(5) == 1
            
            %-------------------------------------------------------------%
            %Unpack additional params
            gConsNormCol = params.gConsNormCol;            
            htCapSolNorm = params.htCapSolNorm; 
            htCapCvNorm  = params.htCapCvNorm ;
            htCapCpNorm  = params.htCapCpNorm ;
            isoStHtNorm  = params.isoStHtNorm ;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Initialize the needed quantities
            
            %Initialize the overall heat capacity
            htCO0 = partCoefHp*ones(1,nVols) ...
                  * htCapSolNorm;     
            
            %Initialize the released heat due to the adsorption
            heatReleased = zeros(1,nVols);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Evaluate the quantities from each species in the system
            
            %For each species, j,
            for j = 1 : nComs
                
                %Sum jth species contribution to the overall heat capacity
                %from the gas and adsorbed phases
                htCO0 ...
                    = htCO0 ...
                    + htCapCvNorm(j) ...
                    * col.(sColNums{i}).gasCons.(sComNums{j}) ...                                                              
                    + partCoefHp ...
                    * htCapCpNorm(j) ...
                   .* col.(sColNums{i}).adsCons.(sComNums{j});
               
               %Sum the heat released from the jth species to the overall
               %sum of the total heat released
               heatReleased ...
                   = heatReleased ...
                   + (isoStHtNorm(j)./ ...
                     col.(sColNums{i}).temps.cstr-1) ...
                  .* col.(sColNums{i}).adsRat.(sComNums{j});
                
            end
            
            %Save the overall heat capacities into a struct
            col.(sColNums{i}).htCO = gConsNormCol ...
                                  .* cstrHt ...
                                  .* htCO0;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%            
            %Compute the quantities for the right hand side vectors for the
            %non-isothermal volumetric flow rates
                          
            %Define the nonisothermal correction term, \beta_n \ti
            col.(sColNums{i}).volCorRatTot ...
                = (cstrHt./col.(sColNums{i}).htCO) ...
               .* ((col.(sColNums{i}).temps.wall ...
                  ./col.(sColNums{i}).temps.cstr-1) ...
                  +(gConsNormCol.*partCoefHp.*cstrHt) ...
                 .*heatReleased);  
            %-------------------------------------------------------------%
            
        %If isothermal, 
        else
            
            %Assign zeros for the entries
            col.(sColNums{i}).htCO         = zeros(1,nVols);
            col.(sColNums{i}).volCorRatTot = zeros(1,nVols);
            
        end              
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Calculate relevant quantities for the system with a given momentum
        %balance equation
                
        %Calculate only when there is an axial pressure drop
        if bool(3) == 1 && modSp(6) == 2
        
            %-------------------------------------------------------------%
            %Unpack additional params
            
            %Unpack params
            molecWtC    = params.molecWtC   ;   
            coefQuadPre = params.coefQuadPre;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Initialize solution arrays
            
            %Initialize the quadratic coefficnent array
            quadCoeffEval = zeros(1,nVols);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Compute the molar density
            
            %For each species, j,
            for j = 1 : nComs
                
                %Calculate the molar density as the weighted sum of gas
                %phase concentration with the corresponding molecular
                %weight
                quadCoeffEval = quadCoeffEval ...
                              + molecWtC(j) ...
                             .* col.(sColNums{i}). ...
                                gasCons.(sComNums{j});
                
            end
            
            %Multiply the prefactor
            quadCoeffEval = coefQuadPre.*quadCoeffEval;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Save the results
            
            %Save the molar density in the CSTRs associated with ith column
            col.(sColNums{i}).quadCoeff = quadCoeffEval;
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%
        
    end                    
    %---------------------------------------------------------------------%                          
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%