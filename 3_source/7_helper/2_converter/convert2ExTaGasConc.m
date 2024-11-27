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
%Code created on       : 2022/1/25/Tuesday
%Code last modified on : 2022/1/25/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2ExTaGasConc.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) 
%             associated with a single product tank and returns the 
%             corresponding gas phase concentration values as the
%             following:
%             Components   - $i \in \left\{ 1, ..., params.nComs \right\}$
%             CSTRs        - $n \in \left\{ 1, ..., params.nVols \right\}$
%             time points  - $t \in \left\{ 1, ..., nTimePts \right\}$ 
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution of the
%                            following dimension:
%                            number of rows = nTimePts
%                            number of columns = nColStT
%             exTaNum      - (an optional input) this input represents an
%                            optional input denoting the product tank
%                            number that we would like the states for.
%Outputs    : exTaGasCons  - a struct containing nComs fields where each of
%                            them represents dimensionless gas phase 
%                            concentrations of a product tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function exTaGasCons = convert2ExTaGasConc(params,states,varargin)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2ExTaGasConc.m';
    
    %Unpack params    
    nComs    = params.nComs   ;
    sComNums = params.sComNums;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Grab the raffinate tank state
           
    %Get the product tank number from the first varargin input
    exTaNum = varargin{1};

    %Grab states associated with a given product tank 
    exTaStates = convert2ExTaStates(params,states,exTaNum);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and save as dimensionless CSTR temperatures
    
    %Unpack states into a struct called prTaGasCons that holds fields with
    %different dimensionless CSTR gas phase concentrations
    for i = 1 : nComs        
        
        %For each field in the struct, assign the dimensionless gas phase
        %concentrations for a given product tank and for all time points
        exTaGasCons.(sComNums{i}) = exTaStates(:,i);
        
    end        
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%