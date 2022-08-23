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
%Code created on       : 2021/1/7/Thursday
%Code last modified on : 2022/8/13/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getFlowSheetValves.m
%Source     : common
%Description: a function that defines parameters associated with cycle
%             organization of a specified PSA cycle. The interaction
%             matrices for the equalizations were already obtained in
%             getStringParams.m.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getFlowSheetValves(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getFlowSheetValves.m';
    
    %Unpack Params
    nSteps      = params.nSteps     ;  
    sStepCol    = params.sStepCol   ;
    nCols       = params.nCols      ;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays                        
    
    %Interaction matrix for the rest step. 0 indicates that there is no
    %interaction. 1 indicates that thre is an interaction. By default, the
    %rest steps have no interactions with other units.
    valAdsRestClosed = ones(nCols,nSteps);
    
    %Interaction matrix for the feed tank and the adsorption columns. 0
    %indicates that there is no interaction. 1 indicates that there is an
    %interaction.
    valFeTa2AdsFeEnd = zeros(nCols,nSteps); 
    valFeTa2AdsPrEnd = zeros(nCols,nSteps);       
    
    %Interaction matrix for the raffinate product tank and the adsorption 
    %columns. 0 indicates that there is no interaction. 1 indicates that 
    %there is an interaction.
    valRaTa2AdsFeEnd = zeros(nCols,nSteps);     
    valRaTa2AdsPrEnd = zeros(nCols,nSteps);     
    valAdsPrEnd2RaTa = zeros(nCols,nSteps); 
    
    %Interaction matrix for the extract product tank and the adsorption 
    %columns. 0 indicates that there is no interaction. 1 indicates that 
    %there is an interaction.
    valExTa2AdsFeEnd = zeros(nCols,nSteps); 
    valExTa2AdsPrEnd = zeros(nCols,nSteps); 
    valAdsFeEnd2ExTa = zeros(nCols,nSteps); 
    
    %Interaction matrix for the column interactions with the raffinate 
    %product wast stream: 0 means the stream is diverted to the waste 
    %stream and 1 means the stream is diverted to the raffinate product
    %tank.
    valAdsPrEnd2RaWa = ones(nCols,nSteps);   
            
    %Interaction matrix for the column interactions with the extract 
    %product wast stream: 0 means the stream is diverted to the waste 
    %stream and 1 means the stream is diverted to the extract product tank.
    valAdsFeEnd2ExWa = ones(nCols,nSteps);             
    %---------------------------------------------------------------------%                          
    
    
    
    %---------------------------------------------------------------------%
    %Check for no interactions around the feed tank
    
    %Check for the rest steps
    valAdsRestClosed = valAdsRestClosed...
                     + strcmp(sStepCol,'RT-XXX-XXX');
    %---------------------------------------------------------------------%
    
    
                 
    %---------------------------------------------------------------------%
    %Check for the interactions around the feed tank
    
    %Check for all the situations where the feed tank outlet is headed to
    %the feed-end of the adsorbers.
    valFeTa2AdsFeEnd = valFeTa2AdsFeEnd ...
                     + strcmp(sStepCol,'RP-FEE-XXX') ...
                     + strcmp(sStepCol,'HP-FEE-ATM') ...
                     + strcmp(sStepCol,'HP-FEE-RAF'); 
            
    %Check for all the situations where the feed tank outlet is headed to
    %the product-end of the adsorbers.
    valFeTa2AdsPrEnd = valFeTa2AdsPrEnd ...
                     + strcmp(sStepCol,'RP-XXX-FEE') ...
                     + strcmp(sStepCol,'HP-ATM-FEE');     
    %---------------------------------------------------------------------%
   
    
    
    %---------------------------------------------------------------------%
    %Check for the interactions around the raffinate product tank
    
    %Check for all the situations where the raffinate tank outlet is headed
    %to the feed-end of the adsorbers.
    valRaTa2AdsFeEnd = valRaTa2AdsFeEnd ...
                     + strcmp(sStepCol,'RP-RAF-XXX') ...
                     + strcmp(sStepCol,'LP-RAF-ATM'); 
            
    %Check for all the situations where the raffinate tank outlet is headed
    %to the product-end of the adsorbers.
    valRaTa2AdsPrEnd = valRaTa2AdsPrEnd ...
                     + strcmp(sStepCol,'RP-XXX-RAF') ...                     
                     + strcmp(sStepCol,'LP-ATM-RAF'); 
    valAdsPrEnd2RaTa = valAdsPrEnd2RaTa ...
                     + strcmp(sStepCol,'HP-FEE-RAF');
    
    %Check for all the situations where the product-end of the adsorber is
    %directed to the waste stream at the atmospheric pressure.
    valAdsPrEnd2RaWa = valAdsPrEnd2RaWa ...
                     - strcmp(sStepCol,'DP-XXX-ATM') ...
                     - strcmp(sStepCol,'HP-FEE-ATM') ...
                     - strcmp(sStepCol,'LP-RAF-ATM') ...
                     - strcmp(sStepCol,'HR-EXT-ATM');            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for the interactions around the extract product tank
    
    %Check for all the situations where the feed tank outlet is headed to
    %the feed-end of the adsorbers
    valExTa2AdsFeEnd = valExTa2AdsFeEnd ...
                     + strcmp(sStepCol,'RP-EXT-XXX') ...
                     + strcmp(sStepCol,'HR-EXT-ATM'); 
    valAdsFeEnd2ExTa = valAdsFeEnd2ExTa ...
                     + strcmp(sStepCol,'DP-EXT-XXX');
                 
    %Check for all the situations where the feed tank outlet is headed to
    %the product-end of the adsorbers
    valExTa2AdsPrEnd = valExTa2AdsPrEnd ...
                     + strcmp(sStepCol,'RP-XXX-EXT') ...
                     + strcmp(sStepCol,'HR-ATM-EXT');   

    %Check for all the situations where the feed-end of the adsorber is
    %directed to the waste stream at the atmospheric pressure
    valAdsFeEnd2ExWa = valAdsFeEnd2ExWa ...
                     - strcmp(sStepCol,'DP-ATM-XXX') ...
                     - strcmp(sStepCol,'HP-ATM-FEE') ...
                     - strcmp(sStepCol,'LP-ATM-RAF') ...
                     - strcmp(sStepCol,'HR-ATM-EXT');                         
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the results into a struct named params
    
    %Store the information on interaction
    params.valAdsRestClosed = valAdsRestClosed;
    params.valFeTa2AdsPrEnd = valFeTa2AdsPrEnd; 
    params.valFeTa2AdsFeEnd = valFeTa2AdsFeEnd; 
    params.valRaTa2AdsPrEnd = valRaTa2AdsPrEnd; 
    params.valAdsPrEnd2RaTa = valAdsPrEnd2RaTa;
    params.valRaTa2AdsFeEnd = valRaTa2AdsFeEnd;
    params.valExTa2AdsPrEnd = valExTa2AdsPrEnd; 
    params.valExTa2AdsFeEnd = valExTa2AdsFeEnd;
    params.valAdsPrEnd2RaWa = valAdsPrEnd2RaWa; 
    params.valAdsFeEnd2ExWa = valAdsFeEnd2ExWa; 
    params.valAdsFeEnd2ExTa = valAdsFeEnd2ExTa;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%