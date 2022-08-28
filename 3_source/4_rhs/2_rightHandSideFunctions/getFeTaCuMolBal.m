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
%Code created on       : 2021/2/16/Tuesday
%Code last modified on : 2022/8/27/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getFeTaCuMolBal.m
%Source     : common
%Description: a function that calculates cumulative moles flown into the  
%             feed tank up to time t at the boundaries for all feed tanks
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getFeTaCuMolBal(params,units)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getFeTaCuMolBal.m';
    
    %Unpack params    
    nComs         = params.nComs        ;      
    pRatFe        = params.pRatFe       ;
    yFeC          = params.yFeC         ;
    sComs         = params.sComNums     ;
    gasConsNormEq = params.gasConsNormEq;
    tempFeedNorm  = params.tempFeedNorm ;
    
    %Unpack units
    feTa = units.feTa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Do the cumulative mole balance for each species for all species inside 
    %each feed tank

    %Calculate the total concentration of the feed
    gasConsTotFeed = pRatFe/(gasConsNormEq*tempFeedNorm);
                 
    %For each component
    for j = 1 : nComs

        %Assign the right hand side for the cumulative moles flowing into 
        %the feed tank
        feTa.n1.cumMolBal.feed.(sComs{j}) ...
            = gasConsTotFeed ...
            * yFeC(j) ...
            * feTa.n1.volFlRat(:,end);

    end  
    %---------------------------------------------------------------------%       
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.feTa = feTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%