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
    
    %Unpack units
    col  = units.col ;
    raTa = units.raTa;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %Don't do the energy balance on the feed tank
        raTa.n1.cstrEnBal = 0;            
        raTa.n1.wallEnBal = 0;  
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                          
        %Return the updated structure for the units

        %Pack units
        units.raTa = raTa;
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
    nComs          = params.nComs         ;
    htCapCpNorm    = params.htCapCpNorm   ;
    intHtTrFacRaTa = params.intHtTrFacRaTa;
    extHtTrFacRaTa = params.extHtTrFacRaTa;    
    ambTempNorm    = params.ambTempNorm   ;    
    nCols          = params.nCols         ;
    sColNums       = params.sColNums      ;
    sComNums       = params.sComNums      ;
    flowDirCol     = params.flowDirCol    ;    
    valRaTa        = params.valRaTa       ;
    valPurBot      = params.valPurBot     ;
    gConsNormRaTa  = params.gConsNormRaTa ;
    nVols          = params.nVols         ;
    %---------------------------------------------------------------------%                                                  
    
    
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for the feed tank
    
    %Compute the interior heat transfer rates
    dQndt = raTa.n1.temps.wall ...
          - raTa.n1.temps.cstr;

    %Compute the exterior heat transfer rates
    dQnwdt = ambTempNorm ...
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
    %Do the CSTR interior energy balance for the feed tank
              
    %Initialize the convective flow energy term
    convFlowEner = 0;
    
    %Initialize the net molar flow in the raffinate product tank
    netMolarFlow = 0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the species dependent terms, based on the flow direction and
    %the interacting boundary

    %For all each column,
    for i = 1 : nCols

        %If we have a counter-current flow in the current adsorber (i.e., 
        %we are doing a purge or pressurization at the product end)
        if flowDirCol(i,nS) == 1 
            
            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlow = netMolarFlow ...
                         + raTa.n1.volFlRat(i) ...
                         * raTa.n1.gasConsTot;
                     
            %There is no convective flow-in contribution when there is
            %counter-current purge going on.                     
                                    
        %If we have a co-current flow in the current adosrber and we are
        %doing co-current purge or co-current pressurization
        elseif flowDirCol(i,nS) == 0 && valPurBot(nS) == 1
            
            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlow = netMolarFlow ...
                         + raTa.n1.volFlRat(i) ...
                         * raTa.n1.gasConsTot;
            
            %There is no convective flow-in contribution when there is
            %co-current purge going on.   

        %If we have a co-current flow in the current adsorber and we are
        %collecting the raffinate product
        elseif flowDirCol(i,nS) == 0 && valRaTa(nS) == 1

            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlow = netMolarFlow ...
                         + col.(sColNums{i}).volFlRat(:,nVols) ...
                         * col.(sColNums{i}).gasConsTot(:,nVols);
                     
            %Evaluate the species dependent terms
            for j = 1 : nComs

               %Update the summation term for the product of the component
               %heat capacity and the species concentration in the gas
               %phase
               convFlowEner = convFlowEner ...
                            + htCapCpNorm(j) ...
                            * col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,nVols);

            end
            
            %Multiply the updated term with the volumetric flow rate and
            %the temperature difference
            convFlowEner = col.(sColNums{i}).volFlRat(:,nVols) ...
                         * (col.(sColNums{i}).temps.cstr(:,nVols)...
                           -raTa.n1.temps.cstr) ...
                         * convFlowEner;
        
        %Otherwise, we don't have to do anything as there is no interaction
        %with the raffinate product tank
        else
            
            %Do nothing
            
        end
        
        %Scale the terms with the relevant pre-factors
        presDeltaEner = gConsNormRaTa ...
                      * raTa.n1.temps.cstr ...
                      * netMolarFlow;
        convFlowEner = gConsNormRaTa ...
                     * convFlowEner;

    end            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%           
    %Do the energy balance for the raffinate product tank
    
    %Update the existing field
    raTa.n1.cstrEnBal = (raTa.n1.cstrEnBal ...
                        +presDeltaEner ...
                        +convFlowEner) ...
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