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
%Code created on       : 2020/8/9/Sunday
%Code last modified on : 2020/8/9/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : saveParetoFrontData.m
%Source     : common
%Description: a function that receives the output data for constructing
%             a Pareto chart from previously carried out simulations and
%             save the data in terms of .csv files
%Inputs     : parmams      - a struct containing simulation data
%             perfMetrics  - a solution matrix that contains (1) moles that
%                            entered or left a given adsorpiton column
%                            during a given step, (2) duration of the
%                            steps, and (3) heavy key efficiency factors
%                            (HKEF) at the end of the steps.
%             operMode     - a boolean variable that defines an operation 
%                            policy by specifying a boolean variable as
%                            below:
%                            operMode = 1 => valve-free operation
%                            operMode = 0 => valve-based operation 
%             boolean      - a boolean variable that defines a half of a
%                            given Skarstrom type PSA cycle. The halves are
%                            operation-half and re-generation-half, where:
%                            boolean = 1 => re-generation-half
%                            boolean = 0 => operation-half
%             folder       - a string variable that contains the location 
%                            of directory that the excel file should be 
%                            saved
%Outputs    : n.a.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveParetoFrontData(params,perfMetrics,operMode,boolean,folder)
    
    %---------------------------------------------------------------------%
    %Define needed quantities
    
    %Unpack Params
    maxTiFe = params.maxTiFe;
    maxNetPrdOp = params.maxNetPrdOp;
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Make sure that there exists a place to save simulation data files
    
    %Assign the folder directory and create one if there exist none.
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Figure out which simulation data we are saving in the folder
    
    %Based on the boolean variables, we can identify which simulation data
    %we are trying to save
    if operMode == 0 && boolean == 0 %valve-based operation-half
        
        %Assign base file name
        baseFileName = 'operationValve.csv'; 
        
        %Calculate dimensionless quantities
        dimLessProductFrac = (perfMetrics(:,2)-perfMetrics(:,1)) ...
                             ./maxNetPrdOp;
        dimLessTime        = (perfMetrics(:,3)+perfMetrics(:,4)) ...
                             ./maxTiFe;
        
        %Post manipulate the simulation data
        dimLessData = [ dimLessTime, dimLessProductFrac ];
        
    elseif operMode == 0 && boolean == 1 %valve-based re-generation-half
       
        %Assign base file name
        baseFileName = 'regenerationValve.csv'; 
        
        %Calculate dimensionless quantities
        dimLessPurgeFrac = perfMetrics(:,2)./maxNetPrdOp;
        dimLessTime      = (perfMetrics(:,3)+perfMetrics(:,4)) ...
                             ./maxTiFe;
        
        %Post manipulate the simulation data
        dimLessData = [ dimLessTime, dimLessPurgeFrac ];
        
    elseif operMode == 1 && boolean == 0 %valve-free operation-half
        
        %Assign base file name
        baseFileName = 'operationValveFree.csv'; 
        
        %Calculate dimensionless quantities
        dimLessProductFrac = (perfMetrics(:,3)-perfMetrics(:,1)-perfMetrics(:,2)) ...
                             ./maxNetPrdOp;
        dimLessTime        = (perfMetrics(:,4)+perfMetrics(:,5)+perfMetrics(:,6)) ...
                             ./maxTiFe;
        
        %Post manipulate the simulation data
        dimLessData = [ dimLessTime, dimLessProductFrac ];
        
    elseif operMode == 1 && boolean == 1 %valve-free re-generation-half
        
        %Assign base file name
        baseFileName = 'regenerationValveFree.csv'; 
        
        %Calculate dimensionless quantities
        dimLessPurgeFrac = perfMetrics(:,3)./maxNetPrdOp;
        dimLessTime      = (perfMetrics(:,4)+perfMetrics(:,5)+perfMetrics(:,6)) ...
                             ./maxTiFe;
        
        %Post manipulate the simulation data
        dimLessData = [ dimLessTime, dimLessPurgeFrac ];
        
    end                    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Finalize the information about the file being saved

    %Assign full file name
    fullFileName = fullfile(folder, baseFileName);    

    %Save the simensionless data points on the Pareto chart
    writematrix(dimLessData,fullFileName)                  ;    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Print information regarding the saved data
    
    %Change to a new line
    fprintf('\n\n')                                     ;
    
    %Print out a statement
    fprintf('** The simulation results are saved in \n');
    
    %Print the location of the folder where data is saved
    disp(folder)                                        ;
    
    %Change to a new line
    fprintf('\n\n')                                     ;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%