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
%Function   : defineMcerfSeDe.m
%Source     : common
%Description: defines the second derivative of the modified complementary 
%             error function, f(z) = 0.5*erfc(a*z), with the best fitted
%             coefficient.
%Inputs     : mcerfWt      - a scalar weight for the modified complementary
%                            error function.                          
%             axPts        - an independent variable of this non-linear 
%                            function. This is a single variable function.
%             boolean      - boolean = 1 negates the function value of 
%                            boolean = 0 which is the original modified 
%                            error function.
%Outputs    : mcerfVal     - an evaluated function output at a given value 
%                            of input x.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mcerfVal = defineMcerfSeDe(mcerfWt,axPts,boolean)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'defineMcerfSeDe.m';    
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Define the function output
    
    %For the case of calculating the second derivative of original modified
    %error function (boolean=0). For minimm and finding the lower bound.
    if boolean == 0         
        mcerfVal = ...
                  2*mcerfWt^3/sqrt(pi).*axPts.*exp(-(mcerfWt^2.*axPts.^2));    
    %For the case of second derivative of the negated modified error 
    %function (boolean=1). For maximum and finding the upper bound.
    elseif boolean == 1         
        mcerfVal = ...
                 -2*mcerfWt^3/sqrt(pi).*axPts.*exp(-(mcerfWt^2.*axPts.^2));
    end        
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%