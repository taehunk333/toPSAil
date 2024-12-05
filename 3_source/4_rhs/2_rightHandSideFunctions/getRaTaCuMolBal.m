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
%Function   : getRaTaCuMolBal.m
%Source     : common
%Description: a function that calculates cumulative moles flown out from 
%             the raffinate product tank up to time t at the boundaries for
%             all product tanks
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getRaTaCuMolBal(params,units)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaCuMolBal.m';
    
    %Unpack params
    nComs = params.nComs   ;
    sComs = params.sComNums;  
    
    %Unpack units
    raTa = units.raTa;
    %---------------------------------------------------------------------%
    
    
      
    %---------------------------------------------------------------------%    
    %Do the cumulative mole balance for each species for all species inside 
    %each product tank
                  
    %For each component
    for j = 1 : nComs

        %Assign the right hand side for the cumulative moles flowing
        %out of the product tank
        raTa.n1.cumMolBal.prod.(sComs{j}) ...
            = raTa.n1.gasCons.(sComs{j}) ...
            * raTa.n1.volFlRat(:,end);

    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.raTa = raTa;
    %---------------------------------------------------------------------%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%