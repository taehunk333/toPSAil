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
%Code last modified on : 2021/4/28/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcHighPresDur.m
%Source     : common
%Description: takes in the individual rate of adsorption of keys in the
%             system as a row vector input and computes the time predicted
%             to deplete all the adsorbent capacity
%Inputs     : params       - a struct containing parameters for the
%                            simulation.
%             adsRatMtz    - a vector containing rate of adsorption of 
%                            each keys within the mass transfer zone (MTZ).
%                            Naturally, the dimension of the vector is 
%                            [n_comp x 1] as a column vector.
%                            ***The unit is [mol ith adsorbate/(sec)].                        
%Outputs    : maxTiFe      - a scalar value of the normalization constant 
%                            for the duration of the high pressure feed 
%                            step as preicted from the equilibrium theroy.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maxTiFe = calcHighPresDur(params,adsRatMtz)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'calcHighPresDur.m';
    
    %Unpack Params
    maxMolAdsC = params.maxMolAdsC;      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the duration of the adsorption for all components and check
    %for any negative entries
    
    %Compute a vector containing the maximum time for feed for all
    %components
    maxTiFeC = maxMolAdsC ...
            ./ [adsRatMtz(1); ...
                sum(adsRatMtz(2:end))];
    
    %Throw out error if the vector contains a negative entry    
    if isempty(find(maxTiFeC<0,1)) == 0
        
        %Print out error and close the program when we can find a negative
        %entry in maxTiFeC. i.e. the isempty function returns false,
        %thereby saying that there is at least one negative entry in the
        %vector maxTiFeC.
        msg = 'Adsorption is happening in a wrong direction inside MTZ';
        msg = append(funcId,': ',msg);
        error(msg);        
        
    end
    %---------------------------------------------------------------------%   
    
    
        
    %---------------------------------------------------------------------%   
    %Determine the maximum duration of the feed step based on the rule to
    %be spcified: choose the slowest duration among all the durations
    %associated with heavy keys
        
    %Compute the maximum duration for the heavy key to adsorb
    maxRiFeHk = max(maxTiFeC(2:end));        
    %---------------------------------------------------------------------%   
    
    
    
    %---------------------------------------------------------------------%
    %Calculate function outputs
    
    %Compute the maximum duration of high pressure feed step as the max 
    %duration of heavy key adsorption.
    maxTiFe = maxRiFeHk;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%