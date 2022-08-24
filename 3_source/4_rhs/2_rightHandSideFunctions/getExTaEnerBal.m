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
%Code created on       : 2022/1/28/Friday
%Code last modified on : 2022/8/22/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getExTaEnerBal.m
%Source     : common
%Description: This function computes the right hand side for the state
%             variables associated with the extract product tank.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getExTaEnerBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Check to see if we need an energy balance
    
    %Unpack minimal number of params
    bool = params.bool;    
    
    %Unpack units
    col  = units.col ;
    exTa = units.exTa;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %Don't do the energy balance on the feed tank
        exTa.n1.cstrEnBal = 0;            
        exTa.n1.wallEnBal = 0;  
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                          
        %Return the updated structure for the units

        %Pack units
        units.exTa = exTa;
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
    %funcId = 'getExTaEnerBal.m';
    
    %Unpack params     
    nComs            = params.nComs           ;   
    htCapCpNorm      = params.htCapCpNorm     ;
    intHtTrFacExTa   = params.intHtTrFacExTa  ;
    extHtTrFacExTa   = params.extHtTrFacExTa  ;      
    tempAmbiNorm     = params.tempAmbiNorm    ;      
    nCols            = params.nCols           ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;       
    gConsNormExTa    = params.gConsNormExTa   ;    
    valExTa2AdsFeEnd = params.valExTa2AdsFeEnd;
    valExTa2AdsPrEnd = params.valExTa2AdsPrEnd;
    valAdsFeEnd2ExWa = params.valAdsFeEnd2ExWa;
    valAdsFeEnd2ExTa = params.valAdsFeEnd2ExTa;
    %---------------------------------------------------------------------%                                                 
    
    
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for the feed tank
    
    %Compute the interior heat transfer rates
    dQndt = exTa.n1.temps.wall ...
          - exTa.n1.temps.cstr;

    %Compute the exterior heat transfer rates
    dQnwdt = tempAmbiNorm ...
           - exTa.n1.temps.wall;    

    %Save ith feed tank wall energy balance into the struct
    exTa.n1.wallEnBal = extHtTrFacExTa*dQnwdt ...
                      - intHtTrFacExTa*dQndt;
    %---------------------------------------------------------------------%  
    
    
        
    %---------------------------------------------------------------------%  
    %Initialize the right hand side of dimensionless energy balance

    %Save the heat transfer to the column wall from the feed tank in 
    %the right hand side of the dTn/dt
    exTa.n1.cstrEnBal = dQndt;
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%           
    %Do the CSTR interior energy balance for the feed tank
              
    %Initialize the convective flow energy term
    convFlowEner = 0;
    
    %Initialize the net molar flow in the raffinate product tank
    netMolarFlowIn  = 0;
    netMolarFlowOut = 0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the species dependent terms, based on the flow direction and
    %the interacting boundary

    %For all each column,
    for i = 1 : nCols

        %FLOW INTO THE EXTRACT TANK FROM THE FEED-ENDS OF THE ADSORBERS
        %If we have a counter-current flow and no rinse step is going
        %on, we may be pressurizing the extract product tank with the
        %extract product stream from the column
        if valAdsFeEnd2ExTa(i,nS) == 1
       
            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlowIn = netMolarFlowIn ...
                           + min(0,valAdsFeEnd2ExWa(i,nS)...
                           * col.(sColNums{i}).volFlRat(:,1) ...
                           * col.(sColNums{i}).gasConsTot(:,1));
                     
            %Evaluate the species dependent terms
            for j = 1 : nComs

               %Update the summation term for the product of the component
               %heat capacity and the species concentration in the gas
               %phase
               convFlowEner = convFlowEner ...
                            + htCapCpNorm(j) ...
                            * col.(sColNums{i}).gasCons. ...
                              (sComNums{j})(:,1);

            end
            
            %Multiply the updated term with the volumetric flow rate and
            %the temperature difference
            convFlowEner ...
                = min(0,col.(sColNums{i}).volFlRat(:,1)) ...
                * (col.(sColNums{i}).temps.cstr(:,1)...
                  -exTa.n1.temps.cstr) ...
                * convFlowEner;
        
        %If we have a counter-current flow, we can have a rinse going on
        %from the top-end of the adsorption column
        elseif valExTa2AdsPrEnd(i,nS) == 1 || ...
               valExTa2AdsFeEnd(i,nS) == 1
      
            %Update the net molar flow (since the flow is in a negative
            %direction, the voluemtric flow is negative)
            netMolarFlowOut = netMolarFlowOut ...
                            + max(0,exTa.n1.volFlRat(i)) ...
                            * exTa.n1.gasConsTot;           
        
       %Otherwise, we don't have to do anything as there is no interaction
        %with the extract product tank
        else 
            
            %Do nothing
            
        end
        
        %Calculate the net change in the total moles inside the tank; the
        %negative sign accounts for the negative flow direction.
        netChangeInMoles = -(netMolarFlowIn+netMolarFlowOut);
        
        %Scale the terms with the relevant pre-factors
        presDeltaEner = gConsNormExTa ...
                      * exTa.n1.temps.cstr ...
                      * netChangeInMoles;
        convFlowEner = gConsNormExTa ...
                     * convFlowEner;
        
    end                                                                   
    %---------------------------------------------------------------------%
        
        
        
    %---------------------------------------------------------------------%           
    %Do the energy balance for the extract product tank
    
    %Update the existing field
    exTa.n1.cstrEnBal = (exTa.n1.cstrEnBal ...
                        +presDeltaEner ...
                        +convFlowEner) ...
                      / exTa.n1.htCO;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.exTa = exTa;
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%