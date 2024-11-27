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
%Code created on       : 2020/12/12/Saturday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2ColAdsConc.m
%Source     : common
%Description: takes in a state solution (either matrix or vector) 
%             associated with a single adsorption column and 
%             returns the corresponding adsorbed phase concentration for 
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
%             colNum       - (an optional input) this input represents an
%                            optional input denoting the adsorption column
%                            number that we would like the states for.
%Outputs    : colAdsCons   - a struct containing nComs fields where each of
%                            them represents dimensionless adsorbed phase 
%                            concentrations for all time points for all 
%                            CSTRs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function colAdsCons = convert2ColAdsConc(params,states,varargin)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2ColAdsConc.m';
    
    %Unpack params
    nComs    = params.nComs   ;
    nVols    = params.nVols   ;
    nStates  = params.nStates ;
    sComNums = params.sComNums;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Grab ith column states only when needed
    
    %If the column number is provided by the user, then, grab the 
    %associated column state variables
    if ~isempty(varargin) && varargin{1} ~= 0
        
        %Get the column number from the first varargin input
        colNum = varargin{1};
        
        %Grab states associated with a given column 
        colStates = convert2ColStates(params,states,colNum);
      
    %This is a special call to this function where we are only taking a
    %single CSTR states as inputs
    else
     
        %The state becomes the column states
        colStates = states;
        
        %Locally reset the number of volumes
        nVols = 1;
    
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and save as dimensionless adsorbed phase concentrations              
    
    %Unpack states into a struct called colAdsCons that holds fields with
    %different dimensionless adsorbed phase concentrations
    for i = 1 : nComs   
        
        %For each field in the struct, assign the dimensionless gas phase
        %concentrations for all CSTRs and for all time points
        colAdsCons.(sComNums{i}) ...
            = colStates(:,nComs+i:nStates:nStates*(nVols-1)+nComs+i);  
                   
    end        
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%