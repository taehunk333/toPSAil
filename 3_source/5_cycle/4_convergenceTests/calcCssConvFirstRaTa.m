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
%Code created on       : 2021/3/25/Thursday
%Code last modified on : 2022/9/13/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcCssConvFirstRaTa.m
%Source     : common
%Description: given a solution struct to the simulation up to the nCy
%             cycle, computes the L2-norm of the difference between the
%             initial condition vector (of all columns) of the 1st step of
%             the nCy th cycle to the initial condition vector (of all 
%             columns) of the 1st step of the nCy-1 th cycle.
%Inputs     : params       - a struct containing simulation parameters
%             initCondCurr - a current initial condition row vector
%             initCondPrev - a previous initial condition row vector
%Outputs    : css          - a cyclic steady state convergence indicating
%                            numerical value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function css = calcCssConvFirstRaTa(params,initCondCurr,initCondPrev)   
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcCssConvFirstRaTa.m';  
    
    %Unpack params
    inShRaTa = params.inShRaTa;
    nRaTaStT = params.nRaTaStT;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Compute the css convergence value and save it inside the struct
    
    %Calculate the beginning and end indices
    indInit = inShRaTa+1         ;
    indLast = inShRaTa+1+nRaTaStT;
    
    %Compute the difference between the cycle initial conditions
    diffInitCond = initCondCurr(indInit:indLast) ...
                 - initCondPrev(indInit:indLast);
    
    %Compute the l2-norm of the difference and save it inside the struct
    css = sum(diffInitCond.^2,2);     
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%