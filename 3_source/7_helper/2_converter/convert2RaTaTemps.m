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
%Function   : convert2RaTaTemps.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) 
%             associated with a single product tank and returns the 
%             corresponding temperarture value for CSTRs and the walls as
%             the following:
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
%             raTaNum      - (an optional input) this input represents an
%                            optional input denoting the adsorption column
%                            number that we would like the states for.
%Outputs    : raTaTemps    - a struct containing nTemp fields where each of
%                            them represents dimensionless temperature of 
%                            a product tank (e.g. CSTR temperature or wall
%                            temperature)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function raTaTemps = convert2RaTaTemps(params,states,varargin)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2PrTaTemps.m';
    
    %Unpack params
    nTemp = params.nTemp;
    sTemp = params.sTemp;               
    nComs = params.nComs;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Grab the raffinate tank states
      
    %Get the product tank number from the first varargin input
    raTaNum = varargin{1};

    %Grab states associated with a given product tank 
    raTaStates = convert2RaTaStates(params,states,raTaNum);
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%
    %Unpack states and save as dimensionless CSTR temperatures
    
    %Unpack states into a struct called prTaTemps that holds fields with
    %different dimensionless CSTR temperatures
    for i = 1 : nTemp      
        
        %For each field in the struct, assign the dimensionless temperature
        %for a given product tank and for all time points
        raTaTemps.(sTemp{i}) = raTaStates(:,nComs+i);
        
    end        
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%