pro setup2, RA=RA, Dec=Dec, Offset=Offset, Hours=Hours

common setup2_state, s2kb_setup, s2kb, north, south

; Setup the GUI interface and all of the data structures we need ; to control the flow of the 
; information between the subroutines.
;+ s2kb_setup -> main structure that handles the control
s2kb_setup = {baseID: 0L, RAID: 0L, DecID: 0L, oRAID: 0L, oDecID: 0L, cRAID: 0L, cDecID: 0L, $
	      AOverButton: 0L, NOverButton: 0L, AOverlay: 1, NOverlay: 1, AListID: 0L, NListID: 0L, $
	      s2kbwin: 0L, ngdwin: 0L, sgdwin: 0L, $
	      MagID: 0L, MagLimit: 14.5, $
	      ra: 0.0, dec: 0.0, offset: [0.0, 0.0], $
	      ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, $
	      jpeg_dir: strarr(1), jpeg_file: strarr(1), printer: strarr(1)}
;+ s2kb -> strucuture that deals with the S2KB image field-of-view
s2kb  = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, image: dblarr(1470,1470)}
;+ north * south -> structures that deal with the guider camera fields-of-view
north = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, image: dblarr(412,412)   }
south = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, image: dblarr(412,412)   }

; Widget setup
;+ Main Widget Base
main = widget_base(Title="Setup S2KB", /Column, /Align_Left, mbar=menu)
s2kb_setup.baseID = main

;+ Menu Bar
fmenu = widget_button(menu, value=' File ')
  jpeg_button = widget_button(fmenu, value=' Export JPEG ', event_pro='setup2_jpeg')
  print_button = widget_button(fmenu, value=' Print ', event_pro='setup2_print')
  exit_button = widget_button(fmenu, value=' Exit ', uvalue='exit_setup', /Separator)
hmenu = widget_button(menu, value=' Help ')
  about_button = widget_button(hmenu, value=' About ', uvalue='about_view')

;+ Upper Widget Base (coordinates, guide camera limiting magnitude, overlays)
upper = widget_base(main, /Row)
  left = widget_base(upper, /Column, /Frame)
    text = widget_label(left, value=' S2KB Pointing ')
    sub1 = widget_base(left, /Row)
    sub2 = widget_base(left, /Row)
      text = widget_label(sub1, value="Initial RA:  ")
      s2kb_setup.RAID = widget_text(sub1, value='00 00 00.0', uvalue='show', /Editable, XSize=11)
      text = widget_label(sub1, value="    Offset RA:  ")
      s2kb_setup.oRAID = widget_text(sub1, value='   0', uvalue='show', /Editable, XSize=6)
      text = widget_label(sub1, value="    Current RA:  ")
      s2kb_setup.cRAID = widget_label(sub1, value='00 00 00.0')
      text = widget_label(sub2, value="Initial Dec: ")
      s2kb_setup.DecID = widget_texT(sub2, value='+00 00 00', uvalue='show', /Editable, XSize=11)
      text = widget_label(sub2, value="    Offset Dec: ")
      s2kb_setup.oDecID = widget_text(sub2, value='   0', uvalue='show', /Editable, XSize=6)
      text = widget_label(sub2, value="    Current Dec: ")
      s2kb_setup.cDecID = widget_label(sub2, value='+00 00 00')
  right = widget_base(upper, /Column, /Frame)
    text = widget_label(right, value='   Guide Camera   ')
    s2kb_setup.MagID = widget_label(right, value='Current: 14.5 ')
    sub3 = widget_base(right, /Row)
      button_mup = widget_button(sub3, value=' +0.5 ', uvalue='inc_mag_limit')
      button_mdn = widget_button(sub3, value=' -0.5 ', uvalue='dec_mag_limit')
  moreright = widget_base(upper, /Column, /Frame)
    text = widget_label(moreright, value='   Overlays   ')
    label = widget_label(moreright, value=' ALFAFLA: ')
    s2kb_setup.AOverButton = widget_button(moreright, value=' Yes ', uvalue='alfalfa')
    label = widget_label(moreright, value=' NED:     ')
    s2kb_setup.NOverButton = widget_button(moreright, value=' Yes ', uvalue='ned')

;+ Middle Widget Base (S2KB field-of-view, guide camera fields-of-view)
middle = widget_base(main, /Row)
  left = widget_base(middle, /Column)
    label = widget_label(left, value='S2KB Field')
    s2kb_setup.s2kbwin = widget_draw(left, XSize=512, YSize=512, /Frame, $
	    /Button_Events, Event_Pro='setup2_display_event')
    s2kb.WinID = s2kb_setup.s2kbwin

    lower = widget_base(left, /Row, /Align_Center)
      abase = widget_base(lower, /Column)
        label = widget_label(abase, value='ALFALFA Sources (green):')
        s2kb_setup.AListID = widget_list(abase, /Frame, XSize=35, YSize=7, value='', uvalue='ALFAClick')
      nbase = widget_base(lower, /Column)
        label = widget_label(nbase, value='NED Sources (yellow/orange):')
        s2kb_setup.NListID = widget_list(nbase, /Frame, XSize=35, YSize=7, value='', uvalue=NEDClick)

  right = widget_base(middle, /Column)
    label = widget_label(right, value='North Guide Camera')
    s2kb_setup.ngdwin = widget_draw(right, XSize=256, YSize=256, /Frame)
    label = widget_label(right, value='South Guide Camera')
    s2kb_setup.sgdwin = widget_draw(right, XSize=256, YSize=256, /Frame)
    north.WinID = s2kb_setup.ngdwin
    south.WinID = s2kb_setup.sgdwin

    obase = widget_base(right, /Align_Left, /Column)
    label = widget_label(obase, value=' ')
    label = widget_label(obase, value='Field Center:  Purple Square')
    label = widget_label(obase, value='Field of View: Green Box')
    label = widget_label(obase, value='CCD Defects:   Red Lines')
    label = widget_label(obase, value=' ')
    button = widget_button(obase, value=' Show Field ', uvalue='show')

widget_control, main, /realize
xmanager, 'setup2', main, /No_Block

; Initialize the values for RA, Dec, and Offset if they are specified on the command line
; Offset has some catches to it like needing to be a 2-elements int, float, or double 
; array.
if n_elements(RA) NE 0 then begin
	;+ If the Hours keyword is set then what is entered for RA is in HOURS
	;+ not degrees
	fact = 1.0
	if Keyword_Set(Hours) then fact = 15.0

	;+ If RA is a string, parse it and convert it to decimal hours
	if size(RA,/Type) EQ 7 then begin
		temp = float( strsplit(RA, '[hdms:]', /Extract) )
		print,temp
		RA = fact*ten(temp)
	endif else RA = fact * RA

	;+ Update s2kb_setup
	s2kb_setup.ra = RA
	s2kb_setup.offset = [0.0, 0.0]

	;+ Update the GUI
	new_ra = string(sixty(RA/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
	widget_control, s2kb_setup.RAID,  set_value=new_ra
	widget_control, s2kb_setup.cRAID, set_value=new_ra
	widget_control, s2kb_setup.oRAID, set_value='0'
endif
if n_elements(Dec) NE 0 then begin
	if size(Dec,/Type) EQ 7 then begin
		temp = float( strsplit(Dec, '[hdms:]', /Extract) )
		print,temp
		Dec = ten(temp)
	endif
	
	s2kb_setup.dec = Dec
	s2kb_setup.offset = [0.0, 0.0]

	new_dec = string(sixty(Dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
	widget_control, s2kb_setup.DecID,  set_value=new_dec
	widget_control, s2kb_setup.cDecID, set_value=new_dec
	widget_control, s2kb_setup.oDecID, set_value='0'
endif
; If we don't have have a correct (2-elements int, float, or double) for Offset, do nothin
temp = size(Offset, /Type)
if n_elements(Offset) EQ 2 AND (temp EQ 2 OR temp EQ 4 or temp EQ 5) then begin
	;+ Save the offset
	s2kb_setup.offset = float(Offset)

	;+ Apply the offset
	s2kb_setup.ra = (s2kb_setup.ra + s2kb_setup.offset[0]/3600.0)
	s2kb_setup.ra = (s2kb_setup.ra + 360) mod 360
	s2kb_setup.dec = s2kb_setup.dec + s2kb_setup.offset[1]/3600.0

	;+ Display the new center and the offset
	new_ra  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
	new_dec = string(sixty(s2kb_setup.dec,     /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
	widget_control, s2kb_setup.cRAID, set_value=new_ra
	widget_control, s2kb_setup.cDecID, set_value=new_dec
	widget_control, s2kb_setup.oRAID,  set_value = strcompress(string(round(Offset[0])))
	widget_control, s2kb_setup.oDecID, set_value = strcompress(string(round(Offset[1])))
endif

end


; setup2_event - Event handler for non-graphical events.  
pro setup2_event, event

common setup2_state

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	;+ Increase limiting magnitude for guide camera GSC overlays, refresh guider displays
	'inc_mag_limit': begin
		c_mag = s2kb_setup.MagLimit
		c_mag = c_mag + 0.5

		Widget_control, s2kb_setup.MagID, set_value=string(c_mag, Format='("Current: ",(F4.1))')
		s2kb_setup.MagLimit = c_mag

		update_guider, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	;+ Decrease limiting magnitude for guide camera GSC overlays, refresh guider displays
	'dec_mag_limit': begin
		c_mag = s2kb_setup.MagLimit
		c_mag = c_mag - 0.5

		widget_control, s2kb_setup.MagID, set_value=string(c_mag, Format='("Current: ",(F4.1))')
		s2kb_setup.MagLimit = c_mag

		update_guider, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Enable overlay of ALFALFA sources, refresh S2KB display
	'alfalfa': begin
		widget_control, s2kb_setup.AOverButton, get_value=status
		if strcmp(status,' Yes ') then begin
			s2kb_setup.AOverlay = 0
			widget_control, s2kb_setup.AOverButton, set_value=' No '
		endif else begin
			s2kb_setup.AOverlay = 1
			widget_control, s2kb_setup.AOverButton, set_value=' Yes '
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	;+ Enable overlay of NED sources, refresh S2KB display
	'ned': begin
		widget_control, s2kb_setup.NOverButton, get_value=status
		if strcmp(status,' Yes ') then begin
			s2kb_setup.NOverlay = 0
			widget_control, s2kb_setup.NOverButton, set_value=' No '
		endif else begin
			s2kb_setup.NOverlay = 1
			widget_control, s2kb_setup.NOverButton, set_value=' Yes '
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Update all displays when the show button is clicked
	'show': begin
		widget_control, s2kb_setup.RAID,   get_value=ra_string
		widget_control, s2kb_setup.DecID,  get_value=dec_string
		widget_control, s2kb_setup.oRAID,  get_value=off_ra_string
		widget_control, s2kb_setup.oDecID, get_value=off_dec_string

		ra_array = strsplit(ra_string, ' ', /Extract)
		s2kb_setup.ra = 15.0*ten(float(ra_array))
		dec_array = strsplit(dec_string, ' ', /Extract)
		s2kb_setup.dec = ten(float(dec_array))
		s2kb_setup.offset = float( [off_ra_string, off_dec_string] )

		s2kb_setup.ra = (s2kb_setup.ra + s2kb_setup.offset[0]/3600.0)
		s2kb_setup.ra = (s2kb_setup.ra + 360) mod 360
		s2kb_setup.dec = s2kb_setup.dec + s2kb_setup.offset[1]/3600.0

		new_ra  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
		new_dec = string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
		
		widget_control, s2kb_setup.cRAID,  set_value=new_ra
		widget_control, s2kb_setup.cDecID, set_value=new_dec

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec
		update_guider, s2kb_setup.ra, s2kb_setup.dec
	end

	;+ About setup2
	'about_view': begin
		h = ['Setup S2KB - Graphical utility for determin- ', $
		     'ing pointings and guide stars for S2KB when  ', $
		     'used on the WINY 0.9m.                       ', $
		     '                                             ', $
		     '  Written, May 2008                          ', $
		     '                                             ', $
		     '  Last update, Tuesday, May 20, 2008         ']
		
		if NOT xregistered('setups2kb_help', /NoShow) then begin
			about_base =  widget_base(group_leader=s2kb_setup.baseID, title='Setup S2KB - About', $
				/Column, /Base_Align_Right, uvalue = 'about_base')
			about_text = widget_text(about_base, /Scroll, value = h, xsize = 45, ysize = 10)
			about_done = widget_button(about_base, value = ' Done ', uvalue = 'exit_about', $
				event_pro='setup2_event')
			
			widget_control, about_base, /realize
			xmanager, 'setups2kb_help', about_base, /no_block
		endif
	end
	'exit_about': begin
		widget_control, event.top, /destroy
	end

	;+ Exit
	'exit_setup': begin
		widget_control, event.top, /Destroy	
	end
	else:
endcase

end


pro setup2_display_event, event

common setup2_state

widget_control, s2kb.WinID, get_value=index
wset, index

Event_Types = ['DOWN', 'UP', 'MOTION', '?', '?', '?', '?']
This_Event = Event_Types[event.type]
case This_Event of
	'DOWN'  : begin
		hor, s2kb.ramax, s2kb.ramin
		ver, s2kb.decmin, s2kb.decmax

		result = convert_coord(event.x, event.y, /Device, /Double, /To_Norm)
		xdata = s2kb.ramax  + result[0]*(s2kb.ramin -s2kb.ramax )
		ydata = s2kb.decmin + result[1]*(s2kb.decmax-s2kb.decmin)

		widget_control, s2kb_setup.RAID,  get_value=ra_string
		widget_control, s2kb_setup.DecID, get_value=dec_string
		
		old_ra = 15.0*ten(float(strsplit(ra_string, ' ', /Extract)))
		old_dec = ten(float(strsplit(dec_string, ' ', /Extract)))


		new_ra  = string(sixty(xdata/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
		new_dec = string(sixty(ydata, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')

		offset_ra  = round( (xdata -  old_ra)*cos(s2kb_setup.dec/!radeg)*3600.0 )
		offset_dec = round( (ydata - old_dec)*3600.0 )

		new_off_ra  = strcompress(string(offset_ra))
		new_off_dec = strcompress(string(offset_dec))

		widget_control, s2kb_setup.cRAID,  set_value=new_ra
		widget_control, s2kb_setup.cDecID, set_value=new_dec
		widget_control, s2kb_setup.oRAID,  set_value=new_off_ra
		widget_control, s2kb_setup.oDecID, set_value=new_off_dec

		s2kb_setup.ra = (xdata+360) mod 360
		s2kb_setup.dec = ydata
		s2kb_setup.offset = [offset_ra, offset_dec]
		
		update_s2kb,  s2kb_setup.ra, s2kb_setup.dec
		update_guider,s2kb_setup.ra, s2kb_setup.dec
	end
	else:
endcase

end


pro update_s2kb, ra, dec, Refresh=Refresh, Export=Export

common setup2_state

BoxOff = [0, 0]
if Keyword_Set(Export) then BoxOff = [20, 296] else begin
	widget_control, s2kb.WinID, get_value=index
	wset, index
endelse

s2kb.ramin =  ra  - 25.0/2.0/60.0
s2kb.ramax =  ra  + 25.0/2.0/60.0
s2kb.decmin = dec - 25.0/2.0/60.0
s2kb.decmax = dec + 25.0/2.0/60.0

if NOT Keyword_Set(Refresh) then begin
	querydss, [ra, dec], opticaldssimage, Hdr, survey='2b', imsize=25.0, /STSCI

	temp = s2kb
	s2kb = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: opticaldssimage}
	DelVarX, temp
endif

tvscl, congrid(s2kb.image,512,512), BoxOff[0], BoxOff[1]
if Keyword_Set(Export) then $
	tv, 255B-bytscl(congrid(s2kb.image,512,512)), BoxOff[0], BoxOff[1]

update_overlay_defect, ra, dec, index, Export=Export
if s2kb_setup.AOverlay AND NOT Keyword_Set(Export) then begin
	widget_control, s2kb_setup.AListID, Sensitive=1
	update_overlay_alfalfa, ra, dec, index, Export=Export
endif
if s2kb_setup.NOverlay AND NOT Keyword_Set(Export) then begin
	widget_control, s2kb_setup.NListID, Sensitive=1
	update_overlay_ned, ra, dec, index, Export=Export
endif
end



pro update_guider, ra, dec, Refresh=Refresh, Export=Export

common setup2_state

BoxOff = [0, 0]
BoxPos = [0, 0, 1, 1]
if Keyword_Set(Export) then begin
	BoxOff = [20, 20]
	BoxPos = [0.031, 0.024, 0.431, 0.333]
endif else begin
	widget_control, s2kb_setup.ngdwin, get_value=index
	wset, index
endelse

nra = ra + 0.0/3600.0
nra = (nra+360) mod 360
ndec = dec + 2610.0/3600.0

if NOT Keyword_Set(Refresh) then begin
	querydss, [nra, ndec], opticaldssimage, Hdr, survey='2b', imsize=7.0, /STSCI

	temp = north
	north = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: opticaldssimage}
	DelVarX, temp
endif

tvscl,congrid(north.image,256,256), BoxOff[0], BoxOff[1]
if Keyword_Set(Export) then begin
	loadct, 0
	tv, 255B-bytscl(congrid(north.image,256,256)), BoxOff[0], BoxOff[1]
endif


plot, [0,0], XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, pos=BoxPos, /NoErase
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')

nstars = queryvizieR('GSC2.3', [nra, ndec], [7.0, 7.0], /Canada, /AllColumns)
valid = where( nstars.vmag LE s2kb_setup.MagLimit and finite(nstars.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(nstars.dej2000[valid]/!radeg)*(-(nstars.raj2000)[valid]+nra)*3600.0/0.2 + 1050
	y = ((nstars.dej2000)[valid]-ndec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((nstars.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif

if Keyword_Set(Export) then begin
	BoxOff = [364, 20]
	BoxPos = [0.569, 0.024, 0.969, 0.333]
endif else begin
	widget_control, s2kb_setup.sgdwin, get_value=index
	wset, index
endelse

sra = ra + 25.0/3600.0
sra = (sra+360) mod 360
sdec = dec - 2410.0/3600.0

if NOT Keyword_Set(Refresh) then begin
	querydss, [sra, sdec], opticaldssimage, Hdr, survey='2b', imsize=7.0, $
		/STSCI

	temp = south
	south = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: opticaldssimage}
	DelVarX, temp
endif

tvscl,congrid(south.image,256,256), BoxOff[0], BoxOff[1]
if Keyword_Set(Export) then $
	tv, 255B-bytscl(congrid(south.image,256,256)), BoxOff[0], BoxOff[1]

plot, [0,0], XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, pos=BoxPos, /NoErase
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')

sstars = queryvizier('GSC2.3', [sra, sdec], [7.0, 7.0], /Canada, /AllColumns)
valid = where( sstars.vmag LE s2kb_setup.MagLimit and finite(sstars.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(sstars.dej2000[valid]/!radeg)*(-(sstars.raj2000)[valid]+sra)*3600.0/0.2 + 1050
	y = ((sstars.dej2000)[valid]-sdec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((sstars.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif

end



pro update_overlay_alfalfa, ra, dec, windex, Export=Export

common setup2_state

BoxPos = [0,0,1,1]
if Keyword_Set(Export) then BoxPos=[0.031, 0.357, 0.831, 0.976] else wset, windex

hor, s2kb.ramax, s2kb.ramin
ver, s2kb.decmin, s2kb.decmax
plot, [0,0], /NoErase, /NoData, XRange=[s2kb.ramax, s2kb.ramin], YRange=[s2kb.decmin, s2kb.decmax], XStyle=5, YStyle=5, Pos=BoxPos

path_list = ['/data/jdowell/ALFALFA/targets_s/', '/data/jdowell/ALFALFA/targets_f/']

disp_list = strarr(101)
list_count = 0
for p=0L,(n_elements(path_list)-1) do begin
	files_full = file_search(path_list[p], 'HI*.cln2')
	files_name = file_basename(files_full)

	alfa_ra  = float(strmid(files_name, 2,2)) + float(strmid(files_name, 4,2))/60.0 + float(strmid(files_name, 6,4))/3600.0
	alfa_dec = float(strmid(files_name,11,2)) + float(strmid(files_name,13,2))/60.0 + float(strmid(files_name,15,2))/3600.0
	is_neg = where( strcmp(strmid(files_name,10,1),'-') )
	if is_neg[0] NE -1 then alfa_dec[is_neg] = -alfa_dec[is_neg]

	for n=0L,(n_elements(files_name)-1) do begin
		x =  15.0*alfa_ra[n]
		y = alfa_dec[n]
		if x GT s2kb.ramin AND x LT s2kb.ramax AND y GT s2kb.decmin AND y LT s2kb.decmax then begin
			restore, files_full[n]
			plots, [x,x], [y,y], PSym=6, Color=FSC_Color('Green')
			xyouts, x, y, string(list_count,Format='(I2)'), Color=FSC_Color('Green')

			print, string(list_count,Format='(I2)')+'  '+string(files_name[n],Format='(A-17)')+'       @ ' $
						+string((src.spectra.vcen)[0],Format='(I6)')
			
			disp_list[list_count] = string(list_count,Format='(I2)')+': '+strmid(files_name[n],0,17)+' @ '+string((src.spectra.vcen)[0],Format='(I6)')
			list_count += 1
		endif
	endfor
endfor

if NOT Keyword_Set(Export) AND list_count NE 0 then begin
	widget_control, s2kb_setup.AListID, set_value=disp_list
endif

end



pro update_overlay_ned, ra, dec, windex, Export=Export

common setup2_state

BoxPos = [0,0,1,1]
if Keyword_Set(Export) then BoxPos=[0.031, 0.357, 0.831, 0.976] else wset, windex

hor, s2kb.ramax, s2kb.ramin
ver, s2kb.decmin, s2kb.decmax
plot, [0,0], /NoErase, /NoData, XRange=[s2kb.ramax, s2kb.ramin], YRange=[s2kb.decmin, s2kb.decmax], XStyle=5, YStyle=5, Pos=BoxPos

nedquery, (ra)[0], (dec)[0], 12.5*sqrt(2.0), numberinfo=ncount, string_array=result
ncount = long(strmid(ncount[0],0,3))
if ncount GT 0 then begin
	ned_list = strarr(ncount)

	;+ Extract names for all objects -> names
	names = strtrim(strmid(result, 0, 33),2)

	;+ Extract object coordinates for all of the objects.  These get stored in 
	; ras and decs.
	  temp1 = strmid(result, 33, 12)
	  temp2 = strmid(temp1, 0, 2)
	  temp3 = strmid(temp1, 3, 2)
	  temp4 = strmid(temp1, 6, 4)
	ras = 15.0*tenv(temp2, temp3, temp4)
	  temp1 = strmid(result, 45, 11)
	  temp2 = strmid(temp1, 0, 3)
	  temp3 = strmid(temp1, 4, 2)
	  temp4 = strmid(temp1, 7, 2)
	decs = tenv(temp2, temp3, temp4)

	;+ Extract Types for all objects -> typ
	typ = strtrim(strmid(result, 56, 7),2)

	;+ Extract Velocities for all objects -> str_vels
	str_vels = strtrim(strmid(result, 63, 6),2)
	
	;+ Begin printing out what we know
	to_disp = 0
	list_count = 0
	for n=0,ncount-1 do begin
		;+ Series of filters to clean out certain undesirable objects
		tempG = strcmp(typ[n], 'G')
		tempGG = strcmp(typ[n], 'GPair') OR strcmp(typ[n], 'GTrpl') OR strcmp(typ[n], 'GGroup') OR strcmp(typ[n], 'GClstr')
		if (tempG+tempGG) EQ 0 then continue

		;+ First, catch those outside the square field of view
		if ras[n] LT s2kb.ramin OR ras[n] GT s2kb.ramax OR decs[n] LT s2kb.decmin OR decs[n] GT s2kb.decmax then $
			continue

		;+ First, catch those with unknown velocities -> orange
		temp1 = strcmp(str_vels[n], '...') + strcmp(str_vels[n], '>75000')
		if temp1 NE 0 then begin
			plots, [ras[n], ras[n]], [decs[n], decs[n]], $
				PSym=5, Color=FSC_Color('Orange')
		endif else begin
			if float(str_vels[n]) LT 9300 then begin 
				plots, [ras[n], ras[n]], [decs[n], decs[n]], PSym=5, $
					Color=FSC_Color('Yellow')
				xyouts, ras[n], decs[n], string(list_count,Format='(I2)'), $
					/Data, Color=FSC_Color('Yellow')

				ned_list[list_count] = string(list_count,Format='(I2)')+': '+names[n]+' ['+typ[n]+'] @ '+str_vels[n]
				list_count = list_count + 1
			endif else begin
				plots, [ras[n], ras[n]], [decs[n], decs[n]], $
					PSym=5, Color=FSC_Color('Orange')
			endelse
		endelse
	endfor
	if NOT Keyword_Set(Export) AND list_count NE 0 then begin
		ned_list = ned_list[0:list_count-1]
		widget_control, s2kb_setup.NListID, set_value=ned_list
	endif
endif

end


pro update_overlay_defect, ra, dec, windex, Export=Export

common setup2_state

BoxPos = [0,0,1,1]
if Keyword_Set(Export) then BoxPos=[0.031, 0.357, 0.831, 0.976] else wset, windex

plot, [0,0], /NoErase, XRange=[1,2500],XStyle=5,YRange=[1,2500],YStyle=5, Pos=BoxPos
if Keyword_Set(Export) then begin
	oplot, [79, 79]+1250,[-280, 1024]+1250, Color=FSC_Color('Black')
	oplot, [-513, -513]+1250, [108, 1024]+1250, Color=FSC_Color('Black')
	oplot, 1024*[-1, -1, 1, 1, -1]+1250, 1024*[-1, 1, 1, -1, -1]+1250, Color=FSC_Color('Black')
endif else begin
	oplot, [1250, 1250], [1250, 1250], Color=FSC_Color('Purple'), PSym=6
	oplot, [79, 79]+1250,[-280, 1024]+1250, Color=FSC_Color('Red')
	oplot, [-513, -513]+1250, [108, 1024]+1250, Color=FSC_Color('Red')
	oplot, 1024*[-1, -1, 1, 1, -1]+1250, 1024*[-1, 1, 1, -1, -1]+1250, Color=FSC_Color('Green')
endelse

end



pro setup2_jpeg, event

common setup2_state

if NOT xregistered('setup2_jpeg', /NoShow) then begin
	jpeg_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Export JPEG', uvalue = 'jpeg_output_base')

	cd, current=pwd  ;Get current working directory into a string
	ra_str  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02),(I02),(F04.1))')
	dec_str = string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03),(I02),(I02))')

	directorybase=widget_base(jpeg_output_base, /Column)
	  label=widget_label(directorybase, value='Output Directory:')
	  s2kb_setup.jpeg_dir  = widget_text(directorybase, xsize=40, value=pwd+'/', /Editable, uvalue='dir')
	  s2kb_setup.jpeg_file = widget_text(directorybase, xsize=40, value='setup_s2kb_'+ra_str+dec_str+'.jpg', /Editable, uvalue='file')
	
	buttonbase=widget_base(jpeg_output_base, xsize=100,ysize=100, /align_right, /column)
	  jpeg_output_export = widget_button(buttonbase, value = ' Export ', uvalue = 'export', event_pro='setup2_jpeg_event')
	  cancel=widget_button(buttonbase, value=' Cancel ', uvalue='cancel', event_pro='setup2_jpeg_event')
	
	widget_control, jpeg_output_base, /realize
	xmanager, 'setup2_jpeg', jpeg_output_base, /no_block
endif

end




pro setup2_jpeg_event, event

common setup2_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'export': begin
		widget_control, s2kb_setup.jpeg_dir, get_value=path
		widget_control, s2kb_setup.jpeg_file, get_value=filename
		filename = path+filename

		thisDevice=!d.name
		set_plot, 'Z', /COPY
			
		Device, Set_Resolution=[640, 828], Z_Buffer=0
		Erase, 'FFFFFF'XL
		loadct, 0, /Silent

		tv, 255B-bytscl(congrid( s2kb.image,512,512)),  20, 296
		tv, 255B-bytscl(congrid(north.image,256,256)),  20,  20
		tv, 255B-bytscl(congrid(south.image,256,256)), 364,  20

		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.357, 0.831, 0.976], $
			XRange=[1,2500], XStyle=5, YRange=[1,2500], YStyle=5
		oplot, [79, 79]+1250,[-280, 1024]+1250, Color=FSC_Color('Black')
		oplot, [-513, -513]+1250, [108, 1024]+1250, Color=FSC_Color('Black')
		oplot, 1024*[-1, -1, 1, 1, -1]+1250, 1024*[-1, 1, 1, -1, -1]+1250, Color=FSC_Color('Black')

		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.024, 0.431, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Black')

		plot, [0,0], /NoData, /NoErase, Pos=[0.569, 0.024, 0.969, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Black')

		xyouts, 0.431, 0.980, 'S2KB', /Norm, Alignment=0.5, Color='000000'XL
		xyouts, 0.231, 0.337, 'North Guide Camera', /Norm, Alignment=0.5, Color='000000'XL
		xyouts, 0.769, 0.337, 'South Guide Camera', /Norm, Alignment=0.5, Color='000000'XL
		
		xyouts, 0.845, 0.970, 'RA:  '+string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))'), /Norm, $
			Color='000000'XL, CharSize=0.8
		xyouts, 0.845, 0.955, 'Dec: '+string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))'), /Norm, $
			Color='000000'XL, CharSize=0.8

		snapshot=tvrd()
		tvlct, r,g,b, /get
		device, Z_Buffer=1
		set_plot, thisDevice
			
		image24 = BytArr(3, 640, 828)
		image24[0,*,*] = r[snapshot]
		image24[1,*,*] = g[snapshot]
		image24[2,*,*] = b[snapshot]
		
		write_jpeg, filename, image24, true=1, quality=100

		widget_control, event.top, /destroy
	end
	'cancel': begin
		widget_control, event.top, /destroy
	end
	else: 
endcase

end




pro setup2_print, event

common setup2_state

if NOT xregistered('setup2_print', /NoShow) then begin
	print_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Print', uvalue = 'print_output_base')

	buttonbase=widget_base(print_output_base, xsize=100,ysize=100, /align_right, /column)
	  print_output_print = widget_button(buttonbase, value = ' Print ', uvalue = 'print', event_pro='setup2_print_event')
	  cancel=widget_button(buttonbase, value=' Cancel ', uvalue='cancel', event_pro='setup2_print_event')
	
	widget_control, print_output_base, /realize
	xmanager, 'setup2_print', print_output_base, /no_block
endif

end




pro setup2_print_event, event

common setup2_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'print': begin
		thisDevice=!d.name
		set_plot, 'PS'
			
		Device, filename='~/setup_temp.ps', /Portrait, /Encapsulated, /Inches, $
			XSize=8.5, YSize=11.
		loadct, 0, /Silent

		tvimage, 255B-bytscl(congrid( s2kb.image,512,512)), Pos=[0.031, 0.357, 0.831, 0.976]
		tvimage, 255B-bytscl(congrid(north.image,256,256)), Pos=[0.031, 0.024, 0.431, 0.333]
		tvimage, 255B-bytscl(congrid(south.image,256,256)), Pos=[0.569, 0.024, 0.969, 0.333]

		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.357, 0.831, 0.976], $
			XRange=[1,2500], XStyle=5, YRange=[1,2500], YStyle=5
		oplot, [79, 79]+1250,[-280, 1024]+1250, Color=FSC_Color('Black'), Thick=2.0
		oplot, [-513, -513]+1250, [108, 1024]+1250, Color=FSC_Color('Black'), Thick=2.0
		oplot, 1024*[-1, -1, 1, 1, -1]+1250, 1024*[-1, 1, 1, -1, -1]+1250, Color=FSC_Color('Black'), Thick=4.0

		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.024, 0.431, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Black'), Thick=4.0

		plot, [0,0], /NoData, /NoErase, Pos=[0.569, 0.024, 0.969, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Black'), Thick=4.0

		xyouts, 0.431, 0.980, 'S2KB', /Norm, Alignment=0.5, Color='000000'XL
		xyouts, 0.231, 0.337, 'North Guide Camera', /Norm, Alignment=0.5, Color='000000'XL
		xyouts, 0.769, 0.337, 'South Guide Camera', /Norm, Alignment=0.5, Color='000000'XL
		
		xyouts, 0.845, 0.970, 'RA:  '+string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))'), /Norm, $
			Color='000000'XL, CharSize=0.8
		xyouts, 0.845, 0.955, 'Dec: '+string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))'), /Norm, $
			Color='000000'XL, CharSize=0.8

		device, /close
		set_plot, thisDevice
			
		;spawn, 'lp ~/setup_temp.ps'
		spawn, 'rm -rf ~/setup_temp.ps'

		widget_control, event.top, /destroy
	end
	'cancel': begin
		widget_control, event.top, /destroy
	end
	else: 
endcase

end
