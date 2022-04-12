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
%Code created on       : 2020/1/21/Tuesday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getMtzParams.m
%Source     : common
%Description: outputs a struct to hold global variables for computing
%             associated calculations for determining the time 
%             normalization constant for the Pareto optimality front chart.
%Inputs     : n.a.
%Outputs    : mtz   - a struct containing globally defined variables
%                            that can be used to carry out associated 
%                            calculations for determining the time
%                            normalization constant.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mtz = getMtzParams() 

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getMtzParams.m';
    %---------------------------------------------------------------------%
            
        
    
    %---------------------------------------------------------------------%
    %Specify information on the modified error function
    
    %Specify a coefficient, c, for the modified error function 
    %i.e. f(z) = c*erfc(a*z)
    mtz.erfcCoef = 0.5;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify information about plotting the modified error function over an
    %interval of choice
    
    %Input variables for plotting and computing coefficients for the best 
    %fit function
    mtz.nAxPts  = 1000;
    mtz.upBound = 0.5 ; 
    mtz.loBound = -0.5;    
    
    %Specify the number of data points where a non-linear function would be
    %fitted to
    mtz.erfcWts = 25;
    
    %Define a vector or logarithmically spaced entries 
    mtz.logErfcWts = logspace(0,3,mtz.erfcWts);

    %Define the lower bound and the upper bound for the dimensionless
    %column height centered at z=0
    mtz.axSpan = [mtz.loBound,mtz.upBound];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define an approach to the equilibrium
    
    %Specify an approach to Equilibrium; i.e. percentage to the equilibrium        
    mtz.areaThres = 0.995;    
    %massTrZone.areaThres = 0.993769675;    
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%