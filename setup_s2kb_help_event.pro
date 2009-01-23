pro setup_s2kb_uguide

common setup_s2kb_state
common setup_2kb_guide, users_guide, sections

section = {title: '', text: strarr(1000)}
sections = replicate(section, 8)

section = sections[0]
section.title='Overview'
section.text = ['There are three main parts to this window.  Located at the top are two panels, "S2KB Pointing" and "Guide Camera Limiting Magnitude", that control the position of the field and the sensitivity of the guide camera.  The values in "S2KB Pointing" are Initial RA/Dec., Offset RA/Dec., and Current RA/Dec.  Initial refers to the initial pointing of the field and all offsets are calculated from this position.  Offset refers to the right ascension and declination offsets that lead to the currently displayed pointing.  Finally, the Current settings give the coordinates associated with the currently displayed pointing.  At start up, all values are set to zero.  The "Guide Camera Limiting Magnitude" panel controls to what  magnitude stars are labeled on the North and South guide camera images.  Stars found in the HST Guide Star Catalog v2.3.2 with V-band magnitudes less than or equal to the displayed value are labeled by their magnitudes.  The default is to label all stars brighter than 14.5 mag, the sensitivity limit of the two guide cameras.  The "+0.5 mag" and "-0.5 mag" buttons located at the bottom of this panel can be used to increase or decrease this limiting magnitude.', ' ', 'The next section of the window contains the three image areas.  The largest display is a 25''x25'' DSS Blue2 image that represents the current field of view as seen by S2KB.  This image is purposely oversized to allow the user to see what is around the edge of the field.  The displays come with a number of overlays turned on by default.  The purple box denotes the center of S2KB (pixel 1024,1024) while the large green boxes represent the field of view of each camera.  To accommodate observers who wish to only read out a portion of the chip, the field of view of S2KB can be changed through the "Field of View" menu.  This is detailed in Section 5.   The red lines show the locations of the bad columns on S2KB and white bars in the lower left of each display indicate scale.  The yellow triangles in the field indicate NED galaxies with known velocities and are overlayed by default.  Usage of the NED overlay is given in Section 7.  The upper right-hand display is for the North camera while the lower right-hand display is for the South camera.  These fields are both 7''x7'' DSS Blue2 images.  Stars brighter than the current guide camera limiting magnitude are denoted by blue boxes and labeled by their V-band apparent magnitudes.', ' ', 'The final section of the main Setup S2KB window is the NED source list.  For every NED object labeled in the field, its name, type, and velocity are listed here.  This list is automatically updated for each new pointing.']
sections[0] = section

section = sections[1]
section.title='Pointing'
section.text = ['There are two ways to move the field center to a particular target.  If you already know the RA and Dec. of the source you are interested in, you can simply enter it into the Initial Ra/Dec. boxes located in the "Setup S2KB" panel.  These boxes accept coordinates in the form of HH MM SS.S for RA and sDD MM SS for declination.  Once the coordinates are entered, the new field can be downloaded and displayed by pushing the "Show Field" button located in the lower right of the main window.  The cursor will change to an hourglass while the images are being loaded and NED is being queried.', ' ', 'If you do not already have the coordinates for your target, Setup S2KB has a built-in name resolver that  uses SIMBAD.  To access this, select File -> Resolve Name.', ' ', 'To use this dialog, type the object name into the text box and click "Resolve".  If the name is resolved successfully, the coordinates of the object will appear below the text box in the dialog window.  If not, then an error message will be displayed.  Once the coordinates are known, the "Go To" button can be clicked to send the resolved coordinates to the main Setup S2KB window and update the pointing.']
sections[1] = section

section = sections[2]
section.title='Offsets'
section.text = ['Once the DSS images have been loaded for a particular pointing, the pointing center can be offset using the left or right mouse button.  To do this, simply click on the "S2KB Field" display where  the new center is desired.  This will shift the pointing center, reload the images, and update the Offset and Current values displayed in the "S2KB Pointing" panel.  Offsets can also be entered manually by typing the desired offsets into the Offset boxes and clicking "Show Field".']
sections[2] = section

section = sections[3]
section.title='Changing the S2KB Field Size'
section.text = ['Although the default S2KB field size is displayed as 20.5''x20.5'', it is possible to display other sizes using the "Field of View" menu.  This menu has three size options: "Full Frame", "1536x1536, Centered", "1024x1024, Centered", and "Custom Frame".  "Full Frame" is the default option and shows the full field of view.  "1536x1536, Centered" is a 15.4''x15.4'' field (roughly 1/2 the total area) that is centered on pixel (1024,1024) that is equivalent to using the IRAF task ''epar detpars'' of 256:1792.  " 1024x1024, Centered" is similar but provides only a 10.2''x10.2'' field of view (roughly 1/4 the total area).  The final option, "Custom Frame", allows the observer to set a custom frame size in the same fashion as ''epar detpars''.  The custom frame size is set using Field of View -> Set Custom Frame.  This option bring up the window shown in Figure 4.', ' ', 'Once the desired size has been entered in the format of <start row/column>:<end row/column>, click "Set Size" to save the values and display the new frame.']
sections[3] = section

section = sections[4]
section.title='Saving/Printing Images'
section.text = ['It is also possible to create finding charts using Setup S2KB through the File -> Export JPEG and File -> Print options.  Export JPEG brings up a window that allows the current view to be saved to a JPEG.  The output file name is automatically suggested based on the current pointing center.  Both of the text boxes can be changed.  The JPEG is saved as gray scale and does not include any of the NED overlay objects.  It does, however, include the RA and declination of the field center, the bad columns, fields of view, and labeled guide stars.', ' ', 'The Print option creates an output similar to Export JPEG but sends it to a printer instead.  By default, this will use the ''lp'' command which sends the image to the default printer.  If you wish to use a different command, enter it in the text box provided.']
sections[4] = section

section = sections[5]
section.title='The NED Overlays'
section.text = ['Some of the more complicated aspects of this program deal with the NED overlays.  Control of the overlays are accomplished through the "Object Types" and "Display Overlays" menus.', ' ', 'Object Types:  This menu is shown in Figure 8 and controls which type of objects are displayed when the various overlays are enabled.  Most of the options are self-explanatory, however, a few are not.  Galaxy Groups includes galaxy pairs, triples, groups and clusters.  Parts of Galaxies consists of SDSS galaxy fragments and HII regions.  Stars contains any object in NED that has a type that includes the ''*'' character.  Unclassified is itself a menu that breaks unclassified objects into various wavelength regimes.  To help distinguish the various object types, they are assigned different symbols.  The default settings are to only display galaxies.  These symbol listings can also be accessed from within Setup S2KB via Help -> Overlay Legend.', ' ', 'Display Overlays:  This menu controls which overlays are displayed and has three sections.  The upper section (two options) sets which NED objects matching the selected criteria set under "Object Types" should be displayed based on velocity information.', ' ', 'The first option, "NED - All known Velocity", is turned on by default and displays all NED objects in the field that have velocity information and have their object type selected in the "Object Types" menu.  The second option displays only the NED objects that do not have any velocity information.  The middle section (five options) is specially designed for extragalactic Halpha work and color-codes galaxies in the current field based on which of the five Halpha filters should be used to observe them.  These alternative colors are only displayed if Object Types -> Galaxies option is enabled.  These color codes can also be accessed from within Setup S2KB via Help -> Overlay Legend.  The final section (one option) allows the user to overlay objects in the loaded telescope cache as open  circles.  If a cache has not been loaded prior to selecting this option, a dialog will appear to load a cache.']
sections[5] = section

section = sections[6]
section.title = 'Telescope Cache'
section.text = ['A properly formated version of a telescope cache file can be loaded into Setup S2KB and accessed.  The format of the cache should look like: ',' ','L112_822  20:42:50.0  +00:15:30  2000  0.00  0.00  0.00','BD75325   08:10:49.3  +74:57:57  2000  0.00  0.00  0.00','Feige34   10:39:36.7  +43:06:10  2000  0.00  0.00  0.00','Feige66   12:37:23.6  +25:04:00  2000  0.00  0.00  0.00',' ','For this formation, each column is separated by one or more spaces.  The first column is the target name, the second is the target RA, the third is the declination, and the fourth is the epoch.  The remaining three columns are expected by the ACE TCS.  To load a cache, select File -> Load Telescope Cache.  This will bring up a dialog window.  If the coordinates are not in J2000.0, they will automatically be precessed.  Note:  A copy of the cache must be stored on sage in order to use this feature.',' ','Once the cache is loaded, targets can be selected from the cache in two ways.  The most direct is through File -> Select From Cache.  This brings up a selection window.  Once an object has been selected, its coordinates appear at the bottom of the window.  To go to the selected target, click "GoTo".  Objects in the telescope cache can also be selected through the coordinate resolver (File -> Resolve Name).  The name typed into the resolved does not need to exactly match the name stored in the cache.  For example, the target "NGC6791" is matched by the names "NGC6791", "NGC 6791", "Ngc 6791", and "ngc 6791".']
sections[6] = section

section = sections[7]
section.title='Known Issues and Limitations'
section.text = ['+ The print feature is UNIX/Linux specific.  For computers without ''lp'', i.e., Windows, this will generate an error.',' ','+ Setup S2KB is heavily dependent on a network connection and access to various services, such as NED and VizieR.  In the case of the DSS images, requests are first sent to archive.stsci.edu.  If the STSCI server does not answer, a request is sent to archive.eso.edu.  However, there is not automatic fall back for all services.  In particular, there is no alternative to NED for labeling objects in the field of view.  There is currently no way to disable all requests to NED.  There is also no way to pick-and-chose which request are sent to which servers.']
sections[7] = section

if NOT xregistered('setup_s2kb_uguide', /NoShow) then begin
	users_guide = { listID: 0L, $
		textID: 0L, $
		next: 0L, prev: 0L }

	labels = ['Overview', 'Pointing', 'Offsets', 'Changing Field Size', 'Saving/Printing Images', $
			'NED Overlays', 'Telescope Cache', 'Known Issues']

	base = widget_base(group_leader=s2kb_setup.baseID, title='Setup S2KB - User''s Guide', /Column, /Base_Align_Left, $
		uvalue = 'about_base')
	  textbase = widget_base(base, /Row)
	    users_guide.listID = widget_list(textbase, /Frame, XSize=20, YSize=20, value=labels, uvalue='section')
	    users_guide.textID = widget_text(textbase, /Scroll, value='', XSize=75, /Wrap)
	  buttonbase = widget_base(base, /Row)
	    users_guide.prev  = widget_button(buttonbase, value = ' Previous ', uvalue = 'sect_prev')
	    users_guide.next  = widget_button(buttonbase, value = '   Next   ', uvalue = 'sect_next')
	    about_done = widget_button(buttonbase, value = ' Done ', uvalue = 'exit_guide')
	
				
	widget_control, base, /realize
	xmanager, 'setup_s2kb_uguide', base, /no_block

	widget_control, users_guide.listID, /Set_List_Top
	widget_control, users_guide.listID, Set_List_Select=0
	
	curr_section = 0
	section = sections[curr_section]
	sec_end = max( where( strlen(section.text) NE 0 ) )
	sec_text = [strcompress(string(curr_section+1), /Remove_All)+'. '+section.title]
	sec_text = [sec_text, (section.text)[0:sec_end]]

	widget_control, users_guide.textID, set_value=sec_text
endif

end



pro setup_s2kb_uguide_event, event

common setup_s2kb_state
common setup_2kb_guide

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	'sect_next': begin
		curr_section = widget_info(users_guide.listID, /List_Select)
		curr_section = ((curr_section + 1)<7)

		widget_control, users_guide.listID, Set_List_Select=curr_section
		section = sections[curr_section]
		sec_end = max( where( strlen(section.text) NE 0 ) )
		sec_text = [strcompress(string(curr_section+1), /Remove_All)+'. '+section.title]
		sec_text = [sec_text, (section.text)[0:sec_end]]

		widget_control, users_guide.textID, set_value=sec_text
	end
	'sect_prev': begin
		curr_section = widget_info(users_guide.listID, /List_Select)
		curr_section = ((curr_section - 1)>0)

		widget_control, users_guide.listID, Set_List_Select=curr_section
		section = sections[curr_section]
		sec_end = max( where( strlen(section.text) NE 0 ) )
		sec_text = [strcompress(string(curr_section+1), /Remove_All)+'. '+section.title]
		sec_text = [sec_text, (section.text)[0:sec_end]]

		widget_control, users_guide.textID, set_value=sec_text
	end

	'section': begin
		curr_section = widget_info(users_guide.listID, /List_Select)

		section = sections[curr_section]
		sec_end = max( where( strlen(section.text) NE 0 ) )
		sec_text = [strcompress(string(curr_section+1), /Remove_All)+'. '+section.title]
		sec_text = [sec_text, (section.text)[0:sec_end]]

		widget_control, users_guide.textID, set_value=sec_text
	end

	'exit_guide': begin
		widget_control, event.top, /destroy
	end
	else:
endcase

end



pro setup_s2kb_help_event, event

common setup_s2kb_state

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	;+ User's Guide
	'uguid_view': begin
		setup_s2kb_uguide
	end

	;+ Overlay Legend
	'nledg_view': begin
		h = ['Plot Symbols:                                ', $
		     ' Triangle:   Galaxies, Galaxy Groups, and    ', $
		     '             Parts of Galaxies               ', $
		     ' Plus Sign:  Qusars                          ', $
		     ' ''X'':        Supernovae                    ', $
		     ' Asterisk:   Stars in NED                    ', $
		     ' Diamond:    Unclassified Objects            ', $
		     ' Circle:     Target in telescope cache       ', $
		     '                                             ', $
		     'Color Codes (All Object Types):              ', $
		     ' Yellow:  NED object with known velocity     ', $
		     ' Orange:  NED object with unknown velocity   ', $
		     '                                             ', $
		     'Optional Color Codes (Galaxies Only):        ', $
		     ' Red:     Halpha in filter Y006 (6580)       ', $
		     '            -140 < v < 1,700 km/s            ', $
		     ' Green:   Halpha in filter Y007 (6620)       ', $
		     '           1,450 < v < 3,600 km/s            ', $
		     ' Blue:    Halpha in filter Y008 (6660)       ', $
		     '           3,300 < v < 5,350 km/s            ', $
		     ' Purple:  Halpha in filter Y009 (6700)       ', $
		     '           5,000 < v < 7,400 km/s            ', $
		     ' White:   Halpha in filter Y010 (6740)       ', $
		     '          7,200 < v < 9,300 km/s             ']
		
		if NOT xregistered('setups2kb_ledg') then begin
			about_base =  widget_base(group_leader=s2kb_setup.baseID, title='Setup S2KB - Overlay Legend', $
				/Column, /Base_Align_Right, uvalue = 'about_base')
			about_text = widget_text(about_base, /Scroll, value = h, xsize = 45, ysize = 25)
			about_done = widget_button(about_base, value = ' Done ', uvalue = 'exit_about', $
				event_pro='setup_s2kb_help_event')
			
			widget_control, about_base, /realize
			xmanager, 'setups2kb_ledg', about_base, /no_block
		endif
	end

	;+ About setup2
	'about_view': begin
		h = ['Setup S2KB - Graphical utility for determin- ', $
		     'ing pointings and guide stars for S2KB when  ', $
		     'used on the WIYN 0.9m.                       ', $
		     '                                             ', $
		     '  Written, May 2008                          ', $
		     '                                             ', $
		     '  Last update: Thursday, September 4, 2008   ', $
		     '  by Jayce Dowell (jdowell@astro.indiana.edu)']
		
		if NOT xregistered('setups2kb_help') then begin
			about_base =  widget_base(group_leader=s2kb_setup.baseID, title='Setup S2KB - About', $
				/Column, /Base_Align_Right, uvalue = 'about_base')
			about_text = widget_text(about_base, /Scroll, value = h, xsize = 50, ysize = 10)
			about_done = widget_button(about_base, value = ' Done ', uvalue = 'exit_about', $
				event_pro='setup_s2kb_help_event')
			
			widget_control, about_base, /realize
			xmanager, 'setups2kb_help', about_base, /no_block
		endif
	end

	'exit_about': begin
		widget_control, event.top, /destroy
	end

	else:
endcase

end
