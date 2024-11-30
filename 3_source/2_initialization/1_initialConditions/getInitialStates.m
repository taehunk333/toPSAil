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
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2022/12/6/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getInitialStates.m
%Source     : common
%Description: given a user specified information from params, construct an 
%             initial condition dimensionless state row vector.
%Inputs     : params       - a struct containing simulation input
%                            parameters.
%Outputs    : iCond        - a non-dimenaional state solution row vector
%                            containing initial conditions for the product
%                            tank, feed tank, adsorption column, and
%                            cumulative species flows at the boundaries.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function iCond = getInitialStates(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getInitialStates.m';
    
    %Unpack Params
    funcIso     = params.funcIso    ;    
    yFeC        = params.yFeC       ;
    yRaC        = params.yRaC       ;
    yExC        = params.yExC       ;
    nComs       = params.nComs      ;
    nLKs        = params.nLKs       ;
    pRat        = params.pRat       ;
    pRatFe0     = params.pRatFe     ; 
    pRatRa0     = params.presRaTa ...
                / params.presColHigh;                 
    pRatEx0     = params.presExTa ...
                / params.presColHigh;
    nCols       = params.nCols      ;       
    iConBed     = params.inConBed   ;
    iConFeTa    = params.inConFeTa  ;
    iConRaTa    = params.inConRaTa  ;
    iConExTa    = params.inConExTa  ;
    nStatesT    = params.nStatesT   ;  
    nColStT     = params.nColStT    ;
    nFeTaStT    = params.nFeTaStT   ;
    nRaTaStT    = params.nRaTaStT   ;  
    nExTaStT    = params.nExTaStT   ;  
    inShFeTa    = params.inShFeTa   ;
    inShRaTa    = params.inShRaTa   ;
    inShExTa    = params.inShExTa   ;
    tempColNorm = params.tempColNorm; 
    bool        = params.bool       ;
    
    %If we have non-isothermal model,
    if bool(5) == 1
    
        tempRaTaNorm = params.tempRaTaNorm;
        tempExTaNorm = params.tempExTaNorm;
        tempFeTaNorm = params.tempFeTaNorm;
       
    %If we have isotermal model,
    elseif bool(5) == 0
        
        tempRaTaNorm = tempColNorm;
        tempExTaNorm = tempColNorm;
        tempFeTaNorm = tempColNorm;                    
        
    end
    %---------------------------------------------------------------------%       
                      
    
                   
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the initial condition vector
    iCond = zeros(1,nStatesT);        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %For each column and its initial condition, obtain the corresponing
    %column states
    
    %Iterate trough the for loop for each columns
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %Determine the initial states for a single CSTR based on the user 
        %specified inputs
                    
        %Saturation with the feed at the high pressure
        if iConBed(i) == 1 
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yFeC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
            
        %Saturation with the raffinate product at the high pressure
        elseif iConBed(i) == 2
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yRaC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
                   
        %Saturation with the extract product at the high pressure
        elseif iConBed(i) == 3
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yExC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
                   
        %Saturation with the feed at the low pressure
        elseif iConBed(i) == 4
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yFeC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
                      
        %Saturation with the raffinate product at the low pressure
        elseif iConBed(i) == 5
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yRaC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
                      
        %Saturation with the extract product at the low pressure
        elseif iConBed(i) == 6
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yExC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];

        %Saturation with the feed at the feed pressure
        elseif iConBed(i) == 7 
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRatFe0*yFeC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
            
        %Saturation with the raffinate product at the feed pressure
        elseif iConBed(i) == 8
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRatFe0*yRaC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];
                   
        %Saturation with the extract product at the feed pressure
        elseif iConBed(i) == 9
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRatFe0*yExC', ...
                          0.1*ones(1,nComs), ...
                          tempColNorm, ...
                          tempColNorm];         
                   
        end        
        %-----------------------------------------------------------------%                                
        
    
    
        %-----------------------------------------------------------------%
        %Create an initial condition state vector for a single adsorption
        %column

        %Define the number of time points
        params.nRows = 1;
        
        %Calculate the adsorbed phase concentration of all species in 
        %equilibrium with the gas phase concentration of species in the C_n
        %vector by evaluating an isothem model
        cstrStates = funcIso(params,cstrStates,0);

        %Duplicate the equilibrium state over nVols volumes
        colStates = convert2InitColStates(params,cstrStates); 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Update the initial condition vector with the ith column entries
        %for the state variables
        
        %Add state variables to the initial condition vector
        iCond(nColStT*(i-1)+1:nColStT*i) = colStates;
        %-----------------------------------------------------------------%
                
    end            
    %---------------------------------------------------------------------%    
    
    
    
    %---------------------------------------------------------------------%  
    %For each feed tank and its initial condition, obtain the corresponing
    %feed tank states
    
    %Determine the initial states for Feed Tanks
    
    %Based on the user specified input, choose the initial condition

    %Feed gas at a feed pressure
    if iConFeTa == 1

        %Assign corresponding dimensionless states for a feed tank
        feTaStates = [pRatFe0*yFeC', ...
                      tempFeTaNorm, ...
                      tempFeTaNorm, ...
                      zeros(1,nComs)];

    %Extract pressure gas at a feed pressure
    elseif iConFeTa == 2

        %Assign corresponding dimensionless states for a feed tank
        feTaStates = [pRatFe0*yExC', ...
                      tempFeTaNorm, ...
                      tempFeTaNorm, ...
                      zeros(1,nComs)];
         
    end
    
    %Update the initial condition vector with the ith feed tank entries
    %for the state variables                

    %Add state variables to the initial condition vector
    iCond(inShFeTa+1:inShFeTa+nFeTaStT) = feTaStates;
    %---------------------------------------------------------------------%
     
    
    
    
    %---------------------------------------------------------------------%  
    %For each raffinate product tank and its initial condition, obtain the 
    %corresponing product tank states
    
    %Determine the initial states for raffinate product Tanks

    %Based on the user specified input, choose the initial condition

    %Raffinate product gas with no heavy keys at the high pressure
    if iConRaTa == 1 
        
        %Initialize the component vector
        yRaCNew = yRaC;
        
        %Remove the heavy keys
        yRaCNew(nLKs+1:nComs) = 0;
        
        %Rescale the mole fractions
        yRaCNew = yRaCNew./sum(yRaCNew);
        
        %Assign corresponding dimensionless states for a product tank
        raTaStates = [yRaCNew', ...
                      tempRaTaNorm, ...
                      tempRaTaNorm, ...
                      zeros(1,2*nComs)];   

    %Raffinate product gas with no heavy keys at the raffinate product
    %pressure
    elseif iConRaTa == 2
        
        %Initialize the component vector
        yRaCNew = yRaC;
        
        %Remove the heavy keys
        yRaCNew(nLKs+1:nComs) = 0;
        
        %Rescale the mole fractions
        yRaCNew = yRaCNew./sum(yRaCNew);

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [pRatRa0*yRaCNew', ...
                      tempRaTaNorm, ...
                      tempRaTaNorm, ...
                      zeros(1,2*nComs)];   

    %Raffinate product gas at a high pressure
    elseif iConRaTa == 3 

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [yRaC', ...
                      tempRaTaNorm, ...
                      tempRaTaNorm, ...
                      zeros(1,2*nComs)];   

    %Raffinate product gas a raffinate product pressure
    elseif iConRaTa == 4 

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [pRatRa0*yRaC', ...
                      tempRaTaNorm, ...
                      tempRaTaNorm, ...
                      zeros(1,2*nComs)];    

    end        

    %Update the initial condition vector with the ith product tank 
    %entries for the state variables                

    %Add state variables to the initial condition vector
    iCond(inShRaTa+1:inShRaTa+nRaTaStT) = raTaStates;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%  
    %For each extract product tank and its initial condition, obtain the 
    %corresponing product tank states
    
    %Determine the initial states for extract product Tanks

    %Based on the user specified input, choose the initial condition

    %Extract product gas with no light key at the feed product pressure
    if iConExTa == 1 
        
        %Initialize the component vector
        yExCNew = yExC;
        
        %Remove the light keys
        yExCNew(1:nLKs) = 0;
        
        %Rescale the mole fractions
        yExCNew = yExCNew./sum(yExCNew);
        
        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatFe0*yExCNew', ...
                      tempExTaNorm, ...
                      tempExTaNorm, ...
                      zeros(1,2*nComs)];   

    %Extract product gas with no light key at the extract product pressure
    elseif iConExTa == 2
        
        %Initialize the component vector
        yExCNew = yExC;
        
        %Remove the light keys
        yExCNew(1:nLKs) = 0;
        
        %Rescale the mole fractions
        yExCNew = yExCNew./sum(yExCNew);
        
        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatEx0*yExCNew', ...
                      tempExTaNorm, ...
                      tempExTaNorm, ...
                      zeros(1,2*nComs)];   

    %Extract product gas at a feed pressure
    elseif iConExTa == 3 

        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatFe0*yExC', ...
                      tempExTaNorm, ...
                      tempExTaNorm, ...
                      zeros(1,2*nComs)];   

    %Extract product gas at an extract product pressure
    elseif iConExTa == 4 

        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatEx0*yExC', ...
                      tempExTaNorm, ...
                      tempExTaNorm, ...
                      zeros(1,2*nComs)];     

    end        

    %Update the initial condition vector with the ith product tank 
    %entries for the state variables                

    %Add state variables to the initial condition vector
    iCond(inShExTa+1:inShExTa+nExTaStT) = exTaStates;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------% 
    %Initialization of the rest of the auxiliary units
    
    %The initial condition for the compresor(s) and the pump(s) is left as
    %zeros from the initialization of the initial state vector   
    %---------------------------------------------------------------------% 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%