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
%Code created on       : 2022/2/19/Saturday
%Code last modified on : 2022/4/11/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4PFD.m
%Source     : common
%Description: This function calculates volumetric flow rates for the rest
%             of the process flow diagram, based on the calcualted and thus
%             became known volumetric flow rates in the adsorbers.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             vFlPlus      - a vector containing all the positive pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             vFlMinus     - a vector containing all the negative pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlows4PFD(params,units,vFlPlus,vFlMinus,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4PFD.m';
    
    %Unpack params   
    nCols     = params.nCols    ; 
    nVols     = params.nVols    ;        
    presBeHi  = params.presBeHi ;
    presRaTa  = params.presRaTa ;
    presExTa  = params.presExTa ;
    sColNums  = params.sColNums ;
    valRaTa   = params.valRaTa  ;
    valExTa   = params.valExTa  ;
    nRows     = params.nRows    ;
    flowDir   = params.flowDir  ;
    valRinTop = params.valRinTop;
    valRinBot = params.valRinBot;
    valPurBot = params.valPurBot;
    valFeeTop = params.valFeeTop;
    pRatAmb   = params.pRatAmb  ;
    pRatVac   = params.pRatVac  ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the volumetric flow rates from the pseudo volumetric flow
    %rates
    
    %Compute the differene between the positive and the negative pseudo
    %volumetric flow rates
    vFlCol = vFlPlus-vFlMinus;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize the numerical solution arrays
    
    %A numeric array for the volumetric flow rates for the feed tank
    vFlFeTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the raffinate 
    %product tank
    vFlRaTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the raffinate waste
    vFlRaWa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the extract product 
    %tank
    vFlExTa = zeros(nRows,(nCols+1));
    
    %A numeric array for the volumetric flow rates for the extract waste
    vFlExWa = zeros(nRows,(nCols+1));
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Determine flow rates for the feed tank
    
    %For all streams around a feed tank coming from or going to an
    %adsorption column, assign the volumetric flow rate values (volumetric
    %flow rate is evaluated at the tank pressure)

    %Get the total concentration of the ith feed tank at time t
    feTaTotCon = feTa.n1.gasConsTot;

    %For a stream associated with jth column,
    for j = 1 : nCols

        %If the flow direction is co-current, and we are interacting with 
        %the feed tank through the feed-end of the jth adsorber 
        if flowDir(j,nS) == 0 && ... %co-current flow
           valFeeTop(nS) == 0 && ... %feed from the bottom
           valRinBot(nS) == 0 && ... %no rinse at the bottom-end
           valPurBot(nS) == 0        %no purge at the bottom-end           
                
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,1) ...
                       ./ feTaTotCon;                              

            %Grab a volumetric flow rate from the feed-end of jth column
            vFlFeTa(:,j) = vFlCol(:,(nVols+1)*(j-1)+1) ...
                        .* vFlScaleFac; 
        
        %If the flow direction is counter-current, and we are interacting 
        %with the product tank through the product-end of the jth adsorber 
        elseif flowDir(j,nS) == 1 && ... %counter-current flow
               valFeeTop(nS) == 1        %feed from the top              
                
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,end) ...
                       ./ feTaTotCon;

            %Grab a volumetric flow rate from the feed-end of jth column.
            %The flow rate is negated to make the counter-current flow
            %(negative) to become a positive number.
            vFlFeTa(:,j) = (-1)*vFlCol(:,(nVols+1)*(j)) ...
                        .* vFlScaleFac; 
        
        %There aren't any other situations to consider as we assume that
        %the flow direction is always co-current and the feed tank is
        %maintained at P_f which is the highest pressure in the system
        
        end

    end

    %The entering valve to the feed tank is always controlled to maintain a
    %constant pressure inside the feed tank

    %Control the flow rate so that a constant pressure is maintained inside
    %the feed tank
    vFlFeTa(:,(nCols+1)) = sum(vFlFeTa(:,1:nCols),2);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Determine flow rates for the raffinate product tank
    
    %For all streams around the product tank coming from or going to an
    %adsorption column, assign the volumetric flow rate values (Volumetric
    %flow rate is evaluated at the tank pressure)
    
    %Get the total concentration of the raffinate product tank at time t
    raTaTotCon = raTa.n1.gasConsTot;

    %For a stream associated with jth column,
    for j = 1 : nCols
                                     
        %If the flow direction is co-current, the jth adsorber can interact
        %with the raffinate product tank through the bottom-end of the jth 
        %adsorber
        if flowDir(j,nS) == 0 && ...
           valPurBot(nS) == 1 
            
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,1) ...
                       ./ raTaTotCon;
                   
            %Calcualate the volumetric flow rate from the raffinate product 
            %tank to the jth adsorption column. Since this is a co-current 
            %flow "out" from the raffinate product tank, we let the 
            %volumetric flow rate to be a negative value
            vFlRaTa(:,j) = (-1) ...
                         * vFlCol(:,(nVols+1)*(j-1)+1) ...
                        .* vFlScaleFac;    
        
        %If the flow direction is co-current, and we are interacting with 
        %the raffinate product tank through the product-end of the jth 
        %adsorber 
        elseif flowDir(j,nS) == 0

            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac1 = col.(sColNums{j}).gasConsTot(:,end) ...
                        ./ raTaTotCon;
            vFlScaleFac2 = col.(sColNums{j}).gasConsTot(:,end) ...
                        ./ pRatAmb;        

            %Grab a volumetric flow rate from the product-end of the jth 
            %column to the product tank
            vFlRaTaVal1 = vFlCol(:,(nVols+1)*j) ...
                       .* vFlScaleFac1;   
            vFlRaTaVal2 = vFlCol(:,(nVols+1)*j) ...
                       .* vFlScaleFac2;  

            %Update a volumetric flow rate for the stream between the 
            %adsorber and the raffinate product tank       
            vFlRaTa(:,j) = valRaTa(nS) ...
                         * vFlRaTaVal1;

            %Update a volumetric flow rate for the waste stream (at the 
            %ambient pressure)
            vFlRaWa(:,j) = (1-valRaTa(nS)) ...
                         * vFlRaTaVal2;
                    
        %If the flow direction is counter-current, and we are interacting
        %with the raffinate product tank through the product-end of the jth 
        %adsorber 
        elseif flowDir(j,nS) == 1 
            
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,end) ...
                       ./ raTaTotCon;

            %Grab a volumetric flow rate from the product-end of the jth 
            %column to the product tank
            vFlRaTa(:,j) = vFlCol(:,(nVols+1)*j) ...
                        .* vFlScaleFac;               
                    
        end
        
    end
    
    %The exit valve is opened only when the tank pressure equals the
    %initial product tank pressure       

    %Get the net volumetric flow rate in the product tank from the streams 
    %associated with the columns
    vFlNetRaTa = sum(vFlRaTa(:,1:nCols),2);

    %When the product tank pressure is greater than equal to the high
    %pressure and there is a net flow out, maintain it!

    %For each time point t
    for t = 1 : nRows                                            
        
            %Get the sign of the current concentration difference
            testConc = raTaTotCon(t) ...
                     - (presRaTa/presBeHi);
        
            %Obtain the volumetric flow rate out of the check valve
            vFlRaTa(t,(nCols+1)) = (testConc >= 0) ...
                                 * max(vFlNetRaTa(t),0);

    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------% 
    %Determine flow rates for the extract product tank
    
    %For all streams around the product tank coming from or going to an
    %adsorption column, assign the volumetric flow rate values (Volumetric
    %flow rate is evaluated at the tank pressure)
    
    %Get the total concentration of the extract product tank at time t
    exTaTotCon = exTa.n1.gasConsTot;

    %For a stream associated with jth column,
    for j = 1 : nCols
                        
        %If the flow direction is counter-current, and we are interacting
        %with the extract product tank through the top-end of the jth 
        %adsorber 
        if flowDir(j,nS) == 1 && ...
           valRinTop(nS) == 1   
           
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,end) ...
                       ./ exTaTotCon;

            %Calcualate the volumetric flow rate from the extract product 
            %tank to the jth adsorption column. Since this is a
            %counter-current flow "out" from the extract product tank, we 
            %let the volumetric flow rate to be a negative value
            vFlExTa(:,j) = vFlCol(:,(nVols+1)*(j)) ...
                        .* vFlScaleFac;   
            
        %If the flow direction is co-current, the jth adsorber can interact
        %with the extract product tank through the bottom-end of the jth 
        %adsorber
        elseif flowDir(j,nS) == 0 && ...
               valRinBot(nS) == 1
           
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac = col.(sColNums{j}).gasConsTot(:,1) ...
                       ./ exTaTotCon;

            %Calcualate the volumetric flow rate from the extract product 
            %tank to the jth adsorption column. Since this is a co-current 
            %flow "out" from the extract product tank, we let the 
            %volumetric flow rate to be a negative value
            vFlExTa(:,j) = (-1) ...
                         * vFlCol(:,(nVols+1)*(j-1)+1) ...
                        .* vFlScaleFac; 
            
        %If the flow direction is counter-current, and we are interacting
        %with the extract product tank through the bottom-end of the jth 
        %adsorber 
        elseif flowDir(j,nS) == 1 ... %Counter-current flow
        
            %Determine the scale factor for the volumetric flow rate
            vFlScaleFac1 = col.(sColNums{j}).gasConsTot(:,1) ...
                        ./ exTaTotCon;
            vFlScaleFac2 = col.(sColNums{j}).gasConsTot(:,1) ...
                        ./ pRatVac;

            %Grab a volumetric flow rate from the feed-end of the jth 
            %column to the extract product tank
            vFlExTaVal1 = vFlCol(:,(nVols+1)*(j-1)+1) ...
                       .* vFlScaleFac1;   
            vFlExTaVal2 = vFlCol(:,(nVols+1)*(j-1)+1) ...
                       .* vFlScaleFac2;

            %Update a volumetric flow rate for the stream between the 
            %adsorber and the extract product tank; the negative sign is 
            %needed because we flip the flow direction on the way and the
            %flow is coming "into" the extract product tank.
            vFlExTa(:,j) = (-1) ...
                         * valExTa(nS) ...
                         * vFlExTaVal1;

            %Update a volumetric flow rate for the waste stream; the 
            %negative sign is needed because we flip the flow direction on 
            %the way and the flow is coming "into" the extract stream.
            vFlExWa(:,j) = (-1) ...
                         * (1-valExTa(nS)) ...
                         * vFlExTaVal2;
        
        end
                  
    end
    
    %The exit valve is opened only when the tank pressure equals the
    %initial product tank pressure       

    %Get the net volumetric flow rate in the product tank from the streams 
    %associated with the columns
    vFlNetExTa = sum(vFlExTa(:,1:nCols),2);

    %When the product tank pressure is greater than equal to the high
    %pressure and there is a net flow out, maintain it!

    %For each time point t
    for t = 1 : nRows          
        
        %Get the sign of the current concentration difference
        testConc = exTaTotCon(t) ...
                 - (presExTa/presBeHi);

        %Obtain the volumetric flow rate out of the check valve
        vFlExTa(t,(nCols+1)) = (testConc >= 0) ...
                             * max(vFlNetExTa(t),0);
       
    end
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------% 
    %Save the results to the structs: assign the volumetric flow rates to 
    %the struct holding column and tank properties
    
    %Loop through each columns,
    for i = 1 : nCols
        
        %Get the first index
        n0 = (nVols+1)*(i-1)+1;
        
        %Get the last index
        nf = (nVols+1)*i;
        
        %Save the volumetric flow rates to a struct
        col.(sColNums{i}).volFlRat = vFlCol(:,n0:nf);
        
        %Save the pseudo volumetric flow rates
        col.(sColNums{i}).volFlPlus  = vFlPlus(:,n0:nf) ;
        col.(sColNums{i}).volFlMinus = vFlMinus(:,n0:nf);
        
    end                     
    
    %Save the volumetric flow rates to a struct
    raTa.n1.volFlRat = vFlRaTa(:,1:(nCols+1));  
    
    %Save the volumetric flow rates to a struct
    exTa.n1.volFlRat = vFlExTa(:,1:(nCols+1));
    
    %Save the volumetric flow rates to a struct
    raWa.n1.volFlRat = vFlRaWa(:,1:(nCols+1));  
    
    %Save the volumetric flow rates to a struct
    exWa.n1.volFlRat = vFlExWa(:,1:(nCols+1));
    
    %Save the volumetric flow rates to a struct
    feTa.n1.volFlRat = vFlFeTa(:,1:(nCols+1));         
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------% 
    %Return the updated structure
    
    %Update units
    units.col  = col ;
    units.feTa = feTa;
    units.raTa = raTa;
    units.exTa = exTa;
    units.raWa = raWa;
    units.exWa = exWa;    
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%