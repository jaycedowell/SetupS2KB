pro setup_s2kb, ra, dec, Offset=Offset

if n_elements(Offset) NE 0 then begin
	ra = (ra*15.0 + Offset[0]/3600.0)/15.0
	dec = dec + Offset[1]/3600.0
endif

window,0,XSize=512,YSize=512,Title='S2KB Field of View'
plot, [0,0], XRange=[1,2500],XStyle=5,YRange=[1,2500],YStyle=5, pos=[0,0,1,1]
querydss, [ra*15.0, dec], opticaldssimage, Hdr, survey='2b', imsize=25.0

tvscl, congrid(opticaldssimage,512,512), 0, 0

oplot, [79, 79]+1250,[-280, 1024]+1250, Color=FSC_Color('Red')
oplot, [-513, -513]+1250, [108, 1024]+1250, Color=FSC_Color('Red')
oplot, 1024*[-1, -1, 1, 1, -1]+1250, 1024*[-1, 1, 1, -1, -1]+1250, Color=FSC_Color('Green')


files_s = file_search('/data/jdowell/ALFALFA/targets_s','HI*.cln2')
files = file_basename(files_s)
alfa_ra  = float(strmid(files, 2,2)) + float(strmid(files, 4,2))/60.0 + float(strmid(files, 6,4))/3600.0
alfa_dec = float(strmid(files,11,2)) + float(strmid(files,13,2))/60.0 + float(strmid(files,15,2))/3600.0
is_neg = where( strcmp(strmid(files,10,1),'-') )
if is_neg[0] NE -1 then alfa_dec[is_neg] = -alfa_dec[is_neg]

to_disp = -1
for n=0L,(n_elements(files)-1) do begin
	x = (-alfa_ra[n]+ra)*15.0*3600.0/0.6+1250
	y = (alfa_dec[n]-dec)*3600.0/0.6+1250
	if abs(x-1250) LE 1250 AND abs(y-1250) LE 1250 then begin
		restore, files_s[n]
		oplot, [x,x], [y,y], PSym=6, Color=FSC_Color('Green')
		xyouts, x-25, y+50, string(to_disp,Format='(I+3)'), Color=FSC_Color('Green')
		print, string(to_disp,Format='(I+3)')+'  '+string(files[n],Format='(A-17)')+'       @ ' $
					+string((src.spectra.vcen)[0],Format='(I6)')
		to_disp = to_disp -1
	endif
endfor


files_f = file_search('/data/jdowell/ALFALFA/targets_f','HI*.cln2')
files = file_basename(files_f)
alfa_ra  = float(strmid(files, 2,2)) + float(strmid(files, 4,2))/60.0 + float(strmid(files, 6,4))/3600.0
alfa_dec = float(strmid(files,11,2)) + float(strmid(files,13,2))/60.0 + float(strmid(files,15,2))/3600.0
is_neg = where( strcmp(strmid(files,10,1),'-') )
if is_neg[0] NE -1 then alfa_dec[is_neg] = -alfa_dec[is_neg]

to_disp = -1
for n=0L,(n_elements(files)-1) do begin
	x = (-alfa_ra[n]+ra)*15.0*3600.0/0.6+1250
	y = (alfa_dec[n]-dec)*3600.0/0.6+1250
	if abs(x-1250) LE 1250 AND abs(y-1250) LE 1250 then begin
		restore, files_f[n]
		oplot, [x,x], [y,y], PSym=6, Color=FSC_Color('Red')
		xyouts, x-25, y+50, string(to_disp,Format='(I+3)'), Color=FSC_Color('Red')
		print, string(to_disp,Format='(I+3)')+'  '+string(files[n],Format='(A-17)')+'       @ ' $
					+string((src.spectra.vcen)[0],Format='(I6)')
		to_disp = to_disp -1
	endif
endfor

nedquery, (ra*15.0)[0], (dec)[0], 12.5*sqrt(2.0), numberinfo=ncount, string_array=result
ncount = long(strmid(ncount[0],0,3))
if ncount GT 0 then begin
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
	for n=0,ncount-1 do begin
		;+ Series of filters to clean out certain undesirable objects
		tempG = strcmp(typ[n], 'G')
		tempGG = strcmp(typ[n], 'GPair') OR strcmp(typ[n], 'GTrpl') OR strcmp(typ[n], 'GGroup') OR strcmp(typ[n], 'GClstr')
		if (tempG+tempGG) EQ 0 then continue

		;+ First, catch those with unknown velocities -> orange
		temp1 = strcmp(str_vels[n], '...') + strcmp(str_vels[n], '>75000')
		if temp1 NE 0 then begin
			oplot, cos(decs[n]/!radeg)*(-[ras[n], ras[n]]+15.0*ra)*3600.0/0.6+1250, ([decs[n], decs[n]]-dec)*3600.0/0.6+1250, $
				PSym=5, Color=FSC_Color('Orange')
		endif else begin
			if float(str_vels[n]) LT 9300 then begin 
				oplot, cos(decs[n]/!radeg)*(-[ras[n], ras[n]]+15.0*ra)*3600.0/0.6+1250, $
					([decs[n], decs[n]]-dec)*3600.0/0.6+1250, PSym=5, Color=FSC_Color('Yellow')
				xyouts, cos(decs[n]/!radeg)*(-ras[n]+15.0*ra)*3600.0/0.6+1275, (decs[n]-dec)*3600.0/0.6+1200, $
					string(to_disp,Format='(I2)'), /Data, Color=FSC_Color('Yellow')
				print,string(to_disp,Format='(I2)')+'  '+string(names[n],Format='(A-24)')+' @ ' $
					+string(str_vels[n],Format='(A6)')+' ['+typ[n]+']'
				to_disp = to_disp + 1
			endif else begin
				oplot, cos(decs[n]/!radeg)*(-[ras[n], ras[n]]+15.0*ra)*3600.0/0.6+1250, ([decs[n], decs[n]]-dec)*3600.0/0.6+1250, $
					PSym=5, Color=FSC_Color('Orange')
			endelse
		endelse
	endfor
endif


window,1,XSize=170,YSize=170,Title='North Guider'
nra = ra*15.0 + 0.0/3600.0
ndec = dec + 2610.0/3600.0
plot, [0,0], XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, pos=[0,0,1,1]
nstars = queryvizier('GSC2.3', [nra, ndec], [7.0, 7.0], /Canada, /AllColumns)
querydss, [nra, ndec], opticaldssimage, Hdr, survey='2b', imsize=7.0
tvscl,congrid(opticaldssimage,170,170), 0, 0
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')
valid = where( nstars.vmag LE 15.0 and finite(nstars.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(nstars.dej2000[valid]/!radeg)*(-(nstars.raj2000)[valid]+nra)*3600.0/0.2 + 1050
	y = ((nstars.dej2000)[valid]-ndec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((nstars.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif


window,2,XSize=170,YSize=170,Title='South Guider'
sra = ra*15.0 + 25.0/3600.0
sdec = dec - 2410.0/3600.0
plot, [0,0], XRange=[1,2100],XStyle=5,YRange=[1,2100],YStyle=5, pos=[0,0,1,1]
sstars = queryvizier('GSC2.3', [sra, sdec], [7.0, 7.0], /Canada, /AllColumns)
querydss, [sra, sdec], opticaldssimage, Hdr, survey='2b', imsize=7.0
tvscl,congrid(opticaldssimage,170,170), 0, 0
oplot, [-492, -492, 492, 492, -492]+1050, [-328, 328, 328, -328, -328]+1050, Color=FSC_Color('Green')
valid = where( sstars.vmag LE 15.0 and finite(sstars.vmag) EQ 1 )
if valid[0] NE -1 then begin
	x = cos(sstars.dej2000[valid]/!radeg)*(-(sstars.raj2000)[valid]+sra)*3600.0/0.2 + 1050
	y = ((sstars.dej2000)[valid]-sdec)*3600.0/0.2 + 1050
	oplot, x,y, PSym=6, Color=FSC_Color('Blue')
	xyouts, x+100, y-100, string((sstars.vmag)[valid],Format='(F4.1)'),/Data, $
		Color=FSC_Color('Blue')
endif

end
