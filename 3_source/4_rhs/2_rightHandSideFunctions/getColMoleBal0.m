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
%Function   : getColMoleBal.m
%Source     : common
%Description: a function that evaluates the mole balance right hand side
%             relationship for the current time point for all adsorption
%             columns.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getColMoleBal0(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getColMoleBal0.m';
    
    %Unpack params
    nVols        = params.nVols       ;
    nCols        = params.nCols       ;
    nComs        = params.nComs       ;
    flowDir      = params.flowDir     ;
    partCoefHp   = params.partCoefHp  ;
    cstrHt       = params.cstrHt      ;    
    sColNums     = params.sColNums    ;
    sComNums     = params.sComNums    ;
    
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
            %Do the mole balance for a counter-current flow 

            %For counter-current case,               
            if flowDir(i,nS) == 1
                
                %---------------------------------------------------------%
                %Do the mole balance
                
                %Get the concentration of species at the product-end of the
                %adsorber
                gasConSpePrEnd ...
                    = col.(sColNums{i}).prEnd.gasCons.(sComNums{j});                                                     

                %Get the convective flow in terms
                flowIn = col.(sColNums{i}). ...
                         gasCons.(sComNums{j})(:,1:nVols) ...
                      .* col.(sColNums{i}).volFlRat(:,1:nVols) ...
                      ./ cstrHt;  

                %Get the convective flow out terms
                flowOut = [col.(sColNums{i}). ...
                          gasCons.(sComNums{j})(:,2:nVols), ...
                          gasConSpePrEnd] ...
                       .* col.(sColNums{i}).volFlRat(:,2:nVols+1) ...
                       ./ cstrHt;

                %Get the rate terms
                adsorption = partCoefHp ...
                           * col.(sColNums{i}).adsRat.(sComNums{j});

                %Do the mole balance on the ith column
                col.(sColNums{i}).moleBal.(sComNums{j}) = flowIn ...
                                                        - flowOut ...
                                                        - adsorption;  
                %---------------------------------------------------------%
                
            %-------------------------------------------------------------%    



            %-------------------------------------------------------------%    
            %Do the mole balance for a co-current flow 

            %For a co-current case,
            elseif flowDir(i,nS) == 0
                
                %---------------------------------------------------------%
                %Do the mole balance
                
                %Get the concentration of species at the feed-end of the
                %adsorber
                gasConSpeFeEnd ...
                    = col.(sColNums{i}).feEnd.gasCons.(sComNums{j});
                                   
                %Get the convective flow in terms
                flowIn = [gasConSpeFeEnd, ...
                         col.(sColNums{i}).gasCons. ...
                         (sComNums{j})(:,1:nVols-1)] ...
                      .* col.(sColNums{i}).volFlRat(:,1:nVols) ...
                      ./ cstrHt;

                %Get the convective flow out terms
                flowOut = col.(sColNums{i}).gasCons. ...
                          (sComNums{j})(:,1:nVols) ...
                       .* col.(sColNums{i}).volFlRat(:,2:nVols+1) ...
                       ./ cstrHt;

                %Get the rate terms
                adsorption = partCoefHp ...
                           * col.(sColNums{i}).adsRat.(sComNums{j});

                %Do the mole balance on the ith column
                col.(sColNums{i}).moleBal.(sComNums{j}) = flowIn ...
                                                        - flowOut ...
                                                        - adsorption;
                %---------------------------------------------------------%

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