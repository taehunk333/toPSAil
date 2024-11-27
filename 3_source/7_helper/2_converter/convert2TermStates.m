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
%Code created on       : 2021/1/7/Thursday
%Code last modified on : 2022/2/2/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2TermStates.m
%Source     : common
%Description: takes a matrix for the set of all state variables in the
%             system and returns the terminal state row vector
%Inputs     : params       - a struct containing simulatino parameters
%             states       - a non-dimenaional state solution row vector.
%Outputs    : termStates   - a non-dimenaional state solution row vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function termStates = convert2TermStates(params,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2TermStates.m';
    
    %Unpack params
    nCols    = params.nCols   ;
    nComs    = params.nComs   ;
    nColStT  = params.nColStT ;
    nFeTaStT = params.nFeTaStT;
    nRaTaStT = params.nRaTaStT;
    nExTaStT = params.nExTaStT;
    inShFeTa = params.inShFeTa;
    inShRaTa = params.inShRaTa;
    inShExTa = params.inShExTa;
    inShComp = params.inShComp;
    inShVac  = params.inShVac ;
    nFeTas   = params.nFeTas  ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate function output
    
    %Grab the terminal states
    termStates = states(end,:);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Knockout cumulative molar flow rates for all columns and tanks
    
    %For each column,
    for i = 1 : nCols
        
        %Knockout the cumulative volumetric flow rates
        termStates(:,nColStT*i-2*nComs+1:nColStT*i) = zeros(1,2*nComs);
        
    end
    
    %For the feed tank
    for i = 1 : nFeTas    
        
    %Get the beginning index
        n0 = inShFeTa+i*nFeTaStT-nComs+1;

    %Get the final index
        nf = inShFeTa+i*nFeTaStT;

    %Knockout the cumulative volumetric flow rates
    termStates(:,n0:nf) = zeros(1,nComs);

    end
    
    %For the raffinate product tank
    
    %Get the beginning index
    n0 = inShRaTa+nRaTaStT-2*nComs+1;

    %Get the final index
    nf = inShRaTa+nRaTaStT;

    %Knockout the cumulative volumetric flow rates
    termStates(:,n0:nf) = zeros(1,2*nComs);
    
    %For the extract product tank
    
    %Get the beginning index
    n0 = inShExTa+nExTaStT-2*nComs+1;

    %Get the final index
    nf = inShExTa+nExTaStT;

    %Knockout the cumulative volumetric flow rates
    termStates(:,n0:nf) = zeros(1,2*nComs);
    
    %For the compressors
    
    %Knockout the cumulative energy for the feed compressor
    termStates(:,inShComp+1) = 0;

    %Knockout the cumulative energy for ith compressor
    termStates(:,inShComp+2) = 0;

    %For the vacuum pump

    %Knockout the cumulative energy for ith vacuum pump
    termStates(:,inShVac+1) = 0; 
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%