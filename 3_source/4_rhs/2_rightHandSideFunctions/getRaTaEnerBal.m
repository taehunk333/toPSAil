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
%Function   : getRaTaEnerBal.m
%Source     : common
%Description: This function computes the right hand side for the state
%             variables associated with the raffinate product tank.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getRaTaEnerBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Check to see if we need an energy balance
    
    %Unpack minimal number of params
    bool = params.bool;    
            
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %Don't do the energy balance on the feed tank
        units.raTa.n1.cstrEnBal = 0;            
        units.raTa.n1.wallEnBal = 0;  
        %-----------------------------------------------------------------%
                     
        

        %-----------------------------------------------------------------%
        %Skip non-isothermal simulation
        
        %Return to the invoking function 
        return;
        %-----------------------------------------------------------------%
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaEnerBal.m';
    
    %Unpack params
    nComs            = params.nComs           ;
    htCapCpNorm      = params.htCapCpNorm     ;
    intHtTrFacRaTa   = params.intHtTrFacRaTa  ;
    extHtTrFacRaTa   = params.extHtTrFacRaTa  ;    
    tempAmbiNorm     = params.tempAmbiNorm    ;    
    nCols            = params.nCols           ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;           
    gConsNormRaTa    = params.gConsNormRaTa   ;
    nVols            = params.nVols           ;
    valAdsPrEnd2RaTa = params.valAdsPrEnd2RaTa;
    raTaVolNorm      = params.raTaVolNorm     ;
    valPrEndEq       = params.valPrEndEq      ;
    
    %Unpack units
    col  = units.col ;
    raTa = units.raTa;
    %---------------------------------------------------------------------%                                                  
    
    
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for the feed tank
    
    %Unpack the temperature of the raffinate product tank
    raTaTempCstr = raTa.n1.temps.cstr;
    
    %Compute the interior heat transfer rates
    dQndt = raTa.n1.temps.wall ...
          - raTaTempCstr;

    %Compute the exterior heat transfer rates
    dQnwdt = tempAmbiNorm ...
           - raTa.n1.temps.wall;    

    %Save ith feed tank wall energy balance into the struct
    raTa.n1.wallEnBal = extHtTrFacRaTa*dQnwdt ...
                      - intHtTrFacRaTa*dQndt;
    %---------------------------------------------------------------------%  
    
    
        
    %---------------------------------------------------------------------%  
    %Initialize the right hand side of dimensionless energy balance

    %Save the heat transfer to the column wall from the feed tank in 
    %the right hand side of the dTn/dt
    raTa.n1.cstrEnBal = dQndt;    
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Unpack additional quantaties associated with the raffinate product
    %tank
    
    %Unpack the net change in the total moles inside the tank
    netChangeGasConcTot = raTa.n1.moleBalTot;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the net change in the total concentration inside the 
    %raffinate product tank
    
    %Compute the net change in the total conecntration term
    presDeltaEner  = gConsNormRaTa ...
                   * raTaVolNorm ...
                   * raTaTempCstr ...
                   * netChangeGasConcTot;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the convective flow energy term

    %Initialize the convective flow energy term
    convFlowEnerIn  = 0;    
           
    %For each column,
    for i = 1 : nCols
    
        %If we have a co-current flow in the current adsorber and we are
        %collecting the raffinate product
        if valAdsPrEnd2RaTa(i,nS) == 1

            %Evaluate the species dependent terms
            for j = 1 : nComs

               %Update the summation term for the product of the component
               %heat capacity and the species concentration in the gas
               %phase
               convFlowEnerIn = convFlowEnerIn ...
                              + htCapCpNorm(j) ...
                              * col.(sColNums{i}).gasCons. ...
                                (sComNums{j})(:,nVols);
  
            end
            
            %Multiply the updated term with the volumetric flow rate and
            %the temperature difference
            convFlowEnerIn ...
                = max(0,col.(sColNums{i}).volFlRat(:,nVols+1)) ...
                * valPrEndEq(i,nS) ...
                * (col.(sColNums{i}).temps.cstr(:,nVols)...
                  -raTaTempCstr) ...
                * convFlowEnerIn;
            
        end           
                
    end         
    
    %Scale the terms with the relevant pre-factors    
    convFlowEnerIn = gConsNormRaTa ...
                   * convFlowEnerIn;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%           
    %Do the energy balance for the raffinate product tank
    
    %Update the existing field
    raTa.n1.cstrEnBal = (raTa.n1.cstrEnBal ...
                        +presDeltaEner ...
                        +convFlowEnerIn) ...
                      / raTa.n1.htCO;        
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