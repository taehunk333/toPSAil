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
%Code created on       : 2022/1/28/Friday
%Code last modified on : 2022/12/1/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getExTaMoleBal.m
%Source     : common
%Description: a function that evaluates the mole balance right hand side
%             relationship for the current time point for all product 
%             tanks.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getExTaMoleBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getExTaMoleBal.m';
    
    %Unpack params
    nComs            = params.nComs           ;
    nCols            = params.nCols           ;    
    exTaVolNorm      = params.exTaVolNorm     ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;
    valAdsFeEnd2ExWa = params.valAdsFeEnd2ExWa;
    valFeEndEq       = params.valFeEndEq      ;
    
    %Unpack units
    col  = units.col ;
    exTa = units.exTa;
    %---------------------------------------------------------------------%
        
    
    
    %---------------------------------------------------------------------%    
    %Do the mole balance for each species for all species inside each 
    %product tank
    
    %Initialize the total mole balance term
    moleBalTot = 0;
        
    %For each species,
    for j = 1 : nComs

        %-----------------------------------------------------------------%    
        %Initialize solution arrays
        
        %Initialize the molar flow rates from the depressurization valves 
        %from the adsorbers (i.e., valve 6's) leading to the extract 
        %product tank.
        convInFromAds = 0; 
        
        %Initialize the molar flow rates from the extract product tank to 
        %the adsorption columns due to rinse/pressurization at the feed-end
        %(i.e., valve 2's) or rinse/pressurization at the product-end 
        %(i.e., valve 5's).
        convOutToAds  = 0;
        %-----------------------------------------------------------------%  



        %-----------------------------------------------------------------%    
        %Account for all flows into/out of product tank from all columns                        

        %For each columns,
        for k = 1 : nCols

            %-------------------------------------------------------------%    
            %Account for the molar flow rate in between the extract
            %product tank and the kth adsorber

            %Calculate the "min" of the feed end molar flow rate of the
            %kth column and 0. We neglect any streams diverted to the waste
            %stream.
            convInFromAdsK = min(0,valAdsFeEnd2ExWa(k,nS) ...
                          .* valFeEndEq(k,nS) ...
                          .* col.(sColNums{k}).volFlRat(:,1) ...
                          .* col.(sColNums{k}).gasCons. ...
                             (sComNums{j})(:,1));
            
            %Calculate the "max" of the molar flow rates from the extract
            %product tank to either the feed-end or product-end of the kth
            %adsorber and 0. The flow is in the positive direction and
            %the volumetric flow rates coming out from the extract tank
            %should have positive sign.
            convOutToAdsK = max(0,exTa.n1.volFlRat(:,k) ...
                         .* exTa.n1.gasCons.(sComNums{j}));
            
            %Update the cumulative convective flow into the extract tank
            convInFromAds = convInFromAds ...
                          + convInFromAdsK;                   

            %Update the cumulative convective flow out from the extract 
            %tank
            convOutToAds = convOutToAds ...                            
                         + convOutToAdsK;
            %-------------------------------------------------------------%    

        end
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%    
        %Account for the outlet molar flows from the extract product tank
        %to the product reservoir
        
        %Convective flow out to the product reservoir
        convOutExRes = exTa.n1.volFlRat(:,end) ...
                    .* exTa.n1.gasCons.(sComNums{j});
        %-----------------------------------------------------------------%    

    
        
        %-----------------------------------------------------------------%    
        %Perform the species mole balance
        
        %Evaluate the jth species mole balance
        moleBalSpec = (1/exTaVolNorm) ...
                   .* (-convInFromAds ... %-negative flow 
                      -convOutToAds ...  %-positive flow                         
                      -convOutExRes);    %-positive flow 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%    
        %Save the results (accounting for all columns)

        %Do the mole balance on the ith tank for species j
        exTa.n1.moleBal.(sComNums{j}) = moleBalSpec;    
        
        %Do the total mole balance
        moleBalTot = moleBalTot ...
                   + moleBalSpec;
        %-----------------------------------------------------------------%                

    end
    
    %Save the overall mole balance for the extract tank
    exTa.n1.moleBalTot = moleBalTot;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.exTa = exTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%