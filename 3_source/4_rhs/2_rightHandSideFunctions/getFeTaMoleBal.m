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
%Code created on       : 2022/4/10/Monday
%Code last modified on : 2022/8/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getFeTaMoleBal.m
%Source     : common
%Description: a function that evaluates the mole balance right hand side
%             relationship for the current time point for all feed tanks.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = getFeTaMoleBal(params,units)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getFeTaMoleBal.m';
    
    %Unpack params    
    nComs        = params.nComs       ;
    nCols        = params.nCols       ;
    yFeC         = params.yFeC        ;
    feTaScaleFac = params.feTaScaleFac;
    pRatFe       = params.pRatFe      ;   
    sComNums     = params.sComNums    ;
    tempColNorm  = params.tempColNorm ;
    tempFeedNorm = params.tempFeedNorm;
    
    %Unpack units
    feTa = units.feTa;
    %---------------------------------------------------------------------%
   
   

    %---------------------------------------------------------------------%    
    %Do the mole balance for each species for all species inside each 
    %feed tank
      
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
                         + feTa.n1.volFlRat(:,k) ...
                        .* feTa.n1.gasCons.(sComNums{j});                                    
            %-------------------------------------------------------------%    

        end

        %Convective flow into the ith feed tank from the feed reservoir. We
        %have c_{feed}/c_{high} = P_{feed}/P_{high} * T_{high}/T_{Feed}.
        convfromFeRes = feTa.n1.volFlRat(:,end) ...
                      * pRatFe*tempColNorm/tempFeedNorm*yFeC(j);
        %-----------------------------------------------------------------%    



        %-----------------------------------------------------------------%    
        %Save the species j result (acconting for all columns)

        %Do the mole balance on the ith tank for species j
        feTa.n1.moleBal.(sComNums{j}) ...
            = feTaScaleFac ...
           .* (convfromFeRes-convOutToAds);                      
        %-----------------------------------------------------------------%                

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