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
%Code created on       : 2021/2/19/Friday
%Code last modified on : 2022/3/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getCompWorkRate0.m
%Source     : common
%Description: a function that evaluates the rate of work done to increase
%             the feed gas pressure form the ambient pressure to the feed
%             tank pressure.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getCompWorkRate0(params,units)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getCompWorkRate0.m';    
    
    %Unpack params       
    gamma      = params.htCapRatioFe;    
    enScaleFac = params.enScaleFac  ;    
    pRatAmb    = params.pRatAmb     ;
    pRat       = params.pRat        ;
    nCols      = params.nCols       ;
    sColNums   = params.sColNums    ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %For a co-current flow into the compressor and out to the feed tank,
    %calculate the necessary terms and evaluate the work rate expression
    %for the compressor.
    
    %Get the dimensionless tank pressure (i.e., dimensionless total
    %concentration)
    presOut = feTa.n1.gasConsTot;

    %Get inlet pressure
    presIn = pRatAmb;

    %Get the inlet volumetric flow rate to the compressor
    molFlIn = presOut ...
            * feTa.n1.volFlRat(:,end);

    %Compute the driving force for the compression
    drivingForce = (presOut/presIn) ...
                 ^ ((gamma-1)/gamma) ...
                 - 1;

    %Evaluate the work rate and store it inside the struct
    comp.n1.workRat = enScaleFac ...
                    * molFlIn ...
                    * drivingForce;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                            
    %For a counter-current flow out of the vacuum pump into the extract 
    %product tank, calculate the necessary terms and evaluate the work rate
    %expression for the compressor.
    
    %Get the dimensionless extract product tank pressure (i.e., 
    %dimensionless total concentration)
    presOut = exTa.n1.gasConsTot;

    %Get the dimensionless extract stream pressure
    presIn = pRat;

    %Initialize the total molar flow rate into the extract product tank
    molFlIn = 0;
    
    %For each adsorption column,
    for i = 1 : nCols
        
        %Get the sum of the volumetric flow rates; the individual
        %volumetric flow rates come from each adsorption column and after
        %the compressor, all streams are at the same pressure. The flow is
        %counter-current, so we need the absolute value function to take
        %the positive flow rate. Also, compression is needed only when we
        %collect extract product as well.
        molFlIn = molFlIn ...
                + abs(col.(sColNums{i}).volFlRat(:,1)) ...
                * col.(sColNums{i}).gasConsTot(:,1);
        
    end

    %Compute the driving force for the compression
    drivingForce = (presOut/presIn) ...
                 ^ ((gamma-1)/gamma) ...
                 - 1;

    %Evaluate the work rate and store it inside the struct
    comp.n2.workRat = enScaleFac ...
                    * molFlIn ...
                    * drivingForce;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.comp = comp;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%