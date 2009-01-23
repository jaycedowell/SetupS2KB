pro setup_s2kb, RA=RA, Dec=Dec, Offset=Offset, Hours=Hours

common setup_s2kb_state, s2kb_setup, ned_control, s2kb, north, south

; Setup the GUI interface and all of the data structures we need ; to control the flow of the 
; information between the subroutines.
;+ s2kb_setup -> main structure that handles the control
s2kb_setup = {baseID: 0L, RAID: 0L, DecID: 0L, oRAID: 0L, oDecID: 0L, cRAID: 0L, cDecID: 0L, $
	      view_full_button: 0L, view_half_button: 0L, view_quat_button: 0L, view_cstm_button: 0L, $
	      use_full: 0.0, view_frame: lonarr(4), $
	      view_custom: lonarr(4), view_frame_x: 0L, view_frame_y: 0L, $
	      ned_kwn_button: 0L, ned_ukwn_button: 0L, ned_known: 0, ned_unknown: 0, $
	      ha_6580_button: 0L, ha_6620_button: 0L, ha_6660_button: 0L, ha_6700_button: 0L, $
	      ha_6740_button: 0L, ha_filters: [0, 0, 0, 0, 0], $
	      NListID: 0L, $
	      s2kbwin: 0L, ngdwin: 0L, sgdwin: 0L, $
	      MagID: 0L, MagLimit: 14.5, $
	      ra: 0.0, dec: 0.0, offset: [0.0, 0.0], $
	      ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, $
	      jpeg_dir: strarr(1), jpeg_file: strarr(1), printer: strarr(1), $
	      res_name: 0L, res_ra: -9999., res_dec: -9999. , res_coord: 0L}
ned_control = {G: 0L, GG: 0L, QSO: 0L, PofG: 0L, S: 0L, SN: 0L, $
	       U_Rad: 0L, U_Smm: 0L, U_Ifr: 0L, U_Vis: 0L, U_UlV: 0L, U_XRy: 0L, U_GRy: 0L, $
	       UseG: 0, UseGG: 0, UseQSO: 0, UsePofG: 0, UseS: 0, UseSN: 0, $
	       UseU_Rad: 0, UseU_Smm: 0, UseU_Ifr: 0, UseU_Vis: 0, UseU_UlV: 0, UseU_XRy: 0, UseU_GRy: 0}
;+ s2kb -> strucuture that deals with the S2KB image field-of-view
s2kb  = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, ned: strarr(1) }
;+ north * south -> structures that deal with the guider camera fields-of-view
north = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, image: dblarr(412,412),   gsc: strarr(1) }
south = {WinID: 0L, ramin: 0.0, ramax: 0.0, decmin: 0.0, decmax: 0.0, image: dblarr(412,412),   gsc: strarr(1) }

; Widget setup
;+ Main Widget Base
main = widget_base(Title="Setup S2KB", /Column, /Align_Left, mbar=menu)
s2kb_setup.baseID = main

;+ Menu Bar
fmenu = widget_button(menu, value=' File ')
  resolve_button = widget_button(fmenu, value=' Resolve Name ', event_pro='setup_s2kb_resolve')
  jpeg_button    = widget_button(fmenu, value=' Export JPEG  ', event_pro='setup_s2kb_jpeg', /Separator)
  print_button   = widget_button(fmenu, value=' Print        ', event_pro='setup_s2kb_print')
  exit_button    = widget_button(fmenu, value=' Exit         ', uvalue='exit_setup', /Separator)
vmenu = widget_button(menu, value=' Field of View ')
  s2kb_setup.view_full_button = widget_button(vmenu, value=' Full Frame          ', uvalue='view_full', /Checked_Menu)
  s2kb_setup.view_half_button = widget_button(vmenu, value=' 1536x1536, Centered ', uvalue='view_half', /Checked_Menu)
  s2kb_setup.view_quat_button = widget_button(vmenu, value=' 1024x1024, Centered ', uvalue='view_quat', /Checked_Menu)
  s2kb_setup.view_cstm_button = widget_button(vmenu, value=' Custom Frame        ', uvalue='view_cstm', /Checked_Menu)
  custom_button               = widget_button(vmenu, value=' Set Custom Frame    ', uvalue='set_cstm', /Separator, $
	event_pro='setup_s2kb_frame')
cmenu = widget_button(menu, value=' Display Overlays ')
  s2kb_setup.ned_kwn_button =  widget_button(cmenu, value=' NED - All Known Velocity  ', uvalue='ned_known', /Checked_Menu)
  s2kb_setup.ned_ukwn_button = widget_button(cmenu, value=' NED - Unknown Velocity    ', uvalue='ned_unknown', /Checked_Menu)
  s2kb_setup.HA_6580_button =  widget_button(cmenu, value=' Galaxies in Halpha - 6580 ', uvalue='ha_6580', /Checked_Menu, /Separator)
  s2kb_setup.HA_6620_button =  widget_button(cmenu, value=' Galaxies in Halpha - 6620 ', uvalue='ha_6620', /Checked_Menu)
  s2kb_setup.HA_6660_button =  widget_button(cmenu, value=' Galaxies in Halpha - 6660 ', uvalue='ha_6660', /Checked_Menu)
  s2kb_setup.HA_6700_button =  widget_button(cmenu, value=' Galaxies in Halpha - 6700 ', uvalue='ha_6700', /Checked_Menu)
  s2kb_setup.HA_6740_button =  widget_button(cmenu, value=' Galaxies in Halpha - 6740 ', uvalue='ha_6740', /Checked_Menu)
omenu = widget_button(menu, value=' Display Filters ')
  ned_control.G   =widget_button(omenu, value='Galaxies',          uvalue='G',/Checked_Menu)
  ned_control.GG  =widget_button(omenu, value='Galaxy Groups',     uvalue='GG',/Checked_Menu)
  ned_control.PofG=widget_button(omenu, value='Parts of Galaxies', uvalue='PofG',/Checked_Menu)
  ned_control.QSO =widget_button(omenu, value='Quasars',           uvalue='QSO',/Checked_Menu, /Separator)
  ned_control.SN  =widget_button(omenu, value='Supernovae',        uvalue='SN',/Checked_Menu)
  ned_control.S   =widget_button(omenu, value='Stars',             uvalue='S',/Checked_Menu)
  umenu           =widget_button(omenu, value='Unclassified', /Menu, /Separator)
    ned_control.U_Rad = widget_button(umenu, value=' Radio Sources     ', uvalue='U_Rad', /Checked_Menu)
    ned_control.U_Smm = widget_button(umenu, value=' Sub-mm Sources    ', uvalue='U_Smm', /Checked_Menu)
    ned_control.U_Ifr = widget_button(umenu, value=' Infrared Sources  ', uvalue='U_Ifr', /Checked_Menu)
    ned_control.U_Vis = widget_button(umenu, value=' Visual Sources    ', uvalue='U_Vis', /Checked_Menu)
    ned_control.U_UlV = widget_button(umenu, value=' UV Excess Sources ', uvalue='U_UlV', /Checked_Menu)
    ned_control.U_XRy = widget_button(umenu, value=' X-Ray Sources     ', uvalue='U_XRy', /Checked_Menu)
    ned_control.U_GRy = widget_button(umenu, value=' Gamma-Ray Sources ', uvalue='U_GRy', /Checked_Menu)

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
  right = widget_base(upper, /Column, /Frame, /Align_Center)
    text = widget_label(right, value=' Guide Camera Limiting Magnitude ')
    text = widget_label(right, value=' Current V-Band Limit: ')
    s2kb_setup.MagID = widget_text(right, value='14.5', uvalue='chg_mag_limit', /Editable, XSize=6)
    sub3 = widget_base(right, /Row)
      button_mup = widget_button(sub3, value=' +0.5 mag ', uvalue='inc_mag_limit')
      button_mdn = widget_button(sub3, value=' -0.5 mag ', uvalue='dec_mag_limit')

;+ Middle Widget Base (S2KB field-of-view, guide camera fields-of-view)
middle = widget_base(main, /Row)
  left = widget_base(middle, /Column)
    label = widget_label(left, value='S2KB Field')
    s2kb_setup.s2kbwin = widget_draw(left, XSize=512, YSize=512, /Frame, $
	    /Button_Events, Event_Pro='setup_s2kb_display_event')
    s2kb.WinID = s2kb_setup.s2kbwin

    lower = widget_base(left, /Row, /Align_Center)
      nbase = widget_base(lower, /Column)
        label = widget_label(nbase, value='NED Sources (yellow = known velocity):')
        s2kb_setup.NListID = widget_list(nbase, /Frame, XSize=70, YSize=7, value='', uvalue='NEDClick')

  right = widget_base(middle, /Column)
    label = widget_label(right, value='North Guide Camera')
    s2kb_setup.ngdwin = widget_draw(right, XSize=256, YSize=256, /Frame)
    label = widget_label(right, value='South Guide Camera')
    s2kb_setup.sgdwin = widget_draw(right, XSize=256, YSize=256, /Frame)
    north.WinID = s2kb_setup.ngdwin
    south.WinID = s2kb_setup.sgdwin

    label = widget_label(right, value=' Legend: ')
    obase = widget_base(right, /Align_Center, /Column)
      label = widget_label(obase, value=' Field Center:      Purple Square')
      label = widget_label(obase, value=' Field of View:     Green Box    ')
      label = widget_label(obase, value=' CCD Defects:       Red Lines    ')
      label = widget_label(obase, value=' Size Indicator:    White Lines  ')
      label = widget_label(obase, value=' ')
    button = widget_button(right, value=' Show Field ', uvalue='show')

widget_control, main, /realize
xmanager, 'setup_s2kb', main, /No_Block

; Setup default values
widget_control, s2kb_setup.view_full_button, Set_Button=1
s2kb_setup.use_full = 1
s2kb_setup.view_frame = [1L, 1L, 2048L, 2048L]
widget_control, s2kb_setup.ned_kwn_button, Set_Button=1
s2kb_setup.ned_known = 1
widget_control, ned_control.G, Set_Button=1
ned_control.UseG = 1

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
		temp = float( strsplit(RA, '[ hdms:]', /Extract) )
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
		temp = float( strsplit(Dec, '[ hdms:]', /Extract) )
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
	s2kb_setup.ra = (s2kb_setup.ra + 360.0) mod 360.0
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


; setup_s2kb_event - Event handler for non-graphical events.  
pro setup_s2kb_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	;+ Manually type in limiting magnitude for guide camera GSC overlays, refresh guider displays
	'chg_mag_limit': begin
		Widget_control, s2kb_setup.MagID, get_value=c_mag_string
		c_mag = min([18.0, max([float(c_mag_string), 10.0])])
		if c_mag NE float(c_mag_string) then $
			Widget_control, s2kb_setup.MagID, set_value=string(c_mag, Format='(F4.1)')
		
		s2kb_setup.MagLimit = c_mag

		update_guider, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end	
	;+ Increase limiting magnitude for guide camera GSC overlays, refresh guider displays
	'inc_mag_limit': begin
		c_mag = s2kb_setup.MagLimit
		c_mag = min([ (c_mag+0.5), 18.0 ])

		Widget_control, s2kb_setup.MagID, set_value=string(c_mag, Format='(F4.1)')
		s2kb_setup.MagLimit = c_mag

		update_guider, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	;+ Decrease limiting magnitude for guide camera GSC overlays, refresh guider displays
	'dec_mag_limit': begin
		c_mag = s2kb_setup.MagLimit
		c_mag = max([ (c_mag-0.5), 10.0 ])

		widget_control, s2kb_setup.MagID, set_value=string(c_mag, Format='(F4.1)')
		s2kb_setup.MagLimit = c_mag

		update_guider, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Switch to full field-of-view
	'view_full': begin
		if s2kb_setup.use_full NE 1 then begin
			widget_control, s2kb_setup.view_full_button, set_button = 1
			widget_control, s2kb_setup.view_half_button, set_button = 0
			widget_control, s2kb_setup.view_quat_button, set_button = 0
			widget_control, s2kb_setup.view_cstm_button, set_button = 0
			s2kb_setup.use_full = 1

			s2kb_setup.view_frame = [1L, 1L, 2048L, 2048L]

			update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
		endif
	end
	'view_half': begin
		if s2kb_setup.use_full NE 0.5 then begin
			widget_control, s2kb_setup.view_full_button, set_button = 0
			widget_control, s2kb_setup.view_half_button, set_button = 1
			widget_control, s2kb_setup.view_quat_button, set_button = 0
			widget_control, s2kb_setup.view_cstm_button, set_button = 0
			s2kb_setup.use_full = 0.5

			s2kb_setup.view_frame = [256L, 256L, 1792L, 1792L]

			update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
		endif
	end
	'view_quat': begin
		if s2kb_setup.use_full NE 0.25 then begin
			widget_control, s2kb_setup.view_full_button, set_button = 0
			widget_control, s2kb_setup.view_half_button, set_button = 0
			widget_control, s2kb_setup.view_quat_button, set_button = 1
			widget_control, s2kb_setup.view_cstm_button, set_button = 0
			s2kb_setup.use_full = 0.25

			s2kb_setup.view_frame = [512L, 512L, 1536L, 1536L]

			update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
		endif
	end
	'view_cstm': begin
		if s2kb_setup.use_full NE 0 then begin
			widget_control, s2kb_setup.view_full_button, set_button = 0
			widget_control, s2kb_setup.view_half_button, set_button = 0
			widget_control, s2kb_setup.view_quat_button, set_button = 0
			widget_control, s2kb_setup.view_cstm_button, set_button = 1
			s2kb_setup.use_full = 0

			if total(s2kb_setup.view_custom) EQ 0 then begin
				setup_s2kb_frame, 0
			endif else begin
				s2kb_setup.view_frame = s2kb_setup.view_custom
			endelse
			
			update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
		endif
	end

	;+ Enable overlay of NED sources with known velocities, refresh S2KB display
	'ned_known': begin
		if s2kb_setup.ned_known EQ 1 then begin
			widget_control, s2kb_setup.ned_kwn_button, set_button = 0
			s2kb_setup.ned_known = 0
		endif else begin
			widget_control, s2kb_setup.ned_kwn_button, set_button = 1
			s2kb_setup.ned_known = 1
		endelse

		widget_control, s2kb_setup.NListID, set_value=''
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	;+ Enable overlay of NED sources with unknown velocities, refresh S2KB display
	'ned_unknown': begin
		if s2kb_setup.ned_unknown EQ 1 then begin
			widget_control, s2kb_setup.ned_ukwn_button, set_button = 0
			s2kb_setup.ned_unknown = 0
		endif else begin
			widget_control, s2kb_setup.ned_ukwn_button, set_button = 1
			s2kb_setup.ned_unknown = 1
		endelse

		widget_control, s2kb_setup.NListID, set_value=''
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Enable Halpha filter selection rules
	'ha_6580': begin
		if s2kb_setup.ha_filters[0] EQ 1 then begin
			widget_control, s2kb_setup.ha_6580_button, set_button = 0
			s2kb_setup.ha_filters[0] = 0
		endif else begin
			widget_control, s2kb_setup.ha_6580_button, set_button = 1
			s2kb_setup.ha_filters[0] = 1
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'ha_6620': begin
		if s2kb_setup.ha_filters[1] EQ 1 then begin
			widget_control, s2kb_setup.ha_6620_button, set_button = 0
			s2kb_setup.ha_filters[1] = 0
		endif else begin
			widget_control, s2kb_setup.ha_6620_button, set_button = 1
			s2kb_setup.ha_filters[1] = 1
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'ha_6660': begin
		if s2kb_setup.ha_filters[2] EQ 1 then begin
			widget_control, s2kb_setup.ha_6660_button, set_button = 0
			s2kb_setup.ha_filters[2] = 0
		endif else begin
			widget_control, s2kb_setup.ha_6660_button, set_button = 1
			s2kb_setup.ha_filters[2] = 1
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'ha_6700': begin
		if s2kb_setup.ha_filters[3] EQ 1 then begin
			widget_control, s2kb_setup.ha_6700_button, set_button = 0
			s2kb_setup.ha_filters[3] = 0
		endif else begin
			widget_control, s2kb_setup.ha_6700_button, set_button = 1
			s2kb_setup.ha_filters[3] = 1
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'ha_6740': begin
		if s2kb_setup.ha_filters[4] EQ 1 then begin
			widget_control, s2kb_setup.ha_6740_button, set_button = 0
			s2kb_setup.ha_filters[4] = 0
		endif else begin
			widget_control, s2kb_setup.ha_6740_button, set_button = 1
			s2kb_setup.ha_filters[4] = 1
		endelse

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Update display filters
	'G': begin
		if ned_control.UseG then begin
			widget_control, NED_Control.G, Set_Button = 0
			NED_Control.UseG = 0
		endif else begin
			widget_control, NED_Control.G, Set_Button = 1
			NED_Control.UseG = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'GG': begin
		if ned_control.UseGG then begin
			widget_control, NED_Control.GG, Set_Button = 0
			NED_Control.UseGG = 0
		endif else begin
			widget_control, NED_Control.GG, Set_Button = 1
			NED_Control.UseGG = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'PofG': begin
		if ned_control.UsePofG then begin
			widget_control, NED_Control.PofG, Set_Button = 0
			NED_Control.UsePofG = 0
		endif else begin
			widget_control, NED_Control.PofG, Set_Button = 1
			NED_Control.UsePofG = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'QSO': begin
		if ned_control.UseQSO then begin
			widget_control, NED_Control.QSO, Set_Button = 0
			NED_Control.UseQSO = 0
		endif else begin
			widget_control, NED_Control.QSO, Set_Button = 1
			NED_Control.UseQSO = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'SN': begin
		if ned_control.UseSN then begin
			widget_control, NED_Control.SN, Set_Button = 0
			NED_Control.UseSN = 0
		endif else begin
			widget_control, NED_Control.SN, Set_Button = 1
			NED_Control.UseSN = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'S': begin
		if ned_control.UseS then begin
			widget_control, NED_Control.S, Set_Button = 0
			NED_Control.UseS = 0
		endif else begin
			widget_control, NED_Control.S, Set_Button = 1
			NED_Control.UseS = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_Rad': begin
		if ned_control.UseU_Rad then begin
			widget_control, NED_Control.U_Rad, Set_Button = 0
			NED_Control.UseU_Rad = 0
		endif else begin
			widget_control, NED_Control.U_Rad, Set_Button = 1
			NED_Control.UseU_Rad = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_Smm': begin
		if ned_control.UseU_Smm then begin
			widget_control, NED_Control.U_Smm, Set_Button = 0
			NED_Control.UseU_Smm = 0
		endif else begin
			widget_control, NED_Control.U_Smm, Set_Button = 1
			NED_Control.UseU_Smm = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_Ifr': begin
		if ned_control.UseU_Ifr then begin
			widget_control, NED_Control.U_Ifr, Set_Button = 0
			NED_Control.UseU_Ifr = 0
		endif else begin
			widget_control, NED_Control.U_Ifr, Set_Button = 1
			NED_Control.UseU_Ifr = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_Vis': begin
		if ned_control.UseU_Vis then begin
			widget_control, NED_Control.U_Vis, Set_Button = 0
			NED_Control.UseU_Vis = 0
		endif else begin
			widget_control, NED_Control.U_Vis, Set_Button = 1
			NED_Control.UseU_Vis = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_UlV': begin
		if ned_control.UseU_UlV then begin
			widget_control, NED_Control.U_UlV, Set_Button = 0
			NED_Control.UseU_UlV = 0
		endif else begin
			widget_control, NED_Control.U_UlV, Set_Button = 1
			NED_Control.UseU_UlV = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_XRy': begin
		if ned_control.UseU_XRy then begin
			widget_control, NED_Control.U_XRy, Set_Button = 0
			NED_Control.UseU_Xry = 0
		endif else begin
			widget_control, NED_Control.U_XRy, Set_Button = 1
			NED_Control.UseU_XRy = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end
	'U_GRy': begin
		if ned_control.UseU_GRy then begin
			widget_control, NED_Control.U_GRy, Set_Button = 0
			NED_Control.UseU_Gry = 0
		endif else begin
			widget_control, NED_Control.U_Gry, Set_Button = 1
			NED_Control.UseU_Gry = 1
		endelse
		
		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Refresh
	end

	;+ Update all displays when the show button is clicked
	'show': begin
		widget_control, s2kb_setup.RAID,   get_value=ra_string
		widget_control, s2kb_setup.DecID,  get_value=dec_string
		widget_control, s2kb_setup.oRAID,  get_value=off_ra_string
		widget_control, s2kb_setup.oDecID, get_value=off_dec_string

		ra_array = strsplit(ra_string, '[ hms:]', /Extract)
		s2kb_setup.ra = 15.0*ten(float(ra_array))
		dec_array = strsplit(dec_string, '[ dms:]', /Extract)
		s2kb_setup.dec = ten(float(dec_array))
		s2kb_setup.offset = float( [off_ra_string[0], off_dec_string[0]] )

		s2kb_setup.ra = (s2kb_setup.ra + s2kb_setup.offset[0]/3600.0)
		s2kb_setup.ra = (s2kb_setup.ra + 360.0) mod 360.0
		s2kb_setup.dec = s2kb_setup.dec + s2kb_setup.offset[1]/3600.0

		new_ra  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
		new_dec = string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
		
		widget_control, s2kb_setup.cRAID,  set_value=new_ra
		widget_control, s2kb_setup.cDecID, set_value=new_dec

		update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Init
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
				event_pro='setup_s2kb_event')
			
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


pro setup_s2kb_display_event, event

common setup_s2kb_state

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

		s2kb_setup.ra = (xdata+360.0) mod 360.0
		s2kb_setup.dec = ydata
		s2kb_setup.offset = [offset_ra, offset_dec]
		
		update_s2kb,  s2kb_setup.ra, s2kb_setup.dec
		update_guider,s2kb_setup.ra, s2kb_setup.dec
	end
	else:
endcase

end


pro update_s2kb, ra, dec, Init=Init, Refresh=Refresh

common setup_s2kb_state

widget_control, s2kb.WinID, get_value=index
wset, index

;if Keyword_Set(Refresh) then begin
;	tvscl, congrid(s2kb.image,512,512), 0, 0
;
;endif else begin
	s2kb.ramin =  ra  - 25.0/2.0/60.0
	s2kb.ramax =  ra  + 25.0/2.0/60.0
	s2kb.decmin = dec - 25.0/2.0/60.0
	s2kb.decmax = dec + 25.0/2.0/60.0
; 
; 	querydss, [ra, dec], opticaldssimage, Hdr, survey='2b', imsize=25.0, /STSCI
; 
; 	temp = s2kb
; 	s2kb = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
; 		Image: opticaldssimage, NED: temp.NED}
; 	;DelVarX, temp
; 	temp = 0
; 
; 	tvscl, congrid(s2kb.image,512,512), 0, 0
; endelse
already_done_huh = where( strcmp(tag_names(s2kb),'IMAGE') EQ 1 )
if already_done_huh NE -1 then S2KB_Tiles = s2kb.image
loadct,0,/Silent
tile_display, ra, dec, 25.0, Tiles=S2KB_Tiles, XSize=512, YSize=512

temp = s2kb
s2kb = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
	Image: S2KB_Tiles, NED: temp.NED}
;DelVarX, temp
temp = 0

update_overlay_defect, ra, dec, index
use_ned_huh = s2kb_setup.ned_known + s2kb_setup.ned_unknown + total(s2kb_setup.ha_filters)
if use_ned_huh NE 0 then begin
	update_overlay_ned, ra, dec, index, Refresh=Refresh
endif
end



pro update_guider, ra, dec, Refresh=Refresh

common setup_s2kb_state

widget_control, s2kb_setup.ngdwin, get_value=index
wset, index

nra = ra + 0.0/3600.0
nra = (nra+360.0) mod 360.0
ndec = dec + 2610.0/3600.0

if NOT Keyword_Set(Refresh) then begin
	querydss, [nra, ndec], opticaldssimage, Hdr, survey='2b', imsize=7.0, /STSCI
	nstars = queryvizier('GSC2.3', [nra, ndec], [7.0, 7.0], /AllColumns)

	temp = north
	north = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: opticaldssimage, gsc: nstars}
	;DelVarX, temp
	temp = 0
endif

tvscl,congrid(north.image,256,256), 0, 0

plot, [0,0], /NoData, /NoErase, XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, Pos=[0,0,1,1]
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')

oplot, 300*[-0.5,0.5]+300, [1,1]+100, Color=FSC_Color('White')
xyouts, 300, 120, '1''', /Data, Alignment=0.5, Color=FSC_Color('White')

valid = where( north.gsc.vmag LE s2kb_setup.MagLimit and finite(north.gsc.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(north.gsc.dej2000[valid]/!radeg)*(-(north.gsc.raj2000)[valid]+nra)*3600.0/0.2 + 1050
	y = ((north.gsc.dej2000)[valid]-ndec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((north.gsc.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif

widget_control, s2kb_setup.sgdwin, get_value=index
wset, index

sra = ra + 25.0/3600.0
sra = (sra+360.0) mod 360.0
sdec = dec - 2410.0/3600.0

if NOT Keyword_Set(Refresh) then begin
	querydss, [sra, sdec], opticaldssimage, Hdr, survey='2b', imsize=7.0, /STSCI
	sstars = queryvizier('GSC2.3', [sra, sdec], [7.0, 7.0], /AllColumns)

	temp = south
	south = {WinID: temp.WinID, RAMin: temp.ramin, RAMax: temp.ramax, DecMin: temp.decmin, DecMax: temp.decmax, $
		Image: opticaldssimage, gsc: sstars}
	;DelVarX, temp
	temp = 0
endif

tvscl,congrid(south.image,256,256), 0, 0

plot, [0,0], /NoData, /NoErase, XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, Pos=[0,0,1,1]
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')

oplot, 300*[-0.5,0.5]+300, [1,1]+100, Color=FSC_Color('White')
xyouts, 300, 120, '1''', /Data, Alignment=0.5, Color=FSC_Color('White')

valid = where( south.gsc.vmag LE s2kb_setup.MagLimit and finite(south.gsc.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(south.gsc.dej2000[valid]/!radeg)*(-(south.gsc.raj2000)[valid]+sra)*3600.0/0.2 + 1050
	y = ((south.gsc.dej2000)[valid]-sdec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((south.gsc.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif

end

	

pro update_overlay_defect, ra, dec, windex

common setup_s2kb_state

wset, windex

plot, [0,0], /NoErase, XRange=[1,2500],XStyle=5,YRange=[1,2500],YStyle=5, Pos=[0,0,1,1]
oplot, [1250, 1250], [1250, 1250], Color=FSC_Color('Purple'), PSym=6
frame = s2kb_setup.view_frame - 1024L

if 79 GT frame[0] AND 79 LT frame[2] AND -280 LT frame[3] then begin
	yrange = [max([-280, frame[1]]), min([1024, frame[3]])]
	oplot, [79, 79]+1250,yrange+1250, Color=FSC_Color('Red')
endif
if -512 GT frame[0] AND -513 LT frame[2] AND 108 LT frame[3] then begin
	yrange = [max([108, frame[1]]), min([1024, frame[3]])]
	oplot, [-513, -513]+1250, yrange+1250, Color=FSC_Color('Red')
endif
oplot, [frame[0], frame[0], frame[2], frame[2], frame[0]]+1250, $
	[frame[1], frame[3], frame[3], frame[1], frame[1]]+1250, Color=FSC_Color('Green')

oplot, 400*[-0.5,0.5]+300, [1,1]+100, Color=FSC_Color('White')
xyouts, 300, 120, '4''', /Data, Alignment=0.5, Color=FSC_Color('White')

end



pro setup_s2kb_jpeg, event

common setup_s2kb_state

if NOT xregistered('setup_s2kb_jpeg', /NoShow) then begin
	jpeg_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Export JPEG', uvalue = 'jpeg_output_base')

	cd, current=pwd  ;Get current working directory into a string
	ra_str  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02),(I02),(F04.1))')
	dec_str = string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03),(I02),(I02))')

	directorybase=widget_base(jpeg_output_base, /Column)
	  label=widget_label(directorybase, value='Output Directory:')
	  s2kb_setup.jpeg_dir  = widget_text(directorybase, xsize=40, value=pwd+'/', /Editable, uvalue='dir')
	  label=widget_label(directorybase, value='Output File Name:')
	  s2kb_setup.jpeg_file = widget_text(directorybase, xsize=40, value='setup_s2kb_'+ra_str+dec_str+'.jpg', /Editable, uvalue='file')
	
	buttonbase=widget_base(jpeg_output_base, xsize=100,ysize=100, /align_right, /column)
	  jpeg_output_export = widget_button(buttonbase, value = ' Export ', uvalue = 'export', event_pro='setup_s2kb_jpeg_event')
	  cancel=widget_button(buttonbase, value=' Cancel ', uvalue='cancel', event_pro='setup_s2kb_jpeg_event')
	
	widget_control, jpeg_output_base, /realize
	xmanager, 'setup_s2kb_jpeg', jpeg_output_base, /no_block
endif

end




pro setup_s2kb_jpeg_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'export': begin
		widget_control, s2kb_setup.jpeg_dir, get_value=path
		widget_control, s2kb_setup.jpeg_file, get_value=filename
		filename = path+filename

		thisDevice=!d.name
		set_plot, 'Z', /COPY
			
		Device, Set_Resolution=[640, 828], Z_Buffer=0
		loadct, 0, /Silent
		Erase, 255

		; Display all images (inverted)
		tv, 255B-bytscl(congrid( s2kb.image,512,512)),  20, 296
		tv, 255B-bytscl(congrid(north.image,256,256)),  20,  20
		tv, 255B-bytscl(congrid(south.image,256,256)), 364,  20

		; S2KB: field-of-view and bad column plots
		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.357, 0.831, 0.976], $
			XRange=[1,2500], XStyle=5, YRange=[1,2500], YStyle=5
		frame = s2kb_setup.view_frame - 1024L
		
		if 79 GT frame[0] AND 79 LT frame[2] AND -280 LT frame[3] then begin
			yrange = [max([-280, frame[1]]), min([1024, frame[3]])]
			oplot, [79, 79]+1250,yrange+1250, Color=0
		endif
		if -512 GT frame[0] AND -513 LT frame[2] AND 108 LT frame[3] then begin
			yrange = [max([108, frame[1]]), min([1024, frame[3]])]
			oplot, [-513, -513]+1250, yrange+1250, Color=0
		endif
		oplot, [frame[0], frame[0], frame[2], frame[2], frame[0]]+1250, $
			[frame[1], frame[3], frame[3], frame[1], frame[1]]+1250, Color=0
		
		oplot, 400*[-0.5,0.5]+300, [1,1]+100, Color=0
		xyouts, 300, 120, '4''', /Data, Alignment=0.5, Color=0


		; North Guide Camera: field-of-view and guide star labels
		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.024, 0.431, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=0
		nra = s2kb_setup.ra + 0.0/3600.0
		nra = (nra+360.0) mod 360.0
		ndec = s2kb_setup.dec + 2610.0/3600.0
		valid = where( north.gsc.vmag LE s2kb_setup.MagLimit and finite(north.gsc.vmag) EQ 1 )
		if valid[0] NE -1 then begin
			x = cos(north.gsc.dej2000[valid]/!radeg)*(-(north.gsc.raj2000)[valid]+nra)*3600.0/0.2 + 1050
			y = ((north.gsc.dej2000)[valid]-ndec)*3600.0/0.2 + 1050
			oplot, x,y, PSym=6, Color=0
			xyouts, x+100, y-100, string((north.gsc.vmag)[valid],Format='(F4.1)'),/Data, Color=0
		endif

		oplot, 300*[-0.5,0.5]+300, [1,1]+100, Color=0
		xyouts, 300, 120, '1''', /Data, Alignment=0.5, Color=0
		
		; South Guide Camera: field-of-view and guide star labels
		plot, [0,0], /NoData, /NoErase, Pos=[0.569, 0.024, 0.969, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=0
		sra = s2kb_setup.ra + 25.0/3600.0
		sra = (sra+360.0) mod 360.0
		sdec = s2kb_setup.dec - 2410.0/3600.0
		valid = where( south.gsc.vmag LE s2kb_setup.MagLimit and finite(south.gsc.vmag) EQ 1 )
		if valid[0] NE -1 then begin
			x = cos(south.gsc.dej2000[valid]/!radeg)*(-(south.gsc.raj2000)[valid]+sra)*3600.0/0.2 + 1050
			y = ((south.gsc.dej2000)[valid]-sdec)*3600.0/0.2 + 1050
			oplot, x,y, PSym=6, Color=0
			xyouts, x+100, y-100, string((south.gsc.vmag)[valid],Format='(F4.1)'),/Data, Color=0
		endif

		oplot, 300*[-0.5,0.5]+300, [1,1]+100, Color=0
		xyouts, 300, 120, '1''', /Data, Alignment=0.5, Color=0

		; Labels
		xyouts, 0.431, 0.980, 'S2KB', /Norm, Alignment=0.5, Color=0
		xyouts, 0.231, 0.337, 'North Guide Camera', /Norm, Alignment=0.5, Color=0
		xyouts, 0.769, 0.337, 'South Guide Camera', /Norm, Alignment=0.5, Color=0
		
		xyouts, 0.845, 0.966, 'RA:  '+string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))'), /Norm, $
			Color=0, CharSize=0.85
		xyouts, 0.845, 0.951, 'Dec: '+string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))'), /Norm, $
			Color=0, CharSize=0.85

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




pro setup_s2kb_print, event

common setup_s2kb_state

if NOT xregistered('setup_s2kb_print', /NoShow) then begin
	print_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Print', uvalue = 'print_output_base')

	buttonbase=widget_base(print_output_base, /align_right, /column)
	  print_output_print = widget_button(buttonbase, value = ' Print ', uvalue = 'print', event_pro='setup_s2kb_print_event')
	  cancel=widget_button(buttonbase, value=' Cancel ', uvalue='cancel', event_pro='setup_s2kb_print_event')
	
	widget_control, print_output_base, /realize
	xmanager, 'setup_s2kb_print', print_output_base, /no_block
endif

end




pro setup_s2kb_print_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'print': begin
		thisDevice=!d.name
		set_plot, 'PS'
			
		Device, filename='~/setup_temp.ps', /Portrait, /Encapsulated, /Inches, $
			XSize=7.5, YSize=10.
		loadct, 0, /Silent

		;+ Display all images
		tvimage, 255B-bytscl(congrid( s2kb.image,512,512)), Pos=[0.031, 0.357, 0.831, 0.976]
		tvimage, 255B-bytscl(congrid(north.image,256,256)), Pos=[0.031, 0.024, 0.431, 0.333]
		tvimage, 255B-bytscl(congrid(south.image,256,256)), Pos=[0.569, 0.024, 0.969, 0.333]

		; S2KB: field-of-view and bad column plots
		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.357, 0.831, 0.976], $
			XRange=[1,2500], XStyle=5, YRange=[1,2500], YStyle=5
		frame = s2kb_setup.view_frame - 1024L
		
		if 79 GT frame[0] AND 79 LT frame[2] AND -280 LT frame[3] then begin
			yrange = [max([-280, frame[1]]), min([1024, frame[3]])]
			oplot, [79, 79]+1250,yrange+1250, Thick=2.0
		endif
		if -512 GT frame[0] AND -513 LT frame[2] AND 108 LT frame[3] then begin
			yrange = [max([108, frame[1]]), min([1024, frame[3]])]
			oplot, [-513, -513]+1250, yrange+1250, Thick=2.0
		endif
		oplot, [frame[0], frame[0], frame[2], frame[2], frame[0]]+1250, $
			[frame[1], frame[3], frame[3], frame[1], frame[1]]+1250, Color=0
		
		oplot, 400*[-0.5,0.5]+300, [1,1]+100, Thick=2.0
		xyouts, 300, 120, '4''', /Data, Alignment=0.5

		; North Guide Camera: field-of-view and guide star labels
		plot, [0,0], /NoData, /NoErase, Pos=[0.031, 0.024, 0.431, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Thick=2.0
		valid = where( north.gsc.vmag LE s2kb_setup.MagLimit and finite(north.gsc.vmag) EQ 1 )
		nra = s2kb_setup.ra + 0.0/3600.0
		nra = (nra+360.0) mod 360.0
		ndec = s2kb_setup.dec + 2610.0/3600.0
		if valid[0] NE -1 then begin
			x = cos(north.gsc.dej2000[valid]/!radeg)*(-(north.gsc.raj2000)[valid]+nra)*3600.0/0.2 + 1050
			y = ((north.gsc.dej2000)[valid]-ndec)*3600.0/0.2 + 1050
			oplot, x,y, PSym=6, Thick=2.0
			xyouts, x+100, y-100, string((north.gsc.vmag)[valid],Format='(F4.1)'),/Data
		endif

		oplot, 300*[-0.5,0.5]+300, [1,1]+100, Thick=2.0
		xyouts, 300, 120, '1''', /Data, Alignment=0.5

		; South Guide Camera: field-of-view and guide star labels
		plot, [0,0], /NoData, /NoErase, Pos=[0.569, 0.024, 0.969, 0.333], $
			XRange=[1,2100], XStyle=5, YRange=[1,2100], YStyle=5
		oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Thick=2.0
		valid = where( south.gsc.vmag LE s2kb_setup.MagLimit and finite(south.gsc.vmag) EQ 1 )
		sra = s2kb_setup.ra + 25.0/3600.0
		sra = (sra+360.0) mod 360.0
		sdec = s2kb_setup.dec - 2410.0/3600.0
		if valid[0] NE -1 then begin
			x = cos(south.gsc.dej2000[valid]/!radeg)*(-(south.gsc.raj2000)[valid]+sra)*3600.0/0.2 + 1050
			y = ((south.gsc.dej2000)[valid]-sdec)*3600.0/0.2 + 1050
			oplot, x,y, PSym=6, Thick=2.0
			xyouts, x+100, y-100, string((south.gsc.vmag)[valid],Format='(F4.1)'), /Data
		endif

		oplot, 300*[-0.5,0.5]+300, [1,1]+100, Thick=2.0
		xyouts, 300, 120, '1''', /Data, Alignment=0.5

		;+ Labels
		xyouts, 0.431, 0.980, 'S2KB', /Norm, Alignment=0.5
		xyouts, 0.231, 0.337, 'North Guide Camera', /Norm, Alignment=0.5
		xyouts, 0.769, 0.337, 'South Guide Camera', /Norm, Alignment=0.5
		
		xyouts, 0.845, 0.966, 'RA:  '+string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))'), /Norm, $
			CharSize=0.85
		xyouts, 0.845, 0.951, 'Dec: '+string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))'), /Norm, $
			CharSize=0.85

		device, /close
		set_plot, thisDevice
			
		spawn, 'lp ~/setup_temp.ps'
		spawn, 'rm -rf ~/setup_temp.ps'

		widget_control, event.top, /destroy
	end
	'cancel': begin
		widget_control, event.top, /destroy
	end
	else: 
endcase

end



pro setup_s2kb_resolve, event

common setup_s2kb_state

if NOT xregistered('setup_s2kb_resolve', /NoShow) then begin
	s2kb_setup.res_ra = -9999.
	s2kb_setup.res_dec = -9999.

	resolve_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Resolve', uvalue = 'resolve_output_base')

	buttonbase=widget_base(resolve_output_base, /align_right, /column)
	  label = widget_label(buttonbase, value='Enter Name to be resolved by SIMBAD/NED: ')
	  s2kb_setup.res_name = widget_text(buttonbase, value='', uvalue='junk', /Editable, XSize=15)
	  coordbase=widget_base(buttonbase, /Row)
	    s2kb_setup.res_coord  = widget_label(coordbase, value='RA:  -- -- ----     Dec: --- -- -- ')
	  label = widget_label(buttonbase, value='  ')
          buttonbase2=widget_base(buttonbase, /Row)
	    resolve_output_resolve = widget_button(buttonbase2, value = ' Resolve ', uvalue = 'resolve')
	    resolve_output_goto    = widget_button(buttonbase2, value = '  Go To  ', uvalue='goto')
	    resolve_output_cancel  = widget_button(buttonbase2, value = ' Cancel  ', uvalue='cancel')
	
	widget_control, resolve_output_base, /realize
	xmanager, 'setup_s2kb_resolve', resolve_output_base, /no_block
endif

end



pro setup_s2kb_resolve_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'resolve': begin
		widget_control, s2kb_setup.res_name, get_value=name
		widget_control, /hourglass
		if strlen(name) NE 0 then begin
			querysimbad, name, ra, dec, Found=Found
		
			if Found then begin
				s2kb_setup.res_ra = ra
				s2kb_setup.res_dec = dec

				out_str = string(sixty(ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
				out_str = 'RA:  '+out_str+'     Dec: '
				out_str = out_str+string(sixty(dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
			endif else begin
; 				querysimbad, name, ra, dec, Found=Found, /NED
; 
; 				if Found then begin
; 					s2kb_setup.res_ra = ra
; 					s2kb_setup.res_dec = dec
; 	
; 					out_str = string(sixty(ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
; 					out_str = 'RA:  '+out_str+'     Dec: '
; 					out_str = out_str+string(sixty(dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
; 				endif else begin
					out_str = 'Name cannot be resolved.'
; 				endelse
			endelse
		endif else begin
			out_str = 'Please enter a name.'
		endelse

		widget_control, s2kb_setup.res_coord, set_value=out_str
	end

	'goto': begin
		if s2kb_setup.res_ra NE -9999. then begin
			s2kb_setup.ra = s2kb_setup.res_ra
			s2kb_setup.dec = s2kb_setup.res_dec
			s2kb_setup.offset = [0.0, 0.0]
			
			ra_str  = string(sixty(s2kb_setup.ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
			dec_str = string(sixty(s2kb_setup.dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
			offset_ra_str  = strcompress(string(0L))
			offset_dec_str = strcompress(string(0L))

			widget_control, s2kb_setup.RAID, set_value=ra_str
			widget_control, s2kb_setup.DecID, set_value=dec_str
			widget_control, s2kb_setup.oRAID, set_value=offset_ra_str
			widget_control, s2kb_setup.oDecID, set_value=offset_dec_str

			widget_control, event.top, /destroy

			widget_control, s2kb_setup.cRAID,  set_value=ra_str
			widget_control, s2kb_setup.cDecID, set_value=dec_str

			update_s2kb, s2kb_setup.ra, s2kb_setup.dec, /Init
			update_guider, s2kb_setup.ra, s2kb_setup.dec
		endif
	end

	'cancel': begin
		widget_control, event.top, /destroy
	end

	else:
endcase

end



pro setup_s2kb_frame, event

common setup_s2kb_state

if NOT xregistered('setup_s2kb_frame', /NoShow) then begin
	if total(s2kb_setup.view_custom) EQ 0 then begin
		s2kb_setup.view_custom = s2kb_setup.view_frame
	endif

	start_x_str = strcompress(string(s2kb_setup.view_custom[0]))+':'+strcompress(string(s2kb_setup.view_custom[2]))
	start_y_str = strcompress(string(s2kb_setup.view_custom[1]))+':'+strcompress(string(s2kb_setup.view_custom[3]))

	frame_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Custom Frame', uvalue = 'frame_output_base')

	buttonbase=widget_base(frame_output_base, /align_right, /column)
	  label = widget_label(buttonbase, value='Enter Custom Frame Size in Pixels: ')
	    xbase = widget_base(buttonbase, /align_right, /Row)
	      label                   = widget_label(xbase, value='X Range (px): ')
	      s2kb_setup.view_frame_x = widget_text(xbase, value=start_x_str, uvalue='junk', /Editable, XSize=12)
            ybase = widget_base(buttonbase, /align_right, /Row)
	      label                   = widget_label(ybase, value='Y Range (px): ')
	      s2kb_setup.view_frame_y = widget_text(ybase, value=start_y_str, uvalue='junk', /Editable, XSize=12)
          buttonbase2=widget_base(buttonbase, /Row)
	    resolve_output_resolve = widget_button(buttonbase2, value = ' Set Size ', uvalue = 'set_frame')
	    resolve_output_cancel  = widget_button(buttonbase2, value = '  Cancel  ', uvalue='cancel')
	
	widget_control, frame_output_base, /realize
	xmanager, 'setup_s2kb_frame', frame_output_base, /no_block
endif

end



pro setup_s2kb_frame_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue = uvalue

case uvalue of 
	'set_frame': begin
		widget_control, s2kb_setup.view_frame_x, get_value=x_str
		widget_control, s2kb_setup.view_frame_y, get_value=y_str

		x = long( strsplit(x_str, '[: ]', /Extract) )
		y = long( strsplit(y_str, '[: ]', /Extract) )
		if n_elements(x) EQ 2 and n_elements(y) EQ 2 then begin
			s2kb_setup.view_custom = [x[0], y[0], x[1], y[1]]
			
			widget_control, event.top, /destroy
		endif
	end

	'cancel': begin
		widget_control, event.top, /destroy
	end
	else:
endcase

end
