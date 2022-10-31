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
%Code created on       : 2020/10/26/Wednesday
%Code last modified on : 2022/10/26/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : funcMultiSiteLang.m
%Source     : common
%Description: the function computes the residual to the coupled system of
%             nonlinear functions, implicitly defining the expression for
%             the unknown equalibrium adsorbed phase concentrations.
%Inputs     : theta        - the vector of unkonwn adsorber equilibrium 
%                            site fraction, evaluated at the current state
%                            (gas phase concentrations and the adsorber
%                            temperatures)
%             KCurr        - a row vector that contains the temperature 
%                            dependent pre-exponential factors
%                            [1 x nComs*nVols]
%             aC           - a column vector that contains the exponential
%                            constants for the multi-site Langmuir isotherm
%                            model
%                            [nComs x 1]
%             colGasCons   - a structure containing the state solutions
%                            corresponding to the species gas phase
%                            concentrations 
%             tempCstrCurr - a structure containing the state solutions
%                            corresponding to the CSTR temperatures
%             nVols        - the number of CSTRs per adsorber
%             nComs        - the total number of adsorbates in the syste
%             sComNums     - a cell array containing strings of the
%                            component names
%             t            - the current time point
%Outputs    : residual     - the evaluated value of the vectorized function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function residual ...
    = funcMultiSiteLang(theta,KCurr,aC,colGasCons,tempCstrCurr, ...
                        nVols,nComs,sComNums,t)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'funcMultiSiteLang.m';
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the solution arrays

    %Initialize the output value as a column vector
    residual = zeros(nVols*nComs,1);
    
    %Initialize the sum of the dimensionless adsorbed phase concentratiosn
    sumTheta = zeros(1,nVols);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Build the residual function for each species at a time, i.e., nVols
    %species at a time
    
    %For each species,
    for i = 1 : nComs
        
        %Define the unknown adsorbed phase concentrations corresponding to
        %the current species
        thetaCurr = theta(i:nComs:nComs*(nVols-1)+i);

        %Update the sum 
        sumTheta = sumTheta ...
                 + thetaCurr;
    
    end
        
    %For each species, 
    for i = 1 : nComs

        %Define the unknown adsorbed phase concentrations corresponding to
        %the current species
        thetaCurr = theta(i:nComs:nComs*(nVols-1)+i);
        
        %Get the current temperature dependent pre-exponential factor
        KCurrSpec = KCurr(i:nComs:nComs*(nVols-1)+i);
        
        %Get the current exponent
        aCurr = aC(i);
        
        %Get the gas phase concentrations for the current species
        gasConsSpecCurr = colGasCons.(sComNums{i})(t,:);
        
        %Evaluate the nonlinear function
        residual(i:nComs:nComs*(nVols-1)+i) ...
            = ((-thetaCurr) ...
            + (KCurrSpec.*tempCstrCurr.*gasConsSpecCurr) ...
           .* (1-sumTheta).^aCurr)';

    end
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%