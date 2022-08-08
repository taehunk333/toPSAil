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
%Code created on       : 2022/2/2/Wednesday
%Code last modified on : 2022/3/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getExWaCuMolBal.m
%Source     : common
%Description: a function that calculates cumulative moles flown out as the
%             extract waste stream.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getExWaCuMolBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getExWaCuMolBal.m';
    
    %Unpack params
    nComs      = params.nComs     ;
    nCols      = params.nCols     ;
    sComs      = params.sComNums  ;  
    sCols      = params.sColNums  ;
    valExTa    = params.valExTa   ;
    flowDirCol = params.flowDirCol;
    
    %Unpack units
    col = units.col;
    %---------------------------------------------------------------------%
    
    
      
    %---------------------------------------------------------------------%    
    %Do the cumulative mole balance for each species for all species inside 
    %each product tank
    
    %For each component
    for j = 1 : nComs
        
        %Initialize the right hand side expression
        exWa.n1.cumMolBal.waste.(sComs{j}) = 0;
        
        %For each column
        for i = 1 : nCols

            %Assign the right hand side for the cumulative moles flowing 
            %out as the raffinate waste
            exWa.n1.cumMolBal.waste.(sComs{j}) ...
                = exWa.n1.cumMolBal.waste.(sComs{j}) ...
                + col.(sCols{i}).gasCons.(sComs{j})(:,1) ...
                * col.(sCols{i}).volFlRat(:,1) ...
                * (1-valExTa(nS)) ...
                * flowDirCol(nS);

        end
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.exWa = exWa;
    %---------------------------------------------------------------------%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%