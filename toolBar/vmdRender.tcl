package provide vmdRender 1.0

namespace eval vmdRender:: {
	namespace export vmdRender
	
	#### Load Packages				
	package require Tk

    #### Variables
    variable version 1.0
    variable topGui ".gui"

    variable renderLocation [lindex [::render default Tachyon] 0]
		
}

proc vmdRender::gui {} {
    #### Check if the window exists
	if {[winfo exists $::vmdRender::topGui]} {wm deiconify $::vmdRender::topGui ;return $::vmdRender::topGui}
	toplevel $::vmdRender::topGui

	#### Title of the windows
	wm title $vmdRender::topGui "vmdRender v$vmdRender::version " ;

    #### Screen Size
    set sWidth [expr [winfo vrootwidth  $::vmdRender::topGui] -0]
	set sHeight [expr [winfo vrootheight $::vmdRender::topGui] -100]

    #### Window Size and Position
	wm geometry $::vmdRender::topGui 500x400+[expr $sWidth / 2 - 500 / 2]+[expr $sHeight / 2 - 400 / 2]
	$::vmdRender::topGui configure -background {#ececec}

    grid columnconfigure $vmdRender::topGui     0   -weight 1
    #grid rowconfigure $vmdRender::topGui     0   -weight 1

    set f0 $vmdRender::topGui.frame0
    grid [ttk::frame $f0] -in $vmdRender::topGui -sticky news
    grid columnconfigure $f0     0   -weight 1

    #### Title
    grid [ttk::label $f0.title \
        -text "VMD Render" \
        -anchor center \
        -font {Helvetica -25} \
        ] -in $f0 -row 0 -column 0 -sticky news -ipady 5 

    #### File Location
    set f1 $vmdRender::topGui.frame1
    grid [ttk::frame $f1] -in $vmdRender::topGui -sticky news
    grid columnconfigure $f1     1   -weight 1

    grid [ttk::label $f1.fileLocationLabel \
        -text "Save image as:" \
        ] -in $f1 -row 1 -column 0 -sticky news -pady 5 -padx 10

    variable path "[file nativename "~/"]/image"
    grid [ttk::entry $f1.fileLocationEntry \
        -textvariable vmdRender::path \
        ] -in $f1 -row 1 -column 1 -sticky news -pady 5 -padx 5

    grid [ttk::button $f1.fileLocationButton \
        -text "Browse" \
        -command {set vmdRender::path [tk_getSaveFile -initialfile "image" -initialdir "~/" -title "Save image as"]} \
        ] -in $f1 -row 1 -column 2 -sticky news -pady 5 -padx 5


    #### Shading Options
    set f2 $vmdRender::topGui.frame2
    grid [ttk::frame $f2] -in $vmdRender::topGui -sticky news -pady [list 10 0]

    grid [ttk::label $f2.label \
        -text "Shading Options" \
        -font {Helvetica -14 bold} \
        ] -in $f2 -row 0 -column 0 -sticky news -padx 10 -pady 5

    if {[display get ambientocclusion] == "on"} {
        variable ambientOcclusion 1
    } else {
        variable ambientOcclusion 0
    }
    grid [ttk::checkbutton $f2.ambientOcclusionCheckButton \
        -text "Ambient Occlusion" \
        -variable vmdRender::ambientOcclusion \
        -command {display ambientocclusion $vmdRender::ambientOcclusion; vmdRender::updateAmbientOcclusion} \
        ] -in $f2 -row 1 -column 0 -sticky news -padx 5 -pady 5


    grid [ttk::label $f2.aoAmbientLabel \
        -text "AO Ambient:" \
        ] -in $f2 -row 1 -column 1 -sticky nes -padx 5 -pady 5

    variable aoAmbient [display get aoambient]
    grid [spinbox $f2.aoAmbientSpinBox \
        -from 0.00 \
        -to 1.00 \
        -increment 0.01 \
        -state readonly \
        -width 5 \
        -textvariable vmdRender::aoAmbient \
        -command {display aodirect $vmdRender::aoAmbient} \
        ] -in $f2 -row 1 -column 2 -sticky nws -padx 5 -pady 5


    grid [ttk::label $f2.aoDirectLabel \
        -text "AO Direct:" \
        ] -in $f2 -row 1 -column 3 -sticky nes -padx 5 -pady 5

    variable aoDirect [display get aodirect]
    grid [spinbox $f2.aoDirectSpinBox \
        -from 0.00 \
        -to 1.00 \
        -increment 0.01\
        -state readonly \
        -width 5 \
        -textvariable vmdRender::aoDirect \
        -command {display aodirect $vmdRender::aoDirect} \
        ] -in $f2 -row 1 -column 4 -sticky nws -padx 5 -pady 5

    vmdRender::updateAmbientOcclusion

    if {[display get shadows] == "on"} {
        variable shadows 1
    } else {
        variable shadows 0
    }
    grid [ttk::checkbutton $f2.shadowsCheckButton \
        -text "Shadows" \
        -variable vmdRender::shadows \
        -command {display shadows $vmdRender::shadows} \
        ] -in $f2 -row 2 -column 3 -sticky news -padx 5 -pady 5 -columnspan 2


    grid [ttk::label $f2.shadowsQualityLabel \
        -text "Rendering Quality" \
        ] -in $f2 -row 2 -column 0 -sticky news -padx 10 -pady 5

    variable shadowsQuality "FullShade (best quality)"
    grid [ttk::combobox $f2.shadowsQualityCombo \
        -values [list "FullShade (best quality)" "MediumShade (good quality)" "LowShade (low quality)" "LowestShade (worst quality)"] \
        -textvariable vmdRender::shadowsQuality \
        -state readonly \
        ] -in $f2 -row 2 -column 1 -sticky news -padx 5 -pady 5 -columnspan 2

    grid columnconfigure $f2 1 -weight 2
    grid columnconfigure $f2 4 -weight 2

    #### Resolution Options
    set f3 $vmdRender::topGui.frame3
    grid [ttk::frame $f3] -in $vmdRender::topGui -sticky news -pady [list 10 0]
    
    grid [ttk::label $f3.label \
        -text "Resolution" \
        -font {Helvetica -14 bold} \
        ] -in $f3 -row 0 -column 0 -sticky news -padx 10 -pady 5

    grid [ttk::label $f3.heighLabel \
        -text "Height:" \
        ] -in $f3 -row 1 -column 0 -sticky news -padx 10 -pady 5

    variable height 760
    grid [spinbox $f3.heightSpin \
        -from 1 \
        -to 999999999 \
        -increment 1 \
        -state readonly \
        -width 8 \
        -textvariable vmdRender::height \
        ] -in $f3 -row 1 -column 1 -sticky news -padx 5 -pady 5

    grid [ttk::label $f3.widthLabel \
        -text "Width:" \
        ] -in $f3 -row 1 -column 3 -sticky news -padx 10 -pady 5

    variable width 1024
    grid [spinbox $f3.widthSpin \
        -from 1 \
        -to 999999999 \
        -increment 1 \
        -state readonly \
        -width 8 \
        -textvariable vmdRender::width \
        ] -in $f3 -row 1 -column 4 -sticky news -padx 5 -pady 5

    grid columnconfigure $f3 2 -weight 1
    grid columnconfigure $f3 1 -weight 2
    grid columnconfigure $f3 4 -weight 2

    #### Format Options
    set f4 $vmdRender::topGui.frame4
    grid [ttk::frame $f4] -in $vmdRender::topGui -sticky news -pady [list 10 0]

    grid [ttk::label $f4.label \
        -text "Image Format" \
        -font {Helvetica -14 bold} \
        ] -in $f4 -row 0 -column 0 -sticky news -padx 10 -pady 5

    grid [ttk::label $f4.shadowsQualityLabel \
        -text "Image Format:" \
        ] -in $f4 -row 1 -column 0 -sticky news -padx 10 -pady 5

    if {[string first "Windows" $::tcl_platform(os)] == 0} {
        variable imageFormat "BMP : 24-bit Windows BMP"
    } else {
        variable imageFormat "TARGA : 24-bit Targa"
    }
    grid [ttk::combobox $f4.shadowsQualityCombo \
        -values [list "BMP : 24-bit Windows BMP" "PPM : 24-bit PPM" "PPM48 : 48-bit PPM" "PSD48 : 48-bit PSD" "RGB : 24-bit SGI RGB" "TARGA : 24-bit Targa"] \
        -textvariable vmdRender::imageFormat \
        -state readonly \
        ] -in $f4 -row 1 -column 1 -sticky news -padx 5 -pady 5


    grid [ttk::label $f4.aasamplesLabel \
        -text "Anti-aliasing:" \
        ] -in $f4 -row 1 -column 3 -sticky news -padx 10 -pady 5

    variable aasamples 12
    grid [spinbox $f4.aasamplesSpin \
        -from 1 \
        -to 999999999 \
        -increment 1 \
        -state readonly \
        -width 8 \
        -textvariable vmdRender::aasamples \
        ] -in $f4 -row 1 -column 4 -sticky news -padx 5 -pady 5

    grid columnconfigure $f4 2 -weight 1
    grid columnconfigure $f4 1 -weight 2
    grid columnconfigure $f4 4 -weight 2    

    #### Buttons Options
    set f5 $vmdRender::topGui.frame5
    grid [ttk::frame $f5] -in $vmdRender::topGui -sticky sew -pady [list 10 0]

    grid [ttk::button $f5.render \
        -text "Render" \
        -command {vmdRender::render} \
        ] -in $f5 -row 0 -column 4 -sticky es -padx 25 -pady 5

    grid [ttk::button $f5.cancel \
        -text "Close" \
        -command "destroy $vmdRender::topGui" \
        ] -in $f5 -row 0 -column 3 -sticky es -padx 5 -pady 5
    
    grid columnconfigure $f5 2 -weight 1


    grid rowconfigure $vmdRender::topGui 5 -weight 1

}

proc vmdRender::updateAmbientOcclusion {} {
    set f2 $vmdRender::topGui.frame2
    if {[display get ambientocclusion] == "off"} {
        $f2.aoAmbientSpinBox configure -state disabled
        $f2.aoDirectSpinBox configure -state disabled
        $f2.aoDirectLabel configure -state disabled
        $f2.aoAmbientLabel configure -state disabled
    } else {
        $f2.aoAmbientSpinBox configure -state normal
        $f2.aoDirectSpinBox configure -state normal
        $f2.aoDirectLabel configure -state normal
        $f2.aoAmbientLabel configure -state normal
    }
}

proc vmdRender::render {} {
    catch {graphics $toolBar::Layer delete all}

    set cmd "\"[lindex [::render default Tachyon] 0]\""
    
    append cmd " $vmdRender::path"

    switch $vmdRender::shadowsQuality {
        "" -
        "FullShade (best quality)" {
            append cmd " -fullshade"
        }
        "MediumShade (good quality)" {
            append cmd " -mediumshade"
        }
        "LowShade (low quality)" {
            append cmd " -lowshade"
        }
        "LowestShade (worst quality)" {
            append cmd " -lowestshade"
        }
    }

    append cmd " -res $vmdRender::width $vmdRender::height"

    append cmd " -aasamples $vmdRender::aasamples"

    switch $vmdRender::imageFormat {
        "" -
        "BMP : 24-bit Windows BMP" {
            append cmd " -format BMP -o $vmdRender::path.bmp"
            set theFilename "$vmdRender::path.bmp"
        }
        "PPM : 24-bit PPM" {
            append cmd " -format PPM -o $vmdRender::path.ppm"
            set theFilename "$vmdRender::path.ppm"
        }
        "PPM48 : 48-bit PPM" {
            append cmd " -format PPM48 -o $vmdRender::path.ppm"
            set theFilename "$vmdRender::path.ppm"
        }
        "PSD48 : 48-bit PSD" {
            append cmd " -format PSD48 -o $vmdRender::path.psd"
            set theFilename "$vmdRender::path.psd"
        }
        "RGB : 24-bit SGI RGB" {
            append cmd " -format RGB -o $vmdRender::path.rgb"
            set theFilename "$vmdRender::path.rgb"
        }
        "TARGA : 24-bit Targa" {
            append cmd " -format TARGA -o $vmdRender::path.tga"
            set theFilename "$vmdRender::path.tga"
        }
    }
    
    ::render Tachyon $vmdRender::path $cmd

}

#### Start
#vmdRender::gui