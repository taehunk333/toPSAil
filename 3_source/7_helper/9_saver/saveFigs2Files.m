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
%Code created on       : 2022/7/12/Tuesday
%Code last modified on : 2022/10/20/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : saveFigs2Files.m
%Source     : common
%Description: This .m function saves the currently active plot into .eps
%             file format under the example folder subdirectory:
%             \5_simulation_outputs\1_figs
%Inputs     : figObj       - using the gcf.m, grab the current figure
%                            handle
%             figPath      - A string for the path to the folder where we
%                            will save the figure
%             figName      - A string designating the name of the figure
%Outputs    : a .eps file in the designated folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveFigs2Files(figObj,figPath,figName)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'saveFigs2Files.m';
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Save the figure into a .eps file

    %Get the full filename
    fileName = fullfile(figPath,figName); 

    %Export the figure as a .eps file. Make sure we are saving as a vector
    %graphic file.
    exportgraphics(figObj,fileName,'ContentType','vector');
    %---------------------------------------------------------------------%             
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%