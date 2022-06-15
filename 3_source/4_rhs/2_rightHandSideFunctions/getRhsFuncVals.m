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
%Code last modified on : 2022/6/14/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getRhsFuncVals.m
%Source     : common
%Description: a function that returns a column vector comprised of each
%             entry corresponding to the evaluated right hand side first
%             derivative value for a given state variable.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : rhsVals      - evaluated values for the right hand side 
%                            function for a given step inside a PSA cycle.
%                            This is a column vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  rhsVals = getRhsFuncVals(params,units)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'rhsFuncEval.m';
    
    %Unpack Params       
    nStatesT = params.nStatesT;
    nColStT  = params.nColStT ;
    nSt      = params.nStates ;
    nComs    = params.nComs   ; 
    nCols    = params.nCols   ;     
    inShFeTa = params.inShFeTa;
    nFeTaStT = params.nFeTaStT;
    inShRaTa = params.inShRaTa;
    nRaTaStT = params.nRaTaStT;
    inShExTa = params.inShExTa;
    nExTaStT = params.nExTaStT;
    nColSt   = params.nColSt  ;
    sCols    = params.sColNums;
    sComs    = params.sComNums;
    inShComp = params.inShComp;
    inShVac  = params.inShVac ;
    nVols    = params.nVols   ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    raWa = units.raWa;
    exWa = units.exWa;
    comp = units.comp;
    pump = units.pump;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution array
    
    %Initialize a numeric array (a column vector) to hold the state rate of
    %changes for the right hand side function output
    rhsVals = zeros(nStatesT,1);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                            
    %Add all evaluated right hand side values associated with adsorption
    %columns
    
    %For each columns
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Calculate shift indices
        
        %Shift index for each column
        s = 2*nComs*(i-1);                        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For each species
        for j = 1 : nComs
        
            %Grab the gas phase mole balances
            rhsVals(s+nColSt*(i-1)+j:nSt:s+nColSt*i-nSt+j) ...
                = col.(sCols{i}).moleBal.(sComs{j});

            %Grab the adsorbed phase mole balances
            rhsVals(s+nColSt*(i-1)+nComs+j:nSt:s+nColSt*i-nSt+nComs+j) ...
                = col.(sCols{i}).adsRat.(sComs{j}); 

            %Grab the cumulative mole balances for species j at the
            %feed-end            
            rhsVals(nColStT*i-2*nComs+j) ...
                = col.(sCols{i}).cumMolBal.feed.(sComs{j}); 

            %Grab the cumulative mole balances for species j at the
            %product-end            
            rhsVals(nColStT*i-nComs+j) ...
                = col.(sCols{i}).cumMolBal.prod.(sComs{j}); 
            
        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For each temperatures
                    
        %Grab the energy balances for the CSTRs
        rhsVals(s+nColSt*(i-1)+2*nComs+1:nSt:s+nColSt*i-nSt+2*nComs+1) ...
            = col.(sCols{i}).cstrEnBal;
        
        %Grab the energy balances for the CSTR walls
        rhsVals(s+nColSt*(i-1)+2*nComs+2:nSt:s+nColSt*i-nSt+2*nComs+2) ...
            = col.(sCols{i}).wallEnBal;
        %-----------------------------------------------------------------%
        
    end        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                            
    %Add all evaluated right hand side values associated with the feed tank
    
    %For each species
    for j = 1 : nComs

        %Grab the gas phase mole balances            
        rhsVals(inShFeTa+j) ...
            = feTa.n1.moleBal.(sComs{j});

        %Grab the cumulative mole balance for a species leaving the feed 
        %tank
        rhsVals(inShFeTa+nFeTaStT-nComs+j) ...
            = feTa.n1.cumMolBal.feed.(sComs{j});

    end
 
    %For each temperatures

    %Grab the energy balances for the CSTRs
    rhsVals(inShFeTa+nComs+1) = feTa.n1.cstrEnBal;

    %Grab the energy balances for the CSTR walls
    rhsVals(inShFeTa+nComs+2) = feTa.n1.wallEnBal;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%                            
    %Add all evaluated right hand side values associated with the raffinate
    %tank
    
    %For each species
    for j = 1 : nComs

        %Grab the gas phase mole balances
        rhsVals(inShRaTa+j) ...
            = raTa.n1.moleBal.(sComs{j});

        %Grab the cumulative mole balance for a species leaving the 
        %raffinate product tank
        rhsVals(inShRaTa+nRaTaStT-2*nComs+j) ...
            = raTa.n1.cumMolBal.prod.(sComs{j});
        
        %Grab the cumulative mole balance for a species leaving as a
        %raffinate waste
        rhsVals(inShRaTa+nRaTaStT-nComs+j) ...
            = raWa.n1.cumMolBal.waste.(sComs{j});
        
    end
    
    %For each temperatures

    %Grab the energy balances for the CSTRs
    rhsVals(inShRaTa+nComs+1) = raTa.n1.cstrEnBal;

    %Grab the energy balances for the CSTR walls
    rhsVals(inShRaTa+nComs+2) = raTa.n1.wallEnBal;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                            
    %Add all evaluated right hand side values associated with the extract
    %tank
    
    %For each species
    for j = 1 : nComs

        %Grab the gas phase mole balances
        rhsVals(inShExTa+j) ...
            = exTa.n1.moleBal.(sComs{j});

        %Grab the cumulative mole balance for a speceis leaving the extract
        %product tank
        rhsVals(inShExTa+nExTaStT-2*nComs+j) ...
            = exTa.n1.cumMolBal.prod.(sComs{j});
        
        %Grab the cumulative mole balance for a species leaving as an 
        %extract waste
        rhsVals(inShExTa+nExTaStT-nComs+j) ...
            = exWa.n1.cumMolBal.waste.(sComs{j});
                                     
    end
    
    %For each temperatures

    %Grab the energy balances for the CSTRs
    rhsVals(inShExTa+nComs+1) = exTa.n1.cstrEnBal;

    %Grab the energy balances for the CSTR walls
    rhsVals(inShExTa+nComs+2) = exTa.n1.wallEnBal;  
    %---------------------------------------------------------------------% 
    
    
     
    %---------------------------------------------------------------------%                            
    %Add all evaluated right hand side values associated with the energy
    %expenditure from compression of the feed and the vacuum during
    %depressurization
             
    %Grab the work rate of the compression of the feed gas
    rhsVals(inShComp+1) = comp.n1.workRat;
    rhsVals(inShComp+2) = comp.n2.workRat;
    
    %Grab the work rate of the ith vacuum pump
    rhsVals(inShVac+1) = pump.n1.workRat;                        
    %---------------------------------------------------------------------%                            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%