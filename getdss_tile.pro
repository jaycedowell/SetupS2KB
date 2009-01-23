pro getdss_tile, out, ra, dec, side, Init=Init

n_split = 3

side = side / 60.0

if n_elements(out) EQ 0 or Keyword_Set(Init) then begin
	tile = {DSS_Tile, RA: 0.0, Dec: 0.0, DeltaRA: 0.0, DeltaDec: 0.0, Image: fltarr(256,256)}
	out = replicate(tile, float(n_split)^2.0)

	ra_array  =  ra + side*((findgen(n_split)-n_split/2)/n_split)
	ra_array = (ra_array+360.0) mod 360.0
	dec_array = dec + side*((findgen(n_split)-n_split/2)/n_split)
	for i=0,(n_split-1) do begin
		for j=0,(n_split-1) do begin
			querydss2, [ra_array[i], dec_array[j]], timage, imsize=side*60.0/float(n_split), $
				survey='2b', /STSCI, /GIF

			tile.ra = ra_array[i]
			tile.dec = dec_array[j]
			tile.DeltaRA = side/float(n_split)
			tile.DeltaDec = side/float(n_split)
			tile.image = congrid(timage,256,256)

			out[i*n_split+j] = tile
		endfor
	endfor
endif else begin
	ra_range = ra + side*[-1/2.0, 1/2.0]/cos(dec/!radeg)
	dec_range = dec + side*[-1/2.0, 1/2.0]

	n_tiles = n_elements(out)

	;+ Clip tiles that are entirely hidden from view
	tst_ra_range = ra + 1.00*side*[-1/2.0, 1/2.0]
	tst_dec_range = dec + 1.00*side*[-1/2.0, 1/2.0]

	;if max(tst_ra_range) GE 24 then begin
	;	tst_ra_range = tst_ra_range - 360.0
	;endif 

	print,tst_ra_range
	print,tst_dec_range

	to_keep = [-1]
	for i=0,(n_tiles-1) do begin
		curr = out[i]

		tile_ra_range = curr.ra + curr.DeltaRA*[-1/2.0, 1/2.0]
		tile_dec_range = curr.dec + curr.DeltaDec*[-1/2.0, 1/2.0]

		print,tile_ra_range
		print,tile_dec_range

		corner_touch = 0
		for l=0,1 do begin
			x = tile_ra_range[l]
			for m=0,1 do begin
				y = tile_dec_range[m]
				if x GT tst_ra_range[0] AND x LT tst_ra_range[1] AND $
					y GT tst_dec_range[0] AND y LT tst_dec_range[1] then begin
					corner_touch = 1
					goto, FoundCorner
				endif
			endfor
		endfor
		
		FoundCorner:
		if corner_touch NE 0 then to_keep = [to_keep, i]
	endfor
	to_keep = to_keep[ uniq(to_keep) ]
	print,to_keep
	print,'% GETDSS_TILE: Removing '+strcompress(string(n_elements(out) - (n_elements(to_keep)-1)),/Remove_All)+' tiles'
	if n_elements(to_keep) NE 1 then begin
		out = out[ to_keep[1:(n_elements(to_keep)-1)] ]
	endif else begin
		print,'% GETDSS_TILE: All many tiles removed - reinitializing'
		getdss_tile, out, ra, dec, side, /Init
		return
	endelse

	;+ Fill in coverage gaps - upper boundary
	if max(dec_range) GT max(out.dec+0.5*out.DeltaDec) then begin
		tile = {RA: 0.0, Dec: 0.0, DeltaRA: 0.0, DeltaDec: 0.0, Image: fltarr(256,256)}
		temp = out	

		ra_array = (temp.ra+360.0) mod 360.0
		ra_array = ra_array[ sort(ra_array) ]
		ra_array = ra_array[ uniq(ra_array) ]
		num_row = ceil( (max(dec_range)-max(out.dec))/(out.DeltaDec)[0] )
		print,'% GETDSS_TILE: Adding '+strcompress(string(num_row*n_elements(ra_array)),/Remove_All)+ $
			' tiles on upper boundary'
		for k=1,num_row do begin
			dec_array = max(temp.dec) + k*(temp.DeltaDec)[0]

			for i=0,(n_elements(ra_array)-1) do begin
				querydss2, [ra_array[i], dec_array], timage, imsize=60.0*(temp.DeltaDec)[0], $
					survey='2b', /STSCI, /GIF
					
				tile.ra = ra_array[i]
				tile.dec = dec_array
				tile.DeltaRA = (temp.DeltaRA)[0]
				tile.DeltaDec = (temp.DeltaDec)[0]
				tile.image = congrid(timage,256,256)
				
				out = [out, tile]
			endfor
		endfor
	endif
	;+ Fill in coverage gaps - lower boundary
	if min(dec_range) LT min(out.dec-0.5*out.DeltaDec) then begin
		tile = {RA: 0.0, Dec: 0.0, DeltaRA: 0.0, DeltaDec: 0.0, Image: fltarr(256,256)}
		temp = out	

		ra_array = (temp.ra+360.0) mod 360.0
		ra_array = ra_array[ sort(ra_array) ]
		ra_array = ra_array[ uniq(ra_array) ]
		num_row = ceil( (min(out.dec)-min(dec_range))/(out.DeltaDec)[0] )
		print,'% GETDSS_TILE: Adding '+strcompress(string(num_row*n_elements(ra_array)),/Remove_All)+ $
			' tiles on lower boundary'
		for k=1,num_row do begin
			dec_array = min(temp.dec) - k*(temp.DeltaDec)[0]

			for i=0,(n_elements(ra_array)-1) do begin
				querydss2, [ra_array[i], dec_array], timage, imsize=60.0*(temp.DeltaDec)[0], $
					survey='2b', /STSCI, /GIF
					
				tile.ra = ra_array[i]
				tile.dec = dec_array
				tile.DeltaRA = (temp.DeltaRA)[0]
				tile.DeltaDec = (temp.DeltaDec)[0]
				tile.image = congrid(timage,256,256)
				
				out = [out, tile]
			endfor
		endfor
	endif

	;+ Fill in coverage gaps - right boundary
	if max(ra_range) GT max(out.ra+0.5*out.DeltaRA) then begin
		tile = {RA: 0.0, Dec: 0.0, DeltaRA: 0.0, DeltaDec: 0.0, Image: fltarr(256,256)}
		temp = out	

		dec_array = temp.dec
		dec_array = dec_array[ sort(dec_array) ]
		dec_array = dec_array[ uniq(dec_array) ]
		num_col = ceil( (max(ra_range)-max(out.ra))/(out.DeltaRA)[0] )
		print,'% GETDSS_TILE: Adding '+strcompress(string(num_col*n_elements(dec_array)),/Remove_All)+ $
			' tiles on left boundary'
		for k=1,num_col do begin
			ra_array = max(temp.ra) + k*(temp.DeltaRA)[0]
			ra_array = (ra_array+360.0) mod 360.0

			for j=0,(n_elements(dec_array)-1) do begin
				querydss2, [ra_array, dec_array[j]], timage, imsize=60.0*(temp.DeltaDec)[0], $
					survey='2b', /STSCI, /GIF
				
				tile.ra = ra_array
				tile.dec = dec_array[j]
				tile.DeltaRA = (temp.DeltaRA)[0]
				tile.DeltaDec = (temp.DeltaDec)[0]
				tile.image = congrid(timage,256,256)
				
				out = [out, tile]
			endfor
		endfor
	endif
	;+ Fill in coverage gaps - left boundary
	if min(ra_range) LT min(out.ra-0.5*out.DeltaRA) then begin
		tile = {RA: 0.0, Dec: 0.0, DeltaRA: 0.0, DeltaDec: 0.0, Image: fltarr(256,256)}
		temp = out	

		dec_array = temp.dec
		dec_array = dec_array[ sort(dec_array) ]
		dec_array = dec_array[ uniq(dec_array) ]
		num_col = ceil( (min(out.ra)-min(ra_range))/(out.DeltaRA)[0] )
		print,'% GETDSS_TILE: Adding '+strcompress(string(num_col*n_elements(dec_array)),/Remove_All)+ $
			' tiles on right boundary'
		for k=1,num_col do begin
			ra_array = min(temp.ra) - k*(temp.DeltaRA)[0]
			ra_array = (ra_array+360.0) mod 360.0

			for j=0,(n_elements(dec_array)-1) do begin
				querydss2, [ra_array, dec_array[j]], timage, imsize=60.0*(temp.DeltaDec)[0], $
					survey='2b', /STSCI, /GIF
				
				tile.ra = ra_array
				tile.dec = dec_array[j]
				tile.DeltaRA = (temp.DeltaRA)[0]
				tile.DeltaDec = (temp.DeltaDec)[0]
				tile.image = congrid(timage,256,256)
				
				out = [out, tile]
			endfor
		endfor
	endif
endelse

end
