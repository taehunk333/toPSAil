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
%Code created on       : 2022/1/26/Wednesday
%Code last modified on : 2022/6/9/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getScaleFacs.m
%Source     : common
%Description: given an initial set of parameters, define relevant scale
%             factors and save them as field variables in a struce named
%             params.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getScaleFacs(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getScaleFacs.m';
    overVoid     = params.overVoid    ;
    colVol       = params.colVol      ;
    volFlowFeed  = params.volFlowFeed ;
    gasConT      = params.gasConT     ;
    adsConT      = params.adsConT     ;
    tempAmbi     = params.tempAmbi    ;
    gasCons      = params.gasCons     ;
    feFeVol      = params.feTaVol     ;
    feRaVol      = params.raTaVol     ;
    feExVol      = params.exTaVol     ;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Define the scale factors     
    
    %Define a term to scale dimensional time to non-dimensional time. i.e.
    %the residence time Tau [sec]
    params.tiScaleFac = overVoid ...
                      * colVol ...
                      / volFlowFeed;        
    
    %Define a term to scale dimensional gas phase concentrations to 
    %non-dimensional concentrations [mol/cc]
    params.gConScaleFac = gasConT; 
    
    %Define a term to scale dimensional adsorbed phase concentrations to
    %non-dimensional concentrations [mol/kg]
    params.aConScaleFac = adsConT; 
    
    %Define a term to scale dimensional volumetric flowrates to
    %non-dimensional volumetric flowrates [cc/sec]
    params.volScaleFac = volFlowFeed;
    
    %Define a term to scale dimensional temperature variables to 
    %non-dimensional temperature variables [K]
    params.teScaleFac = tempAmbi;
    
    %Define scaling factor for maximum moles (initialize it with zero).
    %This will be updated after the equilibrium theory calculation. [mol]
    params.nScaleFac = params.volScaleFac ...
                     * params.gConScaleFac ...
                     * params.tiScaleFac; 
    
    %Define a factor to be multiplied to a valve constant so that the valve
    %constant becomes dimensionless quantity [bar-sec/kmol]
    params.valScaleFac = 1000 ...
                       * gasCons ...
                       * tempAmbi ...
                       / params.volScaleFac;
                     
    %Define scaling factor for volume for tanks [-]; actually this is the
    %inverse of the tank scale factor derived in the derivation.
    params.feTaScaleFac = overVoid ...
                        * colVol ...
                        / feFeVol;
    params.raTaScaleFac = overVoid ...
                        * colVol ...
                        / feRaVol;
    params.exTaScaleFac = overVoid ...
                        * colVol ...
                        / feExVol;
       
    %Define scaling factor for the energy [J]
    %Energy scaling factor = $\tau 0.1 z R T_{amb} 
    %                         \left( \frac{\gamma}{\gamma-1} \right)
    %                         c_0 v_0 / \eta$
    % \tau [=] the residence time of the adsorber
    % R [=] cc-bar/mol-K, the ideal gas constant
    % 1 J = 10 cc-bar, a conversion factor
    % z [=] -, the compressibility factor
    % T_{amb} [=] the ambient temperature
    % \gamma [=] the ratio of the constant pressure heat capacity to the
    %            constant volumen heat capacity
    % c_0 [=] the feed gas total concentration
    % v_0 [=] the feed volumetric flow rate
    params.enScaleFac = (1/10) ...                      
                      * params.gasCons ...
                      * params.teScaleFac ...
                      * params.tiScaleFac ...
                      * params.volScaleFac ...
                      * params.gConScaleFac;             
    %---------------------------------------------------------------------%                                               
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%