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
%Code created on       : 2019/2/3/Sunday
%Code last modified on : 2020/12/14/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcEosIdealGas.m
%Source     : common
%Description: The function receives 4 (P, V, T, n) variables (one of them 
%             is zero) as inputs and calculates the zero input variable as
%             output using the ideal gas law PV = nRT.
%             (1) One unknown to be solved for should be passed into 
%                 function as zero
%             (2) Units listed are one example of what can be used. The 
%                 user can decide to use another set of units
%Inputs     : params       - a struct containing simulation parameters.
%             P            - P is the pressure in the system [=] bar                          
%             V            - V is volume in the system [=] cc
%             T            - T is the temperature in the system [=] K
%             n            - n is the number of moles in the system [=] 
%                            moles
%Outputs    : P            - P is the pressure in the system [=] bar                          
%             V            - V is volume in the system [=] cc
%             T            - T is the temperature in the system [=] K
%             n            - n is the number of moles in the system [=] 
%                            moles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,V,T,n] = calcEosIdealGas(params,P,V,T,n)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    funcId = 'calcEOSIdealGas.m';
    
    %Unpack params
    gasCons = params.gasCons;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Solve the ideal gas law
    
    %Solve for an unknown variable
    if (n==0)&&(gasCons~=0)&&(T~=0)
        %Solve for n
        n = (P*V)/(gasCons*T);
    elseif (P==0)&&(V~=0)
        %Solve for P
        P = (n*gasCons*T)/V  ;
    elseif (V==0)&&(P~=0)
        %Solve for V
        V = (n*gasCons*T)/P  ;
    elseif (T==0) && (n~=0) && (gasCons~=0)
        %Solve for T
        T = (P*V)/(n*gasCons);
    else
        %In case of user specifying wrong inputs, print warning
        disp(['ERROR in ',funcId,'. Too many inputs are equal to zero.']); 
        return;
    end
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%