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
%Code created on       : 2021/1/14/Thursday
%Code last modified on : 2022/7/20/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : defineRhsFunc.m
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

function xDot = defineRhsFunc(~,x,params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'defineRhsFunc.m';    
    
    %Unpack params              
    funcVol = params.funcVol;
    nS      = params.nS     ;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %Check function inputs
      
    %Convert the states to a row vector
    x = x(:).';
    %---------------------------------------------------------------------%                            
    

    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each columns and tanks    
    
    %Create an object for the columns
    units.col = makeColumns(params,x);
    
    %Create an object for the feed tanks
    units.feTa = makeFeedTank(params,x);
    
    %Create an object for the raffinate product tanks
    units.raTa = makeRaffTank(params,x);  
    
    %Create an object for the extract product tanks
    units.exTa = makeExtrTank(params,x); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define the inter-unit interactions in a given process flow diagram    
    
    %Update adsorption column structures to contain interactions between 
    %units down or upstream
    units = makeCol2Interact(params,units,nS);
    
    %Based on the volumetric flow function handle, obtain the corresponding
    %volumetric flow rates associated with the adsorption columns
    units = funcVol(params,units,nS);
    %---------------------------------------------------------------------%                      
    
        
    
    %---------------------------------------------------------------------%
    %Evaluate the time derivatives of the state variables based on the
    %evaluation of the conservation laws including mole and energy balances
    
        %-----------------------------------------------------------------%
        %Adsorption Columns
        
        %Do the column mole balance
        units = getColMoleBal(params,units);                    
        
        %Do the column energy balance                                  
        units = getColEnerBal(params,units);  

        %Do the column cumulate flow calculations
        units = getColCuMolBal(params,units);
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Feed Tank

        %Do the feed tank mole balance      
        units = getFeTaMoleBal(params,units);       

        %Do the feed tank energy balance               
        units = getFeTaEnerBal(params,units);      
        
        %Do the feed tank cumulative flow calculations
        units = getFeTaCuMolBal(params,units);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Raffinate Product Tank    
    
        %Do the raffinate product tank mole balance      
        units = getRaTaMoleBal(params,units,nS);

        %Do the raffinate product tank energy balance             
        units = getRaTaEnerBal(params,units,nS);
        
        %Do the raffinate product tank cumulative flow calculations 
        units = getRaTaCuMolBal(params,units);
        
        %Get the right hand side expression for the raffinate waste streams
        units = getRaWaCuMolBal(params,units,nS);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Extract Tank
        
        %Do the extract product tank mole balance     
        units = getExTaMoleBal(params,units,nS);

        %Do the extract product tank energy balance             
        units = getExTaEnerBal(params,units,nS);
        
        %Do the extract product tank cumulative flow calculations
        units = getExTaCuMolBal(params,units);
        
        %Get the right hand side expression for the extract waste streams
        units = getExWaCuMolBal(params,units,nS);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Compressor
        
        %Get the right hand side expression for feed compression work rate
        units = getCompWorkRate(params,units);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Vacuum Pump
        
        %Get the right hand side expression for vacuum depressurization 
        %work rate
        units = getVacWorkRate(params,units,nS); 
        %-----------------------------------------------------------------%                               
        
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Return the right hand side function values containing the time
    %derivatives of the state variables associated with the system 
       
    %Put together the resulting right hand sides from conservation laws and
    %produce the final output (a column vector) for the right hand side 
    %function
    xDot = getRhsFuncVals(params,units); 
    %---------------------------------------------------------------------%                        
         
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%