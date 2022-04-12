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
%Code created on       : 2019/9/30/Monday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcEqTheoryRePresVoid.m
%Source     : common
%Description: takes in a struct containing the simulation parameters and
%             compute the number of moles to be removed or added to the 
%             void space in order to achieve a certain pressure change 
%             (delta P). The adsorbents are assumed to be non-interacting 
%             with the gases during the step pressure change.
%Inputs     : params       - a struct containing parameters for the
%                            simulation.
%Outputs    : voidMolDiff  - a scalar value that denotes the moles removed 
%                            from the void space in the wake of the 
%                            instantaneous depressurization. The unit of 
%                            the scalar value [=] mol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function voidMolDiff = calcEqTheoryRePresVoid(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcEqTheoryRePresVoid.m';
    
    %Unpack Params
    presBeHi = params.presBeHi;
    presBeLo = params.presBeLo;
    colVol   = params.colVol  ;
    overVoid = params.overVoid;
    tempCol  = params.tempCol ;
    funcEos  = params.funcEos ;
    
    %Define column void space
    colVoidVol = overVoid*colVol;

    %Define the pressure difference 
    presDiff = presBeHi-presBeLo; 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute changes in number of moles in the void space upon the pressure
    %change using an equation of state
    
    %Let's solve for number of moles needed to achieve the pressure change
    n = 0;

    %Use EOS to relate pressure difference to the moles needed
    [~,~,~,voidMolDiff] = funcEos(params,presDiff,colVoidVol,tempCol,n);
    %---------------------------------------------------------------------%   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%