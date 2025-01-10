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
%Function   : getFeTaMoleBal.m
%Source     : common
%Description: a function that evaluates the mole balance right hand side
%             relationship for the current time point for all feed tanks.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getFeTaMoleBal(params,units,nS)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getFeTaMoleBal.m';
    
    %Unpack params    
    nComs         = params.nComs        ;
    nCols         = params.nCols        ;
    yFeC          = params.yFeC         ;
    feTaVolNorm   = params.feTaVolNorm  ;
    pRatFe        = params.pRatFe       ;   
    sComNums      = params.sComNums     ;    
    gasConsNormEq = params.gasConsNormEq;
    tempFeedNorm  = params.tempFeedNorm ;
    valFeEndEq    = params.valFeEndEq   ;
    nFeTas        = params.nFeTas       ;
    sFeTaNums     = params.sFeTaNums    ;
    bool          = params.bool         ;
    if length(bool) > 12 && bool(13) == 1
        yFeC = [params.yFeC,params.yFeTwoC];
    end
    
    %Unpack units
    feTa = units.feTa;
    %---------------------------------------------------------------------%
   
   

    %---------------------------------------------------------------------%    
    %Do the mole balance for each species for all species inside each 
    %feed tank
    for i = 1 : nFeTas
    
        %Initialize the total mole balance term
        moleBalTot = 0;
          
        %For each species,
        for j = 1 : nComs
            
            %-----------------------------------------------------------------%    
            %Initialize solution arrays
            
            %Initialize the convective flow after the feed valve (i.e., valve 
            %2) 
            convOutToAds = 0;        
            %-----------------------------------------------------------------%   
    
    
            
            %-----------------------------------------------------------------%    
            %Account for all flows into/out of feed tank from all columns                        
    
            %For each columns,
            for k = 1 : nCols
    
                %-------------------------------------------------------------%    
                %Calculate the molar flow rates from the feed tank, heading to
                %the adsorbers.
    
                %Molar flow coming out from the feed tank, heading to the kth
                %adsorber.
                convOutToAds = convOutToAds ...
                            .* valFeEndEq(k,nS) ...
                                 + feTa.(sFeTaNums{i}).volFlRat(:,k) ...
                                .* feTa.(sFeTaNums{i}).gasCons.(sComNums{j});                                    
                %-------------------------------------------------------------%    
    
            end
    
            %Convective flow into the ith feed tank from the feed reservoir. We
            %have c_{feed}/c_{high} = P_{feed}/P_{high} * T_{high}/T_{Feed}.
                convfromFeRes = feTa.(sFeTaNums{i}).volFlRat(:,end) ...
                          * pRatFe/(gasConsNormEq*tempFeedNorm) ...
                              * yFeC(j,i);
            %-----------------------------------------------------------------%    
    
    
    
            %-----------------------------------------------------------------%    
            %Perform the species mole balance
            
            %Evaluate the jth species mole balance
            moleBalSpec = (1/feTaVolNorm) ...
                       .* (convfromFeRes-convOutToAds);  
            %-----------------------------------------------------------------%
            
            
            
            %-----------------------------------------------------------------%    
            %Save the j results (acconting for all columns)
    
            %Do the mole balance on the ith tank for species j
                feTa.(sFeTaNums{i}).moleBal.(sComNums{j}) = moleBalSpec;    
            
            %Do the total mole balance
            moleBalTot = moleBalTot ...
                       + moleBalSpec;
            %-----------------------------------------------------------------%                
    
        end
        
        %Save the overall mole balance for the raffinate tank
        feTa.(sFeTaNums{i}).moleBalTot = moleBalTot;
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