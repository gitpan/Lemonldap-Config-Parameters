use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lemonldap::Config::Parameters',
    VERSION_FROM      => 'Parameters.pm', # finds $VERSION
    PREREQ_PM         => { 
      IPC::Shareable =>'0',
      Data::Dumper =>'0',
      XML::Simple => '0',
      SOAP::Lite => '0',
      LWP        => 'O',
      Storable => '0' ,
               }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
        (AUTHOR         => 'Eric German <germanlinux@yahoo.fr>') : ()),
);
