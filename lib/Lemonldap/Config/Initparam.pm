package Lemonldap::Config::Initparam;
use Apache::Table;
use Lemonldap::Config::Parameters;

our $VERSION = '2.01';

##########################
##########################
sub init_param_httpd {
##########################
# parameter input 
    my ($__c) =@_;

#declaration
    my %__config;
    my $__param  = {
         'lemonldapportal' => 'PORTAL',
        'lemonldapbasepub' => 'BASEPUB',
        'lemonldapbasepriv' => 'BASEPRIV',
        'lemonldapdomain'  => 'DOMAIN',
 	'lemonldaphandlerid' => 'ID_HANDLER' ,
	'lemonldapconfig' => 'FILE',
	'lemonldapconfigipckey' => 'GLUE',
	'lemonldapconfigttl' => 'TTL',
	'lemonldapconfigdbpath' => 'GLUE',
	'lemonldapenabledproxy' => 'PROXY',
	'lemonldapproxyphase' => 'PROXY',
#	'lemonldapipckey' => 'KEYIPC',
	'lemonldappathdb' => 'PATHDB',
#	'lemonldapcache2' => 'IPCNB',
#	'lemonldapipcnb'  => 'IPCNB',
        'lemonldapattrldap' => 'ATTRLDAP',
        'lemonldapmajeur' => 'ATTRLDAP',
        'lemonldapcodeappli' => 'LDAPCONTROL',
        'lemonldapmineur' => 'LDAPCONTROL',
        'lemonldapdisabled' => 'DISABLEDCONTROL',
        'lemonldapsession' => 'CACHE',
        'lemonldapstopcookie' => 'STOPCOOKIE',
        'lemonldaprecursive' => 'RECURSIF',
        'lemonldapproxyext' => 'PROXYEXT',
        'lemonldapics' => 'ICS',
        'lemonldapmultihoming' => 'MULTIHOMING',
        'lemonldaplwptimeout' => 'LWPTIMEOUT',
        'lemonldapsoftcontrol' =>'SOFTCONTROL', 
        'lemonldapheader' =>'HEADER', 
        'lemonldapallow' =>'ALLOW', 
        'lemonldappluginpolicy' =>'PLUGINPOLICY', 
	'lemonldappluginhtml' =>'PLUGINHTML', 
        'lemonldappluginheader' =>'PLUGINHEADER',
        'lemonldappluginbackend' =>'PLUGINBACKEND',
         'lemonldphttps' =>'HTTPS' ,
        'lemonldapauth' => 'AUTH',
        'lemonldappkcs12' => 'PKCS12',
        'lemonldappkcs12_pwd' => 'PKCS12_PWD',
        'lemonldapcert_file' => 'CERT_FILE' ,
        'lemonldapkey_file'  => 'KEY_FILE',    
       
};
# input
foreach (keys %$__c) {
 my $lkey =lc($_);
 my $val = $__c->get($_);
 my $mkey = $__param->{$lkey};
 if ($mkey) {
 $__config{$mkey} = $val;
 }  else {print STDERR  "ERROR :lemonldap Initparam $_ : no valid parameter nam
e \n"; }
 }


#    my $debug = Dumper (%__param );
#    print STDERR  "param $debug\n";
#     $debug = Dumper ($__c );
#    print STDERR  "input $debug __\n";
#    $debug = Dumper (%__config );
#    print STDERR  "config $debug\n";
## work is done tel this 
$__config{'HTTPD'} =1;

return (\%__config );


}

##########################
##########################
sub init_param_xml {
##########################
my ($cn ) = @_;
my $__config;
my %CONFIG=%$cn;
my $GENERAL;
my $tmpconf;
	my $message;
    my $__param  = {
     'Cookie' => 'COOKIE' ,
     'Portal' => 'PORTAL',
     'Session' => 'CACHE',  
     'IpcKey' => 'KEYIPC',
#     'IpcNb' => 'IPCNB' ,
#     'DbPath' => 'KEYIPC',
     'SoftControl' =>'SOFTCONTROL', 
#	'DbPath' => 'DBPATH',
	'Cache2' => 'IPCNB',
        'LWPTimeout' =>'LWPTIMEOUT',
        'Header' => 'HEADER' ,       
        'Allow' =>'ALLOW',
        'PlugInPolicy' =>'PLUGINPOLICY', 
        'PlugInHtml' =>'PLUGINHTML', 
        'PlugInBackend' =>'PLUGINBACKED',
        'PlugInHeader' =>'PLUGINHEADER',
        'HTTPS' =>'HTTPS' ,
        'AUTH' => 'AUTH',
        'PKCS12' => 'PKCS12',
        'PKCS12_PWD' => 'PKCS12_PWD',
        'CERT_FILE' => 'CERT_FILE' ,
        'KEY_FILE'  => 'KEY_FILE',
};
  my $__param_loc  = {
     'Enabledproxy' => 'PROXY' ,
 #    'IpcKey' => 'KEYIPC',
 #    'IpcNb' => 'IPCNB' ,
     'AttrLdap' =>'ATTRLDAP',
     'CodeAppli' => 'LDAPCONTROL',
     'Disabled' => 'DISABLEDCONTROL' ,
     'BasePub' => 'BASEPUB' ,
     'BasePriv' => 'BASEPRIV',
     'StopCookie' => 'STOPCOOKIE' ,
     'Recursive' => 'RECURSIF' ,
     'Portal' =>     'PORTAL',      
     'Proxyphase' => 'PROXY',
#	'DbPath' => 'KEYIPC',
#	'DbPath' => 'DBPATH',
#	'Cache2' => 'IPCNB',
        'Majeur' => 'ATTRLDAP',
        'Mineur' => 'LDAPCONTROL',
        'Ics' => 'ICS',
        'MultiHoming' => 'MULTIHOMING',
        'MotifIn' =>'MOTIFIN',
        'MotifOut' => 'MOTIFOUT', 
        'LWPTimeout' => 'LWPTIMEOUT',
        'SoftControl' =>'SOFTCONTROL', 
        'Header' => 'HEADER',        
        'Allow' =>'ALLOW',
        'PlugInPolicy' =>'PLUGINPOLICY', 
        'PlugInHtml' =>'PLUGINHTML', 
        'PlugInBackend' =>'PLUGINBACKED',
        'PlugInHeader' =>'PLUGINHEADER',
        'HTTPS' =>'HTTPS' ,
        'AUTH' => 'AUTH',
        'PKCS12' => 'PKCS12',
        'PKCS12_PWD' => 'PKCS12_PWD',
        'CERT_FILE' => 'CERT_FILE' ,
        'KEY_FILE'  => 'KEY_FILE',
};
 my $CONF= Lemonldap::Config::Parameters->new (
                        file => $CONFIG{FILE} ,
		       	cache => $CONFIG{GLUE} );
    if ($CONF) {
	$message="$CONFIG{ID_HANDLER}: Phase : handler initialization LOAD XML conf :succeded"; } 
	 else {
	$message="$CONFIG{ID_HANDLER}: Phase : handler initialization LOAD XML conf : failed";
		}
    if ($CONFIG{DOMAIN}) {
       $GENERAL = $CONF->getDomain($CONFIG{DOMAIN}) ;
       $tmpconf = $GENERAL->{handler}->{$CONFIG{ID_HANDLER}};
 foreach (keys %$__param )  {
my $key = $__param->{$_};
 $__config{$key} = $GENERAL->{lc($_)} if defined ($GENERAL->{lc($_)}) ;
 } 
     
                }  else                 {
        $tmpconf= $CONF->{$CONFIG{ID_HANDLER}} ;
                        }
##  load session info 
my $xmlsession= $CONF->findParagraph('session',$__config{CACHE});
$__config{STR_SERVERS}=  $xmlsession; 
$__config{SERVERS} = $CONF->formateLineHash ($xmlsession->{SessionParams});

			
### parse local conf #####

 foreach (keys %$__param_loc )  {
my $key = $__param_loc->{$_};
# $__config{$key} = lc($tmpconf->{$_}) if defined ($tmpconf->{$_}) ;
 $__config{$key} = $tmpconf->{lc($_)} if defined ($tmpconf->{lc($_)}) ;

 } 
$__config{'OK'} =1;
$__config{'message '} =$message;
## addon multihoming 
my $lig;
$lig= $CONFIG{MULTIHOMING} || $__config{MULTIHOMING}  ;
if ($lig ) { 
my @lmh= split "," ,$lig;
my @__TABLEMH=();
my %__HASHMH =();
foreach (@lmh) {
my $clmh = $GENERAL->{handler}->{$_};
my %__tmp;
 foreach (keys %$__param_loc )  {

my $key = $__param_loc->{$_};
# $__tmp{$key} = $clmh->{$_} if defined ($clmh->{$_}) ;
 $__tmp{$key} = $clmh->{lc($_)} if defined ($clmh->{lc($_)}) ;
 
} 
$__tmp{HANDLER} =$_;
$__HASHMH{$_} = \%__tmp;
## call function builer
my $sub = built_function(\%__HASHMH);
## add key in config 
$__config{SUB} =$sub;
$__config{MH} =\%__HASHMH;
}


}
 

$__config{XML}=1;
return (\%__config);
}

##########################
##########################
sub built_function    {
##########################

    my $tablemh= shift;

    my @key = keys %$tablemh ;
    my $def;
my $code = "sub {local \$_ = shift;\n"; 

foreach (@key) {
    my $tmp = $tablemh->{$_};
      if ($tmp->{HANDLER} =~ /DEFAULT/i)  {
     $def= 'DEFAULT';
    next ;
 }

$code .= "return \"$tmp->{HANDLER}\"  if /^\\$tmp->{MOTIFIN}/i;\n";  
}
    $code.= "return \"DEFAULT\";\n" if $def;

$code.= "1;}\n";
return $code;
}

##########################
##########################
sub built_functionics {
##########################
    my $tablemh= shift;
my @lmh= split "," ,$tablemh;

    my $code = "sub {local \$_ = shift;\n"; 
foreach (@lmh) {
$code .= "return \"OK\"  if /\\.$_\$/i;\n";  
}
$code.= "1;}\n";
return $code;
}

##########################
##########################
sub merge {
##########################

my ($ht , $xm) =@_;
my %__config;
foreach (keys %$xm ){
$__config{$_} = $xm->{$_} ;
} 
foreach (keys %$ht ){
$__config{$_} = $ht->{$_} if defined ($ht->{$_})  ;
} 
delete $__config{message};
return (\%__config);

}
##########################
##########################
sub mergeMH {
##########################

my ($ht , $mh) =@_;
my %__config;
%__config=%$ht;
my $_tmp = $__config{MH}->{$mh} ;
my %tmp= %$_tmp;
foreach (keys %tmp ){
$__config{$_} = $tmp{$_} ;
} 
my $id =$__config{ID_HANDLER}."/".$mh ;
$__config{ID_HANDLER} = $id;
$__config{XML}=1;
return (\%__config);

}

	
1;

