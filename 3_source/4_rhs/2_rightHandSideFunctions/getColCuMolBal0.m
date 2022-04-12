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
%Function   : getColCuMolBal0.m
%Source     : common
%Description: a function that calculates cumulative moles flown through up
%             to time t at the boundaries for all adsorption columns.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getColCuMolBal0(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColCuMolBal0.m';
    
    %Unpack params
    flowDir  = params.flowDir ;
    nCols    = params.nCols   ;    
    nComs    = params.nComs   ;
    sColNums = params.sColNums;
    sComNums = params.sComNums;
    
    %Unpack units
    col = units.col;
    %---------------------------------------------------------------------%
    
            
    
    %---------------------------------------------------------------------%    
    %Compute the rate of change in the cumulative flows at the boundaries
    
    %For each column,
    for i = 1 : nCols              
        
        %-----------------------------------------------------------------%               
        %For each component
        for j = 1 : nComs                
        
            %-------------------------------------------------------------%               
            %If the flow direction is a counter-current in ith column
            if flowDir(i,nS) == 1                               
                
                %---------------------------------------------------------%
                %Get the concentration of species at the product-end of
                %the adsorber
                gasConSpePrEnd ...
                    = col.(sColNums{i}).prEnd.gasCons.(sComNums{j});
                
                %Assign the volumetric flow rate flowing into the 
                %adsorption column from the extract product tank
                volFlRatPrEnd ...
                    = col.(sColNums{i}).volFlRat(:,end); 
                
                %Assign the right hand side for the cumulative moles
                %flowing into the adsorption column from the product-end
                col.(sColNums{i}).cumMolBal.prod.(sComNums{j}) ...
                        = gasConSpePrEnd ...
                        * volFlRatPrEnd;                
                
                %Assign the right hand side for the cumulative moles
                %flowing out of the adsorption column from the column at
                %the feed-end
                col.(sColNums{i}).cumMolBal.feed.(sComNums{j}) ...
                    = col.(sColNums{i}).gasCons.(sComNums{j})(:,1) ...
                    * col.(sColNums{i}).volFlRat(:,1);                          
                %---------------------------------------------------------%
                
            %-------------------------------------------------------------%
              
        
            
            %-------------------------------------------------------------%               
            %If the flow direction is a co-current in ith column
            elseif flowDir(i,nS) == 0
            
                %Get the concentration of species at the feed-end of
                %the adsorber
                gasConSpeFeEnd ...
                    = col.(sColNums{i}).feEnd.gasCons.(sComNums{j});
                
                %Assign the volumetric flow rate flowing into the 
                %adsorption column from the extract product tank
                volFlRatFeEnd ...
                    = col.(sColNums{i}).volFlRat(:,1);                                
                
                %Assign the right hand side for the cumulative moles
                %flowing into the adosorption column at the feed-end
                col.(sColNums{i}).cumMolBal.feed.(sComNums{j}) ...
                        = gasConSpeFeEnd ...
                        * volFlRatFeEnd;
                
                %Assign the right hand side for the cumulative moles 
                %flowing out from the adsorption column into the raffinate 
                %product tank or to the raffinate waste stream at the 
                %product-end
                col.(sColNums{i}).cumMolBal.prod.(sComNums{j}) ...
                    = col.(sColNums{i}).gasCons.(sComNums{j})(:,end) ...
                    * col.(sColNums{i}).volFlRat(:,end);    
                                
            end            
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