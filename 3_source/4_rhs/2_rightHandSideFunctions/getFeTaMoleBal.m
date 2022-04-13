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
%Code last modified on : 2022/4/11/Tuesday
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
    colIntActFeed = params.colIntActFeed;
    yFeC          = params.yFeC         ;
    tankScaleFac  = params.tankScaleFac ;
    pRatFe        = params.pRatFe       ;   
    sComNums      = params.sComNums     ;
    
    %Unpack units
    feTa = units.feTa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Initialize solution arrays
    
    %Initialize the convective flow after the feed valve (i.e., valve 2) 
    convOutVal2 = 0;        
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%    
    %Do the mole balance for each species for all species inside each 
    %feed tank
      
    %For each species,
    for j = 1 : nComs

        %-----------------------------------------------------------------%    
        %Account for all flows into/out of feed tank from all columns                        

        %For each columns,
        for k = 1 : nCols

            %-------------------------------------------------------------%    
            %Calculate molar flow rates around the feed tank                                

            %If the interaction b/t kth column and the feed tank
            %is through valve 2
            if colIntActFeed(k,nS) == 2

                %Convective flow out through valve 2 (into kth adsorption 
                %column). Note that the pressure is reduced after the valve 
                %to P_high. However, the mole fraction of the gas remains
                %the same
                convOutVal2 = convOutVal2 ...
                            + feTa.n1.volFlRat(:,k) ...
                           .* feTa.n1.gasCons.(sComNums{j});

            %If there is no interaction with kth column and the ith
            %feed tank, for nS step,                            
            else

                %No need to update anything

            end
            %-------------------------------------------------------------%    

        end

        %Convective flow into the ith feed tank from the feed reservoir
        convfromFeRes = feTa.n1.volFlRat(:,end) ...
                      * pRatFe*yFeC(j);
        %-----------------------------------------------------------------%    



        %-----------------------------------------------------------------%    
        %Save the species j result (acconting for all columns)

        %Do the mole balance on the ith tank for species j
        feTa.n1.moleBal.(sComNums{j}) ...
            = tankScaleFac ...
           .* (convfromFeRes-convOutVal2);    

        %Initialize the molar flow rates for the next iteration
        convOutVal2 = 0;                     
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