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
%Code last modified on : 2022/8/10/Wednesday
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
    nCols        = params.nCols       ;
    nSteps       = params.nSteps      ;
    maxNoBC      = params.maxNoBC     ;
    typeDaeModel = params.typeDaeModel;
    bool         = params.bool        ;
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
        
    %Get a cell array to store function handles for the boundary volumetric
    %flow rates
    volFlBo = cell(maxNoBC,nCols,nSteps);
    
    %Get a numerical array to store the location of the specified boundary
    %conditions for constant pressure with no axial pressure drop case
    volFlBoFree = zeros(nCols,nSteps);    
    %---------------------------------------------------------------------%                    
           
    
    
    %---------------------------------------------------------------------%
    %For all steps and all columns, assign the function handles for the
    %boundary volumetric flow rate
    
    %For each step, 
    for i = 1 : nSteps
        
        %-----------------------------------------------------------------%
        %For each column in ith step,
        for j = 1 : nCols
            
            %-------------------------------------------------------------%
            %For each boundary condition associated with jth column,
           
                %---------------------------------------------------------%
                %Obtain the boundary conditions
                
                %Assign the function handle for the product-end (1) and the
                %feed-end (2)
                [volFlBo{1,j,i},volFlBo{2,j,i},flags] ...
                    = getVolFlowFuncHandle(params,i,j);
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Save the information about the boundary conditions
                
                %Check to see if we should save the location of the 
                %boundary condition where it was specifeid; we save when we
                %have a constant pressure DAE model with no axial pressure 
                %drop
                checkDaeModel = typeDaeModel(j,i);    
                
                %Check if we have momentum balance or not
                checkMomBal = bool(3);
                
                %Unpack the flags
                whichEnd = flags.whichEnd;
                
                if checkDaeModel == 0 && ... %Constant pressure DAE
                   checkMomBal == 0 && ...   %No axial pressure drop
                   whichEnd ~= 0             %Update only when needed
  
                    %Indicate whether the boundary condition for the 
                    %constant pressure no axial pressure drop DAE model, 
                    %which requires only one boundary condition, has its
                    %boundary condition specified for the feed end
                    volFlBoFree(j,i) = whichEnd;

                end
                %---------------------------------------------------------%
                       
            %-------------------------------------------------------------%
            
        end    
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Return the computed values to the struct
    
    %Pack into params
    params.volFlBo     = volFlBo    ;   
    params.volFlBoFree = volFlBoFree;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%