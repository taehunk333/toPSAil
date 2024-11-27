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
%Code last modified on : 2020/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcMtzTheory.m
%Source     : common
%Description: determines the thickness of the mass transfer zone (MTZ)
%             given and approach to the equilibrium, approximates the rate
%             of adsorption inside the MTZ, and computes the normalization
%             time for the high pressure feed assuming an operation near
%             the equilibrium limit.
%             Note that this function can be used with any given approach
%             to the equilibrium, i.e. different areaThres values can be
%             used.
%Inputs     : params       - a struct containing parameters for the
%                            simulation.
%             areaThres    - an approach to the equilibrium, specified by
%                            the threshold on the left half of the modified
%                            complementary error function:
%                                                      f(z) = 0.5*erfc(az).
%Outputs    : maxTiFe      - a scalar value of the normalization constant 
%                            for the duration of the high pressure feed as 
%                            preicted from the equilibrium theroy.                       
%             adsRatMtz    - a vector containing rate of adsorption of 
%                            each keys within the mass transfer zone (MTZ).
%                            Naturally, the dimension of the vector is 
%                            [n_comp x 1] as a column vector.
%                            The vector contains the entries in the 
%                            following sequence:
%                            [HK1;HK2;...;HK_{n_HK};LK1;LK2;...;LK_{n_Lk}]
%                            where n_{HK} is the number of heavy keys, 
%                            n_{LK} is the number of light keys and 
%                            n_HK+n_LK = n_comp.
%                            ***The unit is ...
%                               [mol ith adsorbate/(kg adsorbent-sec)].  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [maxTiFe,adsRatMtz] = calcMtzTheory(params,areaThres)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'calcMtzTheory.m';
    
    %Unpack Params
    axSpan   = params.mtz.axSpan;    
    nTimePts = params.nTiPts    ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Given an approach to the equilibrium, find the weighting coefficient
    
    %Compute the coefficient for the non-linear fit function to the area 
    %under the curve vs ln(a) plot.
    coefValOpt = plotErfcFunc(params);

    %Calculate the weighting coefficient for the modified complementary
    %error function
    mcerfWt = calcMcerfWt(coefValOpt,areaThres);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Perform the second derivative test on the modified complementary error
    %function
    
    %Define the second derivative of the modified complementary error 
    %function for both min and max cases.
    mcerfMin = @(axPts) defineMcerfSeDe(mcerfWt,axPts,0);
    mcerfMax = @(axPts) defineMcerfSeDe(mcerfWt,axPts,1);
    
    %Find the extrema of the second derivative of the modified error 
    %function to identify the lower bound and the upper bound of the moving 
    %concentration wave front 
    [loBoundIn,upBoundIn] = findExtrema(mcerfMin,mcerfMax,axSpan);   
    %---------------------------------------------------------------------%            
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the thickness of the mass transfer zone given an approach to
    %the equilibrium
    
    %Compute the initially estimated length of the mass transfer zone (MTZ)
    mtzThickIn = (upBoundIn-loBoundIn); % flp_length_MTZ

    %Compute the refined length of the MTZ with its refined bounds
    mtzThick  = 3*mtzThickIn        ;
    loBoundFi = loBoundIn-mtzThickIn;
    upBoundFi = upBoundIn+mtzThickIn;

    %Define a vector in which the upper bound and the lower bound is stored
    mtzBounds = [loBoundFi,upBoundFi];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check to see if the bounds were calculated correctly
    
    %Test to see if the lower bound is indeed less than equal to the upper
    %bound; Also check to see if the bounds are bounded inside [-0.5,0.5]
    if loBoundFi <= upBoundFi && -0.5 <= loBoundFi && loBoundFi <= 0.5 ...
       && -0.5 <= upBoundFi && upBoundFi <= 0.5
   
        testResult = false; %We have the right bounds
        
    else
        
        testResult = true; %We do not have the right bounds
        
    end        
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Plot the modified error function and the mass transfer zone. Note that
    %only when we do not have valid bounds, we go ahead and plot the
    %results.
    
    %When the test results shows that the bounds are incorrect, plot the
    %result to visualize the problem
    if testResult == 1
        
        %Generate vector for holding a chosen value of time points
        axPts = linspace(-0.5,0.5,nTimePts);
        
        %Evaluate the modified error function at the specified time points
        mcerfVal = defineMcerf(mcerfWt,axPts,0);
        
        % Check the length of the MTZ visually
        figure(3)
        plot(axPts,mcerfVal) 
        xline(loBoundIn)
        xline(upBoundIn)
        xline(loBoundFi)
        xline(upBoundFi)
        
        % Label the plot
        title('UB and LB of MTZ')
        xlabel('x [=] -')
        ylabel('f(x) = 0.5*erfc(ax) [=] -')  
        
    end
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %For the case where a correct bound is not obtained, the program should
    %terminate
    
    %If we cannot get a proper bound on the MTZ, then the program cannot
    %continue.
    if testResult == 1
        
        msg = 'The algorithm failed to estmiate the MTZ thickness.';
        msg = append(funcId,': ',msg)                              ;
        error(msg)                                                 ;         
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate function outputs
    
    %Approximate the reaction rate in the MTZ
    adsRatMtz = calcAdsRatMtz(params,mtzThick,mcerfWt,mtzBounds);

    %Compute the normalization constant for the time axis. i.e. the total
    %time for the high pressure feed step under the equilibrium condition.
    maxTiFe = calcHighPresDur(params,adsRatMtz);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%