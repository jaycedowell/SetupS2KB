Using Setup S2KB to Setup Observations and Locate Guide Stars
=============================================================

Introduction
------------
Setup S2KB started as simple command line utility written in IDL to help determine a pointing center for observation.  
It was originally intended to help deal with the problem of which way and how much to offset the telescope to find a 
suitable guide star.  However, it has evolved into a much more flexible tool that can be used both before observations
begin to plan a field and during observations to help identify guide stars.  The purpose of this document is to introduce 
how to use the program and its various features.  No previous knowledge of IDL is necessary.

Start Up
--------
Setup S2KB is currently installed on sage.  To start the program, open an xterm and type `/home/36inch/setup_s2kb.sh` at 
the command prompt.  This will bring up an IDL start up dialog (shown in Figure 1) that needs to be clicked to continue.

![Figure 1](doc/pic_0_idl.png)

Figure 1: IDL startup dialog which can be cleared by clicking the “Click to Continue” button.
After the dialog disappears, the main program window, shown in Figure 2, appears.  

There are three main parts to this window.  Located at the top are two panels, "S2KB Pointing" and "Guide Camera Limiting Magnitude", 
that control the position of the field and the sensitivity of the guide camera.  The values in "S2KB Pointing" are Initial RA/Dec., 
Offset RA/Dec., and Current RA/Dec.  Initial refers to the initial pointing of the field and all offsets are calculated from this 
position.  Offset refers to the right ascension and declination offsets that lead to the currently displayed pointing.  Finally, 
the Current settings give the coordinates associated with the currently displayed pointing.  At start up, all values are set to 
zero.  The "Guide Camera Limiting Magnitude" panel controls to what  magnitude stars are labeled on the North and South guide 
camera images.  Stars found in the HST Guide Star Catalog v2.3.2 with V-band magnitudes less than or equal to the displayed value 
are labeled by their magnitudes.  The default is to label all stars brighter than 14.5 mag, the sensitivity limit of the two guide 
cameras.  The “+0.5 mag” and “-0.5 mag” buttons located at the bottom of this panel can be used to increase or decrease this 
limiting magnitude.

![Figure 2](doc/pic_3_running.png)

Figure 2: Main program window for Setup S2KB with the field around NGC 4214 displayed.  Yellow triangles denote the locations 
of galaxies in NED with known velocities.

The next section of the window contains the three image areas.  The largest display 
is a 25'x25' DSS Blue2 image that represents the current field of view as seen by S2KB.  This image is purposely oversized to 
allow the user to see what is around the edge of the field.  The displays come with a number of overlays turned on by default.  
The purple box denotes the center of S2KB (pixel 1024,1024) while the large green boxes represent the field of view of each 
camera.  To accommodate observers who wish to only read out a portion of the chip, the field of view of S2KB can be changed 
through the “Field of View” menu.  This is detailed in Section 5.   The red lines show the locations of the bad columns on S2KB 
and white bars in the lower left of each display indicate scale.  The yellow triangles in the field indicate NED galaxies with 
known velocities and are overlayed by default.  Usage of the NED overlay is given in Section 7.  The upper right-hand display 
is for the North camera while the lower right-hand display is for the South camera.  These fields are both 7'x7' DSS Blue2 
images.  Stars brighter than the current guide camera limiting magnitude are denoted by blue boxes and labeled by their V-band 
apparent magnitudes.  

The final section of the main Setup S2KB window is the NED source list.  For every NED object labeled in the field, its name, 
type, and velocity are listed here.  This list is automatically updated for each new pointing.

Pointing
--------
There are two ways to move the field center to a particular target.  If you already know the RA and Dec. of the source you are 
interested in, you can simply enter it into the Initial Ra/Dec. boxes located in the "Setup S2KB" panel.  These boxes accept 
coordinates in the form of HH MM SS.S for RA and sDD MM SS for declination.  Once the coordinates are entered, the new field 
can be downloaded and displayed by pushing the “Show Field” button located in the lower right of the main window.  The cursor 
will change to an hourglass while the images are being loaded and NED is being queried.

If you do not already have the coordinates for your target, Setup S2KB has a built-in name resolver that uses SIMBAD.  To access 
this, select File -> Resolve Name.  This brings up the window shown in Figure 3.

![Figure 3](doc/pic_2_resolve.png)

Figure 3: SIMBAD name resolver window.

To use this dialog, type the object name into the text box and click "Resolve".  If the name is resolved successfully, the 
coordinates of the object will appear below the text box in the dialog window.  If not, then an error message will be displayed.  
Once the coordinates are known, the "Go To" button can be clicked to send the resolved coordinates to the main Setup S2KB 
window and update the pointing.

Offsets
-------
Once the DSS images have been loaded for a particular pointing, the pointing center can be offset using the left or right mouse 
button.  To do this, simply click on the "S2KB Field" display where  the new center is desired.  This will shift the pointing 
center, reload the images, and update the Offset and Current values displayed in the "S2KB Pointing" panel.  Offsets can also be 
entered manually by typing the desired offsets into the Offset boxes and clicking "Show Field".

Changing the S2KB Field Size
----------------------------
Although the default S2KB field size is displayed as 20.5'x20.5', it is possible to display other sizes using the "Field of View"
menu.  This menu has three size options: "Full Frame", "1536x1536, Centered", "1024x1024, Centered", and "Custom Frame".  
"Full Frame" is the default option and shows the full field of view.  "1536x1536, Centered" is a 15.4’x15.4’ field (roughly 1/2 
the total area) that is centered on pixel (1024,1024) that is equivalent to using the IRAF task `epar detpars` of 256:1792.  
"1024x1024, Centered" is similar but provides only a 10.2'x10.2' field of view (roughly 1/4 the total area).  The final option, 
"Custom Frame", allows the observer to set a custom frame size in the same fashion as `epar detpars`.  The custom frame size is 
set using Field of View -> Set Custom Frame.  This option bring up the window shown in Figure 4.

![Figure 4](doc/pic_4_custom.png)

Figure 4: Dialog window used to set and display a custom frame for S2KB.

Once the desired size has been entered in the format of <start row/column>:<end row/column>, click "Set Size" to save the values 
and display the new frame.

Saving/Printing Images
----------------------
It is also possible to create finding charts using Setup S2KB through the File -> Export JPEG and File -> Print options.  Export 
JPEG brings up a window, shown in Figure 5, that allows the current view to be saved to a JPEG.  The output file name is automatically 
suggested based on the current pointing center.  Both of the text boxes can be changed.  The JPEG is saved as gray scale and does 
not include any of the NED overlay objects.  It does, however, include the RA and declination of the field center, the bad 
columns, fields of view, and labeled guide stars.

![Figure 5](doc/pic_5_jpeg.png)

Figure 5: Window used to save a JPEG of the current view.

![Figure 6](doc/pic_6_print.png)

Figure 6: Print window.

The Print option creates an output similar to Export JPEG but sends it to a printer instead.  The print window is pictured in 
Figure 6.  By default, this will use the `lp` command which sends the image to the default printer.  If you wish to use a different 
command, enter it here.

The NED Overlays
----------------
Some of the more complicated aspects of this program deal with the NED overlays.  Control of the overlays are accomplished through 
the "Object Types" and "Display Overlays" menus.

![Figure 7](doc/pic_8_filter.png)

Figure 7: Image of the "Display Filters" menu.

Object Types:

This menu is shown in Figure 8 and controls which type of objects are displayed when the various overlays are enabled.  Most of the
options are self-explanatory, however, a few are not.  Galaxy Groups includes galaxy pairs, triples, groups and clusters.  Parts 
of Galaxies consists of SDSS galaxy fragments and HII regions.  Stars contains any object in NED that has a type that includes 
the '*' character.  Unclassified is itself a menu that breaks unclassified objects into various wavelength regimes.  To help 
distinguish the various object types, they are assigned different symbols.  The symbols are listed in Table 1.  The default settings 
are to only display galaxies.  These symbol listings can also be accessed from within Setup S2KB via Help -> Overlay Legend.

| Object Type       | Symbol    |
|-------------------|-----------|
| Galaxies          | Triangle  |
| Galaxy Groups     | Triangle  |
| Parts of Galaxies | Triangle  |
| Quasars           | Plus Sign |
| Supernovae        | 'X'       |
| Stars             | Asterisk  |
| Unclassified      | Diamond   |

Table 1: NED object types symbol table.
   
Display Overlays:

This menu, pictured in Figure 8, controls which overlays are displayed and has three sections.  The upper section (two options) 
sets which NED objects matching the selected criteria set under "Object Types" should be displayed based on velocity information.  

![Figure 8](doc/pic_7_overlay.png)

Figure 8: Image of the "Display Overlays" menu.

The first option, "NED – All known Velocity", is turned on by default and displays all NED objects in the field that have velocity 
information and have their object type selected in the "Display Filters" menu.  The second option displays only the NED objects 
that do not have any velocity information.  

The middle section (five options) is specially designed for extragalactic H-alpha work and color-codes galaxies in the current 
field based on which of the five WIYN 0.9m H-alpha filters should be used to observe them.  The color-coding and velocity ranges 
of each filter are shown in Table 2.

| Filter Name | Central Wavelength [ang] | Color Code | Velocity Range [km/s] |
|-------------|--------------------------|------------|-----------------------|
| Y006        | ~6580                    | Red        | -140 – 1,700          |
| Y007        | ~6620                    | Green      | 1,450 – 3,600         |
| Y008        | ~6660                    | Blue       | 3,300 – 5,350         |
| Y009        | ~6700                    | Purple     | 5,000 – 7,400         |
| Y010        | ~6740                    | White      | 7,200 – 9,300         |

Table 2: Color code key for H-alpha filter selection.

The velocity ranges are computed off the width of the filter at 80% transmission.  These alternative colors are only displayed if Display Filters -> Galaxies option is enabled.  These color codes can also be accessed from within Setup S2KB via Help -> Overlay Legend.

The final section (one option) allows the user to overlay objects in the loaded telescope cache as open  circles.  If a cache has not been loaded prior to selecting this option, a dialog will appear (Figure ##) to load a cache.

The Telescope Cache
-------------------
A properly formatted version of a telescope cache file can be loaded into Setup S2KB and accessed.  The cache format is:

```
L112_822   20:42:50.0  +00:15:30  2000  0.00  0.00  0.00
BD75325    08:10:49.3  +74:57:57  2000  0.00  0.00  0.00
Feige34    10:39:36.7  +43:06:10  2000  0.00  0.00  0.00
Feige66    12:37:23.6  +25:04:00  2000  0.00  0.00  0.00
```

Each columns are separated by one or more spaces.  The first column is the target name, the second is the target RA, the third is 
the declination, and the fourth is the epoch.  

![Figure 9](doc/pic_10_cache.png)

Figure 9: Dialog window to load a telescope cache.

The remaining three columns are expected by the ACE TCS.  To load a cache, select File -> Load Telescope Cache.  This will bring up 
a dialog window (Figure 9).  Note:  A copy of the cache must be stored on sage.

Once the cache is loaded, targets can be selected from the cache in two ways.  The most direct is through File -> Select From Cache.  
This brings up the window shown in Figure 10.

![Figure 10](doc/pic_11_select.png)

Figure 10: Selection dialog for the telescope cache.

Once an object has been selected, its coordinates appear at the bottom of the window.  To go to the selected target, click "GoTo".  
Objects in the telescope cache can also be selected through the coordinate resolver (File -> Resolve Name).  The name typed into 
the resolved does not need to exactly match the name stored in the cache.  For example, the target "NGC6791" is matched by the 
names "NGC6791", "NGC 6791", "Ngc 6791", and "ngc 6791".  

Known Issues and Limitations
----------------------------
  * The print feature is UNIX/Linux specific.  For computers without `lp`, i.e., Windows, this will generate an error.
