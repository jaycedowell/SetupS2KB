PRO QuerySDSS, target, Image,  Header, IMSIZE=ImSize, NED=ned, Grayscale=Grayscale

compile_opt idl2
if N_params() LT 1 then begin
	print,'Syntax - QuerySDSS, TargetName_or_coords, image, header'
	print,"           [Imsize= /NED /Grayscale]"
	return
endif

if N_elements(target) EQ 2 then begin
	ra = float(target[0])
	dec = float(target[1])
endif else begin
	QuerySimbad, target, ra,dec, NED= ned, Found = Found
	if found EQ 0 then begin 
		message,/inf,'Target name ' + target + $
			' could not be translated by SIMBAD'
		return
	endif
endelse  

if n_elements(ImSize) EQ 0 then $
	ImSize = 10.0

QueryURL='http://casjobs.sdss.org/ImgCutoutDR7/getjpeg.aspx?ra='+$
                    strcompress(ra, /remove_all)+$
                    '&dec='+strcompress(dec, /remove_all)+$
                    '&scale='+strcompress(ImSize/8.5333,/remove_all)+$
                    '&width=512&height=512'

result = webget2(QueryURL, copyfile='s2kb_sdss.jpg')
if Keyword_Set(Grayscale) then begin
	read_jpeg, 's2kb_sdss.jpg', Image, /Grayscale
endif else begin
	read_jpeg, 's2kb_sdss.jpg', Image, true=1
endelse
Header = 'No header found.'

if strcmp(strupcase(!Version.OS_Family), 'UNIX') then begin
	spawn,'rm -rf s2kb_sdss.jpg'
endif else begin
	spawn,'erase /F /Q s2kb_sdss.jpg'
endelse

end