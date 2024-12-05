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
%Function   : getTotalGasConc.m
%Source     : common
%Description: a function that calculates total gas phase concentration and
%             total adsorbed phase concentation at a feed composition at a
%             high pressure inside an adsorption column.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : gasConT      - a total gas phase concentration at a high
%                            pressure feed composition and pressure
%             params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getTotalGasConc(params)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getTotalGasConc.m';
    
    %Unpack params
    presColHigh = params.presColHigh;
    cstrVoidVol = params.cstrVoidVol;
    tempCol     = params.tempCol    ;
    funcEos     = params.funcEos    ;
    %---------------------------------------------------------------------%    
    
    
                         
    %---------------------------------------------------------------------%                           
    %Compute dimensional total gas phase concentration and total adsorbed 
    %phase concentration
            
    %Compute state variables at a high pressure feed condition using ideal 
    %gas law in a single CSTR (n=0 means solve for n)
    [~,voidVol,~,voidMol] ...
        = funcEos(params,presColHigh,cstrVoidVol,tempCol,0);
    
    %Define the total concentration of high pressure feed
    params.gasConT = voidMol/voidVol;           
    %---------------------------------------------------------------------%              
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%