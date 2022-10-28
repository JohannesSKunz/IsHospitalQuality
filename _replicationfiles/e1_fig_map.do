* Kunz & Propper 
clear all 
set more off 
tempfile temp temp1 temp2 
loc estdate   "22_06_10"
loc datedata  "21_11_20"
cd "/Users/jkun0001/Desktop/_replicationfiles/"
set matsize 10000

* Can choose different weightings 
loc indwgt		 "zipwgt" 
loc indicator 	 "`indwgt'_phi_brglmpenalty3" 

* -----------------------------------------------------------------------------
use maindata_fig1_maps.dta, clear 

* Gen maps 
loc i 1 
//*
format `indicator' %12.2f
spmap `indicator' using aux_map_b, ///
		polygon(data("aux_map_a") osize(0.5) ocolor(black)) ///
		id(_ID) name(gr`i', replace) ///
		title("A. County-level hospital quality exposure" "(darker worse quality)" , s(medsmall)) ///
		fcolor(Reds2) cln(9) 
		loc i = `i' + 1 

format `indicator'_res %12.2f
spmap `indicator'_res using aux_map_b, ///
		polygon(data("aux_map_a") osize(0.5) ocolor(black)) ///
		id(_ID) name(gr`i', replace) ///
		title("B. Residual county-level hospital quality exposure" "(darker worse quality)" , s(medsmall)) ///
		fcolor(Reds2) cln(9)
		loc i = `i' + 1 		
graph combine  gr1 gr2 , scheme(s2mono) graphregion(color(white)) ysize(6) xsize(10)
	graph export e1_fig_map.png , replace 	
	graph export e1_fig_map.tif , replace 	
