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
    nComs            = params.nComs           ;
    htCapCpNorm      = params.htCapCpNorm     ;
    intHtTrFacRaTa   = params.intHtTrFacRaTa  ;
    extHtTrFacRaTa   = params.extHtTrFacRaTa  ;    
    ambTempNorm      = params.ambTempNorm     ;    
    nCols            = params.nCols           ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;           
    gConsNormRaTa    = params.gConsNormRaTa   ;
    nVols            = params.nVols           ;
    valRaTa2AdsPrEnd = params.valRaTa2AdsPrEnd;
    valRaTa2AdsFeEnd = params.valRaTa2AdsFeEnd;
    valAdsPrEnd2RaWa = params.valAdsPrEnd2RaWa;
    valAdsPrEnd2RaTa = params.valAdsPrEnd2RaTa;
    
    %Unpack units
    col  = units.col ;
    raTa = units.raTa;
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
              
    %Initialize the convective flow energy terms
    convFlowEnerIn  = 0;
    
    %Initialize the net molar flow in the raffinate product tank
    netMolarFlowIn  = 0;  
    netMolarFlowOut = 0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the species dependent terms, based on the flow direction and
    %the interacting boundary

    %MOLAR FLOW RATE INTO THE RAFFINATE TANK
           
    %For each column,
    for i = 1 : nCols
    
        %FLOW OUT FROM THE RAFFINATE TANK INTO THE PRODUCT-ENDS OF THE
        %ADSORBERS
        %If we have a counter-current flow in the current adsorber (i.e., 
        %we are doing a purge or pressurization at the product-end) or if
        %we have a co-current flow in the current adsorber (i.e., we are
        %doing co-current purge or co-current pressurization)
        if valRaTa2AdsPrEnd(i,nS) == 1 || ...
           valRaTa2AdsFeEnd(i,nS) == 1
            
            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlowOut = netMolarFlowOut ...
                            + min(raTa.n1.volFlRat(:,i),0) ...
                            * raTa.n1.gasConsTot;                                                                                              

        %FLOW INTO THE RAFFINATE TANK
        %If we have a co-current flow in the current adsorber and we are
        %collecting the raffinate product
        elseif valAdsPrEnd2RaTa(i,nS) == 1

            %Update the net molar flow (since the flow is in the positive
            %direction, the voluemtric flow is positive). When we are
            %throwing away the product to the waste stream, we mave a zero
            %net molar flow rate coming into the raffinate tank.
            netMolarFlowIn = netMolarFlowIn ...
                           + max(0,valAdsPrEnd2RaWa(i,nS) ... 
                           * col.(sColNums{i}).volFlRat(:,nVols+1) ...
                           * col.(sColNums{i}).gasConsTot(:,nVols));
                     
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
                * (col.(sColNums{i}).temps.cstr(:,nVols)...
                  -raTa.n1.temps.cstr) ...
                * convFlowEnerIn;
        
        %Otherwise, we don't have to do anything as there is no interaction
        %with the raffinate product tank
        else
            
            %Do nothing
            
        end
        
        %Calculate the net change in the total moles inside the tank
        netChangeInMoles = (netMolarFlowIn+netMolarFlowOut);
        
        %Scale the terms with the relevant pre-factors
        presDeltaEner = gConsNormRaTa ...
                      * raTa.n1.temps.cstr ...
                      * netChangeInMoles;
        convFlowEnerIn = gConsNormRaTa ...
                       * convFlowEnerIn;

    end     
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