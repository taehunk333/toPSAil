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
%Code created on       : 2021/4/11/Monday
%Code last modified on : 2022/4/12/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getColCuMolBal.m
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

function units = getColCuMolBal(params,units)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColCuMolBal.m';
    
    %Unpack params
    nCols    = params.nCols   ;    
    nComs    = params.nComs   ;
    sColNums = params.sColNums;
    sComNums = params.sComNums;
    nVols    = params.nVols   ;
    
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
            %Unpack units
            
            %Unpack pseudo volumetric flow rates
            volFlPlus  = col.(sColNums{i}).volFlPlus ;
            volFlMinus = col.(sColNums{i}).volFlMinus;
            
            %Unpack gas species concentration
            gasConsSpec = col.(sColNums{i}).gasCons. ...
                          (sComNums{j});
            
            %Get the pseudo volumetric flow rates
            vPlFe = volFlPlus(:,1)       ;
            vMiFe = volFlMinus(:,1)      ;
            vPlPr = volFlPlus(:,nVols+1) ;
            vMiPr = volFlMinus(:,nVols+1);            
            
            %Get the species concentrations associated with the boundaries
            gasConsSpecPr    = col.(sColNums{i}).prEnd. ...
                               gasCons.(sComNums{j}); 
            gasConsSpecNeq1  = gasConsSpec(:,1);
            gasConsSpecFe    = col.(sColNums{i}).feEnd. ...
                               gasCons.(sComNums{j});
            gasConsSpecNeqNc = gasConsSpec(:,nVols);                        
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Do the cumulative mole balance at the boundaries
            
            %Assign the right-hand side for the cumulative moles
            %flowing into the adsorption column from the product-end
            col.(sColNums{i}).cumMolBal.prod.(sComNums{j}) ...
                = gasConsSpecNeqNc*vPlPr ...
                - gasConsSpecPr*vMiPr;                

            %Assign the right-hand side for the cumulative moles
            %flowing out of the adsorption column from the column at
            %the feed-end
            col.(sColNums{i}).cumMolBal.feed.(sComNums{j}) ...
                = gasConsSpecNeq1*vMiFe ...
                - gasConsSpecFe*vPlFe;                          
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