# This file uses the "Perlish" coding style
# please read http://perl.4pro.net/perlish_coding_style.html

; use ExtUtils::MakeMaker

; my $dist = 'CGI::Builder::DFVCheck'
; my $vers = '1.23'

; WriteMakefile
   ( NAME           => $dist
   , VERSION        => $vers
   , ( $] ge '5.005' )
     ? ( AUTHOR     => 'Domizio Demichelis - perl.4pro.net'
       , ABSTRACT   => 'CGI::Builder and Data::FormValidator integration'
       )
     : ()
   , PREREQ_PM      => { 'CGI::Builder'        => '1.2'
                       , 'Data::FormValidator' => '3'
                       }
   )


; 1
