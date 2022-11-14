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
% 	[O] case_study_1.0: 
%	  	- 2-adsorber
%		- Isothermal
% 		- Flow-driven
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle (180 degrees out of phase)
%			- Adsorber 1
%				1. Re-pressurization with raffinate
%				   product
%				2. Re-pressurization with feed
%				3. High pressure feed
%				4. Depressurization to a subambient 
%				   pressure
%				5. Low pressure purge				  
%			- Adsorber 2
%				1. High pressure feed
%				2. Depressurization to a subambient 
%				   pressure
%				3. Low pressure purge
%				4. Re-pressurization with raffinate 
%				   product
%				5. Re-pressurization with feed
% 	[X] case_study_1.1: 
%	  	- 2-adsorber
%		- Isothermal
% 		- Pressure-driven (Kozeny-Carman)
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle (180 degrees out of phase)
%			- Adsorber 1
%				1. Re-pressurization with raffinate
%				   product
%				2. Re-pressurization with feed
%				3. High pressure feed
%				4. Depressurization to a subambient 
%				   pressure
%				5. Low pressure purge				  
%			- Adsorber 2
%				1. High pressure feed
%				2. Depressurization to a subambient 
%				   pressure
%				3. Low pressure purge
%				4. Re-pressurization with raffinate 
%				   product
%				5. Re-pressurization with feed
% 	[O] case_study_1.2: 
%	  	- 2-adsorber
%		- Nonisothermal
% 		- Flow-driven
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle (180 degrees out of phase)
%			- Adsorber 1
%				1. Re-pressurization with raffinate
%				   product
%				2. Re-pressurization with feed
%				3. High pressure feed
%				4. Depressurization to a subambient 
%				   pressure
%				5. Low pressure purge				  
%			- Adsorber 2
%				1. High pressure feed
%				2. Depressurization to a subambient 
%				   pressure
%				3. Low pressure purge
%				4. Re-pressurization with raffinate 
%				   product
%				5. Re-pressurization with feed
%	[X] case_study_1.3: 
%	  	- 2-adsorber
%		- Nonisothermal
% 		- Pressure-driven (Kozeny-Carman)
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle (180 degrees out of phase)
%			- Adsorber 1
%				1. Re-pressurization with raffinate
%				   product
%				2. Re-pressurization with feed
%				3. High pressure feed
%				4. Depressurization to a subambient 
%				   pressure
%				5. Low pressure purge				  
%			- Adsorber 2
%				1. High pressure feed
%				2. Depressurization to a subambient 
%				   pressure
%				3. Low pressure purge
%				4. Re-pressurization with raffinate 
%				   product
%				5. Re-pressurization with feed
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single Adsorber Simulation I
% Purpose:
%	- To simulate a single adsorber PSA cycle
% Reference: 
%	- Kayser, J.C., Knaebel, K.S., 1986. Pressure Swing 
%	  Adsorption - Experimental Study of an Equilibrium Theory. 
%	  Chemical Engineering Science, 41, 2931–2938.
% Case Studies:
%	[O] case_study_2.0: 
%	  	- 1-adsorber
%		- Isothermal
% 		- Flow-driven
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
%	[X] case_study_2.1: 
%	  	- 1-adsorber
%		- Isothermal
% 		- Pressure-driven (Kozeny-Carman)
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
%	[X] case_study_2.2: 
%	  	- 1-adsorber
%		- Nonisothermal
% 		- Flow-driven
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
%	[X] case_study_2.3: 
%	  	- 1-adsorber
%		- Nonisothermal
% 		- Pressure-driven (Kozeny-Carman)
%		- Time-driven
%	  	- O2-N2-Zeolite_5A
%		- Linear isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single Adsorber Simulation I
% Purpose:
%	- To simulate a PSA cycle including nonisothermal operation 
%	  and axial pressure drop.
% Reference: 
%	- Cavenati, S., Grande, C.A., Rodrigues, A.E., 2006. Removal
%	  of Carbon Dioxide from Natural Gas by Vacuum Pressure 
%	  Swing Adsorption. Energy & Fuels 20, 2648–2659.
% Case Studies:
% 	[O] case_study_3.0: 
%		- 1-adsorber
%		- Isothermal
% 		- Flow-driven
%		- Time-driven
%	  	- CH4-N2-CO2-Zeolite_13X
%		- multisite Langmuir isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
% 	[X] case_study_3.1: 
%		- 1-adsorber
%		- Isothermal
% 		- Pressure-driven (Ergun)
%		- Time-driven
%	  	- CH4-N2-CO2-Zeolite_13X
%		- multisite Langmuir isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
% 	[O] case_study_3.2: 
%		- 1-adsorber
%		- Nonisothermal
% 		- Flow-driven
%		- Time-driven
%	  	- CH4-N2-CO2-Zeolite_13X
%		- multisite Langmuir isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
% 	[X] case_study_3.3: 
%		- 1-adsorber
%		- Nonisothermal
% 		- Pressure-driven (Ergun)
%		- Time-driven
%	  	- CH4-N2-CO2-Zeolite_13X
%		- multisite Langmuir isotherm
%		- LDF kinetics,
%	        - 5 step PSA cycle
%			1. re-pressurization with raffinate product
%			2. re-pressurization with feed
%			3. high pressure feed
%			4. depressurization to a subambient pressure
%			5. low pressure purge
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multiple Adsorber Simulation II
% Purpose:
%	- To demonstrate a complex PSA cycle, including a pressure 
%	  equalization step
% Reference: 
%	- Yang, J., Lee, C.-H., Chang, J.-W., 1997. Separation of 
%	  Hydrogen Mixture by a Two-Bed Pressure Swing Adsorption 
%	  Process Using Zolite 5A. Ind. Eng. Chem. Res. 36, 2789–2798.
% Case Studies:
% 	[O] case_study_4.0: 
%	  	- 2-adsorber
%		- Isothermal
% 		- Flow-driven
%		- Time-driven
%	  	- H2_CO_Zeolite_5A
%		- Langmuir-Freundlich 
%		- LDF kinetics,
%	        - 6 step PSA cycle
%			- Adsorber 1
%				1. Pressurization with feed
%				2. High pressure feed
%				3. Depressurization 
%				   (equalization, product end)
%				4. Depressurization down to the 
%				   low pressure
%				5. Low pressure purge
%				6. Repressurization 
%				   (equalization, product end)
%			- Adsorber 2
%				1. Depressurization down to the 
%				   low pressure
%				2. Low pressure purge
%				3. Repressurization 
%				   (equalization, product end)
%				4. Pressurization with feed
%				5. High pressure feed
%				6. Depressurization 
%				   (equalization, product end)
% 	[X] case_study_4.1: 
%	  	- 2-adsorber
%		- Isothermal
% 		- Pressure-driven (Ergun)
%		- Time-driven
%	  	- H2_CO_Zeolite_5A
%		- Langmuir-Freundlich 
%		- LDF kinetics,
%	        - 6 step PSA cycle
%			- Adsorber 1
%				1. Pressurization with feed
%				2. High pressure feed
%				3. Depressurization 
%				   (equalization, product end)
%				4. Depressurization down to the 
%				   low pressure
%				5. Low pressure purge
%				6. Repressurization 
%				   (equalization, product end)
%			- Adsorber 2
%				1. Depressurization down to the 
%				   low pressure
%				2. Low pressure purge
%				3. Repressurization 
%				   (equalization, product end)
%				4. Pressurization with feed
%				5. High pressure feed
%				6. Depressurization 
%				   (equalization, product end)
% 	[O] case_study_4.2: 
%	  	- 2-adsorber
%		- Nonisothermal
% 		- Flow-driven
%		- Time-driven
%	  	- H2_CO_Zeolite_5A
%		- Langmuir-Freundlich 
%		- LDF kinetics,
%	        - 6 step PSA cycle
%			- Adsorber 1
%				1. Pressurization with feed
%				2. High pressure feed
%				3. Depressurization 
%				   (equalization, product end)
%				4. Depressurization down to the 
%				   low pressure
%				5. Low pressure purge
%				6. Repressurization 
%				   (equalization, product end)
%			- Adsorber 2
%				1. Depressurization down to the 
%				   low pressure
%				2. Low pressure purge
%				3. Repressurization 
%				   (equalization, product end)
%				4. Pressurization with feed
%				5. High pressure feed
%				6. Depressurization 
%				   (equalization, product end)
% 	[X] case_study_4.3: 
%	  	- 2-adsorber
%		- Nonisothermal
% 		- Pressure-driven (Ergun)
%		- Time-driven
%	  	- H2_CO_Zeolite_5A
%		- Langmuir-Freundlich 
%		- LDF kinetics,
%	        - 6 step PSA cycle
%			- Adsorber 1
%				1. Pressurization with feed
%				2. High pressure feed
%				3. Depressurization 
%				   (equalization, product end)
%				4. Depressurization down to the 
%				   low pressure
%				5. Low pressure purge
%				6. Repressurization 
%				   (equalization, product end)
%			- Adsorber 2
%				1. Depressurization down to the 
%				   low pressure
%				2. Low pressure purge
%				3. Repressurization 
%				   (equalization, product end)
%				4. Pressurization with feed
%				5. High pressure feed
%				6. Depressurization 
%				   (equalization, product end)
% Plots
% 	- TBD
% Data:
% 	- TBD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%