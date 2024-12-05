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
    bool     = params.bool    ;
    sStepCol = params.sStepCol;
    nCols    = params.nCols   ;
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Add additional new parameters for the step
    
    %Define the number of time points
    params.nRows = 1;
    
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
    
    
    
    %---------------------------------------------------------------------%  
    %Handle hysteresis in adsorption isotherm        
    
    %Initialize the hysteresis information vector for the step; by default
    %there is no hysteresis
    hys = zeros(nCols,1);
    
    %If there is a hysteresis
    if bool(12) == 1            
        
        %For each adsorber
        for i = 1 : nCols
        
            %Get the current step name for the 
            sStepColCurr = sStepCol{i,nS};

            %Check to see if we are adsorbing           
            isAdsorbing = contains(sStepColCurr,'HP') || ... %Feed
                          contains(sStepColCurr,'HR') || ... %Rinse
                          contains(sStepColCurr,'RP');       %Repres.

%             %Check to see if we are desorbing           
%             isDesorbing = contains(sStepColCurr,'LP') || ... %Feed
%                           contains(sStepColCurr,'HR') || ... %Rinse
%                           contains(sStepColCurr,'DP');       %Repres.
                      
            %If we are on the adsorption curve
            if isAdsorbing == 1

                %Let us select the isotherm parameters for adsorption
                hys(i) = 1;

            %If we are on the desorption curve
            elseif isAdsorbing == 0

                %Let us select the isotherm parameters for desorpaion
                hys(i) = 2;

            %Otherwise
            else

                %By default, we are adsorbing
                hys(i) = 1;

            end        
                        
        end
        
    end
    
    %Grab the set of isotherm parameters relevant for the selected curve 
    %for the hysteresis
    params = grabHysteresis(params,hys);
    %---------------------------------------------------------------------%  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%