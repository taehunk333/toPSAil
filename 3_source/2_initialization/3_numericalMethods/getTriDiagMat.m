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
%Function   : getTriDiagMat.m
%Source     : common
%Description: generate a tridiagonal constant matrix A upon taking a vector
%             of dimensionless volumns, i.e. l_n = [l_0,...,l_N] and number 
%             of CSTRS as input. Then, the function computes an inverse for
%             the created matrix A, Ainv and returns Ainv. 
%Inputs     : nVols        - a scalar number of CSTRs in the simulation
%             cstrHt       - a vector containing dimentionless volumes: 
%                            i.e. l_n = [l_1,...,l_N].
%Outputs    : tiVaPrMat    - a tridiagonal matrix A with the following 
%                            dimension: (N-1)x(N-1).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tiVaPrMat = getTriDiagMat(nVols,cstrHt)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getTriDiagMat';
    
    %Determine matrix dimension (squared matrix)
    n = (nVols-1);
    %---------------------------------------------------------------------%

    
    
    %---------------------------------------------------------------------%
    %Check function inputs
    
    %Measure the dimension of the vector and reject the vector if the size
    %is not correct as per the function description
    [nR,nC] = size(cstrHt);
    
    %Print warning if the size of the input vector is wrong
    if nR~= 1 || nC~=nVols
        warning('The size of the input vector is not consistent');
        return
    end   
    %---------------------------------------------------------------------%        
            
    
        
    %---------------------------------------------------------------------%
    %Populate the coefficient matrix with entries
    
    %Based on the derivation, creator diagonal entries as row vectors
    mainDiag = (1./cstrHt(1:n)) ...
            +  (1./cstrHt(2:nVols)); %(1)x(n-1)
    abovDiag = (-1) ...
            .* (1./cstrHt(2:n))    ; %(1)x(n-2)
    beloDiag = (-1) ...
            .* (1./cstrHt(1:n-1))  ; %(1)x(n-2)
    
    %Create a tri-diagonal matrix for coefficients for time varying
    %pressure DAE model
    tiVaPrMat = diag(mainDiag)+diag(abovDiag,1)+diag(beloDiag,-1);    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%