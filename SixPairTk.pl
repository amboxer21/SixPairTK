#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Tk;
use Data::Dumper;

require Tk::Pane;
require Tk::NoteBook;

my $USER = $ENV{'USER'};

my $mw = MainWindow->new( );

   $| = 1;

   $mw->geometry("500x400+0+0");
   $mw->title("SixadTk");
   $mw->protocol( WM_DELETE_WINDOW => \&ask, ); 
   
my $Book = $mw->NoteBook()->pack( -fill => 'both', 
				  -expand => 1 );
				  
my $Tab1 = $Book->add( "Sheet 1", -label => "Main", );

my $Frame = $Tab1->Frame()->pack( -side => "right", 
				  -anchor, 'se');  
   
my $Tab2 = $Book->add( "Sheet 2", -label => "tab 2", );

my $Tab3 = $Book->add( "Sheet 3", -label => "tab 3", );
   
my $IntroCounter = 0;   
my $Intro = <<'END_MESSAGE';

  SixadTk maps out your PS3 controller for N64 use by default.

  You must pair your controller with your computer first before you 
  start your ROM or your controller will not work with the emulator.
  
  * HOW TO:
  
    Plug in your PS3 controller to your laptop via USB and click re-map.
    Then unplug your controller and PS button to pair 
    your controller.
  
END_MESSAGE

my $InstalledEmsFrame = $Tab1->Frame( -borderwidth => 2, -relief => 'groove' )->pack( -side => "right", -anchor => 'se');

my $Gens  = "/home/$USER/.gens";
my $Mupen = "/home/$USER/.config/mupen64plus";
my $Zsnes = "/home/$USER/.zsnes";

my $i;
my $Done = 0;
my $Counter = 0;
my $GensCfg;
while( $Done ne 1) {
my $InstaledEmsLabel = $InstalledEmsFrame->Label( -text => 'Installed Ems', -borderwidth => 2, -relief => 'ridge', )->pack( ); 
							            	   
   if( -d $Gens ) { 
   open $GensCfg, '+<', "/home/$USER/.gens/gens.cfg";
   open my $SegaCfg, '<', "SEGA.cfg";
   
   my @Cfg = qw/P1.A=0x900E P1.B=0x900F P1.C=0x900C P1.Down=0x9006 P1.Left=0x9007 P1.Right=0x9005 P1.Start=0x9003 P1.Up=0x9004/;
   
   my @sega_cfg = <$SegaCfg>;
   for $i ( @sega_cfg) {
    print $GensCfg $i;
    }
   
   my $GSelected;   
   my $GensLabel = $InstalledEmsFrame->Checkbutton( -text => 'GENS ', 
                                       		    -onvalue => 1,
   	                               		    -offvalue => 0,
		                       		    -variable => \$GSelected, )->pack( );
    
    close($SegaCfg);
    close($GensCfg);   
   } 
   
   if( -d $Mupen ) {
   open my $MupenCfg, '+>>', "/usr/local/share/mupen64plus/InputAutoCfg.ini" or die "Cannot open file: $!";
   open my $PS3Cfg, '<', "PS3Controller.cfg" or die "Cannot open file: $!";
   
   my @PS3Cfg = <$PS3Cfg>;
   for $i ( @PS3Cfg) {
    print $MupenCfg $i;
    }
   
   my $MSelected; 
   my $MupenLabel = $InstalledEmsFrame->Checkbutton( -text => 'Mupen', 
                                       		     -onvalue => 1,
   	                               		     -offvalue => 0,
		                       		     -variable => \$MSelected, )->pack( );    
    
    close($PS3Cfg);
    close($MupenCfg); 
   }
      
   if( -d $Zsnes ) {

   my $ZSelected;
   my $ZsnesLabel = $InstalledEmsFrame->Checkbutton( -text => 'SNES ', 
                                       		     -onvalue => 1,
   	                               		     -offvalue => 0,
		                       		     -variable => \$ZSelected, )->pack( );
    
   }
      else {
       #&snes_present;
      }

$Done = 1;
}

my $BFrame = $Tab1->Frame( -borderwidth => 1, 
			   -relief => 'solid' )->pack( -side => "top", 
			   			       -anchor => 'nw', );

my $SixPairButton = $BFrame->Button( -text => "RE-MAP", 
				     -command => \&sixpair, )->pack( );
							       				   
my $ClearButton = $BFrame->Button( -text => " CLEAR", 
			           -command => \&clear, )->pack( );							       
							       							    
my $QuitButton = $BFrame->Button( -text => " QUIT ", 
			          -command => \&stopad, )->pack( );
							   												       
#my $Banner = $BFrame->Scrolled( "Pane", Name => 'Display', -foreground => 'red',)->grid( -column =>  '2');							       
							     
my @sixad = qq/\/etc\/init.d\/sixad start/;
#my @sixad = qq/sixad --start/;
   system("@sixad"); 
							     
my @Var;
         	         						         		         				      	    
my $Pane = $Tab1->Scrolled( "Text", Name => 'Display',
        		           -scrollbars => 'e',
			           -relief => "sunken",
			           -foreground => 'blue',
			           -background => "WHITE" )->pack( -side => "top",
			  				  	   -anchor => "nw",
			  				  	  #-fill => 'both', 
      	 		  				  	   -padx => '5', );
      	 		  		
   $Pane->insert("0.0", $Intro, );

## warning sub routine.			  				  
sub warning {
my $Tlw = $Tab1->Toplevel;
   $Tlw->title('Warning');

my $Label = $Tlw->Label( -text => 'Please connect controller before pairing.' )->pack( -side => 'top', 
							   		 	       -pady => '15' );

   $Tlw->Button( -text => "OK",
		 -command => sub { $Tlw->withdraw }, )->pack( -side => 'bottom', 
							      -anchor => 'se', 
							      -padx => '5', 
							      -pady => '5' );
};

my @file1;
my $SegaCfg;
my $Menu = 0;
my $OutFile1;
my $Count = 0; 
## sixpair sub routine.
sub sixpair {
if( $IntroCounter lt 1 ) { 
   &clear 
   }
   $IntroCounter = 1;
   
   open $OutFile1, "+<", "/home/$USER/tmp1", or die "Can't open file: $!";
   @file1 = ();
   
my @sixpair = qq/\/usr\/bin\/sudo \/usr\/bin\/sixpair > \/home\/$USER\/tmp1/;
   system("@sixpair");  
   
while ( <$OutFile1> ) {
   push(@file1, $_);
   $Pane->insert("end", "\n$_");
   
   if ( $_ !~ m/No controller found on USB busses./ ) {
    print "Disconnect sub is called.\n";
    &disconnect; 
    return
    }
   }
   $Count = 1;
   return   
};

## ask subroutine.
sub ask {
my $Tlw = $Tab1->Toplevel;
   $Tlw->title('Prompt');

my $Label = $Tlw->Label( -text => 'Are you sure?' )->pack( -side => 'top', 
							   -pady => '15' );

   $Tlw->Button( -text => "Quit", 
		 -command => \&stopad, )->pack( -side => 'left', 
						-anchor => 'sw', 
						-padx => '5', 
						-pady => '5', );

   $Tlw->Button( -text => "Cancel",
		 -command => sub { $Tlw->withdraw }, )->pack( -side => 'right', 
							      -anchor => 'se', 
							      -padx => '5', 
							      -pady => '5' );
};

## clear subroutine.
sub clear { 
$Pane->delete('0.1', 'end');
};

## stopad subroutine.
sub stopad {
my @stopad = qq/\/etc\/init.d\/sixad stop/;
   system("@stopad");
   exit 0;
};

## counter subroutine.
sub counter {
	$Count = '1';
};

## disconnect subroutine.
my $TlwD;
sub disconnect {
   $TlwD = $Tab1->Toplevel;
   $TlwD->title('Prompt');

my $Label = $TlwD->Label( -text => 'Please disconnect controller.' )->pack( -side => 'top', 
							   		   -pady => '15' );

   $TlwD->Button( -text => "OK", 
   		  -command => \&unplug_to_pair, )->pack( -side => 'bottom', 
						     	 -anchor => 's', 
						     	 -padx => '5', 
						     	 -pady => '5', );
};

## unplug_to_pair sub routine.
sub unplug_to_pair {
   open my $OutFile3, "+<", "/home/$USER/tmp3", or die "Can't open file: $!";
   
my @sixpair = qq/\/usr\/bin\/sudo \/usr\/bin\/sixpair > \/home\/$USER\/tmp3/;
   system("@sixpair");
   
while(<$OutFile3>) {
   if( $_ =~ m/No controller found on USB busses./ ) {
    $Pane->insert("end", "\n\nPress the PS button now to pair.");
    $TlwD->withdraw;
    }  
       else {
       $TlwD->state('normal');
       }
   }
   
   close($OutFile3);
};

##########################
### Beginning of tab 2 ###
##########################


MainLoop;
