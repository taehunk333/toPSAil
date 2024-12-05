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
%Function   : calcMcerfWt.m
%Source     : common
%Description: calculates the weight for the modified complementary error 
%             function based on the determined coefficients for the line of
%             the best fit to the area under the curve vs ln(a) plot.
%Inputs     : coefValOpt   - a row vector containing the two coefficients 
%                            for the Langmuir type non-linear function, 
%                            namely $\alpha$ and $\beta$.                        
%             areaThres    - a decimal number in \left[ 0, 1 \right]
%                            to indicate the approach to the equilibrium by
%                            denoting area under the curve.
%Outputs    : mcerfWt      - a scalar weighting factor for the modified 
%                            complementary error function.                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mcerfWt = calcMcerfWt(coefValOpt,areaThres)

    %---------------------------------------------------------------------%
    %Define needed quantities
    
    %Name the function ID
    %funcId = 'calcMcerfWt';
    
    %Unpack vec_wt_coeff vector 
    alpha = coefValOpt(1);
    beta  = coefValOpt(2);
    
    %Define the threshold for area under the curve
    gamma = areaThres;     
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the function output
    
    %Calculate the weighting factor
    mcerfWt  = gamma ...
             / (2*alpha ...
               -beta*gamma);
    %---------------------------------------------------------------------%    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%