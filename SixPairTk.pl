use strict;
use warnings;
use diagnostics;

use Tk;
use Data::Dumper;

require Tk::Pane;
my $mw = MainWindow->new( );

   $| = 1;

   $mw->geometry("300x300");
   $mw->title("TkSixa");
   $mw->protocol( WM_DELETE_WINDOW => \&ask, );

my $SixPairButton = $mw->Button( -text => "START", 
				 -command => \&sixpair, )->pack( -side => "top",
								 -anchor => "nw", );

my $SixAdButton = $mw->Button( -text => "PAIR", 
			       -command => [ \&sixad, ] )->pack( -side => "top",
							         -anchor => "nw", );
							       				   
my $ClearButton = $mw->Button( -text => "CLEAR", 
			       -command => \&clear, )->pack( -side => "top",
							     -anchor => "nw", );							       
							       							    
my $QuitButton = $mw->Button( -text => "QUIT", 
			      -command => \&stopad, )->pack( -side => "top",
							     -anchor => "nw", );
								   			
my $Pane = $mw->Scrolled( 'Text', Name => 'Display',
        		  -scrollbars => 'e',
			  -relief => "sunken",
			  -background => "WHITE" )->pack( -side => 'bottom', 
			  				  -fill => 'both', 
			  				  -padx => '5', );			  				  
			  
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
sub sixpair {
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
   close($OutFile1);
};


sub sixad {
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

sub clear { 
$Pane->delete('0.1', 'end');
};

sub stopad {
my @stopad = qw/sixad --stop/;
   system(@stopad);
   exit 0;
};

sub counter {
$Count = '1';
};

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
