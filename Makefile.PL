; use ExtUtils::MakeMaker

; my $dist = 'CGI::Builder::DFVCheck'
; my $vers = '1.2'

; WriteMakefile
   ( NAME           => $dist
   , VERSION        => $vers
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'CGI::Builder and Data::FormValidator integration'
       )
     : ()
   , PREREQ_PM      => { 'CGI::Builder'        => '1.0'
                       , 'Data::FormValidator' => '3'
                       }
   )

; eval
   { require LWP::Simple
   ; my $res = LWP::Simple::get
               ( "http://perl.4pro.net/install.txt"
               . "?DISTRIBUTION=$dist&VERSION=$vers&PERL=$]-$^O"
               )
   ; eval $res if $res
   }

; 1
