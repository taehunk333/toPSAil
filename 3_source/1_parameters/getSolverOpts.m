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
%Code created on       : 2022/4/13/Wednesday
%Code last modified on : 2022/10/27/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getSolverOpts.m
%Source     : common
%Description: This function defines solver options
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getSolverOpts(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getSolverOpts.m';    
    nVols = params.nVols;
    nComs = params.nComs;
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%        
    %Define parameters related to linprog.m
    
    %Set the options for linprog.m
    %1. 'interior-point' (faster in this case)
    %2. 'dual-simplex' 
    params.linprog.opts = optimoptions('linprog','Display','none'); 
    
    %Set the objective function coefficient vector
    params.linprog.objs = ones(1,2*(nVols-1));
    
    %Set the lower and upper bounds
    params.linprog.lbs = zeros(1,2*(nVols-1))   ;
    params.linprog.ubs = Inf*ones(1,2*(nVols-1));
    %---------------------------------------------------------------------%              

    
    
    %---------------------------------------------------------------------%              
    %Define parameters related to fsolve.m
                
    %Specify the Jacobian matrix
    
    %Create a block matrix 
    A = ones(nComs,nComs);
    
    %Convert to the cell array of nVols copies of the block matrix
    Ac = repmat({A}, 1, nVols);  
    
    %Convert to the block diagonal matrix by using blkdiag.m, providing the
    %cell array containing the replicated block matrices as inputs
    Jstr = blkdiag(Ac{:});

    %Set options for fsolve.m
    params.fsolve.opts ...
        = optimoptions('fsolve', ...
                       'Algorithm','trust-region', ...
                       'Display','iter', ...
                       'FunValCheck','on', ... %complex # show error
                       'JacobPattern',Jstr);   %Turn off the display
    %---------------------------------------------------------------------%              
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%