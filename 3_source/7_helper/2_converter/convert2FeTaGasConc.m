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
%Function   : convert2FeTaGasConc.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) 
%             associated with a single feed tank and returns the 
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
%             feTaNum      - (an optional input) this input represents an
%                            optional input denoting the feed tank
%                            number that we would like the states for.
%Outputs    : feTaGasCons  - a struct containing nComs fields where each of
%                            them represents dimensionless gas phase 
%                            concentrations of a feed tank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function feTaGasCons = convert2FeTaGasConc(params,states,varargin)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2FeTaGasConc.m';
    
    %Unpack params    
    nComs    = params.nComs   ;
    sComNums = params.sComNums;     
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Grab the feed tank state
    
    %Get the feed tank number from the first varargin input
    feTaNum = varargin{1};

    %Grab states associated with a given feed tank 
    feTaStates = convert2FeTaStates(params,states,feTaNum);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and save as dimensionless CSTR temperatures
    
    %Unpack states into a struct called feTaGasCons that holds fields with
    %different dimensionless CSTR gas phase concentrations
    for i = 1 : nComs        
        
        %For each field in the struct, assign the dimensionless gas phase
        %concentrations for a given feed tank and for all time points
        feTaGasCons.(sComNums{i}) = feTaStates(:,i);
        
    end        
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%