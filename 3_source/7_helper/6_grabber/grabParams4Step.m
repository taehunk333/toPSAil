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
%Code created on       : 2022/10/3/Monday
%Code last modified on : 2022/10/22/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : grabParams4Step.m
%Source     : common
%Description: This function takes in a structure called params, containing
%             the parameters needed for running the entire PSA cycle
%             simulations and specialized the simulation so that the step
%             specific information are defined for the step. Doing this
%             before the numerical integration helps with not having to
%             use index or if-statement inside the right-hand side function
%             for each time step during the numerical integration of the
%             ODEs for a specific step in a PSA cycle.
%Inputs     : params       - a struct containing simulation parameters.  
%             nS           - the current step in a given PSA cycle.
%Outputs    : params       - a struct containing simulation parameters.             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = grabParams4Step(params,nS)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'grabParams4Step.m';
    
    %Unpack params
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Add additional new parameters for the step
    
    %Define the number of time points
    params.nRows = 1  ;
    
    %Define the current step 
    params.nS = nS;        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify event specific parameters for the current step
    
    %Grab the current event value for the light key mole fraction
    params.eveLkMolFrac = params.eveLkMolFrac(nS);
    
    %Grab the current event value for the total pressure
    params.eveTotPresNorm = params.eveTotPresNorm(nS);
    
    %Grab the current event value for the interior temperature
    params.eveTempNorm = params.eveTempNorm(nS);        
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%