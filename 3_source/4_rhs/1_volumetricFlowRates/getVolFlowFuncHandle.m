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
%Code created on       : 2021/1/26/Tuesday
%Code last modified on : 2022/2/6/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getVolFlowFuncHandle.m
%Source     : common
%Description: a function that grabs a corresponding function handle for the
%             boundary condition for "nS" th step, "numCol" th column, and 
%             "numBo" th boundary condition.
%Inputs     : params       - a struct containing simulation parameters.
%             nSt          - the current number of the step.
%             numCol       - the column number
%             numBo        - the current boundary condition number (1 means
%                            product-end and 2 means feed-end).            
%Outputs    : funcHandle   - a function handle that returns the
%                            corresponding boundary condition for the
%                            situation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function funcHandle = getVolFlowFuncHandle(params,nSt,numCol,numBo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getVolFlowFuncHandle.m';
    
    %Unpack Params
    valConNorm = params.valConNorm;       
    flowDir    = params.flowDir   ; 
    nAdsVals   = params.nAdsVals  ;
    valRaTa    = params.valRaTa   ;
    valExTa    = params.valExTa   ;
    valRinTop  = params.valRinTop ;
    valRinBot  = params.valRinBot ;
    valPurBot  = params.valPurBot ;
    valFeeTop  = params.valFeeTop ;
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Grab information for the current situation in terms of nSt, numCol, 
    %and numBo
    
    %Get the current valve constant values
           
    %Procuct-end raffinate product valve
    val1Con = valConNorm(nAdsVals*(numCol-1)+1,nSt);

    %Product-end equalization valve
    val3Con = valConNorm(nAdsVals*(numCol-1)+3,nSt);

    %Product-end purge/pressurization(w/product)/rinse valve 
    val5Con = valConNorm(nAdsVals*(numCol-1)+5,nSt);

    %Feed-end feed/purge/rinse/pressuroization(w/feed) valve
    val2Con = valConNorm(nAdsVals*(numCol-1)+2,nSt);

    %Feed-end equalization valve
    val4Con = valConNorm(nAdsVals*(numCol-1)+4,nSt);

    %Feed-end extract product/waste valve
    val6Con = valConNorm(nAdsVals*numCol,nSt);        
    
    %The flow direction in the current adsorber
    flowDirCurr = flowDir(numCol,nSt);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Pre-compute some logics

    %The top-end of the column is closed
    topClosed = (val1Con == 0 && ...
                 val3Con == 0 && ...
                 val5Con == 0);

    %The bottom-end of the column is closed
    botClosed = (val2Con == 0 && ...
                 val4Con == 0 && ...
                 val6Con == 0);       
    
    %Valve has a linear valve constant (Cv) value assigned to it
    val1HasCv = (val1Con ~= 1 && ...
                 val1Con ~= 0);
    val2HasCv = (val2Con ~= 1 && ...
                 val2Con ~= 0);
    val3HasCv = (val3Con ~= 1 && ...
                 val3Con ~= 0);
    val4HasCv = (val4Con ~= 1 && ...
                 val4Con ~= 0);
    val5HasCv = (val5Con ~= 1 && ...
                 val5Con ~= 0);
    val6HasCv = (val6Con ~= 1 && ...
                 val6Con ~= 0);
    %---------------------------------------------------------------------%
        
        
    
    %---------------------------------------------------------------------%
    %Based on the conditions, decide the value of function handle for the
    %current situation in terms of nS, numCol, and numBo                

        %-----------------------------------------------------------------%
        %Check for the completely closed valves
        
        %If all the product-end valves are closed, assign the function 
        %handle a value of zero
        if topClosed && numBo == 1

            %Define the function handle to be a constant value of zero
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 0;

        %If all the feed-end valves are closed, assign the function handle 
        %a value of zero    
        elseif botClosed && numBo == 2

            %Define the function handle to be a constant value of zero
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 1               
            
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val1HasCv && ...        %valve 1 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 1 && ...       %product-end boundary condition
               valRaTa(nSt) == 1       %goes to the raffinate product tank
                                    
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValOne2RaTa(params,col,feTa,raTa,exTa,nS,nCo);            
        
        %If the product-end has a Cv leading to the raffinate waste stream
        elseif val1HasCv && ...        %valve 1 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 1 && ...       %product-end boundary condition
               valRaTa(nSt) == 0       %goes to the raffinate waste stream
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValOne2RaWa(params,col,feTa,raTa,exTa,nS,nCo);                                          
        %-----------------------------------------------------------------%     
        
        
           
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 2
        
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %feed tank
        elseif val2HasCv && ...           %valve 2 has a Cv
               flowDirCurr == 0 && ...    %co-current flow
               numBo == 2 && ...          %feed-end boundary condition
               valRinBot(nSt) == 0 && ... %not from the extract tank
               valPurBot(nSt) == 0        %not from the raffinate tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeTa2Two(params,col,feTa,raTa,exTa,nS,nCo); 
           
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %raffinate product tank
        elseif val2HasCv && ...        %valve 2 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 2 && ...       %feed-end boundary condition
               valPurBot(nSt) == 1     %from the raffinate tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaTa2Two(params,col,feTa,raTa,exTa,nS,nCo); 
        
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %raffinate product tank
        elseif val2HasCv && ...        %valve 2 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 2 && ...       %feed-end boundary condition
               valRinBot(nSt) == 1     %from the extract tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValExTa2Two(params,col,feTa,raTa,exTa,nS,nCo);      
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 3
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val3HasCv && ...        %valve 3 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 1              %product-end boundary condition
                         
           %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCu(params,col,feTa,raTa,exTa,nS,nCo);  
        
        %If the product-end is open and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val3Con == 1 && ...     %valve 3 is open
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 1              %product-end boundary condition                           
                        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCu(params,col,feTa,raTa,exTa,nS,nCo);
                    
        %If the product-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val3HasCv && ...        %valve 3 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 1              %product-end boundary condition                    
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCo(params,col,feTa,raTa,exTa,nS,nCo); 
              
        %If the product-end is open and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val3Con == 1 && ...     %valve 3 is open
               flowDirCurr == 0 && ... %co-current flow
               numBo == 1              %product-end boundary condition 
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCo(params,col,feTa,raTa,exTa,nS,nCo);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 4
                
        %If the feed-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val4HasCv && ...        %valve 4 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 2              %feed-end boundary condition
            
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCu(params,col,feTa,raTa,exTa,nS,nCo);

        %If the feed-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val4Con == 1 && ...     %valve 4 is open
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 2              %feed-end boundary condition   
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCu(params,col,feTa,raTa,exTa,nS,nCo);
  
        %If the feed-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val4HasCv && ...        %valve 4 has a Cv
               flowDirCurr == 0 && ... %co-current flow
               numBo == 2              %feed-end boundary condition
            
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCo(params,col,feTa,raTa,exTa,nS,nCo);

        %If the feed-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val4Con == 1 && ...     %valve 4 is open
               flowDirCurr == 0 && ... %co-current flow
               numBo == 2              %feed-end boundary condition   
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCo(params,col,feTa,raTa,exTa,nS,nCo);        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 5        
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the extract product tank
        elseif val5HasCv && ...        %valve 5 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 1 && ...       %product-end boundary condition                        
               valRinTop(nSt) == 1     %rinse from the top end
               
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValExTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo);
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the feed tank
        elseif val5HasCv && ...        %valve 5 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 1 && ...       %product-end boundary condition                                        
               valFeeTop(nSt) == 1      %feed from the top end

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo);      
              
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the raffinate product tank
        elseif val5HasCv && ...        %valve 5 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 1              %product-end boundary condition                                        

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo);                 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 6
        
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val6HasCv && ...        %valve 6 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 2 && ...       %feed-end boundary condition
               valExTa(nSt) == 1       %goes to the extract product tank
                                    
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValSix2ExTa(params,col,feTa,raTa,exTa,nS,nCo);
        
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val6HasCv && ...        %valve 6 has a Cv
               flowDirCurr == 1 && ... %counter-current flow
               numBo == 2 && ...       %feed-end boundary condition
               valExTa(nSt) == 0       %goes to the extract waste stream 
                 
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValSix2ExWa(params,col,feTa,raTa,exTa,nS,nCo);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For all other cases, by default the valves must be completely
        %opened. Therefore, we assign a unity for the boundary condition
        %for the time being. 
        else
            
            %We define an open boundary condition
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 1;
            
            %List of Cases that do not require a boundary condition
            %
            %Case 1: If the product-end has an open valve leading to the
            %        raffinate product tank (i.e., valve 1) and we use a 
            %        constant pressure DAE model to simulate an adsorption 
            %        column. Also, we have a feed-end valve constant 
            %        specified. This is a co-current flow case.
            %Case 2: If the product-end has an open valve leading to the 
            %        raffinate product tank (i.e., valve 1) and we use
            %        discretized momentum balance equations to obtain the
            %        interior volumetric flow rates, while we have an
            %        expression or the control law that calculates the
            %        volumetric flow rate coming out from the product-end
            %        to maintain a constant pressure in the last CSTR. This
            %        is a co-current flow case.
            %Case 3: If there is an open valve between the feed tank and 
            %        the feed-end of the column (i.e., valve 2) and we use
            %        a constant pressure DAE model to simulate an
            %        adsorption column. Also, we have a product-end valve
            %        constant specified.
            %Case 4: If there is an open valve between the feed tank and
            %        the feed-end of the column (i.e., valve 2) and we use
            %        discretized momentum balance equations to obtain the
            %        interoir volumetric flow rates, while we have an
            %        expression or the control law that calculates the
            %        volumetric flow rate coming out from the feed-end to
            %        maintain a constrant pressure in the first CSTR. This
            %        is a counter-current case.
            %Case 5: If the product-end has an open valve leading to the 
            %        top-end of the adsorption column from the raffinate 
            %        product tank (i.e., valve 5), counter-current rinse is
            %        going on at a high pressure, and we use a constant
            %        pressure DAE model to simulate an adsorption column. 
            %        In this case, we have a specified valve constant at 
            %        the feed-end of the adsorption column.
            %Case 6: If the product-end has a linear valve with a specified 
            %        valve constant leading to the top-end of the 
            %        adsorption column from the raffinate product tank 
            %        (i.e., valve 5), counter-current rinse is going on at 
            %        a high pressure, and we use a constant pressure DAE 
            %        model to simulate an adsorption column. In this case, 
            %        we have a specified valve constant at the product-end 
            %        of the adsorption column.
            %Case 7: If the product-end has a linear valve with a specified 
            %        valve constant leading to the top-end of the 
            %        adsorption column from the raffinate product tank 
            %        (i.e., valve 5), counter-current rinse is going on at 
            %        a high pressure, and we use discretized momentum 
            %        balance equations to obtain the interior volumetric 
            %        flow rates and we have an expression or the control
            %        law to maintain the pressure in the 1st CSTR constant.
            %Case 8: If the product-end has a linear valve with a specified
            %        valve constant leading to the top-end of the adsorption
            %        column from the raffinate product tank,
            %        counter-current purge is going on at a low pressure,
            %        and we use a constant pressure DAE model to simulate
            %        the adsorber, we obtain the volumetric flow rate at
            %        the feed end as a result. 
            %Case 9: If the feed-end has a linear valve with a specified
            %        valve constant leading to the bottom-end of the 
            %        adsorption column from the raffinate product tank,
            %        co-current purge is going on at a low pressure,
            %        and we use a constant pressure DAE model to simulate
            %        the adsorber, we obtain the volumetric flow rate at
            %        the product end as a result. 
            %Case 10: If the product-end has a linear valve with a 
            %         specified valve constant leading to the top-end of 
            %         the adsorption column from the raffinate product 
            %         tank, counter-current purge is going on at a low 
            %         pressure, and we use discretized momentum balance
            %         equations to obtain the interior volumetric flow 
            %         rates, and have an expression for controlling the 
            %         volumetric flow rate in the 1st CSTR to maintain a
            %         constant pressure in the CSTR.
            %Case 11: If the feed-end has a linear valve with a specified 
            %         valve constant leading to the top-end of the 
            %         adsorption column from the raffinate product tank, 
            %         co-current purge is going on at a low pressure, and
            %         we use discretized momentum balance equations to 
            %         obtain the interior volumetric flow rates, and have 
            %         an expression for controlling the volumetric flow 
            %         rate in the last CSTR to maintain a constant pressure
            %         in the CSTR.
        
        end 
        %-----------------------------------------------------------------%
        
                            
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%