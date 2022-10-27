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
%Code created on       : 2020/2/19/Wednesday
%Code last modified on : 2022/10/27/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcEqTheoryRePresAds.m
%Source     : common
%Description: takes in a struct containing the simulation parameters and
%             compute the total number of moles adsorbed during 
%             re-pressurization step of a given standard Skarstrom type PSA
%             cycle. 
%             Note: In this case we are assuming that the initial state 
%                   before the re-pressurization is adsorption column in 
%                   equilibrium with light key product at a low pressure.
%                   The final state after the re-pressurization is 
%                   adsorption column in equilibrium with light key product
%                   at a high pressure.
%Inputs     : params       - a struct containing parameters for the
%                            simulation.
%Outputs    : adsMolDiff   - a scalar value that denotes the total moles 
%                            adsorbed during re-pressurization step of a 
%                            given standard Skarstrom type PSA cycle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function adsMolDiff = calcEqTheoryRePresAds(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcEqTheoryRePresAds.m';
    
    %Unpack Params
    massAds  = params.massAds ;         
    yRaC     = params.yRaC    ;       
    tempCol  = params.tempCol ;
    tempAmbi = params.tempAmbi;
    pRat     = params.pRat    ;
    funcIso  = params.funcIso ;
    nComs    = params.nComs   ;
    sComNums = params.sComNums;
    
    %Make local params specifications
    
    %Locally define nScaleFac = 1 so that we can use
    %convert2DimColStates.m within this function locally; we don't need
    %to dimensinoalize cumulative moles anyways for a single CSTR state.
    params.nScaleFac = 1;   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate concentrations at initial states: light key saturation at
    %a low pressure
    
    %Grab a vector containing mole fractions of low pressure gas phase 
    %concentrations of product
    yLpPrC = pRat*yRaC';          
            
    %Define an initial state for a single CSTR
    statesLpPrGas = [yLpPrC, ...
                     [1,zeros(1,nComs-1)], ...
                     tempCol/tempAmbi, ...
                     tempAmbi/tempAmbi];   
        
    %Define the number of time points
    params.nRows = 1;
        
    %Invoke adsorption isotherm relationship to compute adsorbed phase in
    %equilibrium with product gas composition
    statesLpPrGas = funcIso(params,statesLpPrGas,0);
    
    %Dimensionalize the states
    statesLpPrGas = convert2DimColStates(params,statesLpPrGas);    
    
    %Grab the equilibrium adsorbed phase compositions of the product gas
    dimAdsConLpPr = convert2ColAdsConc(params,statesLpPrGas);     
    %---------------------------------------------------------------------%
   
    
    
    %---------------------------------------------------------------------%
    %Calculate concentrations at final states: light key saturation at a
    %high pressure  
    
    %Grab a vector containing mole fractions of low pressure gas phase 
    %concentrations of product
    yHpPrC = yRaC';          
            
    %Define an initial state for a single CSTR
    statesHpPrGas = [yHpPrC, ...
                     [1,zeros(1,nComs-1)], ...
                     tempCol/tempAmbi, ...
                     tempAmbi/tempAmbi];   
    
    %Define the number of time points
    params.nRows = 1;
        
    %Invoke adsorption isotherm relationship to compute adsorbed phase in
    %equilibrium with product gas composition
    statesHpPrGas = funcIso(params,statesHpPrGas,0);
    
    %Dimensionalize the states
    statesHpPrGas = convert2DimColStates(params,statesHpPrGas);    
    
    %Grab the equilibrium adsorbed phase compositions of the product gas
    dimAdsConHpPr = convert2ColAdsConc(params,statesHpPrGas); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate adsorbed phase concentrations at initial and final states
    
    %Initialize a solution vector to hold differece in the adsorbed phase
    %amount (in moles) for all species
    adsMolDiffC = zeros(nComs,1);
    
    %loop through For-Loop and compute the difference in the adsorbed phase
    %moles for species i for all species $i \in \left\{ 1, ..., n_s 
    %\right\}$
    for i = 1 : nComs
        
        %Compute the difference in moles of adsorbed species i b/t two
        %different states and store it in the solution vector
        adsMolDiffC(i) = ...
         massAds*(dimAdsConHpPr.(sComNums{i})-dimAdsConLpPr.(sComNums{i}));  
     
    end       
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate total moles adsorbed during re-pressurization    

    %Compute total  moles of adsorbents adsorbed during the 
    %re-pressurization step
    adsMolDiff = sum(adsMolDiffC);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%