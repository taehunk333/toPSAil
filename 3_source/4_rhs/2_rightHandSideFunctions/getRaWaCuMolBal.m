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
%Function   : getRaWaCuMolBal.m
%Source     : common
%Description: a function that calculates cumulative moles flown out as the
%             raffinate waste stream.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getRaWaCuMolBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaWaCuMolBal.m';
    
    %Unpack params
    nComs            = params.nComs           ;
    nCols            = params.nCols           ;
    sComs            = params.sComNums        ;  
    sCols            = params.sColNums        ;
    nVols            = params.nVols           ;
    valAdsPrEnd2RaWa = params.valAdsPrEnd2RaWa;
    
    %Unpack units
    col = units.col;
    %---------------------------------------------------------------------%
    
    
      
    %---------------------------------------------------------------------%    
    %Do the cumulative mole balance for each species for all species inside 
    %each product tank
    
    %For each component
    for j = 1 : nComs
        
        %Initialize the right hand side expression
        raWa.n1.cumMolBal.waste.(sComs{j}) = 0;
        
        %For each column
        for i = 1 : nCols

            %Assign the right hand side for the cumulative moles flowing 
            %out as the raffinate waste
            raWa.n1.cumMolBal.waste.(sComs{j}) ...
                = raWa.n1.cumMolBal.waste.(sComs{j}) ...
                + col.(sCols{i}).gasCons.(sComs{j})(:,nVols) ...
                * max(0,col.(sCols{i}).volFlRat(:,nVols+1)) ...
                * (1-valAdsPrEnd2RaWa(i,nS));

        end
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.raWa = raWa;
    %---------------------------------------------------------------------%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%