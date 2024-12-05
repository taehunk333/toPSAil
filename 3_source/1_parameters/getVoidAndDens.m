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
%Function   : getVoidAndDens.m
%Source     : common
%Description: given a rate controlling mechanism, determine the definitions
%             of the void fraction and the density to be used for a
%             material balance. We will use params.overFrac for the overall
%             void fraction for the material balance
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getVoidAndDens(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getVoidAndDens.m';
    
    %Unpack params
    maTrRes     = params.maTrRes      ;    
    voidFracBed = params.voidFracBed  ;
    %---------------------------------------------------------------------%                                                          
    
    
        
    %---------------------------------------------------------------------%                                                          
    %Depending on the controlling resistance, define the overall Density
    %and the overall Void Fraction to be used for material balance
    
    %If adsorbent pellet skin resistance (i.e., the boundary layer) is 
    %controlling
    if maTrRes == 0
        
        %Define overall void fraction (ignore the boundary layer volume)
        params.overVoid = voidFracBed;
        
    %If the controlling resistance is of the macropore,     
    elseif maTrRes == 1
        
        %Define overall void fraction (consider macropore as an adsorbed 
        %phase)
        params.overVoid = voidFracBed;
        
    %If the controlling resistance is of the micropore,  
    elseif maTrRes == 2
        
        %Unpack params
        voidFracMac = params.voidFracMac;
        
        %Define overall void fraction (consider micropore as an adsorbed
        %phase)
        params.overVoid = voidFracBed + (1-voidFracBed)*voidFracMac;
        
    %If the controlling resistance is of the physisorption,  
    elseif maTrRes == 3
       
        %Unpack parameters
        voidFracMac = params.voidFracMac;
        voidFracMic = params.voidFracMic;
        
        %Define parameters
        voidFracPell = voidFracMac + voidFracMic;

        %Save the definied parameters into the struct
        params.voidFracPell = voidFracPell;
        
        %Define overall void fraction (the only adsorbed phase is the
        %adsorbates on the adsorbent)
        params.overVoid = voidFracBed + (1-voidFracBed)*voidFracPell;
        
    end
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%