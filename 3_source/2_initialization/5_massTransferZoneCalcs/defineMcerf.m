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
%Code last modified on : 2020/12/16/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : defineMcerf.m
%Source     : common
%Description: defines the modified complementary error function with the 
%             best fitted coefficient for weight. The function is defined
%             as the following: f(z) = 0.5*erfc(a*z), where a is the best
%             fitted coefficient for weight.             
%Inputs     : mcerfWt      - a scalar weight for the modified complementary
%                            error function.                          
%             mcerfWt      - an independent variable of this non-linear 
%                            function. This is a single variable function.
%             boolean      - boolean = 1 negates the function value of 
%                            boolean = 0 which is the original modified 
%                            error function.
%Outputs    : mcerfVal     - an evaluated function output at a given value 
%                            of input z.                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mcerfVal = defineMcerf(mcerfWt,axPts,boolean)
    
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    FuncID = 'defineMcerf';
    %---------------------------------------------------------------------%    
    
    

    %---------------------------------------------------------------------%
    %Define the modified error function f(z) = 0.5*erfc(a*z) 
        
    %For the case of the original modified error function (boolean = 0)
    %For finding the minimm and finding the lower bound
    if boolean == 0 
        
        mcerfVal = 0.5*erfc(mcerfWt.*axPts) ;
        
    %For the case of the negated modified error function (boolean = 1)
    %For maximum and finding the upper bound
    elseif boolean == 1 
        
        mcerfVal = -0.5*erfc(mcerfWt.*axPts);
        
    end       
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%