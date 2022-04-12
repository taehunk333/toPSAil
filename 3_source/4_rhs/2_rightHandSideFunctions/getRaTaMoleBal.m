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
%Code last modified on : 2022/3/14/Monday
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
    nComs         = params.nComs        ;
    nCols         = params.nCols        ;
    colIntActRaff = params.colIntActRaff;
    tankScaleFac  = params.tankScaleFac ;
    sColNums      = params.sColNums     ;
    sComNums      = params.sComNums     ;
    valRaTa       = params.valRaTa      ;
    valPurBot     = params.valPurBot    ;
    
    %Unapck units
    col  = units.col ;
    raTa = units.raTa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Initialize solution arrays
    
    %Initialize the molar flow rate after the product valve (i.e., valve 1) 
    convInVal1 = 0;
    
    %Initialize the molar flow rate after the feed/purge/rinse valve 
    %(i.e., valve 2)
    convOutVal2 = 0; 
    
    %Initialize the molar flow rate after the purge/pressurization valve 
    %(i.e., valve 5)
    convOutVal5 = 0; 
    %---------------------------------------------------------------------%    
    
    
      
    %---------------------------------------------------------------------%    
    %Do the mole balance for each species for all species inside each 
    %product tank
        
    %For each species,
    for j = 1 : nComs

        %-----------------------------------------------------------------%    
        %Account for all flows into/out of product tank from all columns                        

        %For each columns,
        for k = 1 : nCols

            %-------------------------------------------------------------%    
            %Calculate molar flow rates around the raffinate product tank
            %(The balance is done over product tank + valve 1)

            %If the interaction b/t kth column and the ith product tank
            %is through valve 1 
            if colIntActRaff(k,nS) == 1
                
                %Convective flow in through valve 1
                convInVal1 = convInVal1 ...
                           + valRaTa(nS) ...
                           * col.(sColNums{k}).volFlRat(:,end) ...
                          .* col.(sColNums{k}).gasCons. ...
                             (sComNums{j})(:,end);                   

            %If the interaction b/t kth column and the ith product tank
            %is through valve 2
            elseif colIntActRaff(k,nS) == 2

                %Convective flow out through valve 2
                convOutVal2 = convOutVal2 ...
                            + valPurBot(nS) ...
                            * raTa.n1.volFlRat(:,k) ...
                           .* raTa.n1.gasCons.(sComNums{j});
                         
            %If the interaction b/t kth column and the ith product tank
            %is through valve 5 
            elseif colIntActRaff(k,nS) == 5

                %Convective flow out through valve 5 (must have a negative
                %value because the flow is a counter-current flow)
                convOutVal5 = convOutVal5 ...
                            + raTa.n1.volFlRat(:,k) ...
                           .* raTa.n1.gasCons.(sComNums{j});  

            %If there is no interaction with kth column and the ith
            %product tank, for nS step,                            
            else

                %No need to update anything

            end
            %-------------------------------------------------------------%    

        end

        %Convective flow out to the product reservoir
        convOutRfRes = raTa.n1.volFlRat(:,end) ...
                    .* raTa.n1.gasCons.(sComNums{j});
        %-----------------------------------------------------------------%    



        %-----------------------------------------------------------------%    
        %Save the species j result (acconting for all columns)
        
        %Do the mole balance on the ith tank for species j
        raTa.n1.moleBal.(sComNums{j}) = tankScaleFac ...
                                     .* (convInVal1 ...
                                      + convOutVal2 ...
                                      + convOutVal5 ...
                                      - convOutRfRes);    

        %Initialize the molar flow rates for the next iteration
        convInVal1  = 0;
        convOutVal2 = 0; 
        convOutVal5 = 0;                 
        %-----------------------------------------------------------------%                

    end  

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