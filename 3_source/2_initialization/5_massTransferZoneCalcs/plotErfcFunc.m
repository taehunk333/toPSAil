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
%Code created on       : 2020/1/14/Tuesday
%Code last modified on : 2020/12/16/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : plotErfcFunc.m
%Source     : common
%Description: plot a scaled complementary error function from 
%             z \in \left[ -1, 1\right] so that we can visualize the 
%             artifically synthesized concentration wave front. The
%             function plots the results only when there is a failure in
%             the LSQ fit.
%Inputs     : params       - a struct containing a list of input parameters
%                            to calcularte the best fitted regression 
%                            coefficients to the non-linear function of 
%                            f(z) = \frac{\alpha z}{(1+\beta z)}.                          
%Outputs    : coefValOpt   - a vector of dimsneion [1 x 2] in which the 
%                            coefficients to the non-linear equation 
%                            fitting the data generated for area under the
%                            curve of the left half of the funcsion 
%                            f(z) = 0.5*erfc(wt*z) for different values of
%                            wt which is a vector containing different 
%                            types of weights to the function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function coefValOpt = plotErfcFunc(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'plotErfcFunc.m';    
    
    %Unpack Params    
    nAxPts     = params.mtz.nAxPts    ;
    upBound    = params.mtz.upBound   ;
    loBound    = params.mtz.loBound   ;
    erfcCoef   = params.mtz.erfcCoef  ;
    logErfcWts = params.mtz.logErfcWts;
    
    %Determine the index for computing area under the curve of the left 
    %half of the curve
    areaIndLeft = (nAxPts/2); 
                                                                                    
    %Create a vector containing points for z-axis
    axPts = linspace(loBound,upBound,nAxPts);

    %Determine the length of the weight vector
    nLogErfcWts = length(logErfcWts);              
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialized solution arrays
    
    %Initialize solution matrix for the evaluated function values in axial
    %direction; number of rows = the number of different pair of error
    %function parameters, number of columns = the number of axial points to
    %evaluate the error function with a specific pair of parameters.
    evalErfcAx = zeros(nLogErfcWts,nAxPts);

    %Initialize solution vector for holding the computed area under the 
    %curve (autc); just the area under the curve for the left hand side is
    %considered.
    areaErfcLeft = zeros(nLogErfcWts,1);

    %Initialize the cell containing the text. For each "n" there is a cell
    %legendStr = cell(1,nLogErfcWts);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calcualte the modified complementary error function
        
    %Compute values for complementary error function
    for i = 1 : nLogErfcWts
        
        %Evaluate the modified complementary error function and store the
        %row in a matrix
        evalErfcAx(i,:) = erfcCoef*erfc(logErfcWts(i)*axPts);
        
        %Evaluate the area under the curve (autc) of the function        
        %Compute area under the curve of the left half
        areaErfcLeft(i) ...
            = trapz(axPts(1:areaIndLeft),evalErfcAx(i,1:areaIndLeft));  
               
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the results for area under the curve vs log(wt)
        
    %Define the non-linear function to fit the data
    nonLinFunc = @(coefVals,z) defineNlf(coefVals,z);   

    %Define the an initial guess to the function
    coefValIn = [2,2];
    
    %Let us not see any display from the optimizer
    opts = optimset('Display','off');
    
    %Determine the optimal coefficients to the non-linear function
    [coefValOpt,~,~,exitFlag] = ...
     lsqcurvefit(nonLinFunc,coefValIn,logErfcWts,areaErfcLeft',[],[],opts);          
    %---------------------------------------------------------------------%        
            
    
            
    %---------------------------------------------------------------------%
    %Plot the results for area under the curve vs log(wt) only when there 
    %is an error in the LSQ fit; Otherwise, we assume that the fit is good
    
    if exitFlag ~= 1      
        
        %Generate a vector for holding a chosen value of 100 weights
        logErfcWt100 = logspace(0,3,100);

        %Use the coefficients for the function to evaluate the log function
        areaErfcLeftLsq ...
            = coefValOpt(1) ...
            * logErfcWt100 ...
           ./ (1+coefValOpt(2) ...
              *logErfcWt100);

        %Plot the result for the area under the curve for the left half of 
        %the modified complementary error function.
        figure(1)

        %Plot the area under curve as the function of the weight
        semilogx(logErfcWts,areaErfcLeft,'o');

        %Hold onto the figure so that next curve can be plotted on the same
        %graph
        hold on
        semilogx(logErfcWt100,areaErfcLeftLsq);

        %Unhold the figure 
        hold off

        %Label the results
        xlabel('ln(wt) [=] -')                          ;
        ylabel('Area under the curve [=] -')            ;
        title('AUTC of 0.5*erfc(wt*x) vs wt')           ;
        legend('func eval','lsq','Location','SouthEast');
        
        
        %Plot the result for the modified complementary error function
        figure(2)
        
        %Compute values for complementary error function
        for i = 1 : nLogErfcWts      
            
            %Plot the result
            plot(axPts,evalErfcAx(i,:));   
            
            %Hold onto the figure so that next curve can be plotted on the
            %same graph
            hold on
            
            %Add an entry to the legend
            %legendStr{i}  = sprintf('wt = %i',logErfcWts(i))       ;
            
        end
        
        %Hold off of the figure
        hold off

        % label the results
        xlabel('x [=] -');
        ylabel('f(x) [=] -');
        title('0.5*erfc(wt*x) vs x');
        %legend(legendStr);
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check for the LSQ fit
    
    %If the exitFlags gave an error, then, the LSQ fit has failed and we
    %cannot use the determined weights to approximate an approach to the
    %equilibrium at a given threshold.
    if exitFlag ~= 1
        
        msg = 'LSQ Minimzation at a given approach to equilibrium failed';
        msg = append(funcId,': ',msg);
        error(msg);          
        
    end  
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%