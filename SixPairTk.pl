use strict;
use warnings;
use diagnostics;

use Tk;
use Data::Dumper;

require Tk::Pane;
my $mw = MainWindow->new( );

   $| = 1;

   $mw->geometry("500x400");
   $mw->title("SixadTk");
   $mw->protocol( WM_DELETE_WINDOW => \&ask, );
   
my $Intro = <<'END_MESSAGE';

  SixadTk maps out your PS3 controller for N64 use by default.

  You must pair your controller with your computer first before you 
  start your ROM or your controller will not work with the emulator.
  

		      ,'00000000000,
		   ,00000000000000000
                 ,000000'         '000
               .O00000'              o 
              O00000'
             OOO000'   ,oOOOOOOOOO*o.
             OOOO0O  ,O'            'O.
             OOOOOO,O'                O',                
              OOOOOO      Sixpair      OO,                 
               OOOOOO.                 OOO,  
                OOOOOOO.             ,OOOOO   
                 'OOOOOOO.         .oOOOOOO  
                   'OOOOOOOOOOOOOOOOOOOOOO   
                      'OOOOOOOOOOOOOOOOOD'    
                         *qOOOOOOOooo**    
                             *oooo**'
                               
                PPP, ,aaaa. IIIII     RRRRRRR
                P  P      a II II     RR   RR
                PPP  ,aaaaa    II     RR
                P    a    a    II     RR
                P    'aaaaa IIIIIII RRRRRR
  
END_MESSAGE

my $SixPairButton = $mw->Button( -text => "START", 
				 -command => \&sixpair, )->pack( -side => "top",
								 -anchor => "nw", 
								 -padx => 5, );

my $SixAdButton = $mw->Button( -text => "PAIR", 
			       -command => [ \&sixad, ] )->pack( -side => "top",
							         -anchor => "nw", 
							         -padx => 5, );
							       				   
my $ClearButton = $mw->Button( -text => "CLEAR", 
			       -command => \&clear, )->pack( -side => "top",
							     -anchor => "nw", 
							     -padx => 5, );							       
							       							    
my $QuitButton = $mw->Button( -text => "QUIT", 
			      -command => \&stopad, )->pack( -side => "top",
							     -anchor => "nw", 
							     -padx => 5, );
my $p = 0;
my @selected;
my @systems = qw/SNES NES/;
for my $r (@systems) {			  				  
my $Config = $mw->Checkbutton( -text => "$r", 
                               -onvalue => $r,
   	                       -offvalue => 0,
		               -variable => \$selected[$p], )->pack( -side => "right",
      	         						     -anchor => "sw" );
         	         						         		         				      	    
   $p=$p+1;   
   }
							   			
my $Pane = $mw->Scrolled( 'Text', Name => 'Display',
        		  -scrollbars => 'e',
			  -relief => "sunken",
			  -background => "WHITE" )->pack( -side => "top",
			  				  -anchor => "nw",
			  				  #-fill => 'both', 
			  				  -padx => '5', );
			  				  
   $Pane->insert("0.0", $Intro);
			  				  
sub warning {
my $Tlw = $mw->Toplevel;
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
my $OutFile1;
my $Count = 0;
## sixpair sub routine.
sub sixpair {
   &clear;
   open $OutFile1, "+<", "tmp1", or die "Can't open file: $!";
   @file1 = ();
   
my @sixpair = qw/sixpair >tmp1/;
   system( "@sixpair" );  
   
while ( <$OutFile1> ) {
   push(@file1, $_);
   $Pane->insert("end", "\n$_");
   }

for my $x ( @selected ) {
   print $x;  
   }     
   
   $Count = 1;
   return   
   close($OutFile1);
};

## sixad subroutine.
sub sixad {
   &clear;
   
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
my $Tlw = $mw->Toplevel;
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
sub disconnect {
my $Tlw = $mw->Toplevel;
   $Tlw->title('Prompt');

my $Label = $Tlw->Label( -text => 'Please disconnect controller.' )->pack( -side => 'top', 
							   		   -pady => '15' );

   $Tlw->Button( -text => "OK", 
   		 -command => sub { $Tlw->withdraw },)->pack( -side => 'left', 
						     	     -anchor => 'sw', 
						     	     -padx => '5', 
						     	     -pady => '5', );
};

MainLoop;
