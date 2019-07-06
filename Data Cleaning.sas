
/* Data Cleaning Exercise 
   Using MSC Picnic Data */
dm log 'clear'; ods html close; ods html;
options formdlim='-' nodate nonumber;

Proc Format;
value yesno 1 = 'Yes' 0 = 'No';
value pct 1 = '0%' 2 = '25%' 3 = '50%' 4 = '75%' 5 = '100%';
value $gender 'F' = 'Female' 'M' = 'Male';
value compare 1 = 'Much worse' 2 = 'Somewhat worse' 3 = 'About the same' 4 = 'Somewhat better' 5 = 'Much better';
value age 1 = 'Under 18' 2 = '18 - 25' 3 = '26 - 35' 4 = '36 - 45' 5 = '46 - 55' 6 = '56 - 65' 7 = 'Over 65';
value income 1 = 'Less than $40,000' 2 = '40,000 - $75,000' 3 = '75,001 - $100,000' 4 = 'More than $100,000';

data picnic;
proc import datafile="F:\STATS Data\wSTA419\MSC Data Bad.xls" out=picnic dbms='xls' replace;
label ID = 'ID Number'
first = 'Is this the first year that you have attended any Summer Celebration Event?'
picnic = 'Is this your first year at Plumbs Picnic?'
plumbs = 'Which of the following best represents how often you shop at Plumbs stores?'
activities = 'On a scale from 1 to 10, to what extent did you enjoy the activities offered at Plumbs Picnic?'
variety = 'On a scale from 1 to 10, how would you rate the variety of events offered at Summer Celebration?'
festivals = 'In the last 12 months, have you attended other festivals in Michigan?'
compare = 'How does your overall experience at Muskegon Summer Celebration compare?'
groupnum = 'How many people are in your group?'
zipcode = 'What is your zip code?'
gender = 'Gender'
race = 'What is your nationality/race?'
age = 'Which of the following describes your age?'
income = 'Which of the following categories describes your annual household income?';
run;

data picnic;
set picnic;
format first picnic festivals yesno. plumbs pct. gender $gender. compare compare. age age. income income.;

/* check for unexpected values for the variable Income */
data _null_;
set picnic;
file print;
if income = 0 or income gt 4 then put 
'ID number ' ID 'has an unexpected Income value of ' income;

/* check for missing or invalid entries for variable Income */
if missing(income) then put
'ID number ' ID 'has a missing value for the variable Income';
title 'Print of unexpected values for variable Income';
title2 'Group Number 4';
run;

/* Fix income */
data picnic;
set picnic;
if id = 8 then income = 1;
if id = 12 then income = 4;

/* check for missing or invalid entries for variable Income */
if missing(income) then put
'ID number ' ID 'has a missing value for the variable Income';
title 'Print of Corrected values for the variable Income';
title2 'Group Number 4';
run;

proc print data = picnic;
where id = 8 or id = 12;
var income;
run;


/* variable race */
proc freq data = picnic;
tables race;
run;

data _null_;
set picnic;
file print pad;
/* check for unexpected values for the variable Race */
race = propcase(race);
if race = 'White' then race = 'Caucasian';
if race = 'Black' then race = 'African American';
if race not in('Caucasian', 'African American', 'Hispanic', 'Native American', '.') then put
'ID number ' ID 'has an unexpected value for the variable Race';
/* check for missing or invalid entries for variable Race */
if race eq '.' then put
'ID number ' ID 'has a missing value for the variable Race of ' race;
title 'Print of unexpected/missing values for the variable Race';
title2 'Group Number 4';
run;

/* Fix Race */
data picnic;
set picnic;
race = propcase(race);
if race = 'White' then race = 'Caucasian';
if race = 'Black' then race = 'African American';
if race = "Cuacasian" then race = "Caucasian";
if race = "Mexican/Irish" then race = "Mixed Ethnicity";
if race = "European" then race = "Caucasian";

proc print data = picnic;
where id = 6 or id = 12 or id = 16 or id = 19 or id = 21 or id= 24 or id= 33 or id = 38 or id = 46;
var race;
run;

/*
data picnicZip;
set picnic;
badZip=verify(trim(zipcode), '0123456789') and not missing(zipcode) or length(zipcode) gt 5 or length(zipcode) lt 5;*0=zipcode is good, 1=zipcode is bad;
checkZip=lowcase(zipcode); *makes letters lowercase for easier identification in the zipcode variable;
run;

proc print data=picnicZip;
where badZip=1;
var checkZip;
title 'Print of unexpected values for the variable ZipCode';
run;
*/


data _null_;
set picnic;
file print pad;
if verify(trim(zipcode), '0123456789') and not missing(zipcode) or length(zipcode) gt 5 or length(zipcode) lt 5 then put id= zipcode=;
title 'Print of unexpected values for the variable ZipCode';
title2 'Group Number 4';
run;

data picnic;
set picnic;
file print pad;
if zipcode in (49441,49442,49444,49445,49415) then region='Greater Muskegon';
else if zipcode in (49503,49534) then region='Greater Grand Rapids';
else if zipcode in (49457,49461) then region='Other Muskegon County';
else if zipcode in (49404,49456) then region='Ottawa County';
put id= 'is from ' region;
run;
