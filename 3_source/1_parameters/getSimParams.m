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
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2022/1/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getSimParams.m
%Source     : common
%Description: a function MATLAB function file in which Parameters 
%             describing a given PSA system will be specified for the 
%             simulation in a format of a structure called "Params".
%Inputs     : exampleFolder - a string denoting a location of the example
%                            folder
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getSimParams(exampleFolder)        
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getSimParams.m';
    %---------------------------------------------------------------------%    
    

    
    %---------------------------------------------------------------------%
    %Opening remarks for the getSimParams.m
    
    %Print the statement saying that we have successfully initialized the
    %simulation environment and are ready for a simulation
    fprintf('\n\nThe simulator started the initialization...\n\n');         
    %---------------------------------------------------------------------%     
    
    
    
    %---------------------------------------------------------------------%    
    %Read simulation inputs from an excel file & create a struct named
    %"params"
    
    %Obtain the initial set of simulation input parameters
    params = getExcelParams(exampleFolder);
    %---------------------------------------------------------------------%
    
               
    
    %---------------------------------------------------------------------%    
    %Identify system information
        
    %Get parameters associated with the system's state variables
    params = getStatesParams(params);
    
    %Get parameters associated with the stream properties
    params = getStreamParams(params);
    
    %Get parameters associated with string names
    params = getStringParams(params);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define functions for the sub-models used in the simulator. 
    
    %Specify sub-models from user inputs in params        
    models = getSubModels(params);
    
    %Unpack models (basic):
    if true
        
        %Specify isotherm model inside params
        params.funcIso = models{1};

        %Specify adsorption rate model inside params
        params.funcRat = models{2};

        %Specify equation of states inside params
        params.funcEos = models{3};

        %Specify a valve model inside params
        params.funcVal = models{4};
        
        %Specify a volumetric flow rate calculation model
        params.funcVol = models{6};
        
        %Specify a CSS convergence model
        params.funcCss = models{7};
        
    end
    
    %Unpack models (non-isothermal):
    if params.bool(5) == 1
        
        %Specify a heat capacity model
        params.funcHtCap = models{5};        
        
    end
    %---------------------------------------------------------------------%          
    
    
    
    %---------------------------------------------------------------------%
    %Define sub-model parameters
    
    %Define adsorption isotherm (equilibrium) parameters
    params = getAdsEquilParams(params);
    
    %Define adsorption rate parameters
    params = getAdsRateParams(params);
    %---------------------------------------------------------------------%
    
    
                    
    %---------------------------------------------------------------------%    
    %Determine the definition of the void fraction and the density to be
    %used for mole balance based on the controlling resistance specified by
    %the user
    
    %Define overall void fraction and overall density
    params = getVoidAndDens(params);
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%    
    %Specification of dimensions and operational windows of appratus in the
    %system
    
    %Get the pressure ratios
    params = getPresRats(params);
    
    %Get the temperature ratios
    params = getTempRats(params);
    
    %Get parameters associated with an adsorption column from calculations
    params = getColumnParams(params);
    
    %Get parameters associated with feed/product receiver tanks from 
    %calculations
    params = getTankParams(params);        
    %---------------------------------------------------------------------%    
    
    
                                
    %---------------------------------------------------------------------%                           
    %Compute gas properties for the feed gas
    
    %Calculate the total concentrations
    params = getTotalConc(params);           
    
    %Calculate the overall heat capacity ratio for the feed mixture
    params = getFeHtCapRatio(params);
    
    %Calculate the overall compressibility factor for the feed mixture
    params = getFeMixCompFac(params); 
    %---------------------------------------------------------------------%    

    
    %---------------------------------------------------------------------%
    %Calculate necessary volumetric flow rates from valve constants
    
    %Get a feed volumetric flow rate to an adsorption column at a high
    %pressure
    params.volFlowFeed = calcVolFlowNorm(params);
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%
    %Define scaling factors for non-dimensionalization
    
    %Get the scale factors for the non-dimensionalization
    params = getScaleFacs(params);
    %---------------------------------------------------------------------%                                       
    
    
    
    %---------------------------------------------------------------------%
    %Perform equilibrium theory based calculations          
    
    %Compute the maximum moles of raffinate product that can be produced 
    %under the equilibrium theory
    [params.maxMolPr,params.maxMolFe,params.maxMolAdsC] ...
        = calcEqTheoryHighPres(params);    
    
    %Compute changes absolute amount of moles between high and low 
    %pressuresdue 
    params.voidMolDiff ...
        = calcEqTheoryRePresVoid(params);

    %Compute moles adsorbed during re-pressurization
    params.adsMolDiff ...
        = calcEqTheoryRePresAds(params);
    
    %Compute the Normalization constant for product generated as per the
    %Equilibrium theory
    params.maxNetPrdOp ...
        = params.maxMolPr ...
        - params.voidMolDiff ...
        - params.adsMolDiff;
    %---------------------------------------------------------------------%    
   
    
   
    %---------------------------------------------------------------------%
    %Get parameters for conservation laws (if needed)
    
    %Get Parameters for Energy Balance       
    if params.bool(5) == 1
        
        %Calculate parameters that are needed for energy balance
        params = getEnergyBalanceParams(params);        
        
    end    
    
    %Get Parameters for Momentum Balance      
    if params.bool(6) == 1
        
        %Calculate parameters that are needed for momentum balance
        params = getMomentumBalanceParams(params);    
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute dimensionless quantities
    
    %Grab dimensionless quantities
    params = getDimLessParams(params);                           
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Perform mass transfer zone theory based calculations          
    
    %Specifty parameters for computing MTZ thickness
    params.mtz = getMtzParams();    
    
    %Define the areaThreshold
    areaThres = params.mtz.areaThres;
    
    %Compute the normalization constant for time [=] seconds
    [params.maxTiFe,~] = calcMtzTheory(params,areaThres);     
    
    %Compute the nominal volumetric feed flow rate as per the predicted
    %equilibrium calculations above for the high pressure feed step 
    %duration and the maximum moles of raffinate product produced.
    %[=] cc/sec
    params.volFlowEq = params.maxMolFe/params.maxTiFe/params.gConScaleFac; 
    %---------------------------------------------------------------------%

    
    
    %---------------------------------------------------------------------%
    %Organize the PSA cycle
    
    %Get parameters related to cycle organization
    params = getCycleOrg(params);                     
    
    %Get parameters related to boundary conditions
    params = getColBoundConds(params);
    
    %Get a normalized duration of each steps in a given PSA cycle
    params = getTimeSpan(params);     
    
    %Get the parameters related to event functions
    params = getEventParams(params);
    
    %Get event functions for all the steps in a given PSA cycle
    params.funcEve = getEventFuncs(params);                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define parameters related to numerical methods             
    
    %Grab parameters associated with numerical methods and store inside
    %params as fields
    params = getNumParams(params);                        
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Get solver related parameters

    %Get solver options
    params = getSolverOpts(params);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define the initial condition
    
    %Define an initial state row vector (dimensionless)
    params.initStates = getInitialStates(params);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove any unnecessary fields in params
    
    %Remove unnecessary fields from the structure named params
    params = removeParams(params);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Closing remarks for the getSimParams.m
    
    %Print the statement saying that we have successfully initialized the
    %simulation environment and are ready for a simulation
    fprintf('The simulator has successfully initialized!\n\n');         
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%