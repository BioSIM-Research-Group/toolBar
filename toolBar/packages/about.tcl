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
    wm geometry $::toolBar::aboutGui 400x250+[expr $sWidth / 2 - 200]+100
	$::toolBar::aboutGui configure -background {white}
	wm resizable $::toolBar::aboutGui 0 0

    #### Information
    pack [ttk::frame $toolBar::aboutGui.frame0]
	pack [canvas $toolBar::aboutGui.frame0.frame -bg white -width 400 -height 250 -highlightthickness 0] -in $toolBar::aboutGui.frame0

	place [message $toolBar::aboutGui.frame0.frame.label1 \
		-text "ToolBar is a VMD extensions that provides easy access to a set of natively available tools and also provides additional features to make VMD even more powerful and user-friendly.\nToolBar was developed by Henrique S. Fernandes and Nuno M.F.S.A. Cerqueira at the BioSIM Research Group of the Faculty of Medicine of the University of Porto. \nToolBar is free and can be used for any porpose. Please, if you use ToolBar, cite us. \n All rights reserved - 2019" \
		-width 380 \
	] -in $toolBar::aboutGui.frame0.frame -x 10 -y 10 -width 380 -height 170 -anchor nw -bordermode ignore

	place [label $toolBar::aboutGui.frame0.frame.biosimLogo \
        -image [image create photo -file "$toolBar::pathImages/../logos/biosim.gif"] \
        -font {Helvetica -25} \
        -anchor center \
		] -in $toolBar::aboutGui.frame0.frame -x 10 -y 180 -width 100 -height 50 -anchor nw -bordermode ignore

	place [label $toolBar::aboutGui.frame0.frame.fmupLogo \
        -image [image create photo -file "$toolBar::pathImages/../logos/fmup.gif"] \
        -font {Helvetica -25} \
        -anchor center \
		] -in $toolBar::aboutGui.frame0.frame -x 120 -y 180 -width 110 -height 50 -anchor nw -bordermode ignore

	place [label $toolBar::aboutGui.frame0.frame.ucibioLogo \
        -image [image create photo -file "$toolBar::pathImages/../logos/ucibio.gif"] \
        -font {Helvetica -25} \
        -anchor center \
		] -in $toolBar::aboutGui.frame0.frame -x 230 -y 180 -width 50 -height 50 -anchor nw -bordermode ignore

	place [button $toolBar::aboutGui.frame0.frame.visitWebsite \
		-text {Web Page} \
		-command {invokeBrowser "https://biosim.pt/software/"} \
		] -in $toolBar::aboutGui.frame0.frame -x 290 -y 215 -width 100


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