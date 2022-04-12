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
%Code created on       : 2019/3/6/Wednesday
%Code last modified on : 2021/2/1/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcSumKeyEfficiency.m
%Source     : common
%Description: calculates a key efficiency given a state vector and struct
%             containing relevent parameters.
%Inputs     : states       - a state solution row vector/matrix
%             params       - a struct containing parameters for the
%                            simulation.
%             comNum       - the component number of a given species
%             colNum       - the column number where we are going to
%                            compute the HKEF values.
%Outputs    : xkef         - the x key eficiency from all CSTRs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xkef = calcSumKeyEfficiency(states,params,comNum,colNum)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcSumKeyEfficiency';    
    
    %Unpack Params
    nVols        = params.nVols       ;
    nColStT      = params.nColStT     ;
    nStates      = params.nStates     ;
    aConScaleFac = params.aConScaleFac;    
    adsConC      = params.adsConC     ;
    nComs        = params.nComs       ;    
    
    %If state is a vector, 
    if isvector(states)
        
        %Transform the state to a row vector
        states = states(:).';
        
    end
    
    %Unpack states and obtain adsorbed phase concentrations (dimensionless)
    %for species i
    adsConSp = states(:,nColStT*(colNum-1)+nComs+comNum: ...
                nStates:nColStT*(colNum-1)+nStates*(nVols-1)+nComs+comNum);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the heavy key efficiency factors for all CSTRs
    
    %Compute individual xKEFs for all CSTRs in a chosen adsorption column
    xkefCstr = adsConSp*aConScaleFac/adsConC(comNum);
    
    %Compute the overall xKEF for the chosen adsorption column
    xkef = sum(xkefCstr,2)/nVols;    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%