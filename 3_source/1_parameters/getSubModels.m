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
%Code created on       : 2021/1/2/Saturday
%Code last modified on : 2023/2/24/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getSubModels.m
%Source     : common
%Description: a function MATLAB function file in which sub-models for the
%             simulator are flobally defined
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : models       - a cell array containing function handles for
%                            the models.
%             subModels    - a cell array containing function handles for
%                            the sub-models.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [models,subModels] = getSubModels(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getSubModels.m';
    
    %Unpack params
    modSp = params.modSp;
    bool  = params.bool ;
    
    %Get the number of models needed
    modNum = length(modSp);
    %---------------------------------------------------------------------%        
    
    
    
    %---------------------------------------------------------------------%        
    %Initialize solution arrays
    
    %Initialize the array for containing the model functions
    models = cell(modNum,1);   
    
    %Initialize the array for containing the sub-model functions
    subModels = cell(modNum,1);
    %---------------------------------------------------------------------%        
    
    
    
    %---------------------------------------------------------------------%
    %Define functions for the sub-models used in the simulator.
    
    %Specify adsorption isotherm model number
    modNo1 = 1;
    
    %Based on the user specification, globally define an isotherm function
    
    %A custom (explicit) isotherm
    if modSp(modNo1) == 0 
        
        %models{modNo1} = 0;
        
        %Model under development
        noteModelNotReady(modNo1);
        
    %Linear (decoupled) isotherm
    elseif modSp(modNo1) == 1 && bool(7) == 0
        
        %Define the isotherm
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermLinear(params,states,nAds);
                                         
    %Extended Langmuir isotherm
    elseif modSp(modNo1) == 2 && bool(7) == 0 
        
        %Define the isotherm
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermExtLang(params,states,nAds);
                   
    %Multisite Langmuir isotherm
    elseif modSp(modNo1) == 3 
                
        %Define the isotherm
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermMultiSiteLang(params,states,nAds);
    
    %Extended Langmuir-Freundlich isotherm    
    elseif modSp(modNo1) == 4
        
        %Define the isotherm
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermExtLangFreu(params,states,nAds);
    
    %"Decoupled" dual-site Langmuir-Freundlich isotherm    
    elseif modSp(modNo1) == 5
        
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermDecDuSiLangFreu(params,states,nAds);
    
    %"Extended" dual-site Langmuir-Freundlich isotherm 
    elseif modSp(modNo1) == 6
        
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermExtDuSiLangFreu(params,states,nAds);
    
    %Toth isotherm
    elseif modSp(modNo1) == 7
        
        models{modNo1} = @(params,states,nAds) ...
                         calcIsothermToth(params,states,nAds);
        
        %Model under development
        % noteModelNotReady(modNo1);
    
    %TBD
    elseif modSp(modNo1) == 8
        
        %models{modNo1} = 0;
        
        %Model under development
        noteModelNotReady(modNo1);
    
    %TBD
    elseif modSp(modNo1) == 9
        
        %models{modNo1} = 0;
        
        %Model under development
        noteModelNotReady(modNo1);
    
    %If no adsoption isotherm model was selected...
    else 
        
        %Print the error message
        msg = 'No isotherm model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify adsorption rate model
    
    %Specify adsorption rate model number
    modNo2 = 2;
    
    %Based on the user specification, globally define a rate function
    
    %Custom rate model
    if modSp(modNo2) == 0 
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
        
    %Linear driving force (LDF) adsorption rate law
    elseif modSp(modNo2) == 1 && bool(8) == 0
        
        %Define the rate expression
        models{modNo2} = @(params,states,nC) ...
                         calcAdsRateLdf(params,states,nC);
                        
    %TBD
    elseif modSp(modNo2) == 2 && bool(8) == 0
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
        
    %TBD
    elseif modSp(modNo2) == 3 %TBD
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
        
    %TBD
    elseif modSp(modNo2) == 4 
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
    
    %TBD
    elseif modSp(modNo2) == 5
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
    
    %TBD
    elseif modSp(modNo2) == 6
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
    
    %TBD
    elseif modSp(modNo2) == 7
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
    
    %TBD
    elseif modSp(modNo2) == 8
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
    
    %TBD
    elseif modSp(modNo2) == 9
        
        %models{modNo2} = 0;
        
        %Model under development
        noteModelNotReady(modNo2);
     
    %If no adsorption rate model is selected...
    else
        
        %Print the error message
        msg = 'No rate model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end         
    %---------------------------------------------------------------------%
    
           
    
    %---------------------------------------------------------------------%
    %Specify equation of states
    
    %Specify equation of states model number
    modNo3 = 3;
    
    %Based on the user specification, globally define an equation of states
    
    %Custom EOS
    if modSp(modNo3) == 0 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
        
    %Ideal gas law
    elseif modSp(modNo3) == 1 && bool(6) == 0
        
        %Define the EOS
        models{modNo3} ...
            = @(params,P,V,T,n) calcEosIdealGas(params,P,V,T,n);
                     
    %TBD
    elseif modSp(modNo3) == 2 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
        
    %TBD
    elseif modSp(modNo3) == 3 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
    
    %TBD
    elseif modSp(modNo3) == 4 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
    
    %TBD
    elseif modSp(modNo3) == 5 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
        
    %TBD
    elseif modSp(modNo3) == 6 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
    
    %TBD
    elseif modSp(modNo3) == 7 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
      
    %TBD
    elseif modSp(modNo3) == 8 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
    
    %TBD
    elseif modSp(modNo3) == 9 && bool(6) == 1
        
        %models{modNo3} = 0;
        
        %Model under development
        noteModelNotReady(modNo3);
     
    %If no equation of state was selected...
    else
        
        %Print out the error message
        msg = 'No equation of state was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify a valve model
    
    %Specify a valve model number
    modNo4 = 4;
    
    %Based on the user specification, globally define the valve model
    
    %Define a custom valve model
    if modSp(modNo4) == 0
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %Linear valve model        
    elseif modSp(modNo4) == 1 %a linear valve
        
        %Define the linear valve model
        models{modNo4} = @(valCoeff,c1,c2,T1,T2) ...
                         calcLinValveMolFlow(valCoeff,c1,c2,T1,T2);
     
    %TBD
    elseif modSp(modNo4) == 2
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD    
    elseif modSp(modNo4) == 3
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 4
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 5

        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 6
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 7
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 8
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %TBD
    elseif modSp(modNo4) == 9
        
        %models{modNo4} = 0;
        
        %Model under development
        noteModelNotReady(modNo4);
        
    %If no valve model is selected...
    else 
        
        %Print the error message
        msg = 'No valve model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end              
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%
    %Specify a heat capacity model
    
    %Specify a heat capacity model number
    modNo5 = 5;
    
    %Based on the user specification, globally define a model for heat
    %capacity
    
    %A constant heat capacity model
    if modSp(modNo5) == 0 && bool(5) == 1 
        
        models{modNo5} = @(htCapParamsC,temps) ...
                         calcHtCapConst(htCapParamsC,temps);
                                   
    %TBD
    elseif modSp(modNo5) == 1 && bool(5) == 1 
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
    
    %TBD
    elseif modSp(modNo5) == 2 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 3 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 4 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 5 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 6 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 7 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 8 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %TBD
    elseif modSp(modNo5) == 9 && bool(5) == 1
        
        %models{modNo5} = 0;
        
        %Model under development
        noteModelNotReady(modNo5);
        
    %If we have an isothermal operation,
    elseif bool(5) == 0
        
        %No heat capacity model is needed
        models{5} = [];
            
    else 
        
        %Print the error message
        msg = 'No heat capacity model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end              
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Specify a momentum balance model
    
    %Specify a momentum balance model number
    modNo6 = 6;
    
    %Based on the user specification, globally define a model for
    %calculating the volumteric flow rate associated with the CIS model
    
    %No axial pressure drop and isothermal
    if modSp(modNo6) == 0 && ... %No axial pressure drop
             bool(3) == 0 && ... %No axial pressure drop
             bool(5) == 0        %Isothermal
        
        %Define the function for calculating the volumetric flow rates
        models{modNo6} ...
            = @(params,units,nS) calcVolFlowsDP0DT0(params,units,nS); 
        
        %Define submodels for the calculating the unit volumetric flow
        %rates
        subModels{modNo6} ...
            = @(params,units,nS) ...
              calcVolFlows4UnitsFlowCtrlDT0(params,units,nS);
      
    %No axial pressure drop and non-isothermal                 
    elseif modSp(modNo6) == 0 && ... %No axial pressure drop
                 bool(3) == 0 && ... %No axial pressure drop
                 bool(5) == 1        %Non-isothermal
        
        %Define the function for calculating the volumetric flow rates
        models{modNo6} ...
            = @(params,units,nS) calcVolFlowsDP0DT1(params,units,nS); 
        
        %Define submodels for the calculating the unit volumetric flow
        %rates
        subModels{modNo6} ...
            = @(params,units,nS) ...
              calcVolFlows4UnitsFlowCtrlDT1(params,units,nS);
                              
    %Carman-Kozeny equation discretized momentum balance
    elseif modSp(modNo6) == 1 && ... %linear axial pressure drop
                 bool(3) == 1  %axial pressure drop
              
        %Define the function for calculating the volumetric flow rates
        models{modNo6} ...
            = @(params,units,nS) calcVolFlowsDP1KC(params,units,nS);  
        
        %Define submodels for the calculating the unit volumetric flow
        %rates
        subModels{modNo6} ...
            = @(params,units,nS) ...
              calcVolFlows4UnitsPresDriv(params,units,nS);
        
    %Ergun's equation discretized momentum balance
    elseif modSp(modNo6) == 2 && ... %quadratic axial pressure drop
                 bool(3) == 1  %axial pressure drop
        
        %Define the function for calculating the volumetric flow rates
        models{modNo6} ...
            = @(params,units,nS) calcVolFlowsDP1ER(params,units,nS);
        
        %Define submodels for the calculating the unit volumetric flow
        %rates
        subModels{modNo6} ...
            = @(params,units,nS) ...
              calcVolFlows4UnitsPresDriv(params,units,nS);
        
    elseif modSp(modNo6) == 3 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 4 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 5 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 6 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 7 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 8 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    elseif modSp(modNo6) == 9 && bool(3) == 1 %TBD
        %models{modNo6} = 0;
        
        %Model under development
        noteModelNotReady(modNo6);
        
    else 
        
        %Print out the error message
        msg = 'No volumetric flow rate model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end              
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%
    %Specify a CSS convergence model
    
    %Specify a CSS convergence model number
    modNo7 = 7;
    
    %Based on the user specification, globally define a model for
    %determining the cyclic steady state (CSS)
    
    %CSS based on the overall states
    if modSp(modNo7) == 0 
        
        %Define the function
        models{modNo7} ...
            = @(params,initCondCurr,initCondPrev) ...
              calcCssConvOverall(params,initCondCurr,initCondPrev);
    
    %CSS besed on the first column states              
    elseif modSp(modNo7) == 1 
        
        %Define the function
        models{modNo7} ...
            = @(params,initCondCurr,initCondPrev) ...
              calcCssConvFirstCol(params,initCondCurr,initCondPrev);
   
    %CSS based on multiple column states             
    elseif modSp(modNo7) == 2 
        
        %Define the function
        models{modNo7} ...
            = @(params,initCondCurr,initCondPrev) ...
              calcCssConvAllCols(params,initCondCurr,initCondPrev);
        
    %CSS based on product tank states
    elseif modSp(modNo7) == 3 
        
        %Define the function
        models{modNo7} ...
            = @(params,initCondCurr,initCondPrev) ...
              calcCssConvFirstRaTa(params,initCondCurr,initCondPrev);
        
    %TBD
    elseif modSp(modNo7) == 4 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
        
    %TBD
    elseif modSp(modNo7) == 5 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
       
    %TBD
    elseif modSp(modNo7) == 6 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
        
    %TBD
    elseif modSp(modNo7) == 7 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
        
    %TBD
    elseif modSp(modNo7) == 8 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
        
    %TBD
    elseif modSp(modNo7) == 9 
        
        %models{modNo7} = 0;
        
        %Model under development
        noteModelNotReady(modNo7);
        
    %If no CSS model is selected...
    else 
        
        %Print the error message
        msg = 'No CSS convergence model was selected.';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end              
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%