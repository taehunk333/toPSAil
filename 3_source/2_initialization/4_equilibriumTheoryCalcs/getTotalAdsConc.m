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
%Code created on       : 2021/1/3/Sunday
%Code last modified on : 2022/10/27/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getTotalAdsConc.m
%Source     : common
%Description: a function that calculates total adsorbed phase concentation
%             at a feed composition at a high pressure inside an adsorption 
%             column.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : gasConT      - a total gas phase concentration at a high
%                            pressure feed composition and pressure
%             params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getTotalAdsConc(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getTotalAdsConc.m';
    
    %Unpack params
    tempCol  = params.tempCol ;
    tempAmbi = params.tempAmbi;
    yFeC     = params.yFeC    ;
    nComs    = params.nComs   ;
    funcIso  = params.funcIso ;    
    gasConT  = params.gasConT ;
    %---------------------------------------------------------------------%    
    
    
                         
    %---------------------------------------------------------------------%                           
    %Compute dimensional total gas phase concentration and total adsorbed 
    %phase concentration
            
    %Define a term to scale dimensional gas phase concentrations to 
    %non-dimensional concentrations (for now)
    params.gConScaleFac = gasConT; 
    
    %Define a term to scale dimensional adsorbed phase concentration to
    %non-dimensional concentrations (for now). Use the value of 1 to just
    %get the dimensional solution out.
    params.aConScaleFac = 1;
    
    %Define a term to scale dimensional temperatures to non-dimensional
    %temperatures (for now)
    params.teScaleFac = tempAmbi;
    
    %Define dimensionless temperatures
    colTempNorm = tempCol/params.teScaleFac;
    ambTempNorm = tempAmbi/params.teScaleFac;
    
    %Define an initial state based on the saturation with the feed for a
    %single CSTR.
    cstrStates = [yFeC',zeros(1,nComs),colTempNorm,ambTempNorm];          
    
    %Define the number of time points
    params.nRows = 1;

    %Compute the adsorbed phase composition for all species as per the
    %chose isotherm function; Note that adsorbed phase concentrations will
    %be dimensional values because aConScaleFac = 1.
    newStates = funcIso(params,cstrStates,0);
    
    %newStates has dimensional adsorbed phase concentrations. Just multiply
    %dimensionless gas concentrations by gConScaleFac and dimensionaless 
    %temperatures by teScaleFac to get the dimensional states for a single
    %CSTR
    newStates(1,1:nComs)       = params.gConScaleFac ...
                               * newStates(1,1:nComs);
    newStates(1,2*nComs+1:end) = params.teScaleFac ...
                               * newStates(1,2*nComs+1:end);
                          
    %Get adsorbed phase concentrations in equilibrium with the feed gas
    %composition
    params.adsConC = newStates(1,nComs+1:2*nComs);
    
    %Get adsorbed phase total heavy key concentration in equilibrium with
    %feed gas composition
    params.adsConHkT = sum(newStates(1,nComs+2:2*nComs),2);
    
    %Remove gConScaleFac, aConScaleFac, and teScaleFac for now. We want to 
    %define the scaling factors later all together
    params = rmfield(params,'gConScaleFac');  
    params = rmfield(params,'aConScaleFac'); 
    params = rmfield(params,'teScaleFac')  ; 
              
    %compute the total adsorbed phase concentration in equilibrium with the
    %high pressure feed
    params.adsConT = sum(newStates(1,nComs+1:2*nComs));        
    %---------------------------------------------------------------------%              
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%