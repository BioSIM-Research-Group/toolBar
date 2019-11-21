package provide toolBarAbout 1.0.0

#### GUI ############################################################
proc toolBar::about {} {

	#### Check if the window exists
	if {[winfo exists $::toolBar::aboutGui]} {wm deiconify $::toolBar::aboutGui ;return $::toolBar::aboutGui}
	toplevel $::toolBar::aboutGui

	#### Title of the windows
	wm title $toolBar::aboutGui "About" ;# titulo da pagina

	#### Change the location of window
	# screen width and height
	set sWidth [expr [winfo vrootwidth  $::toolBar::aboutGui] -0]
	set sHeight [expr [winfo vrootheight $::toolBar::aboutGui] -50]

	#### Change the location of window
    wm geometry $::toolBar::aboutGui 400x515+[expr $sWidth / 2 - 200]+100
	$::toolBar::aboutGui configure -background {white}
	wm resizable $::toolBar::aboutGui 0 0


  #### Colors

  set color1 #CE9FFC
  set color2 #7367F0

#set color1 #8f92ba
#set color2 #949ad9
  



  #### header
  grid [ttk::frame $toolBar::aboutGui.frame0] -row 0 -column 0
  grid [canvas $toolBar::aboutGui.frame0.canvas -bg $color1 -width 400 -height 150 -highlightthickness 0] -in $toolBar::aboutGui.frame0

  DrawGradient $toolBar::aboutGui.frame0.canvas $color1	$color2 0 0 400

  #Draw text
  $toolBar::aboutGui.frame0.canvas create text 20 80 \
                -text "VMDToolBar"  \
                -font {Arial -40 bold} \
                -anchor w \
                -fill white \
                -tag "delete"

  #Draw text
  $toolBar::aboutGui.frame0.canvas create text 20 110 \
                -text "(version $toolBar::version)"  \
                -font {Arial -12 bold} \
                -anchor w \
                -fill white \
                -tag "delete"



  #### Information 1
  grid [ttk::frame $toolBar::aboutGui.frame1] -row 1 -column 0
	grid [canvas $toolBar::aboutGui.frame1.canvas1 -bg #fffaf0 -width 400 -height 270 -highlightthickness 0] -in $toolBar::aboutGui.frame1


  #set color1 #232526
  #set color2 #414345
  #DrawGradient $toolBar::aboutGui.frame1.canvas1 $color1	$color2 0 0 400

  #Draw text 1
  $toolBar::aboutGui.frame1.canvas1 create text 20 50 \
                -text "ToolBar is a VMD extension that provides easy access to a set of natively available tools and also provides new features to make VMD an even more powerful and user-friendly application."  \
                -font {Helvetica -15} \
                -anchor w \
                -width 370 \
                -fill #575756\
                -tag "delete"

	
  #Draw text 2
  $toolBar::aboutGui.frame1.canvas1 create text 20 120 \
                -text "ToolBar was developed by: \nHenrique S. Fernandes and Nuno M.F.S.A. Cerqueira"  \
                -font {Helvetica -15} \
                -anchor w \
                -width 370 \
                -fill #575756 \
                -tag "delete"

	

   #Draw text 2
  $toolBar::aboutGui.frame1.canvas1 create text 20 210 \
                -text "UCIBIO@REQUIMTE, BioSIM\nDepartamento de Biomedicina, Room 22P4EP\nFaculdade de Medicina da Universidade do Porto\nAlameda Professor Hernani Monteiro,\n4200-319 Porto\nPortugal"  \
                -font {Helvetica -12} \
                -anchor w \
                -width 370 \
                -fill  #575756 \
                -tag "delete"

	#Draw line
	$toolBar::aboutGui.frame1.canvas1 create line 20 160 380 160 -fill #2A2A28 -smooth true -width 1



  #### Logos 1
  grid [ttk::frame $toolBar::aboutGui.frame2] -row 2 -column 0
	grid [canvas $toolBar::aboutGui.frame2.canvas1 -bg white -width 400 -height 60 -highlightthickness 0] -in $toolBar::aboutGui.frame2


  #Image 1
  $toolBar::aboutGui.frame2.canvas1 create image 50 30 \
        -image [image create photo -file "$toolBar::pathImages/../logos/biosim.gif"] \
        -anchor w

  #Image 2
  $toolBar::aboutGui.frame2.canvas1 create image 170 30 \
        -image [image create photo -file "$toolBar::pathImages/../logos/fmup.gif"] \
        -anchor w

  #Image 3
  $toolBar::aboutGui.frame2.canvas1 create image 300 32 \
        -image [image create photo -file "$toolBar::pathImages/../logos/ucibio.gif"] \
        -anchor w



  #### Button
  grid [ttk::frame $toolBar::aboutGui.frame3] -row 3 -column 0 -sticky ew

	grid [button $toolBar::aboutGui.frame3.visitWebsite \
		-text {Web Page} \
    -height 2 \
		-command {invokeBrowser "https://biosim.pt/software/"} \
		] -in $toolBar::aboutGui.frame3  -row 0 -column 0 -sticky ew


  grid rowconfigure $toolBar::aboutGui.frame3   3   -weight 1
  grid columnconfigure $toolBar::aboutGui.frame3   0   -weight 1
}


proc invokeBrowser {url} {
  # open is the OS X equivalent to xdg-open on Linux, start is used on Windows
  set commands {xdg-open open start}
  foreach browser $commands {
    if {$browser eq "start"} {
      set command [list {*}[auto_execok start] {}]
    } else {
      set command [auto_execok $browser]
    }
    if {[string length $command]} {
      break
    }
  }

  if {[string length $command] == 0} {
    return -code error "couldn't find browser"
  }
  if {[catch {exec {*}$command $url &} error]} {
    return -code error "couldn't execute '$command': $error"
  }
}



proc DrawGradient {win col1Str col2Str x0 y0 size} {

    set height 200
    set width [expr $x0 + $size]
    
    set color1 [winfo rgb $win $col1Str]
    set color2 [winfo rgb $win $col2Str]

    foreach {r1 g1 b1} $color1 break
    foreach {r2 g2 b2} $color2 break
    set rRange [expr $r2.0 - $r1]
    set gRange [expr $g2.0 - $g1]
    set bRange [expr $b2.0 - $b1]

    set rRatio [expr $rRange / $width]
    set gRatio [expr $gRange / $width]
    set bRatio [expr $bRange / $width]


    # Draw Line
    for {set i $x0} {$i < $width} {incr i} {
        set nR [expr int( $r1 + ($rRatio * $i) )]
        set nG [expr int( $g1 + ($gRatio * $i) )]
        set nB [expr int( $b1 + ($bRatio * $i) )]

        set col [format {%4.4x} $nR]
        append col [format {%4.4x} $nG]
        append col [format {%4.4x} $nB]

        #$win create line $i $y0 [expr $y0 + $height] $i -fill #${col} -tag "delete"
        $win create line $i $y0 $i [expr $y0 + $height] -fill #${col} -tag "delete"
        

    }

    #Draw box
    $win create rect $x0 $y0 $width [expr $y0 + $height] \
        -outline black \
        -tag "delete"

    return $win
 }