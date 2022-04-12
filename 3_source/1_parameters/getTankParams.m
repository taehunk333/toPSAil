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
%Function   : getTankParams.m
%Source     : common
%Description: given an initial set of parameters, calculate parameters that
%             are associated with an adsorption column
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getTankParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getTankParams.m';
    
    %Unpack params
    radInTan  = params.radInTan ;
    radOutTan = params.radOutTan;
    heightTa  = params.heightTa ;
    colVol    = params.colVol   ;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Specification of tank dimensions (both feed and product tanks treated
    %as identical dimension and material of constructions)
    
    %Calculate the interior and exterior cross-sectional area of the 
    %feed or profuct tank [=] cm^2
    params.crsAreaInTan   = pi()*radInTan^2 ;    
    params.crsAreaOutTan  = pi()*radOutTan^2;
    params.crsAreaWallTan = params.crsAreaOutTan ...
                          - params.crsAreaInTan;
    
    %Calculate the aspect ratio: defined by a column height divided by a 
    %cross sectional area [=] -
    params.aspRatioTan = heightTa ...
                       / sqrt(4*params.crsAreaInTan/pi());  
            
    %Calculate the volume of a single adsorption column [=] cm^3
    params.taVol = params.crsAreaInTan*heightTa;   
    
    %Calcualte the height of a single tank
    params.taVolNorm = params.taVol/colVol;
    %---------------------------------------------------------------------%                                               
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%