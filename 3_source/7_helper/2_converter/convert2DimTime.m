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
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2022/8/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2DimTime.m
%Source     : common
%Description: converts a given time vector from dimensionaless form to 
%             dimensional form using scaling factors from the struct called
%             params.
%Inputs     : timePts      - a dimensionaless time vector (either row or
%                            column vector) defined as:
%                            timePts = [s_0,...,s_f];
%             params       - a struct containing simulation parameters
%Outputs    : dimTimePts   - a dimensional time vector (either row or 
%                            column vector). The unit is in seconds.
%                            timePts = [t_0,...,t_f];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dimTimePts = convert2DimTime(timePts,params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'convert2DimTime.m';
    
    %Unpack Params
    tiScaleFac = params.tiScaleFac;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check function inputs
    
    %Check if the input timePts is neither a vector nor a scalar
    if ~isvector(timePts) && ~isscalar(timePts)         
        
        %Print the error message
        msg = 'Please provide a scalar or a vector as an input';
        msg = append(funcId,': ',msg)                          ;
        error(msg)                                             ;
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the function output
    
    %Convert dimensionless time to dimensional time
    dimTimePts = tiScaleFac*timePts;    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%