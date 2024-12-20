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
%Function   : getFeTaEnerBal.m
%Source     : common
%Description: This function computes the right hand side for the state
%             variables associated with the feed tank.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getFeTaEnerBal(params,units)
    
    %---------------------------------------------------------------------%
    %Check to see if we need an energy balance
    
    %Unpack minimal number of params
    bool = params.bool;
    nFeTas         = params.nFeTas        ;
    sFeTaNums      = params.sFeTaNums     ;
    
    %Unpack units
    feTa = units.feTa;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %Don't do the energy balance on the feed tank
        for i = 1:nFeTas
            units.feTa.(sFeTaNums{i}).cstrEnBal = 0;            
            units.feTa.(sFeTaNums{i}).wallEnBal = 0;  
        end
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
    %funcId = 'getFeTaEnerBal.m';
    
    %Unpack params
    nComs          = params.nComs         ;
    intHtTrFacFeTa = params.intHtTrFacFeTa;
    extHtTrFacFeTa = params.extHtTrFacFeTa;
    tempAmbiNorm   = params.tempAmbiNorm  ;
    gConsNormFeTa  = params.gConsNormFeTa ;
    htCapCpNorm    = params.htCapCpNorm   ;
    yFeC           = params.yFeC          ;
    pRatFe         = params.pRatFe        ;
    gasConsNormEq  = params.gasConsNormEq ;
    tempFeedNorm   = params.tempFeedNorm  ;
    feTaVolNorm    = params.feTaVolNorm   ;
    nFeTas         = params.nFeTas        ;
    sFeTaNums      = params.sFeTaNums     ;
    bool           = params.bool          ;
    if bool(13) == 1
        yFeC = [params.yFeC,params.yFeTwoC];
    end
    %---------------------------------------------------------------------%              
        
    
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for the feed tank
    
    for i = 1 : nFeTas

    %Unpack the temperature of the feed tank
    feTaTempCstr = feTa.(sFeTaNums{i}).temps.cstr;
    
    %Compute the interior heat transfer rates
    dQndt = feTa.(sFeTaNums{i}).temps.wall ...
          - feTaTempCstr;

    %Compute the exterior heat transfer rates
    dQnwdt = tempAmbiNorm ... 
           - feTa.(sFeTaNums{i}).temps.wall;    

    %Save ith feed tank wall energy balance into the struct
    feTa.(sFeTaNums{i}).wallEnBal = extHtTrFacFeTa*dQnwdt ...
                      - intHtTrFacFeTa*dQndt;
    %---------------------------------------------------------------------%    



    %---------------------------------------------------------------------%                                       
    %Initialize the right hand side of dimensionless energy balance
  
    %Save the heat transfer rate to the column wall from CSTR in the 
    %right hand side of the dTn/dt
    feTa.(sFeTaNums{i}).cstrEnBal = dQndt;    
    %---------------------------------------------------------------------%               
    
    
    
    %---------------------------------------------------------------------%
    %Unpack additional quantaties associated with the extract product tank
    
    %Unpack the net change in the total moles inside the feed tank
    netChangeGasConcTot = feTa.(sFeTaNums{i}).moleBalTot;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the net change in the total concentration inside the 
    %raffinate product tank
    
    %Compute the net change in the total conecntration term
    presDeltaEner  = gConsNormFeTa ...
                   * feTaVolNorm ...
                   * feTaTempCstr ...
                   * netChangeGasConcTot;              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%               
    %Calculate needed quantities to describe the feed stream into the 
    %overall process flow sheet
    
    %Unpack the volumetric flow rates
    feedVolFlowRat = feTa.(sFeTaNums{i}).volFlRat(:,end);
         
    %Calculate the total concentration of the feed
    gasConsTotFeed = pRatFe/(gasConsNormEq*tempFeedNorm);
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate species dependent term
    
    %Initialize the convective energy flow term
    convFlowEnerIn = 0;        

    %For each species
    for j = 1 : nComs
        
        %Update the first term
        convFlowEnerIn = convFlowEnerIn ...
                       + htCapCpNorm(j) ...
                       * (gasConsTotFeed*yFeC(j,i));    
        
    end            
    
    %Multiply the updated term with the volumetric flow rate and the 
    %temperature difference
    convFlowEnerIn = gConsNormFeTa ...
                   * max(0,feedVolFlowRat) ...
                   * (tempFeedNorm-feTaTempCstr) ...
                   * convFlowEnerIn;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%           
    %Calculate the right hand side of dimensionless energy balance for the
    %feed tank. We assume that the flow is always in co-current direction
    %for the feed tank; this is because the feed tank by definition should
    %be maintained and the highest pressure in the system.
    
    %Evaluate the right hand side for the interior temperature for the feed
    %tank by accounting for the flow term.
    feTa.(sFeTaNums{i}).cstrEnBal = (feTa.(sFeTaNums{i}).cstrEnBal ...
                        +presDeltaEner ...
                        +convFlowEnerIn) ...
                      / feTa.(sFeTaNums{i}).htCO;
    %---------------------------------------------------------------------%
    
    end
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.feTa = feTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%