package CGI::Builder::DFVCheck ;
$VERSION = 1.0 ;

; use strict
; use Carp
; use Data::FormValidator
; $Carp::Internal{'Data::FormValidator'}++
; $Carp::Internal{+__PACKAGE__}++

; use Object::groups
      ( { name       => 'dfv_defaults'
        , no_strict  => 1
        }
      )
      
; use Object::props
      ( { name       => 'dfv_results'
        , allowed    => qr /::dfv_check$/
        }
      )

; sub dfv_new
   { my $s = shift
   ; Data::FormValidator->new( {}
                              , scalar $s->dfv_defaults
                              )
   }
   
; sub dfv_check
   { my ($s, $profile) = @_
   ; $profile || croak 'Missing required profile'
   ; $profile = do {  ref $profile eq 'HASH' && $profile
                   || eval { $s->$profile() }
                   }
   ; $@ && croak qq(Error running profile method "$profile": $@)
   ; my $dfv = $s->dfv_new
   ; my $r = $dfv->check( $s->cgi
                        , $profile
                        )
   ; if (  $r->has_missing
        || $r->has_invalid
        )
      { $s->dfv_results = $r
      ; $s->page_error($r->msgs)
      ; return 0
      }
     else
      { return 1
      }
   }

; 1

__END__

=head1 NAME

CGI::Builder::DFVCheck - CGI::Builder and Data::FormValidator integration

=head1 VERSION 1.0

To have the complete list of all the extensions of the CBF, see L<CGI::Builder/"Extensions List">

=head1 INSTALLATION

=over

=item Prerequisites

    CGI::Builder        >= 1.0
    Data::FormValidator >= 3.5

=item CPAN

    perl -MCPAN -e 'install CGI::Builder::DFVCheck'

If you want to install all the extensions and prerequisites of the CBF, all in one easy step:

    perl -MCPAN -e 'install Bundle::CGI::Builder::Complete'

=item Standard installation

From the directory where this file is located, type:

    perl Makefile.PL
    make
    make test
    make install

=back

=head1 SYNOPSIS

   use CGI::Builder
   qw| CGI::Builder::DFVCheck
     |;
    
   $s->dfv_check(\%form_profile)
      || return $s->switch_to('myOtherPage');
   
   # if there is any error
   # $s->page_error is automatically set
   # to the $result->msgs HASH ref
   # and $s->dfv_results to the results object
    
   $results = $s->dfv_results

=head1 DESCRIPTION

This module integrates the C<Data::FormValidator> capability with C<CGI::Builder>.

It adds to your build an useful C<dfv_check()> method that you can use in your Switch Handlers (or in your Page Handlers) to check the input e.g. from a form. If any error is found, then the methods will return '0' (false) and will set the C<page_error> group accessor to the $results->msgs, and will add the C<dfv_results> property.

=head2 CGI::Builder Example

    package My::WebApp ;
    use CGI::Builder
    qw| CGI::Builder::DFVCheck
      |;
    
    sub SH_myPage
    {
      my $s = shift ;
      $s->dfv_check({ required => 'email' })
        || $s->switch_to('myOtherPage');
      ...
    }
    
    # do something with page_error
    sub OH_pre_page {
        my $s  = shift ;
        my $E = $s->page_error ;
        while ( my($field, $err) = each %$E ) {
            $s->page_content .= "$field $err\n"
        }
    }


=head1 INTEGRATION WITH CGI::Builder::Magic

The integration with C<CGI::Builder::Magic> is very powerful.

You need just to pass the profile to the dfv_check() method and put the labels in the template: no other configuration needed on your side: the error labels in any template will be auto-magically substituted with the error string when needed.

B<Note>: The hash reference returned by the msgs() method will internally set the C<< $s->page_error >> which is passed as a lookup location to the C<Template::Magic> object.

=head2 CGI::Builder::Magic Example 1

    package My::WebAppMagic ;
    use CGI::Builder
    qw| CGI::Builder::DFVCheck
        CGI::Builder::Magic
      |;
    
    sub SH_myPage
    {
      my $s = shift ;
      $s->dfv_check({ required => 'email',
                      msgs     => { prefix     => 'err_' },
                    })
        || $s->switch_to('myOtherPage');
      ...
    }
    
    # the PH_myOtherPage method is optional

Somewhere in the 'myOtherPage.html' template (or in any other template) all the label prefixed with 'err_' will be substitute with the relative error if present (with the profile passed in the example it happens just with 'err_email'):

    <!--{err_email}-->

=head2 CGI::Builder::Magic Example 2

    package My::WebAppMagic ;
    use CGI::Builder
    qw| CGI::Builder::DFVCheck
        CGI::Builder::Magic
      |;
    
    sub SH_myPage
    {
      my $s = shift ;
      $s->dfv_check({ required => 'email',
                      msgs     => { prefix     => 'err_'  }
                   })
        || $s->switch_to('myOtherPage');
      ...
    }
    
    # the PH_myOtherPage method is optional
    
    package WebAppMagic::Lookups;
    
    sub MISSING {
        my $s = shift ;
        my $missing
        if ( $s->dfv_resuts->has_missing ) {
            foreach my $f ( $s->dfv_resuts->missing ) {
               $missing .= $f, " is missing\n";
            }
        }
        $missing
    }

Somewhere in the 'myOtherPage.html' template (or in any other template) all the 'MISSING' labels will be substitute with the relative error if present:

    <!--{MISSING}-->


=head1 METHODS

=head2 dfv_check ( dfv_profile )

Use this method to check the query parameters with the I<dfv_profile>. It returns 1 on success and 0 on failure. If there are some missing or unvalid fields it set also the C<dfv_results> property to the Data::FormValidator::Results object, and the C<page_error> CBF property to the C<< $s->dfv_results->msgs >> HASH reference.

=head2 dfv_new

This method is not intended to be used directly in your CBB. It is used internally to initialize and returns the C<Data::FormValidator> object. You should redefine this method in your CBB if you need some more customized object. (see L<Data::FormValidator>).

=head1 PROPERTY and GROUP ACCESSORS

This module adds a couple of properties to the standard CBF properties.

=head2 dfv_defaults

This group accessor handles the C<Data::FormValidator> defaults that are used in the creation of the internal C<Data::FormValidator> object.

B<Note>: You can completely override the creation of the internal object by overriding the C<dfv_new()> method.

=head2 dfv_results

This property allows you to access the C<Data::FormValidator::Results> object set by the C<dfv_check()> method only if there are some missing or invalid fields.

=head1 SUPPORT and FEEDBACK

You can join the CBF mailing list at this url:

    http://lists.sourceforge.net/lists/listinfo/cgi-builder-users

=head1 AUTHOR and COPYRIGHT

© 2004 by Domizio Demichelis (http://perl.4pro.net)

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as perl itself.

