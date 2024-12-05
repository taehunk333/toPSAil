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
%Function   : savePsaSimulationResults.m
%Source     : common
%Description: takes in data from dynamic simulation of pressure swing
%             adsorption (PSA) process of choice and creates excel files
%             that contain simulation data.
%Inputs     : params       - a struct containing simulation parameters
%             sol          - a struct containing simulation outputs
%             folder       - a string denoting the folder directory on
%                            which to save the simulation results
%Outputs    : any requested .csv files are saved inside the example folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function savePsaSimulationResults(params,sol,folder)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'savePsaSimulationResults';
    
    %Unpack Params
    nCols        = params.nCols       ;       
    nTimePts     = params.nTiPts      ;
    lastStep     = sol.lastStep       ;
    nVols        = params.nVols       ;
    nComs        = params.nComs       ;
    nTemp        = params.nTemp       ;
    tiScaleFac   = params.tiScaleFac  ;
    gConScaleFac = params.gConScaleFac;
    aConScaleFac = params.aConScaleFac;
    teScaleFac   = params.teScaleFac  ;
    volScaleFac  = params.volScaleFac ;
    overVoid     = params.overVoid    ;
    cstrVol      = params.cstrVol     ;
    massAds      = params.massAds     ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte needed quantities
    
    %Calculate the volume of the void space per CSTR 
    voidVolCstr = overVoid*cstrVol;
    
    %Calculate the mass of adsorbent per CSTR
    massAdsCstr = massAds/nVols;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Determine the details associated with solution outputs
    
    %Find the final number of time points
    nTimePtsFinal = lastStep*nTimePts;            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize a numerical array for holding the time points
    timeNum = zeros(nTimePtsFinal,1);
    
    %Initialize a cell array for holding the strings of step names
    timeStr = cell(nTimePtsFinal,nCols);
        
        %-----------------------------------------------------------------%
        %Initialize cell arrays associated with adsorption columns

        %Initialize gas phase concentration solution matrix
        gasMolesCol = zeros(nTimePtsFinal,nVols*nComs*nCols);

        %Initialize adsorbed phase concentration solution matrix
        adsMolesCol = zeros(nTimePtsFinal,nVols*nComs*nCols);

        %Initialize volumetric flow rate solution matrix
        volFlRatCol = zeros(nTimePtsFinal,(nVols+1)*nCols);

        %Initialize temperature solution matrix
        tempCol = zeros(nTimePtsFinal,nVols*nTemp*nCols);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Initialize cell arrays associated with the feed tank

        %Initialize feed molar flow rate solution matrix
        gasMolesFeTa = zeros(nTimePtsFinal,nComs);

        %Initialize volumetric flow rate solution matrix
        volFlRatFeTa = zeros(nTimePtsFinal,nCols+1);

        %Initialize temperature solution matrix
        tempFeTa = zeros(nTimePtsFinal,nTemp);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Initialize cell arrays associated with the raffinate product tank

        %Initialize raffinate product molar flow rate solution matrix
        gasMolesRaTa = zeros(nTimePtsFinal,nComs); 

        %Initialize volumetric flow rate solution matrix
        volFlRatRaTa = zeros(nTimePtsFinal,nCols+1);

        %Initialize temperature solution matrix
        tempRaTa = zeros(nTimePtsFinal,nTemp);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Initialize cell arrays associated with the extract product tank
        
        %Initialize extract product molar flow rate solution matrix
        gasMolesExTa = zeros(nTimePtsFinal,nComs); 

        %Initialize volumetric flow rate solution matrix
        volFlRatExTa = zeros(nTimePtsFinal,nCols+1);

        %Initialize temperature solution matrix
        tempExTa = zeros(nTimePtsFinal,nTemp);
        %-----------------------------------------------------------------%
        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get dimensional time points
    
    %For each step,
    for i = 1 : lastStep
        
       %Dimensionalize the time points and save it in the column vector
       timeNum(nTimePts*(i-1)+1:nTimePts*i,1) ...
           = tiScaleFac ...
          .* sol.(append('Step',int2str(i))).timePts;
        
    end   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get string identifier for the time points
    
    %For each step,
    for i = 1 : lastStep
        
       %Save the string identifiers for a given step into the cell array
       timeStr(nTimePts*(i-1)+1:nTimePts*i,:) ...
           = sol.(append('Step',int2str(i))).timeFlags;
        
    end          
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For each adsorption column, get dimensional gas phase concentration 
    %values, adsorbed phase concentration values, and temperature values
    
    %For each adsorption column,
    for i = 1 : nCols
        
        %Compute column shift factor for concentrations
        colShiftCon = nComs*nVols*(i-1);
        
        %Compute column shift factor for volumetric flow rates
        colShiftVol = (nVols+1)*(i-1);
        
        %Compute column shift factor for temperatures
        colShiftTem = nTemp*nVols*(i-1);
        
        %For each step,
        for j = 1 : lastStep
            
            %Determine the time range
            timeRange = nTimePts*(j-1)+1:nTimePts*j;
            
            %Determine the volumetric flow rate range
            volFlRange = colShiftVol+1:colShiftVol+(nVols+1);
            
            %Update the solution matrix with volumetric flow rates for a
            %given column, a given step
            volFlRatCol(timeRange,volFlRange) ...
                = sol.(append('Step',int2str(j))).col. ...
                  (append('n',int2str(i))).volFlRat ...
                * volScaleFac;
            
            %For each species,
            for k = 1 : nComs
                                                
                %Determine the gas/adsorbed phase concentration range
                consRange = colShiftCon+nVols*(k-1)+1 ...
                          : colShiftCon+nVols*k;
                
                %Update the solution matrix with the proper gas phase 
                %amount for a given column, a given step, and a given 
                %species
                gasMolesCol(timeRange,consRange) ...
                    = sol.(append('Step',int2str(j))).col. ...
                      (append('n',int2str(i))).gasCons. ...
                      (append('C',int2str(k))) ...
                    * gConScaleFac ...
                    * voidVolCstr;                                 
                
                %Update the solution matrix with the proper adsorbed phase 
                %amount for a given column, a given step, and
                %a given species
                adsMolesCol(timeRange,consRange) ...
                    = sol.(append('Step',int2str(j))).col. ...
                      (append('n',int2str(i))).adsCons. ...
                      (append('C',int2str(k))) ...
                    * aConScaleFac ...
                    * massAdsCstr;
                                                   
            end
                             
            %For each temperature value,
            for k = 1 : nTemp

                %Determine the temperature range
                tempRange = colShiftTem ...
                          + nVols*(k-1)+1 ...
                          : colShiftTem ...
                          + nVols*k;

                %Determine the string for the temperature
                if k == 1

                    %We refer to CSTR temperature values
                    tempName = 'cstr';

                elseif k == 2

                    %We refer to wall temperature values
                    tempName = 'wall';

                else

                    %Print an error message
                    msg = 'The third temperature kind is not defined.';
                    msg = append(funcId,': ',msg);
                    error(msg);  

                end

                %Update the solution matrix with the proper gas phase 
                %conecntration values for a given column, a given step,
                %and a given species
                tempCol(timeRange,tempRange) ...
                    = sol.(append('Step',int2str(j))).col. ...
                      (append('n',int2str(i))).temps. ...
                      (tempName) ...
                    * teScaleFac;

            end
            
        end
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For the feed tank, get dimensional gas phase concentration values, 
    %adsorbed phase concentration values, and temperature values
    
    %For each step,
    for j = 1 : lastStep

        %Determine the time range
        timeRange = nTimePts*(j-1)+1 ...
                  : nTimePts*j;
        
        %Update the solution matrix with volumetric flow rates for a
        %given feed tank, a given step
        volFlRatFeTa(timeRange,:) = sol.(append('Step',int2str(j))). ...
                                    feTa.n1.volFlRat ...
                                  * volScaleFac;

        %For each species,
        for k = 1 : nComs

            %Determine the gas phase concentration range
            consRange = k;

            %Update the solution matrix with the proper gas phase 
            %conecntration values for a given column, a given step, and
            %a given species
            gasMolesFeTa(timeRange,consRange) ...
                = sol.(append('Step',int2str(j))).feTa.n1.gasCons. ...
                  (append('C',int2str(k))) ...
                * gConScaleFac ...
                * voidVolCstr;

        end  

        %For each temperature value,
        for k = 1 : nTemp

            %Determine the temperature range
            tempRange = k;

            %Determine the string for the temperature
            if k == 1

                %We refer to CSTR temperature values
                tempName = 'cstr';

            elseif k == 2

                %We refer to wall temperature values
                tempName = 'wall';

            else

                %Print an error message
                msg = 'The third temperature kind is not defined.';
                msg = append(funcId,': ',msg);
                error(msg);  

            end

                %Update the solution matrix with the proper gas phase 
                %conecntration values for a given column, a given step,
                %and a given species
                tempFeTa(timeRange,tempRange) ...
                    = sol.(append('Step',int2str(j))). ...
                      feTa.n1.temps.(tempName) ...
                    * teScaleFac;

        end

    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For the raffinate product tank, get dimensional gas phase 
    %concentration values, adsorbed phase concentration values, and 
    %temperature values 
        
    %For each step,
    for j = 1 : lastStep

        %Determine the time range
        timeRange = nTimePts*(j-1)+1 ...
                  : nTimePts*j;

        %Update the solution matrix with volumetric flow rates for a
        %given product tank, a given step
        volFlRatRaTa(timeRange,:) ...
            = sol.(append('Step',int2str(j))). ...
              raTa.n1.volFlRat ...
            * volScaleFac;

        %For each species,
        for k = 1 : nComs

            %Determine the gas phase concentration range
            consRange = k;

            %Update the solution matrix with the proper gas phase 
            %conecntration values for a given column, a given step, and
            %a given species
            gasMolesRaTa(timeRange,consRange) ...
                = sol.(append('Step',int2str(j))).raTa. ...
                  n1.gasCons.(append('C',int2str(k))) ...
                * gConScaleFac ...
                * voidVolCstr;

        end                                             

        %For each temperature value,
        for k = 1 : nTemp

            %Determine the temperature range
            tempRange = k;

            %Determine the string for the temperature
            if k == 1

                %We refer to CSTR temperature values
                tempName = 'cstr';

            elseif k == 2

                %We refer to wall temperature values
                tempName = 'wall';

            else

                %Print an error message
                msg = 'The third temperature kind is not defined.';
                msg = append(funcId,': ',msg);
                error(msg);  

            end

            %Update the solution matrix with the proper gas phase 
            %conecntration values for a given column, a given step,
            %and a given species
            tempRaTa(timeRange,tempRange) ...
                = sol.(append('Step',int2str(j))).raTa. ...
                  n1.temps.(tempName) ...
                * teScaleFac;

        end

    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For the extract product tank, get dimensional gas phase concentration 
    %values, adsorbed phase concentration values, and temperature values 
    
    %For each step,
    for j = 1 : lastStep

        %Determine the time range
        timeRange = nTimePts*(j-1)+1 ...
                  : nTimePts*j;

        %Update the solution matrix with volumetric flow rates for a
        %given product tank, a given step
        volFlRatExTa(timeRange,:) ...
            = sol.(append('Step',int2str(j))). ...
              exTa.n1.volFlRat ...
            * volScaleFac;

        %For each species,
        for k = 1 : nComs

            %Determine the gas phase concentration range
            consRange = k;

            %Update the solution matrix with the proper gas phase 
            %conecntration values for a given column, a given step, and
            %a given species
            gasMolesExTa(timeRange,consRange) ...
                = sol.(append('Step',int2str(j))).exTa. ...
                  n1.gasCons.(append('C',int2str(k))) ...
                * gConScaleFac ...
                * voidVolCstr;

        end                                             

        %For each temperature value,
        for k = 1 : nTemp

            %Determine the temperature range
            tempRange = k;

            %Determine the string for the temperature
            if k == 1

                %We refer to CSTR temperature values
                tempName = 'cstr';

            elseif k == 2

                %We refer to wall temperature values
                tempName = 'wall';

            else

                %Print an error message
                msg = 'The third temperature kind is not defined.';
                msg = append(funcId,': ',msg);
                error(msg);  

            end

            %Update the solution matrix with the proper gas phase 
            %conecntration values for a given column, a given step,
            %and a given species
            tempRaTa(timeRange,tempRange) ...
                = sol.(append('Step',int2str(j))).exTa. ...
                  n1.temps.(tempName) ...
                * teScaleFac;

        end

    end        
    %---------------------------------------------------------------------%

    
    
    %---------------------------------------------------------------------%
    %Check to make sure that we have a location to save the results
        
    %If there exist no directory to save the results,
    if ~exist(folder,'dir')
        
        %Make a new directory in the current example folder
        mkdir(folder);
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the results on the time points
    
    %Convert the cell holding numerical time points to a table
    timeNum = array2table(timeNum);
    
    %Convert the cell holding string identifiers to a table
    timeStr = cell2table(timeStr);
    
    %Combine a table (single column) of numerical time values and another 
    %(single column) of string names of the steps
    data = [timeNum, timeStr];
        
    %Save the simulation results for the time points (string values)
    writetable(data,fullfile(folder,'time.csv'), 'WriteVariableNames',0);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%    
    %Save the simulation results for the columns
           
    %For ith column,
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Save the amount of species in gas and adsorbed phases
        
        %Get the string name for the volumetric flow rates for ith column
        fileName = append('volFlowRateCol',int2str(i),'.csv');

        %Save the volumetric flow rates for ith column
        writematrix(volFlRatCol,fullfile(folder,fileName));                                              

        %For jth component
        for j = 1 : nComs

            %Get the file name
            fileName = append('molesCol',int2str(i), ...
                              'Com',int2str(j),'.csv');

            %Grab the beginning index for the concentration variables
            indInit = nComs*nVols*(i-1)+nVols*(j-1)+1;

            %Grab the end index for the concentration variables
            indFinal = nComs*nVols*(i-1)+nVols*j;       

            %Grab gas phase concentrations of a given column for a 
            %given component
            gasMolesColCom = gasMolesCol(:,indInit:indFinal);

            %Grab adsorbed phase concentrations of a given column for a
            %given component
            adsMolesColCom = adsMolesCol(:,indInit:indFinal);

            %Get the state solution data matrix for ith column            
            stSols = reshape([gasMolesColCom;adsMolesColCom], ...
                             size(gasMolesColCom,1), ...
                             []);                            

            %Save the state solutions
            writematrix(stSols,fullfile(folder,fileName));

        end
        %-----------------------------------------------------------------%
        
    
        
        %-----------------------------------------------------------------%
        %Save the temperature values
        
        %Get the file name
        fileName = append('tempsCol',int2str(i),'.csv');

        %Grab the beginning index for the temperature variables
        indInitCstr = nTemp*nVols*(i-1)+1;
        indInitWall = nTemp*nVols*(i-1)+nVols+1;
        
        %Grab the end index for the temperature variables
        indFinalCstr = nTemp*nVols*(i-1)+nVols; 
        indFinalWall = nTemp*nVols*(i-1)+nTemp*nVols; 

        %Grab the cstr temperature values of a given column for a given
        %adsorption column
        cstrTempCol = tempCol(:,indInitCstr:indFinalCstr);

        %Grab the wall temperature values of a given column for a given
        %adsorption column
        wallTempCol = tempCol(:,indInitWall:indFinalWall);

        %Get the state solution data matrix for ith column
        stSols = reshape([cstrTempCol;wallTempCol], ...
                         size(cstrTempCol,1), ...
                         []); 

        %Save the state solutions
        writematrix(stSols,fullfile(folder,fileName));
        %-----------------------------------------------------------------%

    end            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the simulation results for the feed tanks
    
    %Get the string name for the volumetric flow rates for ith
    %feed tank
    fileName = 'volFlowRateFeTa.csv';

    %Save the volumetric flow rates for ith feed tank
    writematrix(volFlRatFeTa,fullfile(folder,fileName));  

    %For jth component
    for j = 1 : nComs

        %Get the file name
        fileName = append('molesFeTa','Com',int2str(j),'.csv');

        %Grab the beginning/end index for the concentration 
        %variables
        ind = j; 

        %Grab gas phase concentrations of a given feed tank for a 
        %given component
        gasMolesFeTaCom = gasMolesFeTa(:,ind);

        %Save the state solutions
        writematrix(gasMolesFeTaCom,fullfile(folder,fileName));

    end

    %Get the file name
    fileName = 'tempsFeTa.csv';

    %Get the state solution data matrix for ith column
    stSols = reshape([tempFeTa(:,1);tempFeTa(:,2)], ...
                     size(tempFeTa(:,1),1), ...
                     []); 

    %Save the state solutions
    writematrix(stSols,fullfile(folder,fileName));           
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the simulation results for the raffinate product tanks
       
    %Get the string name for the volumetric flow rates for the raffinate
    %product tank
    fileName = 'volFlowRateRaTa.csv';

    %Save the volumetric flow rates for ith product tank
    writematrix(volFlRatRaTa,fullfile(folder,fileName));  

    %For jth component
    for j = 1 : nComs

        %Get the file name
        fileName = append('molesRaTa','Com',int2str(j),'.csv');

        %Grab the beginning/end index for the concentration 
        %variables
        ind = j; 

        %Grab gas phase concentrations of a given product tank for
        %a given component
        gasMolesRaTaCom = gasMolesRaTa(:,ind);                        

        %Save the state solutions
        writematrix(gasMolesRaTaCom,fullfile(folder,fileName));

    end

    %Get the file name
    fileName = 'tempsRaTa.csv';

    %Get the state solution data matrix for ith column
    stSols = reshape([tempRaTa(:,1);tempRaTa(:,2)], ...
                     size(tempRaTa(:,1),1), ...
                     []); 

    %Save the state solutions
    writematrix(stSols,fullfile(folder,fileName));   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the simulation results for the extrat product tanks
       
    %Get the string name for the volumetric flow rates for the extract
    %product tank
    fileName = 'volFlowRateExTa.csv';

    %Save the volumetric flow rates for ith product tank
    writematrix(volFlRatExTa,fullfile(folder,fileName));  

    %For jth component
    for j = 1 : nComs

        %Get the file name
        fileName = append('molesExTa','Com',int2str(j),'.csv');

        %Grab the beginning/end index for the concentration 
        %variables
        ind = j; 

        %Grab gas phase concentrations of a given product tank for
        %a given component
        gasMolesExTaCom = gasMolesExTa(:,ind);                        

        %Save the state solutions
        writematrix(gasMolesExTaCom,fullfile(folder,fileName));

    end

    %Get the file name
    fileName = 'tempsExTa.csv';

    %Get the state solution data matrix for ith column
    stSols = reshape([tempExTa(:,1);tempExTa(:,2)], ...
                     size(tempExTa(:,1),1), ...
                     []); 

    %Save the state solutions
    writematrix(stSols,fullfile(folder,fileName));   
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    % Save the "combined results" for the columns. We want to have for each
    % CSTR, [gas_key1, ads_key1, ..., gas_key_n_s, ads_key_n_s]
    
    %Initialize the combined matrix to store the gas phase and adsorbed
    %phase amounts of species
    molesCol = [gasMolesCol,adsMolesCol];
    
    %Calculate the total number of columns in the concentration matrix
    colNumPhase = nVols*nComs*nCols;
    
    %Initialize row vectors containing indices for the columns
    gasOrder = zeros(1,colNumPhase)  ;
    allOrder = zeros(1,2*colNumPhase); %there are 2 phases (gas and ads.)
    
    %For each column i
    for i = 1 : nCols
        
        %Calculate column shift index
        colShift = nVols*nComs*(i-1);
        
        %For each species
        for j = 1 : nComs
            
            %Get the indices
            n0 = colShift+nVols*(j-1)+1;
            nf = colShift+nVols*j      ;
            
            %Update gasOrder
            gasOrder(colShift+j:nComs:colShift+nComs*(nVols-1)+j) ...
                = linspace(n0,nf,nVols);
            
        end
        
    end
    
    %Define adsOrder (set equal to gasOrder shifted by the total number of 
    %parameters)
    adsOrder = gasOrder ...
             + colNumPhase;
    
    %Loop through each adsorption column
    for i = 1 : nCols
    
        %Compute the index for shifting the column
        colShInd = 2*nVols*nComs*(i-1);
        
        %Loop through each node and assign the column indices
        for j = 1 : nVols

            %Compute the initial indices
            n00 = colShInd+2*nComs*(j-1)+1;
            n0  = colShInd/2+nComs*(j-1)+1;         
            
            %Compute the final indices
            nff = colShInd+2*nComs*j;
            nf  = colShInd/2+nComs*j;           
                        
            %Update allOrder vector
            allOrder(n00:nff) = [gasOrder(n0:nf),adsOrder(n0:nf)];

        end
        
    end
    
    %Reorder molesCol
    molesCol = molesCol(:,allOrder);
    
    %For each adsorption column
    for i = 1 : nCols
    
        %Get the file name
        fileName = append('molesCol',int2str(i),'.csv');
        
        %Grab the initial and final indices
        n0 = 2*nVols*nComs*(i-1)+1;
        nf = 2*nVols*nComs*i      ;
        
        %Grab the associated concentrations
        molesColSave = molesCol(:,n0:nf);

        %Save the state solutions
        writematrix(molesColSave,fullfile(folder,fileName));
            
    end     
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the performance metrics results
        
    %Get product purity
    prodPur = sol.perMet.productPurity;
    
    %Save product purity      
    writematrix(prodPur,fullfile(folder,'productPurity.csv')); 
    
    %Get product recovery
    prodRec = sol.perMet.productRecovery;
    
    %Save product recovery     
    writematrix(prodRec,fullfile(folder,'productRecovery.csv')); 
    
    %Get productivity
    productivity = sol.perMet.productivity;
     
    %Save productivity     
    writematrix(productivity,fullfile(folder,'productivity.csv')); 
    
    %Get energy efficiency
    eEfficiency = sol.perMet.energyEfficiency;

    %Save energy efficiency
    writematrix(eEfficiency,fullfile(folder,'energyEfficiency.csv')); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Print out relevant statements for the user
    
    %Print a statement regarding the location where the data is saved
    fprintf('The simulation results are saved in %s \n\n',folder);    
    %---------------------------------------------------------------------%
    
end
