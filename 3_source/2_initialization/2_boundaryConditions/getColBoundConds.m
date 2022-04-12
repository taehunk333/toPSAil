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
%Code created on       : 2021/1/25/Monday
%Code last modified on : 2022/2/7/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getColBoundConds.m
%Source     : common
%Description: a function that defines parameters associated with the
%             boundary conditions for the columns, the product tank, and
%             the feed tank.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getColBoundConds(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getColBoundConds.m';
    
    %Unpack Params
    nCols   = params.nCols  ;
    nSteps  = params.nSteps ;
    maxNoBC = params.maxNoBC;
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
        
    %Get a cell array to store function handles for the boundary volumetric
    %flow rates
    volFlBo = cell(maxNoBC,nCols,nSteps);
    %---------------------------------------------------------------------%                    
           
    
    
    %---------------------------------------------------------------------%
    %For all steps and all columns, assign the function handles for the
    %boundary volumetric flow rate
    
    %For each step, 
    for i = 1 : nSteps
        
        %For each column in ith step,
        for j = 1 : nCols
            
            %For each boundary condition associated with jth column,
            for k = 1 : maxNoBC
            
                %Assign the function handle
                volFlBo{k,j,i}  = getVolFlowFuncHandle(params,i,j,k);

            end
            
        end    
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Return the computed values to the struct
    
    %Pack into params
    params.volFlBo = volFlBo;        
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%