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
%Function   : getVacWorkRate0.m
%Source     : common
%Description: a function that evaluates the rate of work done either during
%             (1) vacuumming out the adsorption column from the current 
%             column pressure at time t down to a specified pressure below 
%             the atmospheric pressure (i.e., the sub-ambient low pressure)
%             or (2) pressurizing the adsorption column from its current
%             column pressure at time t up to a specified high pressure of
%             the column.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure contain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getVacWorkRate0(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getVacWorkRate0.m';    
    
    %Unpack params       
    gamma      = params.htCapRatioFe;    
    enScaleFac = params.enScaleFac  ;            
    pRat       = params.pRat        ;
    nCols      = params.nCols       ;
    sColNums   = params.sColNums    ;
    flowDir    = params.flowDir     ;
    
    %Unpack units
    col = units.col;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %Initialize solution arrays
    
    %Initialize the rate of change in the cumulative energy incurred
    cumEnerRhs = 0;    
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %Evaluate the work rate expression for the pump
                   
    %For each adsorption column, 
    for i = 1 : nCols
                    
        %Get the outlet pressure; we assume that the pump will do work to
        %pull down the outlet pressure to the lowest pressure (specified)
        %in an adsorption column
        presOut = pRat;

        %Get the adsorption column pressure from the bottom CSTR
        presIn = col.(sColNums{i}).gasConsTot(:,1);

        %Get the absolute value of the inlet volumetric flow rate to the 
        %compressor; we take an absolute value of the volumetric flow rate
        %because we care about the magnitude of the work rate.
        molFlIn = presIn ...
                * abs(col.(sColNums{i}).volFlRat(:,1)) ...
                * flowDir(i,nS);            
            
        %Compute the driving force for the compression
        drivingForce = (presOut/(presIn)) ...
                     ^ ((gamma-1)/gamma) ...
                     - 1;

        %Evaluate the work rate and store it inside the struct
        cumEnerRhs = cumEnerRhs ...
                   + enScaleFac ...
                   * molFlIn ...
                   * drivingForce;
           
    end
    
    %Evaluate the work rate and store it inside the struct
    pump.n1.workRat = cumEnerRhs;              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.pump = pump;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%