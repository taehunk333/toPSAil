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
%Code created on       : 2022/10/23/Sunday
%Code last modified on : 2022/10/23/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : grabSteps.m
%Source     : common
%Description: given the two structures containing the solutions from the
%             numerical integrations of the ODEs, we now combin the two
%             data structures to get a single data structure.
%Inputs     : sol0         - the data structure from the pre-integration
%             sol          - the data structure from the original
%                            integration
%Outputs    : sol          - the combined data structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sol = grabCombSol(sol0,sol)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'grabCombSol.m';
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Combine the time steps
    
    %Obtain the shifted time steps from the original numerical integration
    newTime = sol.x+sol0.x(end);
    
    %Combine the time steps
    sol.x = [sol0.x,newTime(2:end)];
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %Combine the state solutions
    
    %Obtain the solutions from the original numerical intagration
    newSol = sol.y;
    
    %Combine the state solutions
    sol.y = [sol0.y,newSol(:,2:end)];  
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Combine idata fields
    
    %Combine kvec
    sol.idata.kvec = [sol0.idata.kvec,sol.idata.kvec(2:end)];  
            
    %Get the dimensions
    dim0 = size(sol0.idata.dif3d,3);
    dim  = size(sol.idata.dif3d,3) ;
    
    %Match the dimensions of the fields
    if dim > dim0
        
        sol0.idata.dif3d(:,:,dim0+1:dim) = 0;
        dim0 = dim;
        
    elseif dim < dim0
        
        sol.idata.dif3d(:,:,dim+1:dim0) = 0;       
        
    end
    
    %Combine dif3d
    sol.idata.dif3d = [sol0.idata.dif3d,sol.idata.dif3d];
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%