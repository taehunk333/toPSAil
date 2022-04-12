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
%Code last modified on : 2022/1/24/Monday
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
    pRat        = params.pRat       ;
    pRatFe      = params.pRatFe     ;  
    pRatRa      = params.pRatRa     ;
    pRatEx      = params.pRatEx     ;
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
    colTempNorm = params.colTempNorm; 
    bool        = params.bool       ;
    
    %If we have non-isothermal model,
    if bool(5) == 1
    
        raTaTempNorm = params.raTaTempNorm;
        exTaTempNorm = params.exTaTempNorm;
        feTaTempNorm = params.feTaTempNorm;
       
    %If we have isotermal model,
    elseif bool(5) == 0
        
        raTaTempNorm = colTempNorm;
        exTaTempNorm = colTempNorm;
        feTaTempNorm = colTempNorm;                    
        
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
                    
        %Saturation with a feed at a high pressure
        if iConBed(i) == 1 
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yFeC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
            
        %Saturation with a raffinate product at a high pressure
        elseif iConBed(i) == 2
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yRaC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
                   
        %Saturation with an extract product at a high pressure
        elseif iConBed(i) == 3
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [yExC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
                   
        %Saturation with a feed at a low pressure
        elseif iConBed(i) == 4
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yFeC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
                      
        %Saturation with a raffinate product at a low pressure
        elseif iConBed(i) == 5
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yRaC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
                      
        %Saturation with an extract product at a low pressure
        elseif iConBed(i) == 6
            
            %Assign corresponding dimensionless states for a single CSTR
            cstrStates = [pRat*yExC', ...
                          zeros(1,nComs), ...
                          colTempNorm, ...
                          colTempNorm];
                   
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
        feTaStates = [pRatFe*yFeC', ...
                      feTaTempNorm, ...
                      feTaTempNorm, ...
                      zeros(1,nComs)];

    %Extract pressure gas at a feed pressure
    elseif iConFeTa == 2

        %Assign corresponding dimensionless states for a feed tank
        feTaStates = [pRatFe*yExC', ...
                      feTaTempNorm, ...
                      feTaTempNorm, ...
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

    %feed gas at a high pressure
    if iConRaTa == 1 
        
        %Assign corresponding dimensionless states for a product tank
        raTaStates = [yFeC', ...
                      raTaTempNorm, ...
                      raTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Feed gas at a raffinate product pressure
    elseif iConRaTa == 2

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [pRatRa*yFeC', ...
                      raTaTempNorm, ...
                      raTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Raffinate product gas at a high pressure
    elseif iConRaTa == 3 

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [yRaC', ...
                      raTaTempNorm, ...
                      raTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Raffinate product gas a raffinate product pressure
    elseif iConRaTa == 4 

        %Assign corresponding dimensionless states for a product tank
        raTaStates = [pRatRa*yRaC', ...
                      raTaTempNorm, ...
                      raTaTempNorm, ...
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

    %Feed gas at a feed pressure
    if iConExTa == 1 
        
        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatFe*yFeC', ...
                      exTaTempNorm, ...
                      exTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Feed gas at an extract product gas pressure
    elseif iConExTa == 2

        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatEx*yFeC', ...
                      exTaTempNorm, ...
                      exTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Extract product gas at a feed pressure
    elseif iConExTa == 3 

        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatFe*yExC', ...
                      exTaTempNorm, ...
                      exTaTempNorm, ...
                      zeros(1,2*nComs)];   

    %Extract product gas at an extract product pressure
    elseif iConExTa == 4 

        %Assign corresponding dimensionless states for a product tank
        exTaStates = [pRatEx*yExC', ...
                      exTaTempNorm, ...
                      exTaTempNorm, ...
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