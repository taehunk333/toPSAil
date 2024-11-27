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
%Code created on       : 2021/1/17/Sunday
%Code last modified on : 2022/2/26/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : makeRaffTank.m
%Source     : common
%Description: given an overall state vector or matrix, constructs a product
%             tank object with associated properties by returning a struct.
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution vector or
%                            matrix containing all the state variables
%Outputs    : raTa         - a nested structure containing all the product
%                            tank properties such as gas concentrations,
%                            tank temperature, and wall temperature.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function raTa = makeRaffTank(params,states)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'makeRaffTank.m';
    
    %Unpack params     
    nComs    = params.nComs   ;
    sComNums = params.sComNums;
    nR       = params.nRows   ;
    bool     = params.bool    ;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each product tanks    
        
    %---------------------------------------------------------------------%
    %Save the state variables associated with the product tank(s)

    %Fetch the gas phase concentrations as a struct
    raTa.n1.gasCons = convert2RaTaGasConc(params,states,1);        

    %Fetch the temperatures as a struct
    raTa.n1.temps = convert2RaTaTemps(params,states,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize soltion arrays
    
    %A numeric array for feed tank total concentrations 
    raTa.n1.gasConsTot = zeros(nR,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Save the results to the struct. For each species,
    for j = 1 : nComs

        %Assign the value of the total concentrations into a struct
        raTa.n1.gasConsTot = raTa.n1.gasConsTot ...
                           + raTa.n1.gasCons.(sComNums{j});

    end                 
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%    
    %Calculate overall heat capacities for the product tank and store the 
    %results inside a struct called htCapOv

    %Only when non-isothermal
    if bool(5) == 1
        
        %Unpack additional params
        htCapCvNorm   = params.htCapCvNorm  ;
        gConsNormRaTa = params.gConsNormRaTa;
        raTaVolNorm   = params.raTaVolNorm  ;
    
        %Initialize the overall heat capacity
        htCO0 = 0;

        %For each species, j,
        for j = 1 : nComs
            
            %Sum jth species contributions to the overall heat capacity
            %from gas phase
            htCO0 ...
                = htCO0 ...
                + htCapCvNorm(j) ...
               .* raTa.n1.gasCons.(sComNums{j});
           
        end
        
        %Save the overall heat capacity to a struct 
        raTa.n1.htCO = (gConsNormRaTa*raTaVolNorm) ...
                     * htCO0;
        
    %If isothermal,
    else
        
        %Then, assign the zeros
        raTa.n1.htCO = 0;
        
    end
    %---------------------------------------------------------------------%  
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%