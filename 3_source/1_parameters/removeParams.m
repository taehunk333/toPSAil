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
%Code created on       : 2022/2/3/Thursday
%Code last modified on : 2022/10/20/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : removeParams.m
%Source     : common
%Description: given a struct, remove any fields that we do not need.
%             Reducing the number of field a struct expedites the search
%             process substantially and is beneficial for improving the
%             performance of the overall simulation code.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = removeParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'removeParams.m';
    bool = params.bool;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove any unnecessary fields for the numerical integration
        
    %Remove any integer parameters
    params = rmfield(params,'nRows');
    
    %Remove any scale factors
    params = rmfield(params,'volScaleFac');
    params = rmfield(params,'valScaleFac');
    
    %Remove initial conditions
    params = rmfield(params,'maTrRes')  ;
    params = rmfield(params,'inConFeTa'); 
    params = rmfield(params,'inConRaTa');
    params = rmfield(params,'inConExTa');
    params = rmfield(params,'inConBed') ;

    %Remove dimensional temperatures
    params = rmfield(params,'tempAmbi');
    params = rmfield(params,'tempStan');
    params = rmfield(params,'tempFeed');
    params = rmfield(params,'tempCol');
    params = rmfield(params,'tempFeTa');
    params = rmfield(params,'tempRaTa');
    params = rmfield(params,'tempExTa');
    
    %Remove dimensional pressures
    params = rmfield(params,'presStan'); 
    params = rmfield(params,'presColLow');    
    params = rmfield(params,'presFeTa');
    params = rmfield(params,'presRaTa');
    params = rmfield(params,'presExTa');
    params = rmfield(params,'presColHigh');    
    params = rmfield(params,'presAmbi');

    %When there is axial pressure drop
    if bool(3) == 1
        
        params = rmfield(params,'presColHighFull');
        params = rmfield(params,'presColHighSet');
        params = rmfield(params,'presColLowFull');
        params = rmfield(params,'presColLowSet');
        params = rmfield(params,'presExTaFull');
        params = rmfield(params,'presExTaSet');
        params = rmfield(params,'presRaTaFull');
        params = rmfield(params,'presRaTaSet');    

    end
    
    %Remove adsorber packing related information
    params = rmfield(params,'voidFracBed');
    params = rmfield(params,'overVoid');
    
    %Remove adsorbent physical properties
    params = rmfield(params,'pellDens');
    params = rmfield(params,'bulkDens');
    
    %Remove feed gas properties
    params = rmfield(params,'compFacC');   

    %Remove cstr related parameters
    params = rmfield(params,'oneCstrHt');
    
    %Remove adsorption column geometry parameters
    params = rmfield(params,'crsAreaInCol');
    params = rmfield(params,'crsAreaOutCol');
    params = rmfield(params,'crsAreaWallCol');
    params = rmfield(params,'aspRatioCol');
    params = rmfield(params,'radInCol');
    params = rmfield(params,'radOutCol');
    params = rmfield(params,'heightCol');
    params = rmfield(params,'waDensCol');
    params = rmfield(params,'colVol');
    
    %Remove feed tank geometry parameters
    params = rmfield(params,'crsAreaInFeTa');
    params = rmfield(params,'crsAreaOutFeTa');
    params = rmfield(params,'crsAreaWallFeTa');
    params = rmfield(params,'aspRatioFeTa');
    params = rmfield(params,'radInFeTa');
    params = rmfield(params,'radOutFeTa');
    params = rmfield(params,'heightFeTa');
    params = rmfield(params,'waDensFeTa'); 
    params = rmfield(params,'feTaVol');
    
    %Remove raffinate product tank geometry parameters
    params = rmfield(params,'crsAreaInRaTa');
    params = rmfield(params,'crsAreaOutRaTa');
    params = rmfield(params,'crsAreaWallRaTa');
    params = rmfield(params,'aspRatioRaTa');
    params = rmfield(params,'radInRaTa');
    params = rmfield(params,'radOutRaTa');
    params = rmfield(params,'heightRaTa'); 
    params = rmfield(params,'waDensRaTa');
    params = rmfield(params,'raTaVol');
    
    %Remove extract product tank geometry parameters
    params = rmfield(params,'crsAreaInExTa');
    params = rmfield(params,'crsAreaOutExTa');
    params = rmfield(params,'crsAreaWallExTa');
    params = rmfield(params,'aspRatioExTa');
    params = rmfield(params,'radInExTa');
    params = rmfield(params,'radOutExTa');
    params = rmfield(params,'heightExTa');
    params = rmfield(params,'exTaVol');
    
    %Remove equilibrium related parameters
    params = rmfield(params,'gasConT');    
    params = rmfield(params,'adsConT');
    
    %Remove mass transfer related parameters    
    params = rmfield(params,'mtz');
    params = rmfield(params,'ldfMtc');    
    params = rmfield(params,'massAds');
    params = rmfield(params,'waDensExTa');

    %Remove plotting information (don't need this for the numerical
    %integration)
    params = rmfield(params,'plot');
    
    %Remove dimensional valve parameters          
    params = rmfield(params,'valProdCol');
    params = rmfield(params,'valFeedCol');

    %When there is axial pressure drop
    if bool(3) == 1

        params = rmfield(params,'valRaTaFull');
        params = rmfield(params,'valExTaFull');   

    end
    %---------------------------------------------------------------------%   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%