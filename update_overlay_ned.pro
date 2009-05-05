function ned_parse, a, delim

working = a
out = ['junk at the start']
curr = 1
while curr NE -1 do begin
	curr = strpos(working, delim)

	if curr EQ 0 then begin
		out = [out, '']
	endif else begin
		temp = strmid(working, 0, curr)
		out = [out, temp]
	endelse
	working = strmid(working, curr+1)
endwhile

return, out[1:(n_elements(out)-1)]

end



pro queryned, ra, dec, radius, NumberInfo=NumberInfo, Result=Result
; Check for the minimum number of parameters
if N_params() LT 3 then begin
	print,'SYNTAX - queryned, ra, dec, radius, NumberInfo=NumberInfo, Result=Result'
	print,'   Input - ra, dec, radius, Numberinfo=Numberinfo, Result=Result'
	print,'   Output -  NumberInfo, Result'
	return
endif
; Check RA and Dec range
if ra LT 0.0 OR ra GT 360.0 then begin
	print,'Error:  RA must be in the range of 0d to 360d!'
	return
endif
if dec LT -90.0 OR dec GT 90.0 then begin
	print,'Error:  Dec must be in the range of -90d to 90d!'
	return
endif

; If RADIUS is a two element array, then we are in box mode.  
; -> Create a search radius that includes all of the box and 
; then filter the results later
if n_elements(radius) EQ 1 then begin
	r_rad = radius
endif else begin
	r_rad = sqrt(radius[0]^2.0 + radius[1]^2.0) / 2.0
endelse

; Build the query
ra_str = strcompress(string(ra), /Remove_All)+'d'
dec_str = strcompress(string(dec), /Remove_All)+'d'
rad_str = strcompress(string(r_rad), /Remove_All)
QueryURL = 'http://nedwww.ipac.caltech.edu/cgi-bin/nph-objsearch?in_csys=Equatorial&in_equinox=J2000.0&lon='+ra_str+'&lat='+dec_str+'&radius='+rad_str+'&search_type=Near+Position+Search&out_csys=Equatorial&out_equinox=J2000.0&obj_sort=Distance+to+search+center&of=ascii_bar&zv_breaker=75000.0&list_limit=5&img_stamp=YES&z_constraint=Unconstrained&z_value1=&z_value2=&z_unit=z&ot_include=ANY&nmp_op=ANY'

; Run the query
result = webget(QueryURL)

; Parse the result
if strpos(result.text[0], 'Error') NE -1 then begin
	NumberInfo = 0

	query = {RA2000: ra, Dec2000: dec, Radius: radius}
	Result = {Query: query, Number: NumberInfo}
	return
endif else begin
	info = result.text[21:(n_elements(result.text)-1)]

	query = {RA2000: ra, Dec2000: dec, Radius: radius}

	base = {Name: '', RA2000: 0.0, Dec2000: 0.0, Type: '', NType: -1, Velocity: 0.0, Dist: 0.0}
	Result_Info = replicate(base, n_elements(info))
	counter = 0
	for i=0L,(n_elements(info)-1) do begin
		fields = ned_parse(info[i], '|')

		o_ra = float(fields[2])
		o_dec = float(fields[3])
		delta_ra  = 60.0*(ra - o_ra)*cos(dec/!radeg)
		delta_dec = 60.0*(dec - o_dec)
		if n_elements(radius) EQ 2 then begin
			if abs(delta_ra) GT radius[0]/2.0 OR abs(delta_dec) GT radius[1]/2.0 then begin
				continue
			endif
		endif

		base.Name    = fields[1]
		base.RA2000  = float(fields[2])
		base.Dec2000 = float(fields[3])
		base.Type    = fields[4]
		case base.Type of 
			'G'      :	base.NType= 1
			'GPair'  :	base.NType= 2
			'GTrpl'  :	base.NType= 2
			'GGroup' :	base.NType= 2
			'GClstr' :	base.NType= 2
			'QSO'    :	base.NType= 3
			'PofG'   :      base.NType= 4
			'HII'    :      base.NType= 4
			'SN'	 :	base.NType= 5
			'Radios' :	base.NType=21
			'SmmS'	 :	base.NType=22 
			'Irs'	 : 	base.NType=23
			'VisS'	 :	base.NType=24
			'UvES'	 : 	base.NType=25
			'XrayS'	 :      base.NType=26
			'GammaS' :      base.NType=27
			else	 :	if strmatch(base.Type, '*\**') then base.NType=6 else base.NType=-1
		endcase

		base.Dist    = float(fields[8])
		if strlen(fields[5]) EQ 0 then begin
			base.Velocity = -9999.9
		endif else begin
			base.Velocity = float(fields[5])
		endelse

		Result_Info[counter] = base
		counter = counter + 1
	endfor
	
	NumberInfo = counter-1
	Result = {Query: query, Number: NumberInfo, Objects: Result_Info[0:(counter-1)]}
endelse

end



function update_overlay_ned_halpha, vel, Colors=Colors, FilterNames=FilterNames

common setup_s2kb_state

Filters = [-1L]
Colors = ['Yellow']
vel = float(vel)
if vel GT -140 AND vel LE 1700 then begin
	Filters = [Filters, 0]
	Colors  = [Colors, 'Red']
endif
if vel GT 1450 AND vel LE 3600 then begin
	Filters = [Filters, 1]
	Colors  = [Colors, 'Green']
endif
if vel GT 3300 AND vel LE 5350 then begin
	Filters = [Filters, 2]
	Colors  = [Colors, 'Blue']
endif
if vel GT 5000 AND vel LE 7400 then begin
	Filters = [Filters, 3]
	Colors  = [Colors, 'Purple']
endif
if vel GT 7200 AND vel LE 9300 then begin
	Filters = [Filters, 4]
	Colors  = [Colors, 'White']
endif

if n_elements(Filters) GT 1 then begin
	Filters = Filters[1:(n_elements(Filters)-1)]
	Colors  =  Colors[1:(n_elements(Colors )-1)]

	if Keyword_Set(FilterNames) then begin
		Filters = 6580L + 40L*Filters
	endif
endif

return, Filters

end	



pro update_overlay_ned, ra, dec, windex, Refresh=Refresh

common setup_s2kb_state

wset, windex

hor, s2kb.ramax, s2kb.ramin
ver, s2kb.decmin, s2kb.decmax
plot, [0,0], /NoErase, /NoData, XRange=[s2kb.ramax, s2kb.ramin], YRange=[s2kb.decmin, s2kb.decmax], XStyle=5, YStyle=5, Pos=[0,0,1,1]

;+ If refresh has not been sent, or we don't have a NED structure to work with, query
;+ NED again.  This is getting to be slow so NED is being turned off by default.
if (NOT Keyword_Set(Refresh)) or size( s2kb.NED, /Type) NE 8 then begin
	queryned, (ra)[0], (dec)[0], [25.0, 25.0], NumberInfo=NumberInfo, Result=Result
	
	temp = s2kb
	s2kb = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: temp.image, Header: temp.header, Astrom: temp.astrom, NED: Result}
	;DelVarX, temp
	temp = 0
endif

;+ Begin printing out what we know
list_count = 0
if s2kb.NED.Number NE 0 then ned_list = strarr(s2kb.NED.Number)

for n=0L,(s2kb.NED.Number-1) do begin
	;+ Load current object
	Object = (S2KB.NED.Objects)[n]

	;+ Series of filters to clean out certain undesirable objects
	Symbol = -1
	if Object.NType*NED_Control.UseG     EQ  1 then Symbol = 5
	if Object.NType*NED_Control.UseGG    EQ  2 then Symbol = 5
	if Object.NType*NED_Control.UseQSO   EQ  3 then Symbol = 1
	if Object.NType*NED_Control.UsePofG  EQ  4 then Symbol = 5
	if Object.NType*NED_Control.UseSN    EQ  5 then Symbol = 7
	if Object.NType*NED_Control.UseS     EQ  6 then Symbol = 2
	if Object.NType*NED_Control.UseU_Rad EQ 21 then Symbol = 4
	if Object.NType*NED_Control.UseU_Smm EQ 22 then Symbol = 4
	if Object.NType*NED_Control.UseU_Ifr EQ 23 then Symbol = 4
	if Object.NType*NED_Control.UseU_Vis EQ 24 then Symbol = 4
	if Object.NType*NED_Control.UseU_UlV EQ 25 then Symbol = 4
	if Object.NType*NED_Control.UseU_XRy EQ 26 then Symbol = 4
	if Object.NType*NED_Control.UseU_GRy EQ 27 then Symbol = 4
	if Symbol EQ -1 then continue

	if Object.Velocity EQ -9999.9 then begin
		if s2kb_setup.NED_Unknown EQ 1 then begin
			if s2kb_setup.UseGIF OR strcmp(s2kb_setup.UseSurvey,'sdss') OR strcmp(s2kb_setup.UseSurvey,'sdssc') then begin
				plots, Object.RA2000*[1,1], Object.Dec2000*[1,1], PSym=Symbol, Color=FSC_Color('Orange')
				xyouts, Object.RA2000, Object.Dec2000, string(list_count,Format='(I3)'), /Data, Color=FSC_Color('Orange')
			endif else begin
				ad2xy, Object.RA2000, Object.Dec2000, S2KB.Astrom, normx, normy
				plots, normx*[1,1]/(size(S2KB.Image))[1], normy*[1,1]/(size(S2KB.Image))[2], PSym=Symbol, $
					Color=FSC_Color('Orange'), /Norm
				xyouts, normx/(size(S2KB.Image))[1], normy/(size(S2KB.Image))[2], string(list_count,Format='(I3)'), /Norm, $
					Color=FSC_Color('Orange')
			endelse
	
			out_str = string(list_count, Format='(I3)')+': '+string(Object.Name, Format='(A-28)')+' ['+$
				string(Object.Type, Format='(A-6)')+'] @    ??? km/s'
			ned_list[list_count] = out_str

			list_count += 1
		endif else begin
			continue
		endelse
	endif else begin
		if s2kb_setup.NED_Known EQ 1 then begin
			if s2kb_setup.UseGIF OR strcmp(s2kb_setup.UseSurvey,'sdss') OR strcmp(s2kb_setup.UseSurvey,'sdssc') then begin
				plots, Object.RA2000*[1,1], Object.Dec2000*[1,1], PSym=Symbol, Color=FSC_Color('Yellow')
				xyouts, Object.RA2000, Object.Dec2000, string(list_count,Format='(I3)'), /Data, Color=FSC_Color('Yellow')
			endif else begin
				ad2xy, Object.RA2000, Object.Dec2000, S2KB.Astrom, normx, normy
				plots, normx*[1,1]/(size(S2KB.Image))[1], normy*[1,1]/(size(S2KB.Image))[2], PSym=Symbol, $
					Color=FSC_Color('Yellow'), /Norm
				xyouts, normx/(size(S2KB.Image))[1], normy/(size(S2KB.Image))[2], string(list_count,Format='(I3)'), $
					/Norm, Color=FSC_Color('Yellow')
			endelse
	
			out_str = string(list_count, Format='(I3)')+': '+string(Object.Name, Format='(A-28)')+' ['+$
				string(Object.Type, Format='(A-6)')+'] @ '
			if Object.Velocity LT 30000.0 then begin
				out_str = out_str+string(Object.Velocity,Format='(I6)')+' km/s'
			endif else begin
				out_str = out_str+'>30000 km/s'
			endelse
			ned_list[list_count] = out_str
		endif

		if Object.NType EQ 1 then begin
			filters = update_overlay_ned_halpha( Object.Velocity, Colors=Colors)
			if filters[0] NE -1 then begin
				did_plot = 0
				for j=0L,(n_elements(Filters)-1) do begin
					if s2kb_setup.ha_filters[Filters[j]] EQ 1 then begin
						did_plot = 1
						if s2kb_setup.UseGIF OR strcmp(s2kb_setup.UseSurvey,'sdss') OR $
						  strcmp(s2kb_setup.UseSurvey,'sdssc') then begin
							plots, Object.RA2000*[1,1], Object.Dec2000*[1,1], PSym=(Symbol+j), $
								Color=FSC_Color(Colors[j])
							if j EQ 0 then $
								xyouts, Object.RA2000, Object.Dec2000, $
									string(list_count,Format='(I3)'), /Data, Color=FSC_Color(Colors[j])
						endif else begin
							ad2xy, Object.RA2000, Object.Dec2000, S2KB.Astrom, normx, normy
							plots, normx*[1,1]/(size(S2KB.Image))[1], normy*[1,1]/(size(S2KB.Image))[2], $
								PSym=Symbol, Color=FSC_Color(Colors[j]), /Norm
							if j EQ 0 then $
								xyouts, normx/(size(S2KB.Image))[1], normy/(size(S2KB.Image))[2], $
									string(list_count,Format='(I3)'), /Norm, Color=FSC_Color(Colors[j])
						endelse
					endif
				endfor
			endif
		endif

		list_count += 1
	endelse
endfor

if list_count NE 0 then begin
	ned_list = ned_list[0:(list_count-1)]
	widget_control, s2kb_setup.NListID, set_value=ned_list
endif

end
