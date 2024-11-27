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
%Code created on       : 2020/1/21/Tuesday
%Code last modified on : 2020/12/17/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcAdsRatMtz.m
%Source     : common
%Description: takes in the computed thickness of the mass transfer zone
%             (MTZ) and computes the approximated adsorption rate for all
%             species in the MTZ.
%Inputs     : params       - a struct containing parameters for the
%                            simulation.
%             mtzThick     - a scalar value ranging from 0 to 1 that 
%                            specifies the length of the mass transfer zone
%                            (MTZ) normalized by the adsorption column 
%                            height.
%             mcerfWt      - a scalar weighting factor for the modified 
%                            complementary error function.
%             mtzBounds    - a row vector containing bounds on the MTZ in
%                            the domain of $z \in \left[-0.5,0.5\right]$.
%Outputs    : adsRatMtz    - a vector containing rate of adsorption of 
%                            each keys within the mass transfer zone (MTZ). 
%                            Naturally, the dimension of the vector is 
%                            [nComs x 1] as a column vector.      
%                            ***The unit for the rate of adsorption of 
%                               species i is as the following:
%                               [mol ith adsorbate/(kg adsorbent-sec)].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function adsRatMtz = calcAdsRatMtz(params,mtzThick,mcerfWt,mtzBounds)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcAdsRatMtz.m';
    
    %Unpack Params 
    yRaC         = params.yRaC        ;
    yFeC         = params.yFeC        ;
    nComs        = params.nComs       ;
    nVols        = params.nVols       ;
    funcRat      = params.funcRat     ;
    funcIso      = params.funcIso     ;
    tempCol      = params.tempCol     ;
    tempAmbi     = params.tempAmbi    ;
    massAds      = params.massAds     ;
    nStates      = params.nStates     ;
    nColStT      = params.nColStT     ;
    tiScaleFac   = params.tiScaleFac  ;
    aConScaleFac = params.aConScaleFac;
    
    %Define dimensionless temperatures
    tempColRat = tempCol ...
               / tempAmbi;
    tempAmbRat = tempAmbi ...
               / tempAmbi;
    
    %Calculate the mass of adsorbents inside the mass transfer zone
    massAdsMtz = massAds ...
               * mtzThick;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Determine a gas phase concentration profile for all species within the
    %mass transfer zone
    
    %Create nVols number of points between the lower and upper bounds
    axPts = linspace(mtzBounds(1),mtzBounds(2),nVols);
    
    %Evaluate the modified error function at the chosen axial points (i.e.
    %axPts)        
    mcerfVal = defineMcerf(mcerfWt,axPts,0);
    
    %Based on the modified complementary error function, define the gas
    %phase concentration profiles for all species as a convex combination
    %between two concentration vectors; one at the feed composition, and
    %the other one at the product composition
    gasConMtz = mcerfVal ...
             .* yFeC ...
             + (1-mcerfVal) ...
             .* yRaC;   
    
    %Define a uniform product gas composition as a hypothetical gas
    %composition to computed the saturation condition with the product gas
    %within the mass transfer zone
    gasConMtzEq = ones(1,nVols) ...
               .* yRaC;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define dimensionaless states for the rate evaluation
    
    %Initialize the state solution vector
    states    = zeros(1,nColStT);        
    hypStates = zeros(1,nColStT);        
    
    %Initialize the solution vector for dimensionless temperatures
    tempVals = repmat([zeros(1,2*nComs), ...
                      tempColRat,tempAmbRat], ...
                      1,nVols);
    
    %Add cumulative moles flow states
    tempVals = [tempVals,zeros(1,2*(nComs))];
    
    %Update states with the current gas phase compositions (dimensionless)   
    for i = 1 : nComs
        
        %Update states for gas phase compositions
        states(1,i:nStates:nStates*(nVols-1)+i) = gasConMtz(i,:);
        
        %Update hypothetical states for the assumed gas phase compositions
        hypStates(1,i:nStates:nStates*(nVols-1)+i) = gasConMtzEq(i,:);
        
    end        
    
    %Update states and hypoStates with the tempVals
    states    = states+tempVals   ; 
    hypStates = hypStates+tempVals; 
    
    %Define the number of time points
    params.nRows = 1;
    
    %Calculate saturation concentration of light key product within the
    %mass transfer zone
    newHypStates = funcIso(params,hypStates,1);
    
    %Update states with the current adsorbed phase compositions 
    %(dimensionless). i.e. saturation with the light key
    for i = 1 : nComs
        
        %Update states for adsorbed phase compositions
        states(1,nComs+i:nStates:nStates*(nVols-1)+nComs+i) = ...
                 newHypStates(1,nComs+i:nStates:nStates*(nVols-1)+nComs+i);
             
    end                            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the rate of adsorption for all species in the mass transfer
    %zone
    
    %Define the number of time points
    params.nRows = 1;
    
    %Compute the adsorption rates per mass based on the given states in the
    %unit of [moles/kg-sec]; we evaluate the rate at the first adsorber.
    adsRatMtzCstrs = aConScaleFac ...
                   / tiScaleFac ...
                  .* funcRat(params,states,1);
    
    %Define the axial points to integrate over    
    axPtsNorm = linspace(0,mtzThick,nVols);
    
    %Initialize solution vector
    adsRatMtz = zeros(nComs,1);
    
    %Iterate and update the solutions
    for i = 1 : nComs
        adsRatMtz(i) = ...
                trapz(axPtsNorm,adsRatMtzCstrs(1,((i-1)*nVols)+1:i*nVols));
    end                
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
        
    %Calculate actual rate of adsorption of all species inside the MTZ in
    %the unit of [moles/sec]
    adsRatMtz = massAdsMtz ...
              * adsRatMtz;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%