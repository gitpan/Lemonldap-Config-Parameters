package Lemonldap::Config::Parameters;
use strict;
use warnings;
use IPC::Shareable;
use XML::Simple;
use Data::Dumper;

our $VERSION = '0.01';
our %IPC_CONFIG;

# Preloaded methods go here.
sub _getFromCache {

my $self=shift;
my $cache= $self->{cache} ;
my $cog;
my $ttl;
 tie %IPC_CONFIG,'IPC::Shareable',$cache ,
    { create => 1,
     mode =>0666 ,
    #  destroy => 1
        };
unless (keys ( %IPC_CONFIG))  {# the cache is empty , we can create it

#first I read the xml file 
###  read file 
$self->_readFile; 
## write cache 
$self->_writeCache;
$cog= $self->{config};
} else {  # the cache exists but is it  good 
$ttl= $IPC_CONFIG{TTL};
$self->{ttl}= $ttl;
$self->{avaiable}= $IPC_CONFIG{AVAIABLE};
my %tmp= %IPC_CONFIG;
my $tmpvar =$tmp{config} ; 
my $it =eval  $tmpvar ; 
$self->{config} =$it;
if ($IPC_CONFIG{AVAIABLE} eq 'RELOAD') {
$self->_readFile;
$self->_writeCache;
$cog= $self->{config};
return ($cog) ;
		} 
if ($IPC_CONFIG{AVAIABLE} eq 'DESTROY') {
$self->_readFile;
$self->_deleteCache;
delete $self->{cache};
$cog= $self->{config};
return ($cog) ;
		} 
$cog= $self->{config};

#### all is good we must compare time and ttl 
return ($cog) if ($self->{ttl}==0) ;
my $timenow = time ;
my $timecalc = $self->{avaiable} + $self->{ttl};
if ($timenow > $timecalc) { # the cache is too old 
$self->_readFile;
$self->_writeCache;

} 
$cog= $self->{config};
return ($cog);

}
} 
sub destroy {
my $self=shift;
$self->_deleteCache;
delete $self->{cache};
1;  
}
####   function in order to manege cache conf from command line
sub f_delete  {
my $arg =shift ;
tie %IPC_CONFIG,'IPC::Shareable',$arg ,
                 { create => 1,
                   mode =>0666 ,
                  # destroy => 1
                       };
## lock
(tied %IPC_CONFIG)->shlock;

tied(%IPC_CONFIG)->remove;

## unlock
(tied %IPC_CONFIG)->shunlock;

return (0);
}
sub f_reload  {
my $arg =shift ;
tie %IPC_CONFIG,'IPC::Shareable',$arg ,
                 { create => 1,
                   mode =>0666 ,
                  # destroy => 1
                       };
## lock
(tied %IPC_CONFIG)->shlock;

$IPC_CONFIG{AVAIABLE}='RELOAD' ;

## unlock
(tied %IPC_CONFIG)->shunlock;

return (0);
}
sub f_dump  {
my $arg =shift ;
tie %IPC_CONFIG,'IPC::Shareable',$arg ,
                 { create => 1,
                   mode =>0666 ,
                  # destroy => 1
                       };
$Data::Dumper::Indent=1;
my $ligne= Dumper(\%IPC_CONFIG) ;
print "$ligne\n";

return "OK\n";
}

sub _readFile {
my $self = shift;
my ($par,$config);
my $file= $self->{file};
my $cache= $self->{cache} ;
 $config= XMLin($file,ForceArray=>1);
# I extract info about the cache ttl

my $cache_param = $config->{cache};
if ($cache_param->{$cache})  { # there are sereval cache descriptors 
    $par= $cache_param->{$cache}{ttl}; }  else 
    { # there  is a single descriptor  I must match the cache name.
         $par= $cache_param->{ttl} if $cache_param->{name} eq $cache; }

$self->{ttl}= $par||'0';
$self->{config}= $config;
return 1;
}
sub _deleteCache {
my $self = shift;
my $cache=$self->{cache};

tie %IPC_CONFIG,'IPC::Shareable',$cache ,
                 { create => 1,
                   mode =>0666 ,
                  # destroy => 1
                       };
## lock 
(tied %IPC_CONFIG)->shlock;

tied(%IPC_CONFIG)->remove;

## unlock
(tied %IPC_CONFIG)->shunlock;
}
 
sub _writeCache {
my $self = shift;
my $time=time;
my $cache= $self->{cache} ;
my $config=$self->{config};
$Data::Dumper::Purity=1;
$Data::Dumper::Terse=1;
my $configs=Dumper ($config);
my $ttl=$self->{ttl};

 (tied %IPC_CONFIG)->shlock;
 delete $IPC_CONFIG{config};
 %IPC_CONFIG=();
 (tied %IPC_CONFIG)->remove;
 (tied %IPC_CONFIG)->shunlock;
tie %IPC_CONFIG,'IPC::Shareable',$cache ,
                 { create => 1,
                   mode =>0660 ,
                #   destroy => 1
                       };
 (tied %IPC_CONFIG)->shlock;
$IPC_CONFIG{config}= $configs;
$IPC_CONFIG{TTL}= $ttl;
$IPC_CONFIG{AVAIABLE}= $time;
##  unlock 
 (tied %IPC_CONFIG)->shunlock;

return 1;
}
sub new {
my $class =shift;
my %conf=@_;

my $self= bless {

},ref($class)||$class;
$self->{file}= $conf{file} if $conf{file};
$self->{cache}= $conf{cache}  if $conf{cache};
return $self;
}
sub getDomain {
    my $self= shift;
    my $domain=shift;
    my $config= $self->getAllConfig ;
     unless ($domain) { 
       my  $d = ( keys %{$config->{domain}});
       die "Ambigious domain\n" if ($d != 1) ;
  ( $domain) =   ( keys %{$config->{domain}});
                   }
 
    my $cdomain= $config->{domain}{$domain} ;
    return ($cdomain); 

}
sub findParagraph  {
my $self =shift;
my $chapitre =shift;
my $motif =shift;
my $config= $self->getAllConfig ;
 my $parag;
if ($chapitre && $motif ) {   
  $parag= $config->{$chapitre}->{$motif} ;}
   else  {
  $parag= $config->{$chapitre} ;}
return ($parag); 
} 
sub formateLineHash {
    my $self=shift;
    my $line =shift;
    my $motif=shift;;
    my $replace= shift;
 my %cf;  
  my $t ;
    if ($line=~/^\(/ ) { $t=$line ;} 
    else {  
    $t= "($line );";
       }

%cf =eval $t;
  if ($motif) {  
       for (values  %cf) {
            s/$motif/$replace/;
                         }
              }
    return (\%cf) ;
} 
sub formateLineArray {
    my $self=shift;
    my $line =shift;
    my $motif=shift;;
    my $replace= shift;
 my @cf;  
  my $t ;
    if ($line=~/^\[/ ) { $t=$line ;} 
    else {  
    $t= "[$line ];";
       }
@cf =eval $t;
  if ($motif) {  
       for (  @cf) {
            s/$motif/$replace/;
                         }
              }
    return (\@cf) ;
} 
sub getAllConfig {
my $self = shift;
my $config;
my $file= $self->{file} ;
if ($self->{cache})   {  #  cache is avaiable 
$config = $self->_getFromCache;

} else { # cache forbiden 
$config= XMLin($file);

}
return $config;
}
1;
__END__


=head1 NAME

Lemonldap::Config::Parameters - Perl extension for lemonldap SSO system

=head1 SYNOPSIS

  #!/usr/bin/perl 
  use strict;
  use Lemonldap::Config::Parameters;
  use Data::Dumper;
  my $nconfig= Lemonldap::Config::Parameters->new(
                             file  =>'applications.xml',
                             cache => 'CONF' );
  my $conf= $nconfig->getAllConfig;
  my $cg=$nconfig->getDomain('appli.cp');
  my $ligne= $cg;
  print Dumper( $ligne);
  my $e = $cg->{templates_options} ;
  my $opt= "templates_dir";
  my $va = $cg->{$opt};
  my $ligne= $nconfig->formateLineHash($e,$opt,$va) ;

 or by API :

 Lemonldap::Config::Parameters::f_delete('CONF');

 or by command line 

 perl -e "use Lemonldap::Config::Parameters;Parameters::f_delete('CONF');"
  

=head1 DESCRIPTION

Lemonldap is a SSO system under GPL. 

Login page , handlers must retrieve their configs in an unique file eg :"applications.xml"
This file has  a XML structrure . The parsing phase may be heavy . So lemonldap can cache the result of parsing in memory with IPC.
For activing the cache you must have in the config :

 <cache type="IPC" name="CONF" ttl="1000"> 
 </cache>
with :  name='CONF' it's the  GLUE value : four letters (see  IPC::Shareable documentation) .
        ttl: time to live in second   ( 0 for not reload ) 
 if ttl is too short the config file will be reload very offen .
  
 You can force the reload by command line  
    perl -e "use Lemonldap::Config::Parameters;Parameters::f_delete('CONF');"
or  perl -e "use Lemonldap::Config::Parameters;Parameters::f_reload('CONF');"

 WITHOUT CACHE SPECIFICATION , LEMONLDAP DOESN'T USE CACHE ! It  will read and parse config file each time.
 

=head1 METHODS
 
=head2  new  (file  =>'/foo/my_xml_file.xml' ,
                 cache => 'CONF' );  # with IPC cache

 or 
        new(file  =>'/foo/my_xml_file.xml');     # without IPC  cache

=head2 getAllConfig 
 
 Return the  reference of hash  storing whole the config.

=head2  getDomain('foo.bar')
 
 Return the reference of hash of config for domain  
 If the config file has only one domain , domain may bo omit .  

eg : 
 for the xml config file :
  <domain    name="foo.bar"  
           cookie=".foo.bar"
           path ="/" 
           templates_dir="/opt/apache/portail/templates"
           templates_options =  "ABSOLUTE     => '1', INCLUDE_PATH => 'templates_dir'" 
           login ="http://cportail.foo.bar/portail/accueil.pl"
           menu= "http://cportail.foo.bar/portail/application.pl"   
           ldap_server ="cpldap.foo.bar"
           ldap_port="389"
           DnManager= "cn=Directory Manager"
           passwordManager="secret"
           branch_people="ou=mefi,dc=foo,dc=bar"  
           session="memcached"
          >
  </domain> 

    my $cg = $nconfig->getDomain();

 DB<2> x $cg
  0  HASH(0x89b108c)
   'DnManager' => 'cn=Directory Manager'
   'branch_people' => 'ou=mefi,dc=foo,dc=bar'
   'cookie' => '.foo.bar'
   'ldap_port' => 389
   'ldap_server' => 'cpldap.foo.bar'
   'login' => 'http://cportail.foo.bar/portail/accueil.pl'
   'menu' => 'http://cportail.foo.bar/portail/application.pl'
   'passwordManager' => 'secret'
   'path' => '/'
   'session' => 'memcached'
   'templates_dir' => '/opt/apache/portail/templates'
   'templates_options' => 'ABSOLUTE => \'1\', INCLUDE_PATH => \'templates_dir\'

=head2  ref_of_hash : formateLineHash(string:line);

     or  formateLineHash(string:line,string:motif,string:key);

 Return a anonyme reference on  hash  and may replace the motif in the value of key by the value of another key  :

 eg 

 my $e = $cg->{templates_options} ;
 my $opt= "templates_dir";
 my $va = $cg->{$opt};
 my $ligne= $nconfig->formateLineHash($e,$opt,$va) ;

 gives :  
  DB<1> x $ligne
 0  HASH(0x848b778)
   'ABSOLUTE' => 1
   'INCLUDE_PATH' => '/opt/apache/portail/templates'

  $ligne can be use directly like option for somes instructions

=head2  ref_of_array : formateLineArray(string:line);

     or  formateLineArray(string:line,string:motif,string:key);

 Return a anonyme reference on  array  and may replace the motif in the element by the value of another key  :

   the return value can be use directly like option for somes instructions

=head2 findParagraph(chapter[,section])
   
 Find and return a reference of chapter finds in xml file , a section can be specified.

=head1 Functions

=head2 Lemonldap::Config::Parameters::f_delete('CONF');

 Delete the cache and the restore segment

=head2 Lemonldap::Config::Parameters::f_reload('CONF');

 The next acces on cache will need to read file before .

=head2 Lemonldap::Config::Parameters::f_dump('CONF');

 Dump of the config 

=head1 SEE ALSO

Lemonldap(3), Lemonldap::Handler::Intrusion(3)

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

