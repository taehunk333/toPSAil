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
%Code created on       : 2022/3/14/Monday
%Code last modified on : 2022/3/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : defineRhsFuncSTBm
%Source     : common
%Description: a function that defines the right hand side functions for all
%             steps involved inside a given PSA simulation. This function
%             returns three outputs, instead of one, so that the right hand
%             side function outputs are consistent with what the SUNDIAL
%             interface expects.
%Inputs     : t            - a scalar value of a current time point 
%             y            - a state solution row vector containing all
%                            the state variables associated with the
%                            current step inside a given PSA cycle.
%             params       - a struct containing simulation parameters.
%Outputs    : yDot         - evaluated values for the right hand side 
%                            function for a given step inside a PSA cycle.
%                            This is a column vector.
%             flag         - FLAG=0 if successful, FLAG<0 if an 
%                            unrecoverable failure occurred, or FLAG>0 if 
%                            a recoverable erro occurred.
%             params       - a new data structure (same as the old one)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yDot,flag,params] = defineRhsFuncSTB(~,y,params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'defineRhsFunc.m';    
    
    %Unpack params              
    funcVol = params.funcVol;
    nS      = params.nS     ;
    nCy     = params.nCy    ;
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%                            
    %Check function inputs
      
    %Convert the states to a row vector
    y = y(:).';
    %---------------------------------------------------------------------%                            
    
    
    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each columns and tanks    
    
    %Create an object for the columns
    col = makeColumns(params,y);
    
    %Create an object for the feed tanks
    feTa = makeFeedTank(params,y);
    
    %Create an object for the raffinate product tanks
    raTa = makeRaffTank(params,y);  
    
    %Create an object for the extract product tanks
    exTa = makeExtrTank(params,y);  
    
    %Update col by including interaction between units down or upstream
    col = makeCol2Interact(params,col,feTa,raTa,exTa,nS);
    %---------------------------------------------------------------------%                      
    
    
    
    %---------------------------------------------------------------------%
    %Calculate associated volumetric flow rates for the currently
    %interacting units in the flow sheet
    
    %Based on the volumetric flow function handle, obtain the corresponding
    %volumetric flow rates associated with the adsorption columns
    [col,feTa,raTa,exTa,raWa,exWa] = ...
        funcVol(params,col,feTa,raTa,exTa,nS,nCy);
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the time derivatives of the state variables based on the
    %evaluation of the conservation laws including mole and energy balances
    
        %-----------------------------------------------------------------%
        %Adsorption Columns
        
        %Do the column mole balance (always)
        col = getColMoleBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);                    
        
        %Do the column energy balance (only when asked)                                      
        col = getColEnerBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);    

        %Do the column cumulate flow calculations (always)
        col = getColCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        %-----------------------------------------------------------------%

        
        
        %-----------------------------------------------------------------%
        %Feed Tank

        %Do the feed tank mole balance (always)        
        feTa = getFeTaMoleBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);       

        %Do the feed tank energy balance (only when asked)                     
        feTa = getFeTaEnerBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);    
        
        %Do the feed tank cumulative flow calculations (always)
        feTa = getFeTaCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Raffinate Product Tank    
    
        %Do the raffinate product tank mole balance (always)      
        raTa = getRaTaMoleBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);

        %Do the raffinate product tank energy balance (only when asked)              
        raTa = getRaTaEnerBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        
        %Do the raffinate product tank cumulative flow calculations 
        %(always)
        raTa = getRaTaCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        
        %Get the right hand side expression for the raffinate waste streams
        raWa = getRaWaCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Extract Tank
        
        %Do the extract product tank mole balance (always)      
        exTa = getExTaMoleBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);

        %Do the extract product tank energy balance (only when asked)              
        exTa = getExTaEnerBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        
        %Do the extract product tank cumulative flow calculations (always)
        exTa = getExTaCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        
        %Get the right hand side expression for the extract waste streams
        exWa = getExWaCuMolBal(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Compressor
        
        %Get the right hand side expression for feed compression work rate
        comp = getCompWorkRate(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Vacuum Pump
        
        %Get the right hand side expression for vacuum depressurization 
        %work rate
        pump = getVacWorkRate(params,col,feTa,raTa,exTa,raWa,exWa,nS,nCy); 
        %-----------------------------------------------------------------%                               
        
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Return the right hand side function values containing the time
    %derivatives of the state variables associated with the system 
       
    %Put together the resulting right hand sides from conservation laws and
    %produce the final output (a column vector) for the right hand side 
    %function
    yDot = getRhsFuncVals(params,col,feTa,raTa,exTa,raWa,exWa,comp,pump);          
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Return the information about the success of a right hand side function
    
    %For now, assume that the right hand side function evaluation worked
    %out
    flag = 0;    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%