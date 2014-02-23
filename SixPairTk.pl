use strict;
use warnings;
use diagnostics;

use Tk;
use Data::Dumper;

require Tk::Pane;
require Tk::NoteBook;

my $mw = MainWindow->new( );

   $| = 1;

   $mw->geometry("500x400");
   $mw->title("SixadTk");
   $mw->protocol( WM_DELETE_WINDOW => \&ask, );
   
my $Book = $mw->NoteBook()->pack( -fill => 'both', -expand => 1 );
my $Tab1 = $Book->add( "Sheet 1", -label => "tab 1", );
   
my $Tab2 = $Book->add( "Sheet 2", -label => "tab 2", );

my $Tab3 = $Book->add( "Sheet 3", -label => "tab 3", );
   
my $IntroCounter = 0;   
my $Intro = <<'END_MESSAGE';

  SixadTk maps out your PS3 controller for N64 use by default.

  You must pair your controller with your computer first before you 
  start your ROM or your controller will not work with the emulator.
  
  * HOW TO:
  
    Plug in your PS3 controller to your laptop via USB and click start.
    Then unplug your controller and click on the pair button to pair 
    your controller.
  
END_MESSAGE

my $SixPairButton = $Tab1->Button( -text => "START", 
				 -command => \&sixpair, )->pack( -side => "top",
								 -anchor => "nw", 
								 -padx => 5, );

my $SixAdButton = $Tab1->Button( -text => "PAIR", 
			       -command => [ \&sixad, ] )->pack( -side => "top",
							         -anchor => "nw", 
							         -padx => 5, );
							       				   
my $ClearButton = $Tab1->Button( -text => "CLEAR", 
			       -command => \&clear, )->pack( -side => "top",
							     -anchor => "nw", 
							     -padx => 5, );							       
							       							    
my $QuitButton = $Tab1->Button( -text => "QUIT", 
			      -command => \&stopad, )->pack( -side => "top",
							     -anchor => "nw", 
							     -padx => 5, );
my $i;
my @Var;
my $d = 0;
my @selected;
my @systems = qw/SNES SEGA/;
for my $r (@systems) {
my $CheckButton = $Tab1->Checkbutton( -text => $r, 
                                    -onvalue => $r,
   	                            -offvalue => 0,
		                    -variable => \$selected[$d], )->pack( -side => "right",
      	         						          -anchor => "sw" );
      	         						     
   $d=$d+1;      	         						     
}
         	         						         		         				      	    
my $Pane = $Tab1->Scrolled( 'Text', Name => 'Display',
        		  -scrollbars => 'e',
			  -relief => "sunken",
			  -background => "WHITE" )->pack( -side => "top",
			  				  -anchor => "nw",
			  				  #-fill => 'both', 
			  				  -padx => '5', );
			  				  
   $Pane->insert("0.0", $Intro);
			  				  
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
my $GensCfg;
my $OutFile1;
my $Count = 0; 
## sixpair sub routine.
sub sixpair {
if( $IntroCounter lt 1 ) { 
   &clear 
   }
   $IntroCounter = 1;
   
   open $OutFile1, "+<", "tmp1", or die "Can't open file: $!";
   @file1 = ();
   
my @sixpair = qw/sixpair >tmp1/;
   system( "@sixpair" );  
   
while ( <$OutFile1> ) {
   push(@file1, $_);
   $Pane->insert("end", "\n$_");
   }
   
   $Count = 1;
   return   
};

## sixad subroutine.
sub sixad {
if( $IntroCounter lt 1 ) { 
   &clear 
   }
   $IntroCounter = 1;
   
for my $t ( @file1 ) {
   if( $t =~ m/No controller found on USB busses./ ) { 
    &warning; 
    $Count = 0;
    return 
    } 
   
   }

if ( $Count gt 0 ) {    

   open my $OutFile2, "+<", "tmp2", or die "Can't open file: $!";
    
my @sixad = qq/\/etc\/init.d\/sixad start >tmp2/;
   system( "@sixad" );
   
for my $t ( @selected ) {
   if( $t =~ 'SEGA' ) {
    &sega_cfg;
    }
   } 

while( <$OutFile2> ) {
   $Pane->insert("end", "\n$_");
   if( $_ =~ m/...done./ ) {
    &disconnect;
    $Pane->insert("end", "\n\nPress the PS button now to pair.");       
    }
   }   
      
   return;
   close($OutFile2);
   }
      else {
      &warning; 
      return;
      }
      
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
my @stopad = qw/sixad --stop/;
   system(@stopad);
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

sub unplug_to_pair {
   open my $OutFile3, "+<", "tmp3", or die "Can't open file: $!";
   
my @sixpair = qw/sixpair >tmp3/;
   system( "@sixpair" );
   
while(<$OutFile3>) {
   if( $_ =~ m/No controller found on USB busses./ ) {
    print $_;
    $TlwD->withdraw;
    }  
       else {
       $TlwD->state('normal');
       }
   }
};

my $Counter = 0;
sub sega_cfg {
opendir my $Dir, '/home/anthony/.gens';

   if( -e $Dir ) {
   print "Dir exists.\n";
   $Counter = $Counter + 1;
   open $GensCfg, '+<', "/home/anthony/.gens/gens.cfg" or die "Cannot open file: $!";

my @Cfg = qw/P1.A=0x900E P1.B=0x900F P1.C=0x900C P1.Down=0x9006 P1.Left=0x9007 P1.Right=0x9005 P1.Start=0x9003 P1.Up=0x9004/;

while(<$GensCfg>) {
   if( $_ =~ m/^P1\./ ) {
   for $i ( @Cfg ) {
      if( $_ =~ $i ) {
         print $_; 
         }
       }
      }
      else {
      &append;
      }
   }
      }
      else { 
      print "Dir does not exist and counter does not equal 0.\n";
      while($Counter eq 0 ) {
      print "Dir does not exist but counter is equal to 0.\n";
       &present;
       $Counter = $Counter + 1;
       }
      
      }

};

sub append {
open $SegaCfg, '<', "SEGA.cfg" or die "Cannot open file: $!";

my @sega_cfg = <$SegaCfg>;
for $i ( @sega_cfg) {
   print $GensCfg $i;
   }
   
   close($SegaCfg);
};

sub present {
my $Tlw = $Tab1->Toplevel;
   $Tlw->title('Prompt');

my $Label = $Tlw->Label( -text => 'Sega is not installed.' )->pack( -side => 'top', 
							            -pady => '15' );

   $Tlw->Button( -text => "OK",
		 -command => sub { $Tlw->withdraw }, return )->pack( -side => 'right', 
							             -anchor => 'se', 
							             -padx => '5', 
							             -pady => '5' );
};

##########################
### Beginning of tab 2 ###
##########################


MainLoop;
