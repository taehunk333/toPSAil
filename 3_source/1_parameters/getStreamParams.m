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
%Code created on       : 2021/1/15/Friday
%Code last modified on : 2022/2/14/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getStreamParams.m
%Source     : common
%Description: given an initial set of parameters, define parameters related 
%             to stream properties.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getStreamParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getStreamParams.m';
    
    %Unpack params
    nCols = params.nCols;
    bool  = params.bool ;
    %---------------------------------------------------------------------% 
    
                                    
    
    %---------------------------------------------------------------------%       
    %Define system properties
            
    %Define number of valves per adsorption column
    params.nAdsVals = 6;
    
    %Define the maximum number of boundary conditions per column: one for
    %the top-end of the column and the other one for the bottom-end of the
    %column
    params.maxNoBC = 2;
    
    %Define the total number of linear valves associated with all the
    %columns in the flow sheet
    params.nAdsValsT = params.nAdsVals*nCols;    
    
    %Check if we have a consistent number of columns specified when
    %considering the uni-bed vs. poly-bed process
    if bool(1) == 0 && nCols > 1
        
        %Print error message
        msg = 'Please indicate that it is a polybed process.';
        msg = append(funcId,': ',msg);
        error(msg);   
        
    elseif bool(1) == 1 && nCols == 1
        
        %Print error message
        msg = 'Please indicate that it is a unibed process.';
        msg = append(funcId,': ',msg);
        error(msg);   
        
    end        
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%