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
%Code last modified on : 2022/8/8/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getVolFlowFuncHandle.m
%Source     : common
%Description: a function that grabs a corresponding function handle for the
%             boundary condition for "nS" th step, "numCol" th column, and 
%             "numBo" th boundary condition.
%Inputs     : params       - a struct containing simulation parameters.
%             numSte       - the current number of the step.
%             numCol       - the column number           
%Outputs    : prodEnd      - a function handle that returns the product-end
%                            boundary condition
%             feedEnd      - a function handle that returns the feed-end
%                            boundary condition
%             flags        - a vector of flags that indicates information
%                            about the boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [prodEnd,feedEnd,flags] ...
    = getVolFlowFuncHandle(params,numStep,numCol)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getVolFlowFuncHandle.m';
    
    %Unpack Params        
    bool         = params.bool         ;
    typeDaeModel = params.typeDaeModel ;
    sStepCol     = params.sStepCol     ;
 
    %Check to see if the step has a momentum balance
    simMode = bool(3);

    %Check to see if we have a time varying vs. constant pressure step
    typeColStep = typeDaeModel(numCol,numStep);

    %Check the name of the current step at the current adsorption column
    stepNameCurr = sStepCol{numCol,numStep};
    
    %Initialize the information about the location of the constant pressure
    %boundary conditions
    flags.whichEnd = 0;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Based on the given simulation mode, assign proper boundary conditions.
    %Th ename code reads as the following: "Acronym for the step" +
    %"feed-end connection" + "product-end connection"
    
    %When we are working with "flow-controlled" simulation mode
    if simMode == 0

        %When we are dealing with constant pressure DAE model
        if typeColStep == 0      
                        
            %High pressure feed step, from the feed tank to the feed-end of
            %the adsorber, and from the product-end of the adsorber to the
            %atmosphere
            if strcmp(stepNameCurr,'HP-FEE-ATM')
                                  
                %Define the function handles                
                prodEnd = [];
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo); 

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;
                
            %High pressure feed step, from the feed tank to the feed-end of
            %the adsorber, and from the product-end of the adsoreber to the
            %raffinate product tank
            elseif strcmp(stepNameCurr,'HP-FEE-RAF')
                
                %Define the function handles                
                prodEnd = [];
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo); 

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;
                
            %High pressure feed step, from the raffinate tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HP-ATM-FEE')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = [];                 
                
            %Low pressure purge step, from the raffinate tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'LP-ATM-RAF')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowRaTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = []; 
                                
            %Low pressure purge step, from the raffinate tank to the
            %feed-end of the adsorber, and from the product-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'LP-RAF-ATM')
                
                %Define the function handles                
                prodEnd = [];
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowRaTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo); 

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;
                
            %High pressure rinse step, from the extract tank to the
            %feed-end of the adsorber, and from the product-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HR-EXT-ATM')

                %Define the function handles                
                prodEnd = [];
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowExTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;
                                
            %High pressure rinse step, from the extract tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HR-ATM-EXT')

                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowExTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = [];

            %Low pressure feed to extract tank purge
            elseif strcmp(stepNameCurr,'LP-EXT-FEE')
                                  
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo); 

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;

            end

        %When we are dealing with varying pressure DAE model
        elseif typeColStep == 1
            
            %Rest step with both ends closed
            if strcmp(stepNameCurr,'RT-XXX-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                
            %Counter-current depressurization step from the feed-end to the
            %atmosphere
            elseif strcmp(stepNameCurr,'DP-ATM-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);

            %Counter-current depressurization step from the feed-end to the
            %extract tank
            elseif strcmp(stepNameCurr,'DP-EXT-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current depressurization step from the product-end to the
            %atmosphere
            elseif strcmp(stepNameCurr,'DP-XXX-ATM')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValOne2RaWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;                            
                
            %Co-current repressurizzation step from the raffinate tank to
            %the feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-RAF-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowRaTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current repressurization step from the feed tank to the
            %feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-FEE-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current repressurization step from the extract tank to the
            %feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-EXT-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowExTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Counter-current repressurization from the raffinate tank to
            %the product-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-XXX-RAF')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowRaTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;   
                                
            %Counter-current repressurization from the feed tank to the 
            %product-end of the adsorber   
            elseif strcmp(stepNameCurr,'RP-XXX-FEE')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0; 
                                
            %Counter-current repressurization from the extract tank to the 
            %product-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-XXX-EXT')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowExTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;                 
                
            %Equalization at the adsorber feed-end
            elseif strcmp(stepNameCurr,'EQ-AFE-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowEqualFeedEnd(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
                
            %Equalization at the adsorber product-end
            elseif strcmp(stepNameCurr,'EQ-XXX-APR')
            
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowEqualProdEnd(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;  

            end

        end

    %When we are working with "pressure-driven" simulation mode
    elseif simMode == 1

        %When we are dealing with constant pressure DAE model
        if typeColStep == 0      

            %High pressure feed step, from the feed tank to the feed-end of
            %the adsorber, and from the product-end of the adsorber to the
            %atmosphere
            if strcmp(stepNameCurr,'HP-FEE-ATM')
                                  
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValOneBpr2RaWa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
%                 prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValOne2RaWa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                
            %High pressure feed step, from the feed tank to the feed-end of
            %the adsorber, and from the product-end of the adsoreber to the
            %raffinate product tank
            elseif strcmp(stepNameCurr,'HP-FEE-RAF')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValOneBpr2RaTa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
%                 prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValOne2RaTa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);          
                
            %High pressure feed step, from the raffinate tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HP-ATM-FEE')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValSixBpr2ExWa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);       
%                 feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValSix2ExWa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo); 
                                                         
            %High pressure rinse step, from the extract tank to the
            %feed-end of the adsorber, and from the product-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HR-EXT-ATM')

                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValOneBpr2RaWa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
%                 prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValOne2RaWa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowExTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                                
            %High pressure rinse step, from the extract tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'HR-ATM-EXT')

                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowExTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValSixBpr2ExWa(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
%                 feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValSix2ExWa(params,col,feTa, ...
%                                                  raTa,exTa,nS,nCo);

            %Low pressure purge step, from the raffinate tank to the
            %product-end of the adsorber, and from the feed-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'LP-ATM-RAF')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowRaTa2ValFiv(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValSixBpr2ExWa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo); 
%                 feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValSix2ExWa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo); 
                                
            %Low pressure purge step, from the raffinate tank to the
            %feed-end of the adsorber, and from the product-end of the
            %adsorber to the atmosphere
            elseif strcmp(stepNameCurr,'LP-RAF-ATM')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowValOneBpr2RaWa(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
%                 prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
%                           calcVolFlowValOne2RaWa(params,col,feTa, ...
%                                                     raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                          calcVolFlowRaTa2ValTwo(params,col,feTa, ...
                                                 raTa,exTa,nS,nCo);   

            elseif strcmp(stepNameCurr,'LP-EXT-FEE')
                                  
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo); 

                %Indicate that the step is a constant pressure step
                flags.whichEnd = 1;

            end

        %When we are dealing with varying pressure DAE model
        elseif typeColStep == 1
            
            %Rest step with both ends closed
            if strcmp(stepNameCurr,'RT-XXX-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                
            %Counter-current depressurization step from the feed-end to the
            %atmosphere
            elseif strcmp(stepNameCurr,'DP-ATM-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);

            %Counter-current depressurization step from the feed-end to the
            %extract tank
            elseif strcmp(stepNameCurr,'DP-EXT-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValSix2ExWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current depressurization step from the product-end to the
            %atmosphere
            elseif strcmp(stepNameCurr,'DP-XXX-ATM')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowValOne2RaWa(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;                            
                
            %Co-current repressurizzation step from the raffinate tank to
            %the feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-RAF-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowRaTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current repressurization step from the feed tank to the
            %feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-FEE-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Co-current repressurization step from the extract tank to the
            %feed-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-EXT-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowExTa2ValTwo(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                
            %Counter-current repressurization from the raffinate tank to
            %the product-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-XXX-RAF')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowRaTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;   
                                
            %Counter-current repressurization from the feed tank to the 
            %product-end of the adsorber   
            elseif strcmp(stepNameCurr,'RP-XXX-FEE')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowFeTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0; 
                                
            %Counter-current repressurization from the extract tank to the 
            %product-end of the adsorber
            elseif strcmp(stepNameCurr,'RP-XXX-EXT')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowExTa2ValFiv(params,col,feTa, ...
                                                   raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;                 
                
            %Equalization at the adsorber feed-end
            elseif strcmp(stepNameCurr,'EQ-AFE-XXX')
                
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowEqualFeedEnd(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
                
            %Equalization at the adsorber product-end
            elseif strcmp(stepNameCurr,'EQ-XXX-APR')
            
                %Define the function handles                
                prodEnd = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                            calcVolFlowEqualProdEnd(params,col,feTa, ...
                                                    raTa,exTa,nS,nCo);
                feedEnd = @(params,col,feTa,raTa,exTa,nS,nCo) 0;  
                
            end

        end

    %When the user specified not a boolean variable
    else

        %Print warnings
        msg1 = 'Please provide a boolean value of either 0 or 1 ';
        msg2 = 'to indicate flow-controlled (0) vs. ';
        msg3 = 'pressure-driven (1) simulation mode';
        msg = append(funcId,': ',msg1,msg2,msg3);
        error(msg);

    end
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%