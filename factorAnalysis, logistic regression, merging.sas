dm log 'clear'; ods html close; ods html;

libname datalib "F:\STATS Data\Examples"; 

proc import datafile="file" out=datalib.generic replace;
run;
proc import datafile="file" out=datalib.genericB replace;
run;

proc sort data=datalib.generic out=datalib.generic2;
	by variableX;
run;
proc sort data=datalib.genericB out=datalib.genericB2;
	by variableX;
run;

data genericMerged;
	set datalib.generic2;
	merge datalib.generic2(in=sub) datalib.genericB2;
	by variableX;
	if sub;
run;
*/

* SRS of dataset (samprate = 0.01 = 1%);
proc surveyselect data=genericMerged
	method=srs seed=1234 samprate=0.01 out=genericMergedSamp;
run;

/* logistic regression and ROC curve, outroc=ROCbands */
proc logistic data=genericMergedSamp plots=none descending;
    class dependentBinary / param=ref;
    model dependentBinary(event='1') = explanatory variables / outroc=ROCbands;
run; quit;

data ROCbands;
	set ROCbands (keep=_SENSIT_ _1MSPEC_);
	SensBands = _SENSIT_; 
	OneMinusSpecBands=_1MSPEC_;
	drop _SENSIT_ _1MSPEC_;
run;	

proc logistic data=genericMergedSamp plots=none descending;
	class dependentBinary / param=ref;
    model dependentBinary(event='1') = explanatory variables / outroc=ROCcnts;
run; quit;

data ROCcnts;
	set ROCcnts (keep=_SENSIT_ _1MSPEC_);
	SensCnts = _SENSIT_; 
	OneMinusSpecCnts =_1MSPEC_;
	drop _SENSIT_ _1MSPEC_;
run;	

* factor analysis, out=factors as variables;
proc factor data=genericMergedSamp
	priors=one method=prin 
	rotate=varimax reorder
	flag=0.40 nfactors=16 out=mergedFactor;
	var variables; 
run;

* adds labels to the factors;
data mergedFactor;
	set mergedFactor;
	label factorVariables;
run;

proc logistic data=mergedFactor descending;
	class is_booking / param=ref;
	model is_booking(event='1') = factor1-factor4 / outroc=ROC1_4;
	title 'Logistic Regression Model for Factor 1 - Factor 4';
run;

data ROC1_4;
	set ROC1_4 (keep=_SENSIT_ _1MSPEC_);
	Sens1_4 = _SENSIT_; 
	OneMinusSpec1_4=_1MSPEC_;
	drop _SENSIT_ _1MSPEC_;
run;	

proc logistic data=mergedFactor descending;
	class dependentBinary / param=ref;
	model dependentBinary(event='1') = factor1-factor7 / outroc=ROC1_7;
	title 'Logistic Regression Model for Factor 1 - Factor 7';
run;

data ROC1_7;
	set ROC1_7 (keep=_SENSIT_ _1MSPEC_);
	Sens1_7 = _SENSIT_; 
	OneMinusSpec1_7=_1MSPEC_;
	drop _SENSIT_ _1MSPEC_;
run;	

proc logistic data=mergedFactor descending;
	class dependentBinary / param=ref;
	model dependentBinary(event='1') = factor1-factor7 / outroc=ROC1_16;
	title 'Logistic Regression Model for Factor 1 - Factor 16';
run;

data ROC1_16;
	set ROC1_16 (keep=_SENSIT_ _1MSPEC_);
	Sens1_16 = _SENSIT_;
	OneMinusSpec1_16=_1MSPEC_;
	drop _SENSIT_ _1MSPEC_;
run;	

data ROCcurves;
	set ROC1_4 ROC1_7 ROC1_16 ROCbands ROCcnts;
	merge ROC1_4 ROC1_7 ROC1_16 ROCbands ROCcnts;
run;

/* plots the ROC curves all together to be compared */
proc sgplot data=ROCcurves;
	series y=Sens1_4 x=OneMinusSpec1_4;
	series y=Sens1_7 x=OneMinusSpec1_7;
	series y=Sens1_16 x=OneMinusSpec1_16;
	series y=SensBands x=OneMinusSpecBands;
	series y=SensCnts x=OneMinusSpecCnts;
	lineparm y=0 x=0 slope=1;  /*  This graphs the reference line y=x	*/
	xaxis label="1-SPECIFICITY";
	yaxis label="SENSITIVITY";
	title "ROC Factors Compared";
run;
