package SOAPserver;

use Lemonldap::Config::Parameters;
use Storable qw( nfreeze);
our $VERSION='0.1';
sub new  {
my $self =shift;
my %conf  = @_;

my $file=$conf{'file'};
my $cache=$conf{'cache'};


my $config=  Lemonldap::Config::Parameters->new(
                 file => $file ,
                 cache => $cache, 
                 server=>'SOAP',  
                 );
my $conf=$config->getAllConfig;
my $res;
if ($conf) { $res='ok'; } else { $res='no'; };
my $conf_serial = nfreeze ($conf );


my $class = ref($self) ||$self;
return bless { code => $res,
               file => $file,
               cache => $cache,
               config => $conf_serial,
                 },$class ;
}

sub retrieve  {
my $self = shift;
my $file=$self->{'file'};
my $cache=$self->{'cache'};
my $config=  Lemonldap::Config::Parameters->new(
                 file => $file ,
                 cache => $cache,
                 server=>'SOAP',
                 );
my $conf=$config->getAllConfig;
my $conf_serial = nfreeze ($conf );
my $self->{conf_serial}= $conf_serial;


return ($self->{conf_serial});
}
1;


__END__


=head1 NAME

Lemonldap::Config::SOAPserver - handler SOAP::Lite under mod_perl for  configuration  of lemonldap SSO system

=head1 DESCRIPTION

 
 With version of Config::parameters > 0.3 we can use an unique file of configuration 
 whi can be retrieve by the lemonldap SSO boxes with SOAP agents .
 On the central server you MUST use SOAP server in combinaison with apache , mod_perl and SOAP::Lite 
 Like this :
 (httpd.conf)  
  <location /conf_lemonldap>
    Options +execcgi
    SetHandler perl-script
    PerlHandler Apache::SOAP
    PerlSetVar dispatch_to  'Lemonldap::Config::SOAPserver'
  </location>
  
 In XML file config :
  
   <cache  id="config1"
        ConfigIpcKey="CONF"
        ConfigTtl ="10000000"
        LastModified='1'
        Method="SOAP" 
        SoapUri="http://www.portable.appli.cp/SOAPserver"
        SoapProxy="http://www.portable.appli.cp/conf_lemonldap"
        SoapAgent="['http://localhost/cgi-bin/refresh.cgi','http://www.portable.appli.cp/perl/refresh.cgi']"
     >

 with :SoapUri and SoapProxy : see SOAP::Lite documentation 
       SoapAgent : the list of agents CGI  on lemonldap server who must to be call in the case of modification

  After that agent receive notification , they do a soap request upon the administration server  for reload the lastnew config .
  If it's fail , slave lemonldap uses a local file XML which is the lastest copy of file config .

 An agent lemonldap MAY to be in same server that the SOAP manager. So SOAP manager uses 'conf' instead 'CONF' for the IPC glue .
 It 'll be two IPC segments 'CONF' and 'conf'  'CONF' for agent 'conf' for SOAP server ,but don't worry it's an internal process ,
 stay to use 'CONF' .


=head1 SEE ALSO

Lemonldap(3), Lemonldap::Portal::Standard(3) , Lemonldap::Config::Parameters(3) 

http://lemonldap.sourceforge.net/

"Writing Apache Modules with Perl and C" by Lincoln Stein E<amp> Doug
MacEachern - O'REILLY

 See the examples directory

=head1 AUTHORS

=over 1

=item Eric German, E<lt>germanlinux@yahoo.frE<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Eric German E<amp> Xavier Guimard

Lemonldap originaly written by Eric german who decided to publish him in 2003
under the terms of the GNU General Public License version 2.

=over 1

=item This package is under the GNU General Public License, Version 2.

=item The primary copyright holder is Eric German.

=item Portions are copyrighted under the same license as Perl itself.

=item Portions are copyrighted by Doug MacEachern and Lincoln Stein.
This library is under the GNU General Public License, Version 2.


=back

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; version 2 dated June, 1991.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  A copy of the GNU General Public License is available in the source tree;
  if not, write to the Free Software Foundation, Inc.,
  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

=cut




