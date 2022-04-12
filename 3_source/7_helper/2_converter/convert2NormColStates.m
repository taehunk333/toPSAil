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
%Code created on       : 2019/2/3/Sunday
%Code last modified on : 2021/2/19/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2NormColStates.m
%Source     : common
%Description: converts given states associated with an adsorption column 
%             from a dimensionaless form into a dimensionless from.
%Inputs     : params       - a struct containing simulation parameters.
%             dimStates    - a dimenaional state solution matrix with the 
%                            following dimensions:
%                            number of rows = the number of time points,
%                            number of cols = nStatesT
%                                           = (2*nComs+nTemp)*nVols+2*nComs
%                            where the units are as the following: 
%                            C_{n,i} [=] mol/cc
%                            q_{n,i} [=] mol/kg
%                            T_{n}   [=] K
%                            T_{n,w} [=] K
%             colNum       - (an optional input) this input represents an
%                            optional input denoting the adsorption column
%                            number that we would like the states for.
%Outputs    : states       - a non-dimenaional state solution matrix with 
%                            the following dimensions:
%                            number of rows = the number of time points,
%                            number of cols = nStatesT
%                                           =
%                                           (2*nComs+nTemp)*nVols+2*nComs%
%                            (e.g.) a single CSTR contains the following
%                            states:
%                            states_n = [C_{n,1}, ..., C_{n,n_c}, ...
%                                        q_{n,1}, ..., q_{n,n_c}, ...
%                                        T_{n}, T_{n,w}];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function states = convert2NormColStates(params,dimStates,varargin)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2NormColStates.m';
          
    %Unpack Params
    gConScaleFac = params.gConScaleFac;
    aConScaleFac = params.aConScaleFac;
    nComs        = params.nComs       ;
    nVols        = params.nVols       ;
    nStates      = params.nStates     ;  
    nColStT      = params.nColStT     ;     
    teScaleFac   = params.teScaleFac  ;
    nTemp        = params.nTemp       ;  
    nR           = params.nRows       ; %makes sure this is specified
    %---------------------------------------------------------------------%            
    
    
    
    %---------------------------------------------------------------------%
    %Grab ith column states only when needed
    
    %If the columnumber is provided by the user, then, grab the associated
    %column state variables
    if ~isempty(varargin) && varargin{1} ~= 0
        
        %Get the column number from the first varargin input
        colNum = varargin{1};
        
        %Grab states associated with a given column 
        dimStates = convert2ColStates(params,dimStates,colNum);
    
    %This is a special call of the function for a single CSTR
    else
        
        %Reset the number of volumes
        nVols = 1;
        
        %Reset the number of states
        nColStT = nStates;
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
        
    %Create a dimensionless state solution matrix
    states = zeros(nR,nColStT);    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Convert from dimensional to dimensionless state solutions                    
    
    %Non-dimensionalize concentrations
    for i = 1 : nComs
        
        %Convert gas phase concentrations
        states(:,i:nStates:nStates*(nVols-1)+i) ...
            = (1/gConScaleFac) ...
            * dimStates(:,i:nStates:nStates*(nVols-1)+i);
                            
        %Convert adsorbed phase concentrations
        states(:,nComs+i:nStates:nStates*(nVols-1)+nComs+i) ...
            = (1/aConScaleFac) ...
            * dimStates(:,nComs+i:nStates:nStates*(nVols-1)+nComs+i);
                
    end
    
    %Non-dimensionalize temperatures
    for i = 1 : nTemp
        
        %Convert temperatures
        states(:,2*nComs+i:nStates:nStates*(nVols-1)+2*nComs+i) ...
            = (1/teScaleFac) ...
            * dimStates(:,2*nComs+i:nStates:nStates*(nVols-1)+2*nComs+i);
            
    end
    
    %Only when needed,
    if nC == params.nColStT
        
        %Unpack params
        nScaleFac = params.nScaleFac; 
        
        %Non-dimensionalize cumulative moles    
        states(:,nColStT-2*nComs+1:nColStT) ...
            = (1/nScaleFac) ...
            * dimStates(:,nColStT-2*nComs+1:nColStT);
                    
    end
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%