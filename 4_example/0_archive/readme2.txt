%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Base Case Simulation
% Purpose: 
%	- to validate toPSAil's simulation capabilities against	the 
%         most challenging (numerically) simulation problem for an 
%	  equilibrium PSA process.
% Reference: 
%	- Kayser, J.C., Knaebel, K.S., 1986. Pressure Swing 
%	  Adsorption - Experimental Study of an Equilibrium Theory. 
%	  Chemical Engineering Science, 41, 2931–2938.
% Case Studies:
%	- case_study_1.4.x: 
%		1-adsorber, isothermal, pressure-driven 
%		(Kozeny-Carman), time-driven, linear isotherm, LDF 
%		kinetics, O2-N2-Zeolite_5A, two single high pressure 
%	 	steps
%	- case_study_1.5.x: 
%		1-adsorber, isothermal, pressure-driven 
%		(Kozeny-Carman), time-driven, linear isotherm, LDF 
%		kinetics, O2-N2-Zeolite_5A, a single co-current
%		repressurization with the raffinate product, followed 
%		by a single high pressure feed, saturation with the 
%		raffinate product at the low pressure
%	- case_study_1.6.x: 
%		1-adsorber, isothermal, pressure-driven
%	        (Kozeny-Carman), time-driven, linear isotherm, LDF 
%		kinetics, O2-N2-Zeolite_5A, a single co-current 
%		repressurization with the feed, followed by a single
%		high pressure feed, saturation with the raffinate 
%		product at the low pressure
%	- case_study_1.7.x: 
%		1-adsorber, isothermal, pressure-driven
%		(Kozeny-Carman), time-driven, linear isotherm, LDF 
%		kinetics, O2-N2-Zeolite_5A, a single counter-current 
%		repressurization with the feed, followed by a single
%		high pressure feed, saturation with the raffinate 
%		product at the low pressure
%	- case_study_1.8.x: 
%		1-adsorber, isothermal, pressure-driven
%		(Kozeny-Carman), time-driven, linear isotherm, LDF
%		kinetics, O2-N2-Zeolite_5A, a single counter-current 
%		repressurization with the feed, followed by a single
%		high pressure feed, saturation with the feed at the
%		low pressure
%	- case_study_1.9.x: 
%		1-adsorber, isothermal, flow-driven
%		(Kozeny-Carman), time-driven, linear isotherm, LDF 
%		kinetics, O2-N2-Zeolite_5A, a single counter-current 
%  		repressurization with the feed, followed by a single
%		high pressure feed, saturation with the feed at the 
%		low pressure
%	- case_study_1.10.x:
%		1-adsorber, isothermal, flow-driven, time-driven, 
%		linear isotherm, LDF kinetics, O2-N2-Zeolite_5A, a 
%		single counter-current repressurization with the feed, 
%		followed by a single high pressure feed, saturation 
%		with the raffinate product at the low pressure
% Plots:
% 	- Pressure profiles (vs. time) for the two adsorption columns
%	- Adsorbed phase concentration of the 1st adsorber at the last
%	  high pressure feed step, before reaching a CSS
% 	- A comparison of the gas phase concentration profiles in the
% 	  1st adsorber, as a function of the number of CSTRs (n_c)
% Data: 
%	- Data for the CPU times/cycle (4 PSA cycle simulations and 
%	  take the average over 10 PSA cycles)
%	- Oxygen recovery %, and  Oxygen purity for the different 
%	  simulations of Kayser's system over different n_c values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%