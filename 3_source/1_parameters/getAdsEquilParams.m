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
%Function   : getAdsEquilParams.m
%Source     : common
%Description: given an initial set of parameters, define parameters that
%             are associated with adsorption equilibrium (isotherm), and
%             nondimensionalize the isotherm parameters as needed.
%Inputs     : params       - a struct containing simulation parameters.
%             varargin     - a cell array containing an additional element.
%                            Specify "1" to indicate that we will perform
%                            additional calculations to nondimensionalize
%                            the adsorption isotherm parameters that
%                            require the normalization by the adsorption
%                            equilibrium amount, i.e., 
%                            q^*\left(\mb{c}_0, T_0\right).
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getAdsEquilParams(params,varargin)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getAdsEquilParams.m';
    
    %Unpack params            
    modSp = params.modSp;
    bool  = params.bool ;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------% 
    %Check the additional inputs
    
    %Check to see if we have an additional input argument
    hasAddArgs = ~isempty(varargin);
    
    %If there is an additional input argument,
    if hasAddArgs
        
        %-----------------------------------------------------------------% 
        %Perform additional calculations to obtain the rest of the
        %dimensionless isotherm paramters requiring the normalization
        %constant for the adsorbed phase in equilibrium with the feed gas
        
        %Check the isotherm model
        whichIsotherm = modSp(1);
        
        %A custom isotherm
        if whichIsotherm == 0
        
            %Currently, no custom isotherm model is supported.
            error("toPSAil: No custom isotherm model is supported.")
        
        %Linear isotherm
        elseif whichIsotherm == 1

            %Unpack additional params
            henryC   = params.henryC  ;
            gasCons  = params.gasCons ;
            tempAmbi = params.tempAmbi;
            gasConT  = params.gasConT ;
            adsConT  = params.adsConT ;

            %Calculate dimensionless parameters (final)
            dimLessHenry = henryC*gasCons*tempAmbi ...
                         * (gasConT/adsConT);
    
            %Save the result
            params.dimLessHenry = dimLessHenry;                        

        %Extended Langmuir isotherm
        elseif whichIsotherm == 2

            %Unpack additional params
            qSatC   = params.qSatC  ;
            adsConT = params.adsConT;
            
            %Calculate dimensionless parameters (final)
            dimLessQsatC = qSatC./adsConT;                       
            
            %Save the result
            params.dimLessQsatC = dimLessQsatC;
            
        %Miltisite Langmuir isotherm
        elseif whichIsotherm == 3   
            
            %Unpack additional params
            qSatC   = params.qSatC  ;
            adsConT = params.adsConT;
            
            %Calculate dimensionless parameters (final)
            dimLessQsatC = qSatC./adsConT; 
                        
            %Save the result
            params.dimLessQsatC = dimLessQsatC;
            
        %Extended Langmuir-Freundlich isotherm
        elseif whichIsotherm == 4
        
            %Unpack additional params
            kOneC    = params.kOneC   ;
            kTwoC    = params.kTwoC   ;
            tempAmbi = params.tempAmbi;
            adsConT  = params.adsConT ;
                        
            %Calculate dimensionless parameters (final)
            dimLessKOneC = kOneC/adsConT         ;
            dimLessKTwoC = kTwoC*tempAmbi/adsConT;
            
            %Save the result
            params.dimLessKOneC = dimLessKOneC;
            params.dimLessKTwoC = dimLessKTwoC;   
            
        %Decoupled or extended dual-site Langmuir-Freundlich isotherm
        elseif whichIsotherm == 5 || whichIsotherm == 6
        
            %Unpack additional params
            qSatSiteOneC = params.qSatSiteOneC;
            qSatSiteTwoC = params.qSatSiteTwoC;            
            adsConT      = params.adsConT     ;
            
            %Calculate dimensionless parameters (final)
            dimLessqSatSiteOneC = qSatSiteOneC./adsConT; 
            dimLessqSatSiteTwoC = qSatSiteTwoC./adsConT; 
                        
            %Save the result
            params.dimLessqSatSiteOneC = dimLessqSatSiteOneC;
            params.dimLessqSatSiteTwoC = dimLessqSatSiteTwoC;

        %Toth isotherm
        elseif whichIsotherm == 7

            %Unpack additional params
            satdConc    = params.nS0C   ;
            adsConT     = params.adsConT;

            %Calculate dimensionless parameters (final)
            dimLessSatdConc     = satdConc./adsConT ;
            
            %Save the results
            params.dimLessSatdConc  = dimLessSatdConc   ;

        %Custom isotherm
        elseif whichIsotherm == 9

            %Unpack additional params

            %Calculate dimensionless parameters

            %Save the resuls

        end
        %-----------------------------------------------------------------% 
        
        
        
        %-----------------------------------------------------------------% 
        %Return to the parent function
        
        %Return to the invoking function
        return;
        %-----------------------------------------------------------------% 
    
    end
    %---------------------------------------------------------------------% 
    
    
        
    %---------------------------------------------------------------------%    
    %Based on the isotherm model, compute any necessary parameters

    %Check the isotherm model
    whichIsotherm = modSp(1);

    %A custom isotherm
    if whichIsotherm == 0
        
        %Currently, no custom isotherm model is supported.
        error("toPSAil: No custom isotherm model is supported.")

    %Linear isotherm
    elseif whichIsotherm == 1
          
        %Unpack additional params
        henryC   = params.henryC  ;
        gasCons  = params.gasCons ;
        tempAmbi = params.tempAmbi;
        gasConT  = params.gasConT ;
        
        %Set the temporary constant
        aConScaleFac = 1;
                        
        %Calculate dimensionless parameters (temporary)
        dimLessHenry = henryC*gasCons*tempAmbi  ...
                     * (gasConT/aConScaleFac);
                                       
        %Save the result
        params.dimLessHenry = dimLessHenry; %Temporary
        
    %Extended Langmuir isotherm
    elseif whichIsotherm == 2
        
        %Unpack additional params
        qSatC    = params.qSatC   ;
        bC       = params.bC      ;
        gasCons  = params.gasCons ;
        tempAmbi = params.tempAmbi;
        gasConT  = params.gasConT ;
        
        %Set the temporary constant
        aConScaleFac = 1;
        
        %Calculate dimensionless parameters (temporary)
        dimLessBC    = bC*gasCons*tempAmbi*gasConT;
        dimLessQsatC = qSatC/aConScaleFac         ;
               
        %Save the result   
        params.dimLessQsatC = dimLessQsatC; %Temporary
        params.dimLessBC    = dimLessBC   ; %Final
        
    %Miltisite Langmuir isotherm
    elseif whichIsotherm == 3
        
        %Unpack additional params
        KC       = params.KC      ;
        gasConT  = params.gasConT ;
        tempAmbi = params.tempAmbi;
        gasCons  = params.gasCons ;      
        qSatC    = params.qSatC   ;
        
        %Set the temporary constant
        aConScaleFac = 1;
        
        %Calculate dimensionless parameters (temporary)
        dimLessKC    = KC*gasCons*tempAmbi*gasConT;
        dimLessQsatC = qSatC/aConScaleFac         ;
        
        %Save the result
        params.dimLessKC    = dimLessKC   ; %Final
        params.dimLessQsatC = dimLessQsatC; %Temporary
        
    %Extended Langmuir-Freundlich isotherm
    elseif whichIsotherm == 4
        
        %Unpack additional params
        kOneC    = params.kOneC   ;
        kTwoC    = params.kTwoC   ;
        kThrC    = params.kThrC   ;
        kFouC    = params.kFouC   ;
        kFivC    = params.kFivC   ;
        kSixC    = params.kSixC   ;
        gasConT  = params.gasConT ;
        tempAmbi = params.tempAmbi;
        gasCons  = params.gasCons ;
        
        %Set the temporary constant
        aConScaleFac = 1;
        
        %Calculate dimensionless parameters (temporary)
        dimLessKOneC = kOneC/aConScaleFac         ;
        dimLessKTwoC = kTwoC*tempAmbi/aConScaleFac;
        dimLessKThrC = kThrC                      ; %(dimensional)
        scaleFacKThr = gasCons*tempAmbi*gasConT   ;
        dimLessKFouC = kFouC/tempAmbi             ;
        dimLessKFivC = kFivC                      ;
        dimLessKSixC = kSixC/tempAmbi             ;
                
        %Save the result
        params.dimLessKOneC = dimLessKOneC; %Temporary
        params.dimLessKTwoC = dimLessKTwoC; %Temporary
        params.dimLessKThrC = dimLessKThrC; %Final (dim & state dependent)
        params.scaleFacKThr = scaleFacKThr; %Final
        params.dimLessKFouC = dimLessKFouC; %Final
        params.dimLessKFivC = dimLessKFivC; %Final
        params.dimLessKSixC = dimLessKSixC; %Final
                     
    %Decoupled or extended dual-site Langmuir-Freundlich isotherm
    elseif whichIsotherm == 5 || whichIsotherm == 6
            
        %Unpack additional params
        qSatSiteOneC = params.qSatSiteOneC;
        qSatSiteTwoC = params.qSatSiteTwoC;
        bSiteOneC    = params.bSiteOneC   ;
        bSiteTwoC    = params.bSiteTwoC   ;
        nSiteOneC    = params.nSiteOneC   ;
        nSiteTwoC    = params.nSiteTwoC   ;
        gasCons      = params.gasCons     ;
        tempAmbi     = params.tempAmbi    ;
        gasConT      = params.gasConT     ;
        
        %Set the temporary constant
        aConScaleFac = 1;
        
        %Calculate dimensionless parameters (temporary)
        dimLessqSatSiteOneC = qSatSiteOneC/aConScaleFac           ;
        dimLessqSatSiteTwoC = qSatSiteTwoC/aConScaleFac           ;
        dimLessbSiteOneC    = bSiteOneC*(gasCons*tempAmbi*gasConT);
        dimLessbSiteTwoC    = bSiteTwoC*(gasCons*tempAmbi*gasConT);
        
        %Save the result
        params.dimLessqSatSiteOneC = dimLessqSatSiteOneC;
        params.dimLessqSatSiteTwoC = dimLessqSatSiteTwoC;
        params.dimLessbSiteOneC    = dimLessbSiteOneC   ;
        params.dimLessbSiteTwoC    = dimLessbSiteTwoC   ;
        params.dimLessnSiteOneC    = nSiteOneC          ;
        params.dimLessnSiteTwoC    = nSiteTwoC          ;            
        
    %Toth isotherm
    elseif whichIsotherm == 7
        
        %Unpack additional params
        satdConc     = params.nS0C   ;
        adsAffCon    = params.b0C    ;
        totIsoExp    = params.t0C    ;
        totChi       = params.ChiC   ;
        totAlpha     = params.alphaC ;
        gasCons      = params.gasCons     ;
        tempAmbi     = params.tempAmbi    ;
        gasConT      = params.gasConT     ;

        
        %Set the temporary constant
        aConScaleFac = 1;
        
        %Calculate dimensionless parameters (temporary)
        dimLessSatdConc  = satdConc/aConScaleFac  ;
        %Final
        dimLessAdsAffCon = adsAffCon*(gasCons*tempAmbi*gasConT) ;
        dimLessTotIsoExp = totIsoExp              ;
        dimLessChi       = totChi                 ;
        dimLessTotAlpha  = totAlpha               ;
                
        %Save the result
        params.dimLessSatdConc  = dimLessSatdConc  ;
        params.dimLessAdsAffCon = dimLessAdsAffCon ;
        params.dimLessTotIsoExp = dimLessTotIsoExp ;
        params.dimLessChi       = dimLessChi       ;
        params.dimLessTotAlpha  = dimLessTotAlpha  ;
        
    end
    %---------------------------------------------------------------------%
    
        
    
    %---------------------------------------------------------------------%    
    %Based on the energy balance model, specify additional parameters
    
    %If nonisothermal
    if bool(5) == 1
        
        %Unpack additional params
        tempAmbi = params.tempAmbi;
        isoStHtC = params.isoStHtC;   
        gasCons  = params.gasCons ;

        %Calculate the constant factor inside the exponent: 
        %(J/mol-L)/(J/mol-L)
        dimLessIsoStHtRef = isoStHtC ...
                         ./ ((gasCons/10)*tempAmbi);
                     
        %Save the result
        params.dimLessIsoStHtRef = dimLessIsoStHtRef;    
    
    end
    %---------------------------------------------------------------------%    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%