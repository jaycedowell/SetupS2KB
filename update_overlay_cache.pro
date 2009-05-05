pro querycache, name, ra, dec, Found=Found

common setup_s2kb_cache

if strcmp(cache.file,'') NE 1 then begin
	q_name = strcompress(name,/Remove_All)
	c_names = strcompress(cache.cache.Objects.Name,/Remove_All)
	
	xmatch = where( strmatch(c_names,q_name,/Fold_Case) EQ 1, Found )
	print,Found,xmatch
	case Found of
		0: message, 'No match found in cache.', /Inf
		1: begin
			ra = (cache.cache.Objects)[xmatch].RA2000
			dec = (cache.cache.Objects)[xmatch].Dec2000
		end
		else: begin
			Found = 0
			message,'Warning - could not determine primary ID',/inf 
		end
	endcase
endif else Found = 0

end



pro setup_s2kb_cache_load, event

common setup_s2kb_state
common setup_s2kb_cache

if NOT xregistered('setup_s2kb_cache_load', /NoShow) then begin
	if strcmp(cache.file,'') NE 1 then begin
		current = file_dirname(cache.file)
		filename = file_basename(cache.file)
	endif else begin
		;Get current working directory into a string
		cd, current=current
		filename = ''
	endelse

	cache_output_base = widget_base(group_leader=s2kb_setup.baseID, /row, /base_align_right, $
		title='Setup SKB - Load Cache', uvalue = 'cache_output_base')

	buttonbase=widget_base(cache_output_base, /align_right, /column)
	  label = widget_label(buttonbase, value=' Load Telescope Cache: ')

	directorybase=widget_base(buttonbase, /Column, /Align_Left)
	  cache.fileID = FSC_FileSelect(directorybase, DirectoryName=current+'/', Filename=filename, SelectDirectory=current+'/', $
		Filter='*', Read=1, Write=0, MustExist=1)

        buttonbase2=widget_base(buttonbase, /Row)
	    cache_output_resolve = widget_button(buttonbase2, value = '  Load   ', uvalue = 'load', event_pro='setup_s2kb_cache_event')
	    cache_output_cancel  = widget_button(buttonbase2, value = ' Cancel  ', uvalue='cancel', event_pro='setup_s2kb_cache_event')
	
	widget_control, cache_output_base, /realize
	xmanager, 'setup_s2kb_cache_load', cache_output_base
endif

end



pro setup_s2kb_cache_pick, event

common setup_s2kb_state
common setup_s2kb_cache


if NOT xregistered('setup_s2kb_cache_pick', /NoShow) then begin
	cache.sel_ra = -9999.0
	cache.sel_dec = -9999.0
	
	cache_pick_base = widget_base(group_leader=s2kb_setup.baseID, /Column, /base_align_right, $
		title='Setup SKB - Select Target', uvalue = 'cache_pick_base')

	listbase=widget_base(cache_pick_base, /align_right, /column)
	  label = widget_label(listbase, value=' Telescope Cache: ')
	  cache.CListID = widget_list(listbase, value=cache.cache.Objects.Name, uvalue='select', event_pro='setup_s2kb_cache_event', $
		XSize=15, YSize=15)
	  cache.sel_coord = widget_label(listbase, value='RA:  -- -- ----     Dec: --- -- -- ')

	buttonbase=widget_base(cache_pick_base, /Row)
	    cache_output_goto = widget_button(buttonbase, value = '  GoTo   ', uvalue='goto', event_pro='setup_s2kb_cache_event')
	    cache_output_cancel  = widget_button(buttonbase, value = ' Cancel  ', uvalue='cancel', event_pro='setup_s2kb_cache_event')
	
	widget_control, cache_pick_base, /realize
	xmanager, 'setup_s2kb_cache_pick', cache_pick_base, /no_block
endif

end



pro setup_s2kb_cache_event, event

common setup_s2kb_state
common setup_s2kb_cache

widget_control, event.id, get_uvalue=uvalue

case uvalue of
	'select': begin
		item = widget_info(cache.CListID, /List_Select)
		cache.sel_ra = (cache.cache.Objects.RA2000)[item]
		cache.sel_dec = (cache.cache.Objects.Dec2000)[item]
		ra_str  = string(sixty(cache.sel_ra/15.0, /TrailSign), Format='((I02)," ",(I02)," ",(F04.1))')
		dec_str = string(sixty(cache.sel_dec, /TrailSign), Format='((I+03)," ",(I02)," ",(I02))')
		widget_control, cache.sel_coord, Set_Value='RA:  '+ra_str+'     Dec: '+dec_str
	end
	'goto': begin
		if cache.sel_ra NE -9999. then begin
			s2kb_setup.ra = cache.sel_ra
			s2kb_setup.dec = cache.sel_dec
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
	
			update_s2kb, s2kb_setup.ra, s2kb_setup.dec
			update_guider, s2kb_setup.ra, s2kb_setup.dec
		endif
	end
	'load': begin
		widget_control, cache.fileID, get_value=filename

		loadcache, filename, NumberInfo=NumberInfo, Result=Result
		temp = cache
		cache = {fileID: temp.fileID, file: filename, CListID: temp.CListID, cache: Result, $
			sel_ra: temp.sel_ra, sel_dec: temp.sel_dec, sel_coord: temp.sel_coord}

		widget_control, event.top, /Destroy
	end
	'cancel': begin
		widget_control, event.top, /Destroy
	end
	else:
endcase

end



function cache_parse, a

working = a
out = ['junk at the start']
curr = 1
while curr NE -1 do begin
	curr = strpos(working, ' ')

	temp = strmid(working, 0, curr)
	out = [out, temp]
	
	working = strtrim( strmid(working,curr+1),1 )
endwhile

return, out[1:(n_elements(out)-1)]

end



pro loadcache, filename, NumberInfo=NumberInfo, Result=Result

openr, lun, filename, /Get_LUN
line = ''
data = strarr(1000)
count = 0
while NOT eof(lun) do begin
	readf, lun, line

	data[count] = line
	count += 1
endwhile
data = data[0:(count-1)]
close, lun
free_lun, lun

base = {Name: '', RA: 0.0, Dec: 0.0, Epoch: 0.0, RA2000: 0.0, Dec2000: 0.0}
objects = replicate(base,count)

for i=0L,(count-1) do begin
	parsed = cache_parse(data[i])

	base = {Name: '', RA: 0.0, Dec: 0.0, Epoch: 0.0, RA2000: 0.0, Dec2000: 0.0}

	base.Name = parsed[0]
	ra = float(strsplit(parsed[1],'[hms:]', /Extract))
	base.ra = ra[0] + ra[1]/60.0 + ra[2]/3600.0
	base.ra *= 15.0
	dec = float(strsplit(parsed[2],'[dms:]', /Extract))
	base.dec = abs(dec[0]) + dec[1]/60.0 + dec[2]/3600.0
	if base.dec LT 0 then base.dec = -base.dec
	base.Epoch = parsed[3]

	if base.Epoch NE 2000.0 then begin
		jprecess, base.ra, base.dec, base.ra2000, base.dec2000, Epoch=base.Epoch
	endif else begin
		base.RA2000 = base.RA
		base.Dec2000 = base.Dec
	endelse

	objects[i] = base
endfor

Result = {File: filename, Number: count, Objects: objects}

end



pro update_overlay_cache, ra, dec, windex, Refresh=Refresh

common setup_s2kb_cache
common setup_s2kb_state

wset, windex

hor, s2kb.ramax, s2kb.ramin
ver, s2kb.decmin, s2kb.decmax
plot, [0,0], /NoErase, /NoData, XRange=[s2kb.ramax, s2kb.ramin], YRange=[s2kb.decmin, s2kb.decmax], XStyle=5, YStyle=5, Pos=[0,0,1,1]

;+ Begin printing out what we know
for n=0L,(cache.Cache.Number-1) do begin
	;+ Load current object
	Object = (cache.Cache.Objects)[n]

	if Object.RA2000 GE s2kb.ramin AND Object.RA2000 LE s2kb.ramax AND $
	   Object.Dec2000 GE s2kb.decmin AND Object.Dec2000 LE s2kb.decmax then begin
		if s2kb_setup.UseGIF OR strcmp(s2kb_setup.UseSurvey,'sdss') OR strcmp(s2kb_setup.UseSurvey,'sdssc') then begin
			plots, Object.RA2000*[1,1], Object.Dec2000*[1,1], PSym=SymCat(9), Color=FSC_Color('Yellow')
			xyouts, Object.RA2000, Object.Dec2000-1/3600.0, strcompress(Object.Name, /Remove_All)+' ', /Data, $
				Color=FSC_Color('Yellow'), Align=1
		endif else begin
			ad2xy, Object.RA2000, Object.Dec2000, S2KB.Astrom, normx, normy
			plots, normx*[1,1]/(size(S2KB.Image))[1], normy*[1,1]/(size(S2KB.Image))[2], $
				PSym=SymCat(9), Color=FSC_Color('Yellow'), /Norm
			xyouts, normx*[1,1]/(size(S2KB.Image))[1], normy*[1,1]/(size(S2KB.Image))[2], $
				strcompress(Object.Name, /Remove_All)+' ', Color=FSC_Color('Yellow'), Align=1
		endelse
	endif 
endfor

end