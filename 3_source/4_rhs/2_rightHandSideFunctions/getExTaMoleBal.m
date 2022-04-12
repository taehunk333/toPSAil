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
%Code last modified on : 2022/3/14/Monday
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
    nComs         = params.nComs        ;
    nCols         = params.nCols        ;
    colIntActExtr = params.colIntActExtr;
    tankScaleFac  = params.tankScaleFac ;
    sColNums      = params.sColNums     ;
    sComNums      = params.sComNums     ;
    valExTa       = params.valExTa      ;
    valRinTop     = params.valRinTop    ;
    valRinBot     = params.valRinBot    ;
    
    %Unpack units
    col  = units.col ;
    exTa = units.exTa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Initialize solution arrays
    
    %Initialize the convective flow in and out of the extract stream valve 
    %(i.e., %valve 6)
    convInVal6  = 0; 
    convOutVal2 = 0;
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
            %Calculate molar flow rates around the extract product tank
            %(The balance is done over product tank + valve 1)

            %If the interaction b/t kth column and the extract product tank
            %is through valve 6, and the flow (inside the adsorber) is 
            %counter-current, i.e., exiting the adsorber and heading 
            %towards either the exteact waste stream of the extract product 
            %tank, we have the following:
            if colIntActExtr(k,nS) == 6 

                %Convective flow in through valve 6; the negative sign is
                %needed because the flow direction switches from
                %counter-current (exiting the column) to co-current
                %(entering the extract feed tank)
                convInVal6 = convInVal6 ...
                           + valExTa(nS) ...
                           * (-1)*col.(sColNums{k}).volFlRat(:,1) ...
                          .* col.(sColNums{k}).gasCons.(sComNums{j})(:,1);                   

            %If the interaction b/t kth column and the extract product tank
            %is through valve 2, and the flow (inside the adsorber) is 
            %co-current, i.e., exiting the extract product tank and
            %entering the adsorber at the bottom-end of the column, we have
            %the following:
            elseif colIntActExtr(k,nS) == 2
                
                %Get the total concentration of the extract product tank
                gasConTotFeEnd = exTa.n1.gasConsTot;

                %Get the upstream species concentration
                gasConSpec = exTa.n1.gasCons.(sComNums{j});
                
                %Get the current total concentration of the Nth CSTR in the
                %ith adsorption column
                gasConTotCstr = col.(sColNums{k}).gasConsTot(:,1);               
                                
                %Convective flow in through valve 2
                convOutVal2 = convOutVal2 ...
                            + valRinBot(nS) ...
                            * col.(sColNums{k}).volFlRat(:,1) ...
                           .* (gasConSpec/gasConTotFeEnd) ...
                            * gasConTotCstr;                             
            
            %If the interaction b/t kth column and the extract product tank
            %is through valve 5, and the flow (inside the adsorber) is 
            %counter-current, i.e., exiting the extract product tank and 
            %entering the adsorber at the top-end of the column, we have 
            %the following:
            elseif colIntActExtr(k,nS) == 5         
                     
                %Get the total concentration of the extract product 
                %tank
                gasConTotPrEnd = exTa.n1.gasConsTot;

                %Get the upstream species concentration
                gasConSpec = exTa.n1.gasCons.(sComNums{j});
                
                %Get the current total concentration of the Nth CSTR in the
                %ith adsorption column
                gasConTotCstr = col.(sColNums{k}).gasConsTot(:,end);
                                
                %Convective flow in through valve 5
                convOutVal5 = convOutVal5 ...
                            + valRinTop(nS) ...
                            * col.(sColNums{k}).volFlRat(:,end) ...
                           .* (gasConSpec/gasConTotPrEnd) ...
                            * gasConTotCstr;
                       
            %If there is no interaction with kth column and the ith
            %product tank, for nS step,                            
            else

                %No need to update anything

            end
            %-------------------------------------------------------------%    

        end

        %Convective flow out to the product reservoir
        convOutExRes = exTa.n1.volFlRat(:,end) ...
                    .* exTa.n1.gasCons.(sComNums{j});
        %-----------------------------------------------------------------%    



        %-----------------------------------------------------------------%    
        %Save the species j result (accounting for all columns)

        %Do the mole balance on the ith tank for species j
        exTa.n1.moleBal.(sComNums{j}) = tankScaleFac ...
                                     .* (convInVal6 ...  %counter-current
                                        -convOutVal2 ... %co-current
                                        +convOutVal5 ... %counter-current
                                        -convOutExRes);  %co-current

        %Initialize the molar flow rates for the next iteration
        convInVal6  = 0; 
        convOutVal2 = 0;
        convOutVal5 = 0;
        %-----------------------------------------------------------------%                

    end
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