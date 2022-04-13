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
%Code last modified on : 2021/3/25/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcCssConvAllCols.m
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

function css = calcCssConvAllCols(params,initCondCurr,initCondPrev)   
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcCssConvAllCols.m';  
    
    %Unpack params
    inShFeTa = params.inShFeTa;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Compute the css convergence value and save it inside the struct
    
    %Compute the difference between the cycle initial conditions
    diffInitCond = initCondCurr(1:inShFeTa)-initCondPrev(1:inShFeTa);
    
    %Compute the l2-norm of the difference and save it inside the struct
    css = sum(diffInitCond.^2,2);    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%