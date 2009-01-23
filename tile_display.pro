pro tile_display, ra, dec, side, Tiles=Tiles, XSize=XSize, YSize=YSize, Init=Init

getdss_tile, tiles, ra, dec, (side+3.0), Init=init

side = side / 60.0

disp_med = median(tiles.image)
disp_min = min(tiles.image)
disp_max = max(tiles.image)

delta_x = tiles.DeltaRA / side * XSize
delta_y = tiles.DeltaDec / side * YSize
x_offset = (ra - tiles.ra)
flipd_E = where( x_offset  GT 180.0 )
flipd_W = where( x_offset  LT -180.0 )
;if flipd_E[0] NE -1 then begin
;	x_offset[flipd_E] = ra[flipd_E] - 360.0 - tiles.ra[flipd_E]
;endif
;if flipd_W[0] NE -1 then begin
;	x_offset[flipd_W] = ra[flipd_W] + 360.0 - tiles.ra[flipd_W]
;endif
x_offset *= cos(dec/!radeg)*XSize/side
x_offset += XSize/2 - delta_x / 2
y_offset = -(dec - tiles.dec)*YSize/side
y_offset += YSize/2 - delta_y / 2

n_tiles = n_elements(tiles)
for i=0L,(n_tiles-1) do begin
	junk = (tiles[i]).image
	junk = junk-median(junk)+disp_med
	tv, bytscl(congrid(junk, ceil(delta_x[i]), ceil(delta_y[i])), min=disp_min, max=disp_max), x_offset[i], y_offset[i]
endfor

end
	

