%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Base Case Simulation
% Purpose: 
%	- to validate toPSAil's simulation capabilities against	the 
%         most challenging (numerically) simulation problem for an 
%	  equilibrium PSA process system.
% Case Studies:
% 	- case_study_1.0: 2-adsorber, isothermal, flow-controlled, 
%		          time-driven, O2-N2-Zeolite_5A.
%			  linear isotherm, LDF kinetics,
%			  Reference: Kayser (1986)
% 	- case_study_1.1: 2-adsorber, isothermal, pressure-driven 
%	  		  (Kozeny-Carman), time-driven 
%			  linear isotherm, LDF kinetics,
%	 		  O2-N2-Zeolite_5A
%	- case_study_1.2: 2-adsorber, nonisothermal, pressure-driven
%			  (Kozeny-Carman), time-driven
%			  linear isotherm, LDF kinetics,
%	 		  O2-N2-Zeolite_5A
%	- case_study_1.3: 1-adsorber, nonisothermal, pressure-driven
%			  (Kozeny-Carman), time-driven,
%			  linear isotherm, LDF kinetics,
%	 		  O2-N2-Zeolite_5A
% Plots:
% 	- Pressure profiles (vs. time) for the two adsorption columns
%	- Adsorbed phase concentration of the 1st adsorber at the last
%	  high pressure feed step, before reaching a CSS
% 	- A comparison of the gas phase concentration profiles in the
% 	  1st adsorber, as a function of the number of CSTRs (n_c)
% Data: 
%	- Data for the CPU times/cycle (4 PSA cycle simulations and 
%	  take the average over 10 PSA cycles), Oxygen recovery %, and
% 	  Oxygen purity for the different simulations of Kayser's 
%	  system over different n_c values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single Adsorber Simulation I
% Purpose:
%	- to compare the isothermal vs. nonisothermal adsorbed phase 
%	  concentration profiles, as well as events vs. no events
% 	- to demonstrate an acceleration to a CSS, using the event 
% 	  functions and flow-driven vs. pressure-driven 
% Case Studies:
% 	- case_study_2.0: 1-adsorber, nonisothermal, pressure-driven
%			  (Kozeny-Carman), time-driven, 
%			  multisite Langmuir isotherm, LDF kinetics,
%		  	  CH4-N2-CO2-Zeolite_13X
% 	- case_study_2.1: 1-adsorber, nonisothermal, flow-controlled,
%			  multisite Langmuir isotherm, LDF kinetics,
%			  time-driven, CH4-N2-CO2-Zeolite_13X
% 	- case_study_2.2: 1-adsorber, isothermal, pressure-driven
%			  (Kozeny-Carman), time-driven, 
%			  multisite Langmuir isotherm, LDF kinetics,
%		  	  CH4-N2-CO2-Zeolite_13X
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single Adsorber Simulation II
% Purpose:
%	- to compare the isothermal vs. nonisothermal adsorbed phase 
%	  concentration profiles, as well as events vs. no events
% 	- to demonstrate an acceleration to a CSS, using the event 
% 	  functions and flow-driven vs. pressure-driven 
% Case Studies:
% 	- case_study_4.1: case_study_1.0 with 1 adsorber.
%			  Reference: Kayser (1986)
% 	- case_study_4.2: case_study_2.1 with the event-driven mode.
%			  Reference: Kayser (1986)
% 	- case_study_4.3: case_study_2.1 with nonisothermal operation.
%			  Reference: Kayser (1986)
%	- case_study_4.4: case_study_2.3 with the event-driven mode.
% 			  Reference: Kayser (1986)
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TITLE
% Purpose:
% 	- TBD
% Case Studies:
% 	- TBD
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TITLE
% Purpose:
% 	- TBD
% Case Studies:
% 	- TBD
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TITLE
% Purpose:
% 	- TBD
% Case Studies:
% 	- TBD
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%