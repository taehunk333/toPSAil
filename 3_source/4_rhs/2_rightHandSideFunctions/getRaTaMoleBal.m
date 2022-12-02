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
%Code created on       : 2021/1/28/Thursday
%Code last modified on : 2022/12/1/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getRaTaMoleBal.m
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

function units = getRaTaMoleBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaMoleBal.m';
    
    %Unpack params
    nComs            = params.nComs           ; 
    nVols            = params.nVols           ;
    nCols            = params.nCols           ;
    raTaVolNorm      = params.raTaVolNorm     ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;
    valAdsPrEnd2RaWa = params.valAdsPrEnd2RaWa;
    valPrEndEq       = params.valPrEndEq      ;
    
    %Unapck units
    col  = units.col ;
    raTa = units.raTa;
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
        
        %Initialize the molar flow rates from the product valves from the
        %adsorbers (i.e., valve 1's) leading to the raffinate product tank.
        convInFromAds = 0;
        
        %Initialize the molar flow rates from the raffiante product tank to 
        %the adsorption columns due to purge/pressurization at the feed-end
        %(i.e., valve 2's) or purge/pressurization at the product-end 
        %(i.e., valve 5's).   
        convOutToAds = 0;         
        %-----------------------------------------------------------------%  



        %-----------------------------------------------------------------%    
        %Account for all molar flows in between the raffinate product tank
        %and the adsorption columns

        %For each columns,
        for k = 1 : nCols

            %-------------------------------------------------------------%    
            %Account for the molar flow rate in between the raffinate
            %product tank and the kth adsorber
            
            %Calculate the "max" of the product-end molar flow rate of the
            %kth column and 0. We neglect any streams diverted to the waste
            %stream.
            convInFromAdsK = max(0,valAdsPrEnd2RaWa(k,nS) ...
                          .* valPrEndEq(k,nS) ...
                          .* col.(sColNums{k}).volFlRat(:,nVols+1) ...
                          .* col.(sColNums{k}).gasCons. ...
                             (sComNums{j})(:,end));
            
            %Calculate the "min" of the molar flow rates from the raffinate
            %product tank to either the feed-end or product-end of the kth
            %adsorber and 0. The flow is in the negative direction and
            %the volumetric flow rates coming out from the raffinate tank
            %should have negative sign.
            convOutToAdsK = min(0,raTa.n1.volFlRat(:,k) ...
                         .* raTa.n1.gasCons.(sComNums{j}));
                                    
            %Update the cumulative convective flow into the raffinate tank
            convInFromAds = convInFromAds ...
                          + convInFromAdsK;                   

            %Update the cumulative convective flow out from the raffinate 
            %tank
            convOutToAds = convOutToAds ...                            
                         + convOutToAdsK;                                    
            %-------------------------------------------------------------%    

        end
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%    
        %Account for the outlet molar flows from the raffinate product tank
        %to the product reservoir
        
        %Convective flow out to the product reservoir
        convOutRfRes = max(0,raTa.n1.volFlRat(:,end)) ...
                    .* raTa.n1.gasCons.(sComNums{j});
        %-----------------------------------------------------------------%    



        %-----------------------------------------------------------------%    
        %Perform the species mole balance
        
        %Evaluate the jth species mole balance
        moleBalSpec = (1/raTaVolNorm) ...
                   .* (convInFromAds ... %positive flow
                      +convOutToAds ...  %negative flow
                      -convOutRfRes);    %positive flow
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%    
        %Save the results (acconting for all columns)
        
        %Do the mole balance on the ith tank for species j
        raTa.n1.moleBal.(sComNums{j}) = moleBalSpec;
        
        %Do the total mole balance
        moleBalTot = moleBalTot ...
                   + moleBalSpec;
        %-----------------------------------------------------------------%                

    end  
    
    %Save the overall mole balance for the raffinate tank
    raTa.n1.moleBalTot = moleBalTot;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.raTa = raTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%