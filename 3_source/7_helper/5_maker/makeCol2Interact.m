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
%Code created on       : 2022/2/18/Friday
%Code last modified on : 2022/11/7/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : makeCol2Interact.m
%Source     : common
%Description: given a struct for columns, this function defines interaction
%             parameters between different units.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             units        - a nested structure containing all the units in
%                            the process flow diagram.
%             nS           - jth step in a given PSA cycle.
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = makeCol2Interact(params,units,nS)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'makeCol2Interact.m';
    
    %Unpack params       
    nCols            = params.nCols           ;
    nComs            = params.nComs           ;
    sColNums         = params.sColNums        ;
    sComNums         = params.sComNums        ;
    numAdsEqPrEnd    = params.numAdsEqPrEnd   ;
    numAdsEqFeEnd    = params.numAdsEqFeEnd   ;        
    valFeTa2AdsPrEnd = params.valFeTa2AdsPrEnd;  
    valRaTa2AdsFeEnd = params.valRaTa2AdsFeEnd;
    valExTa2AdsPrEnd = params.valExTa2AdsPrEnd; 
    valFeTa2AdsFeEnd = params.valFeTa2AdsFeEnd;
    nFeTas           = params.nFeTas          ;
    sFeTaNums        = params.sFeTaNums       ;
    feTaSeq          = params.feTaSeq         ;
       
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%           

        
    
    %---------------------------------------------------------------------%
    %Define upstream and downstream conditions, based on the flow
    %direction, for each adsorption column
    
    %For each adsorber,
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %For each species
        for j = 1 : nComs

            %-------------------------------------------------------------%
            %For each feed tanks,
            % for k = 1 : nFeTas
            k = feTaSeq(nS);

            %-------------------------------------------------------------%
            %Define product-end interactions

            %Check for any pressure equalization at the product-end
            numColEqStep = numAdsEqPrEnd(i,nS);

            %If the upstream is another adsorption column at the
            %product-end
            if numColEqStep ~= 0                    

                %---------------------------------------------------------%
                %Get the total concentration of the other equalizing 
                %adsorption column (in the Nth CSTR)
                gasConTotPrEnd ...
                    = col.(sColNums{numColEqStep}). ...
                      gasConsTot(:,end);

                %Get the jth species concentration inside the 
                %equalizing adsorption column (in the Nth CSTR)
                gasConSpePrEnd ...
                    = col.(sColNums{numColEqStep}). ...
                      gasCons.(sComNums{j})(:,end);

                %Get the current total concentration of the Nth CSTR in the
                %ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}).gasConsTot(:,end);

                %Get the concentration of species at the product end of
                %the adsorber
                col.(sColNums{i}).prEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpePrEnd/gasConTotPrEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the product end
                %of the adsorber
                col.(sColNums{i}).prEnd.gasConsTot ...
                    = gasConTotCstr;
                
                %Get the upstream temperatures from the other column
                %undergoing the equalization
                col.(sColNums{i}).prEnd.temps ...
                    = col.(sColNums{numColEqStep}).temps.cstr(:,end);  
                %---------------------------------------------------------%

            %If the upstream is the extract product tank, i.e., we are 
            %doing a rinse step.
            elseif valExTa2AdsPrEnd(i,nS) == 1

                %---------------------------------------------------------%
                %Get the total concentration of the extract product tank
                gasConTotPrEnd ...
                    = exTa.n1.gasConsTot;

                %Get the jth species concentration inside the extract 
                %product tank
                gasConSpePrEnd ...
                    = exTa.n1.gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the Nth CSTR in the
                %ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,end);

                %Get the concentration of species at the product end of the
                %ith adsorber
                col.(sColNums{i}).prEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpePrEnd/gasConTotPrEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the product end
                %of the adsorber
                col.(sColNums{i}).prEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the upstream temperature from the extract product tank
                col.(sColNums{i}).prEnd.temps ...
                    = exTa.n1.temps.cstr; 
                %---------------------------------------------------------%

            %If the upstream is the feed tank 
    
            elseif k ~= 0 && valFeTa2AdsPrEnd(i,nS,k) == 1    
    
                %---------------------------------------------------------%
                %Get the total concentration of the feed tank
                gasConTotPrEnd ...
                    = feTa.(sFeTaNums{k}).gasConsTot;

                %Get the jth species concentration inside the feed tank
                gasConSpePrEnd ... 
                    = feTa.(sFeTaNums{k}).gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the Nth CSTR in 
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,end);

                %Get the concentration of species at the product end of
                %the ith adsorber.
                col.(sColNums{i}).prEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpePrEnd/gasConTotPrEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the product end
                %of the adsorber
                col.(sColNums{i}).prEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the upstream temperature from the feed tank
                col.(sColNums{i}).prEnd.temps ...
                    = feTa.(sFeTaNums{k}).temps.cstr;
                %---------------------------------------------------------%

            %Otherwise, the flow is from or to the raffinate product tank. 
            else
                
                %---------------------------------------------------------%
                %Get the total concentration of the raffinate product 
                %tank
                gasConTotPrEnd ...
                    = raTa.n1.gasConsTot;

                %Get the jth species concentration inside the raffinate 
                %product tank
                gasConSpePrEnd ...
                    = raTa.n1.gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the Nth CSTR in 
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,end);

                %Get the concentration of species at the product end of
                %the ith adsorber.
                col.(sColNums{i}).prEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpePrEnd/gasConTotPrEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the product end
                %of the adsorber
                col.(sColNums{i}).prEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the temperature from the raffinate product tank
                col.(sColNums{i}).prEnd.temps ...
                    = raTa.n1.temps.cstr;
                %---------------------------------------------------------%

            end
            %-------------------------------------------------------------%

            

            %-------------------------------------------------------------%
            %Define feed-end interactions

            %Check for any pressure equalization at the feed-end
            numColEqStep = numAdsEqFeEnd(i,nS);

            %If the upstream is another adsorption column at the 
            %feed-end
            if numColEqStep ~= 0
                
                %---------------------------------------------------------%
                %Get the total concentration of the other equalizing 
                %adsorption column (in the 1st CSTR)
                gasConTotFeEnd ...
                    = col.(sColNums{numColEqStep}). ...
                      gasConsTot(:,1);

                %Get the jth species concentration inside the 
                %equalizing adsorption column (in the 1st CSTR)
                gasConSpeFeEnd ...
                    = col.(sColNums{numColEqStep}). ...
                      gasCons.(sComNums{j})(:,1);

                %Get the current total concentration of the 1st CSTR in
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,1);

                %Get the concentration of species at the product end of
                %the adsorber
                col.(sColNums{i}).feEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpeFeEnd/ ...
                      gasConTotFeEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the feed end of 
                %the adsorber
                col.(sColNums{i}).feEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the upstream temperatures from the other column
                %undergoing the equalization
                col.(sColNums{i}).feEnd.temps ...
                    = col.(sColNums{numColEqStep}).temps.cstr(:,1); 
                %---------------------------------------------------------%            

            %If there is an interaction between the raffinate product
            %tank and the column(s)
            elseif valRaTa2AdsFeEnd(i,nS) == 1
    
                %---------------------------------------------------------%
                %Get the total concentration of the raffinate tank
                gasConTotFeEnd ...
                    = raTa.n1.gasConsTot;

                %Get the jth species concentration inside the raffinate
                %tank
                gasConSpeFeEnd ...
                    = raTa.n1.gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the 1st CSTR in
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,1);

                %Get the concentration of species at the product end of
                %the adsorber
                col.(sColNums{i}).feEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpeFeEnd/gasConTotFeEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the feed end of 
                %the adsorber
                col.(sColNums{i}).feEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the temperature from the extract product tank
                col.(sColNums{i}).feEnd.temps ...
                    = raTa.n1.temps.cstr;    
                %---------------------------------------------------------%

            %If there is an interaction between the feed tank and the
            %adsorption volumn feed-end,
            elseif k ~= 0 && valFeTa2AdsFeEnd(i,nS,k) == 1
    
                %---------------------------------------------------------%
                %Get the total concentration of the first feed tank
                gasConTotFeEnd ...
                    = feTa.(sFeTaNums{k}).gasConsTot;

                %Get the jth species concentration inside the first 
                %feed tank
                gasConSpeFeEnd ...
                    = feTa.(sFeTaNums{k}).gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the 1st CSTR in
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,1);

                %Get the concentration of species at the product end of
                %the adsorber
                col.(sColNums{i}).feEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpeFeEnd/gasConTotFeEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the feed end of 
                %the adsorber
                col.(sColNums{i}).feEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the temperature from the feed tank
                col.(sColNums{i}).feEnd.temps ...
                    = feTa.(sFeTaNums{k}).temps.cstr;
                %---------------------------------------------------------%
                    
            %Otherwise, there is an interaction between the extract product
            %tank and the adsorption column feed-end.
            else
                
                %---------------------------------------------------------%
                %Get the total concentration of the extract tank
                gasConTotFeEnd ...
                    = exTa.n1.gasConsTot;

                %Get the jth species concentration inside the extract
                %tank
                gasConSpeFeEnd ...
                    = exTa.n1.gasCons. ...
                      (sComNums{j});

                %Get the current total concentration of the 1st CSTR in
                %the ith adsorption column
                gasConTotCstr ...
                    = col.(sColNums{i}). ...
                      gasConsTot(:,1);

                %Get the concentration of species at the product end of
                %the adsorber
                col.(sColNums{i}).feEnd.gasCons.(sComNums{j}) ...
                    = (gasConSpeFeEnd/gasConTotFeEnd) ...
                    * gasConTotCstr;
                
                %Get the total concentration of species at the feed end of 
                %the adsorber
                col.(sColNums{i}).feEnd.gasConsTot ...
                    = gasConTotCstr;

                %Get the temperature from the extract product tank
                col.(sColNums{i}).feEnd.temps ...
                    = exTa.n1.temps.cstr;
                %---------------------------------------------------------%

            end                
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%                     
        
    end       
    %---------------------------------------------------------------------%                          
    
    
    
    %---------------------------------------------------------------------%                          
    %Return the updated structure for the units
    
    %Pack units
    units.col = col;    
    %---------------------------------------------------------------------%                          
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%