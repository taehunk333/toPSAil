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
%Code created on       : 2011/2/4/Thursday
%Code last modified on : 2022/2/17/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : programProfiler.m
%Source     : common
%Description: this is a function that calls runPsaProcessSimulation.m so
%             that MATLAB's profiler can be used to optimize the program.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function programProfiler()        
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'programProfiler.m';
    %---------------------------------------------------------------------%    
    

    
    %---------------------------------------------------------------------%
    %Profile the main function
    
%     %test 1
%     name = strcat("1_kayser", ...
%                   "/1_time_driven", ...
%                   "/2-col_non-isothermal_axial_pressure_drop");

%     %test 2
%     name = strcat("1_kayser", ...
%                   "/1_time_driven", ...
%                   "/2-col_non-isothermal_no_axial_pressure_drop");
    
%     %test 3 (Windows)
%     name = strcat("1_kayser", ...
%                   "\1_time_driven", ...
%                   "\1-col_non-isothermal_no_axial_pressure_drop");
%     

%     %test 4 (Mac)
%     name = strcat("1_kayser", ...
%                   "/2_event_driven", ...
%                   "/1-col_non-isothermal_no_axial_pressure_drop");
             
%     %test 4 (Windows)
%     name = strcat("1_kayser", ...
%                   "\2_event_driven", ...
%                   "\1-col_non-isothermal_no_axial_pressure_drop");    
              
%     %test 5 (Windows)
%     name = strcat("1_kayser", ...
%                   "\2_event_driven", ...
%                   "\1-col_isothermal_no_axial_pressure_drop");

    %test 6 (Windows)
    name = strcat("1_kayser", ...
                  "\1_time_driven", ...
                  "\2-col_isothermal_no_axial_pressure_drop");
    

%     %test 6 (Mac)
%     name = strcat("1_kayser", ...
%                   "/1_time_driven", ...
%                   "/2-col_isothermal_no_axial_pressure_drop");
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the final folder name
    
    %Append the name
    name = append(name);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Profile the code
    
    %Run the PSA process simulator
    runPsaProcessSimulation(name);
    %---------------------------------------------------------------------%            
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%