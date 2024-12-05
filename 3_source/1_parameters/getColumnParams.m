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
%Function   : getColumnParams.m
%Source     : common
%Description: given an initial set of parameters, calculate parameters that
%             are associated with an adsorption column
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getColumnParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getColumnParams.m';
    
    %Unpack params
    radInCol  = params.radInCol ;
    radOutCol = params.radOutCol;
    heightCol = params.heightCol;
    nVols     = params.nVols    ;
    overVoid  = params.overVoid ;    
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Specification of adsorption column dimensions
    
    %Calculate the interior and exterior cross-sectional area of the 
    %adsorption column [=] cm^2
    params.crsAreaInCol   = pi()*radInCol^2 ;    
    params.crsAreaOutCol  = pi()*radOutCol^2;
    params.crsAreaWallCol = params.crsAreaOutCol ...
                          - params.crsAreaInCol;
    
    %Calculate the aspect ratio: defined by a column height divided by a 
    %cross sectional area [=] -
    params.aspRatioCol = heightCol ...
                       / sqrt(4*params.crsAreaInCol/pi());  
            
    %Calculate the volume of a single adsorption column [=] cm^3
    params.colVol = params.crsAreaInCol ...
                  * heightCol;
    
    %Calculate the volume of a single finite volume (CSTR) [=] cm^3
    params.cstrVol = params.colVol/nVols;    
    
    %Calculate a height of the single CSTR
    params.oneCstrHt = params.cstrVol ...
                     / params.crsAreaInCol;
    
    %Define a void volume of a single finite volume (CSTR) [=] cm^3
    params.cstrVoidVol = overVoid*params.cstrVol;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%                                                          
    %Define column parameters related to PSA cycle
    
    %Define the maximum number of columns for an equalization 
    params.maxEqColNum = 2;        
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%