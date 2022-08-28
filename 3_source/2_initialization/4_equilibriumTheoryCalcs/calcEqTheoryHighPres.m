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
%Code created on       : 2020/1/28/Tuesday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcEqTheoryHighPres.m
%Source     : common 
%Description: takes in a struct containing important parameter for the
%             simulation of PSA cycle and computes the maximum number of 
%             moles that can be generated when applying the equilibrium 
%             theory.
%             let A be defined as "total rate of heavy key adsorption" in 
%             the mass transfer zone (MTZ)" and B be defined as "total 
%             capacity for heavy key adsorption" between two different 
%             equalibrium states designated by (1) in equilibrium w/ high
%             pressure product gas, and (2) in equilibrium w/ high pressure
%             feed gas.
%Inputs     : params       - a struct containing parameters for the
%                            simulation.                          
%Outputs    : maxMolPr     - a scalar quantitiy that represents the 
%                            theoretically possible maximum moles of 
%                            products that can be generated according to 
%                            the equilibrium theory of PSA processs.                       
%             maxMolFe     - a scalar quantitiy that represents the moles 
%                            of feed that fed into the column to compute 
%                            the theoretical equilibrium limit of maximum 
%                            raffinate proudcts generated.                          
%             maxMolAdsC   - a row vector holding moles of respective (ith)
%                            key adsorbed in the system by assuming the 
%                            equilibrium theory and carrying out the 
%                            maximum raffinate product generation 
%                            calculation.
%                            The dimension of the vector is, therefore, 
%                            [1 x n_comp], where n_comp represents the 
%                            number of components in the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [maxMolPr,maxMolFe,maxMolAdsC] = calcEqTheoryHighPres(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcEqTheoryHighPres.m';
    
    %Unpack Params
    massAds      = params.massAds     ;    
    yRaC         = params.yRaC        ;
    yFeC         = params.yFeC        ;
    overVoid     = params.overVoid    ;
    presBeHiFull = params.presBeHiFull;
    colVol       = params.colVol      ;    
    tempCol      = params.tempCol     ;
    funcIso      = params.funcIso     ;    
    tempAmbi     = params.tempAmbi    ;
    nComs        = params.nComs       ;
    sComNums     = params.sComNums    ;
    funcEos      = params.funcEos     ;
    
    %Make local params specifications
    
    %Locally define nScaleFac = 1 so that we can use
    %convert2DimColStates.m within this function locally; we don't need
    %to dimensinoalize cumulative moles anyways for a single CSTR state.
    params.nScaleFac = 1;         
        
    %Define mole fraction of the heavy key for feed as the sum of all the
    %heavy keys in the system
    yHpFeLk = yFeC(1)  ; 
    yHpFeHk = 1-yHpFeLk;
    
    %Define mole fractions for raffinate product
    yHpRaLK = yRaC(1)  ;
    yHpRaHK = 1-yHpRaLK;
    
    %Define mole fractions for void space for the initial and final states
    yHpVoHkIn = yHpRaHK;
    yHpVoHkFi = yHpFeHk;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Perform equilibrium calculations for product gas in equilibrium with a
    %high pressure gas
    
    %Define a column vector holding dimensionless product gas compositions
    statesHpPrGas = [yRaC', ...
                     zeros(1,nComs), ...
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
    %Perform equilibrium calculations for feed gas in equilibrium with a
    %high pressure gas
    
    %Define a column vector holding dimensionless feed gas compositions
    statesHpFeGas = [yFeC', ...
                     zeros(1,nComs), ...
                     tempCol/tempAmbi, ...
                     tempAmbi/tempAmbi];
    
    %Define the number of time points
    params.nRows = 1;
        
    %Invoke adsorption isotherm relationship to compute adsorbed phase in
    %equilibrium with feed gas composition
    statesHpFeGas = funcIso(params,statesHpFeGas,0);

    %Dimensionalize the states
    dimStatesHpFeGas = convert2DimColStates(params,statesHpFeGas);
    
    %Grab the equilibrium adsorbed phase compositions of the product gas
    dimAdsConHpFe = convert2ColAdsConc(params,dimStatesHpFeGas);                    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the difference in the adsorbed moles b/t two different states
    
    %Initialize the solution vector for the changes in adsorbed phase
    %concentrations between the two different states, 
    adsMolDiff = zeros(nComs,1);
    
    %Initialize the solution vector for the initial adsorbed moles of all 
    %of the components
    adsMolC = zeros(nComs,1);    
    
    %Compute the moles of keys adsorbed when comparing the two equilibrium
    %states mentioned in the preamble of the function comments            
    for i = 1 : nComs
        
        %Compute the difference in moles b/t the two different states for
        %species i
        adsMolDiff(i) = massAds* ...
                        (dimAdsConHpFe.(sComNums{i}) ...
                        -dimAdsConHpPr.(sComNums{i}));  
     
        %Compute the initial adsorbed moles of an ith component 
        adsMolC(i) = massAds ...
                   * dimAdsConHpPr.(sComNums{i});
        
    end
    
    %Define total change in the light key b/t the two different states
    adsMolDiffLk = adsMolDiff(1);
    
    %Define total change in the heavy key b/t the two different states
    adsMolDiffHk = sum(adsMolDiff(2:end));        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the maximum moles of raffinate product at a given purity
    %baseed on the equilibrium theory    
    
    %Compute total moles adsorbed
    adsTotMolDiff = adsMolDiffHk ...
                  + adsMolDiffLk;
    
    %Compute initial moles of (ith) key on the adsorbent
    adsMolHpLkIn = adsMolC(1)         ;
    adsMolHpHkIn = sum(adsMolC(2:end));
                            
    %Compute total adsorbed moles in the initial states
    adsTotMolHpIn = (adsMolHpHkIn ...
                    +adsMolHpLkIn);
                
    %Compute the heavy key mole fraction of adsorbed phase before 
    %adsorption
    yAdsHpHkIn = (adsMolHpHkIn) ...
               / (adsTotMolHpIn);

    %Compute total moles adsorbed after adsorption
    adsTotMolHpFn = adsTotMolHpIn ...
                  + adsTotMolDiff;

    %Compute the mole fraction of adsorbed phase heavy key after adsorption
    yAdsHpHkFn = (adsMolHpHkIn ...
                 +adsMolDiffHk) ...
               / (adsTotMolHpFn);                     
    
    %Compute the total moles of gas held inside the column void space at a 
    %high pressure with a specified system temperature. Also note that this 
    %quantitiy does not change when the adsorption column is maintained at 
    %a constant pressure. i.e. n_void_before = n_void_after = n_void.    
    [~,~,~,adsHpMolVoid] ...
        = funcEos(params,presBeHiFull,colVol*overVoid,tempCol,0);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the function outputs
    
    %Return the scalar quantity of theoretically possible maximum raffinate
    %amount based on the equilibrium thoery for PSA process
    maxMolPr = ((yAdsHpHkFn-yHpFeHk)*adsTotMolHpFn ...
             + (yHpFeHk-yAdsHpHkIn)*adsTotMolHpIn ...
             + (yHpVoHkFi-yHpVoHkIn)*adsHpMolVoid) ...
             / (yHpFeHk-yHpRaHK);

    %From the overall mass balance, compute the moles of feed that entered 
    %the system
    maxMolFe = maxMolPr ...
             + adsTotMolDiff;
 
    %Return a column vector containing moles of keys adsorbed
    maxMolAdsC = [adsMolDiffLk;adsMolDiffHk];
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%