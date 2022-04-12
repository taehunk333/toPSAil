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
%Code last modified on : 2022/2/3/Thursday
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
    %Remove unused fields for initialization of the simulation environment
    %in the params
    params = rmfield(params,'maTrRes')  ;
    params = rmfield(params,'inConFeTa'); 
    params = rmfield(params,'inConRaTa');
    params = rmfield(params,'inConExTa');
    params = rmfield(params,'inConBed') ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove unused fields in params for describing the geometry of the 
    %apparatus in the flow sheet
    params = rmfield(params,'crsAreaInCol')  ;
    params = rmfield(params,'crsAreaOutCol') ;
    params = rmfield(params,'crsAreaWallCol');
    params = rmfield(params,'aspRatioCol')   ;
    params = rmfield(params,'crsAreaInTan')  ;
    params = rmfield(params,'crsAreaOutTan') ;
    params = rmfield(params,'crsAreaWallTan');
    params = rmfield(params,'aspRatioTan')   ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove isotherm and bulk gas related fields in the field
    params = rmfield(params,'gasConT');
    params = rmfield(params,'nRows')  ;
    params = rmfield(params,'adsConT');
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove mass transfer zone calculations related unused fields in params
    params = rmfield(params,'mtz');
    %---------------------------------------------------------------------%

    
    
    %---------------------------------------------------------------------%
    %Remove dimensional valve Constants
    params = rmfield(params,'valCon');
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove dimensional LDF mass transfer coefficients
    params = rmfield(params,'ldfMtc');
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove isothermal simulation parameters for non-isothermal simulations
    
    %If we are doing a non-isothermal simulation
    if bool(5) == 1
    
        %Remove isothermal parameter
        params = rmfield(params,'loTrMat')  ;
        params = rmfield(params,'upTrMat')  ;
        params = rmfield(params,'coPrFeMat');
        params = rmfield(params,'coPrPrMat');
        params = rmfield(params,'coefMat')  ;
        
    end      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Remove unused fields for
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');
%     params = rmfield(params,'');    
    %---------------------------------------------------------------------%                                                                                                                  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%