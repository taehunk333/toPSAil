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
%Code created on       : 2021/1/5/Tuesday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getNumParams.m
%Source     : common
%Description: a function that calculates a constant volumetric flow rate at
%             the feed end of an adsorption column at a high pressure.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getNumParams(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getNumParams.m';
    
    %Unpack params
    nVols      = params.nVols     ;
    cstrHt     = params.cstrHt    ;
    daeModel   = params.daeModel  ;    
    nCols      = params.nCols     ;
    nSteps     = params.nSteps    ;
    valConT    = params.valConT   ;
    valFeedCol = params.valFeedCol;
    valProdCol = params.valProdCol;
    maxNoBC    = params.maxNoBC   ;
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%        
    %Initialize solution arrays
    
    %Initialze a solution array for holding the coefficient matrices
    coefMat = cell(nCols,nSteps);
    %---------------------------------------------------------------------%        
    
    
    
    %---------------------------------------------------------------------%        
    %Pre-compute coefficient matrix for solving Ax=b for dimensionless
    %volumetric flowrate for the time "varying pressure" DAE model.
     
    %Populate A and return Ainv and A
    triDiagPlus = getTriDiagMat(nVols,cstrHt);

    %Perform LU Decomposition and save the LU factors as fields inside a
    %struct
    [loTriPlusVaPr,upTriPlusVaPr] = lu(triDiagPlus);
    
    %Save as sparse matrices
    loTriPlusVaPr = sparse(loTriPlusVaPr)             ;
    upTriPlusVaPr = sparse(upTriPlusVaPr)             ;
    dTriDiag      = sparse([triDiagPlus,-triDiagPlus]);
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%        
    %Pre-compute coefficient matrices for solving Ax=b for dimensionless
    %volumetric flowrate for the "constant pressure" DAE model.
    
        %-----------------------------------------------------------------%
        %Consider the case when the volumetric flow rate at the feed end is
        %given

        %Create a vector for the diagonal at -1 position
        beloDiag = -ones(1,nVols-1);

        %Create a coefficient matrix for a specified value of v_0
        loTriPlusCoPr = eye(nVols) ...
                      + diag(beloDiag,-1);

        %Save as a sparse matrix
        loTriPlusCoPr = sparse(loTriPlusCoPr);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Consider the case when the volumetric flow rate at the product end
        %is given
        
        %Create a vector for the diagonal at +1 position
        abovDiag = ones(1,params.nVols-1);

        %Create a coefficient matrix for a specified value of v_N
        upTriPlusCoPr = diag(abovDiag,+1) ...
                      - eye(params.nVols);

        %Save as a sparse matrix
        upTriPlusCoPr = sparse(upTriPlusCoPr);
        %-----------------------------------------------------------------%
        
    %---------------------------------------------------------------------%              
    
    
    
    %---------------------------------------------------------------------%              
    %Assign coefficient matrices for calculating volumetric flow rates for
    %each column in all steps for all columns
    
    %For each step in a given PSA cycle,
    for i = 1 : nSteps
        
        %And for each column in a given step,
        for j = 1 : nCols
            
            %-------------------------------------------------------------%
            %Determine logical statements
            
            %See if the product-end of the column has a Cv            
            prodHasCv = valProdCol(j,i) ~= 1 && ...
                        valProdCol(j,i) ~= 0;  
            
            %See if the feed-end of the column has a Cv
            feedHasCv = valFeedCol(j,i) ~= 1 && ...
                        valFeedCol(j,i) ~= 0;                        
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Check the needed information and assign the right coefficient
            %matrices
            
            %If we have a time varying pressure DAE model,
            if daeModel(j,i) == 1
                
                %We assign the lower and upper triangular matrices
                coefMat{j,i} = {loTriPlusVaPr,upTriPlusVaPr};  
            
            %If we have a constant pressure DAE model with a CV in the
            %product-end,
            elseif daeModel(j,i) == 0 && prodHasCv
                
                %We assign the coefficient matrix for the product-end
                coefMat{j,i} = {upTriPlusCoPr,-upTriPlusCoPr};
            
            %If we have a constant pressure DAE model with a CV in the
            %feed-end,    
            elseif daeModel(j,i) == 0 && feedHasCv    
                
                %We assign the coefficient matrix for the feed-end
                coefMat{j,i} = {loTriPlusCoPr,-loTriPlusCoPr};
                
            end            
            %-------------------------------------------------------------%
            
        end
                
    end           
    %---------------------------------------------------------------------%              
    
    
    
    %---------------------------------------------------------------------%              
    %Store the result inside a struct
    
    %Pack into params
    params.coefMat  = coefMat ;   
    params.dTriDiag = dTriDiag;
    %---------------------------------------------------------------------%              
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%