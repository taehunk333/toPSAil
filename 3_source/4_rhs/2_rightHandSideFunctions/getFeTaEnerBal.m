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
    
    %Unpack units
    feTa = units.feTa;
    
    %If isothermal model
    if bool(5) == 0
        
        %-----------------------------------------------------------------%
        %Don't do the energy balance on the feed tank
        feTa.n1.cstrEnBal = 0;            
        feTa.n1.wallEnBal = 0;  
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                          
        %Return the updated structure for the units

        %Pack units
        units.feTa = feTa;
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
    intHtTrFacTan  = params.intHtTrFacTan ;
    extHtTrFacTan  = params.extHtTrFacTan ; 
    ambTempNorm    = params.ambTempNorm   ;
    gasConsNormTan = params.gasConsNormTan;
    htCapCpNorm    = params.htCapCpNorm   ;
    pRatFe         = params.pRatFe        ;
    yFeC           = params.yFeC          ;
    %---------------------------------------------------------------------%              
        
    
    
    %---------------------------------------------------------------------%    
    %Do the CSTR wall energy balance for the feed tank
    
    %Compute the interior heat transfer rates
    dQndt = feTa.n1.temps.wall ...
          - feTa.n1.temps.cstr;

    %Compute the exterior heat transfer rates
    dQnwdt = ambTempNorm ... 
           - feTa.n1.temps.wall;    

    %Save ith feed tank wall energy balance into the struct
    feTa.n1.wallEnBal = extHtTrFacTan*dQnwdt ...
                      - intHtTrFacTan*dQndt;
    %---------------------------------------------------------------------%    



    %---------------------------------------------------------------------%                                       
    %Initialize the right hand side of dimensionless energy balance
  
    %Save the heat transfer rate to the column wall from CSTR in the 
    %right hand side of the dTn/dt
    feTa.n1.cstrEnBal = dQndt;              
    %---------------------------------------------------------------------%               
    
    
    
    %---------------------------------------------------------------------%               
    %Unpack states    
    
    %Unpack the volumetric flow rates
    vnm1 = feTa.n1.volFlRat(:,end) ;                

    %Unpack the interior temperature variables
    
    %Assume that the temperature of the compressed feed remains the same
    Tnm1 = ambTempNorm; 
    
    %Get the current temperature of the feed tank
    Tnm0 = feTa.n1.temps.cstr;                

    %Unpack the overall heat capacity                
    htCOnm0 = feTa.n1.htCO;                                                               
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate species dependent term
    
    %Initialize the convective energy flow term
    convFlowEner = 0;
    
    %For each species
    for j = 1 : nComs
        
        %Update the first term
        convFlowEner = convFlowEner ...
                     + htCapCpNorm(j) ...
                     * (pRatFe*yFeC(j));    
        
    end            
    
    %Update the term with the prefactors
    convFlowEner = gasConsNormTan ...
                 * vnm1*(Tnm1-Tnm0) ...
                 * convFlowEner;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%           
    %Calculate the right hand side of dimensionless energy balance for the
    %feed tank. We assume that the flow is always in co-current direction
    %for the feed tank; this is because the feed tank by definition should
    %be maintained and the highest pressure in the system.
    
    %Evaluate the right hand side for the interior temperature for the feed
    %tank by accounting for the flow term
    feTa.n1.cstrEnBal = (feTa.n1.cstrEnBal ...
                        +convFlowEner) ...
                      / htCOnm0;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.feTa = feTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%