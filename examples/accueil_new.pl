#!/usr/bin/perl -w

##==============================================================================
##
## Ce fichier gère l'authentification de l'utilisateur vis à vis du serveur LDAP.
##
## Il peut être appelé dans les cas suivants :
## 1) L'utilisateur a demandé une URL, mais n'étant pas authentifié, il est
##    redirigé ici
## 2) L'utilisateur est en time-out, c'est-à-dire qu'il n'a pas accèdé au contenu
##    depuis un temps limite : sa session a donc été supprimée
## 3) Première connection de l'utilisateur (pas d'URL demandée)
## 
## Il affiche une page HTML contenant un formulaire login/passwd qui le rappèle.
## Il teste l'existance de l'utilisateur, il teste la véracité du mot de passe
## founi. En cas d'erreur, le formulaire est à nouveau affiché.
##
## En cas de réussite, une session est créée (elle contient les informations de
## l'utilisateur extraites du LDAP), un cookie est positionné avec l'identifiant
## de la session et l'utilsateur est redirigé vers l'URL qu'il demandait
## (ou la page qui liste des applications dans le cas où il ne demandait aucune URL)
## 
##==============================================================================

use strict;
use CGI;
use Template;
use Net::LDAP;
use MIME::Base64;
use Apache::Session::Memorycached;
use Lemonldap::Config::Parameters;
use CGI::Carp 'fatalsToBrowser';
our $template_config;
our $login;
our $applications_list_url;
our $path;
our $cookie_name;
our $domain;
our $ldap_server;
our $ldap_port;
our $dnmanager;
our $pass ;
our $session;
##==============================================================================
## Fonction connectLDAP
##  Effectue l'opération de connextion et d'autentification au LDAP
##  Paramètres :
##      dn = login de l'utilisateur
##      passwd = mot de passe
##      messageRef = référence vers la variable de message
##        Cette référence permet de renseigner le message à afficher.
##        Si cette reference vaut undef, la fonction meurt en cas de problème.
##==============================================================================
sub connectLDAP
{
   my ($dn,$passwd,$messageRef) = @_;

   ##---------------------------------------------------------------------------
   ## Connexion
   ##---------------------------------------------------------------------------
   my $ldap = Net::LDAP->new( $ldap_server,
                              port => $ldap_port,
                              onerror => undef,
                            ) or die('Net::LDAP->new: '.$@);

   ##---------------------------------------------------------------------------
   ## Autentification
   ##---------------------------------------------------------------------------
   my $mesg = $ldap->bind( $dn, password => $passwd );

   if( $mesg->code() != 0 )
   {
      $ldap = undef;
      if( defined($messageRef) )
      {
         $$messageRef = 'Mot de passe erron&eacute;';
      }
      else
      {
         die( $mesg->error() );
      }
   }

   return $ldap;
}

##==============================================================================
## Fonction disconnectLDAP
##  Effectue l'opération de déconnextion
##==============================================================================
sub disconnectLDAP
{
   my ($ldap) = @_;
   $ldap->unbind();
}

##==============================================================================
## Fonction testUser
##  Description : Cette fonction teste dans l'annuaire LDAP la présence d'un user
##      En cas de problème, la fonction renvoie un message pour affichage au dessus
##      du formulaire. En cas de succès, cette fonction effectue l'écriture
##      d'une petite page HTML comportant une redirection vers l'URL demandée
##      ou vers la liste des applications.
##  Paramètres :
##      identifiant = identifiant de l'utilisateur saisi dans le formulaire
##      secret = mot de passe saisi dans le formulaire
##      urldc = l'URL demandée (pour la redirection)
##==============================================================================
sub testUser
{
   my ($identifiant,$secret,$urldc) = @_;

   ##---------------------------------------------------------------------------
   ## Connexion au serveur LDAP en tant qu'administrateur
   ## pour extraire les informations sur l'utilisateur
   ##---------------------------------------------------------------------------
   my $ldap = connectLDAP( $dnmanager,
                           $pass,
                           undef );

   ##---------------------------------------------------------------------------
   ## Recherche de la personne en question
   ##---------------------------------------------------------------------------
   my $identifiantCopy = $identifiant;
   $identifiant .= '-cp' if( $identifiant !~ /-cp$/ );

   my $mesg = $ldap->search(
                          base   => 'ou=personnes,ou=dgcp,ou=mefi,o=gouv,c=fr',
                          scope  => 'sub',
                          filter => '(uid='.$identifiant.')',
                        );
   die $mesg->error() if( $mesg->code() != 0 );

   my $retour=$mesg->entry(0);
   return $identifiantCopy.' n\'a pas &eacute;t&eacute; trouv&eacute; dans l\'annuaire'
      if( ! defined( $retour ) );

   ##---------------------------------------------------------------------------
   ## La personne existe : extraction des infos
   ##---------------------------------------------------------------------------
   my $dn            = $retour->dn();
   my $uid           = $retour->get_value('uid');
   my $cn            = $retour->get_value('cn');
   my $personaltitle = $retour->get_value('personaltitle');
   my @mefiapplidgcp = $retour->get_value('mefiapplidgcp');
   my @mefiappliapt  = $retour->get_value('mefiapplihabilitdgcp');
   my @mefiapplidgi  = $retour->get_value('mefiapplidgi');
   my $codique       = $retour->get_value('affectation');
   my $departement   = $retour->get_value('departement');
   my $mail          = $retour->get_value('mail');
   my $grade          = $retour->get_value('title');
   my $fonction          = $retour->get_value('fonction');
    $fonction=~ s/:/ /g; 
  my $igap          = $retour->get_value('igap');
   disconnectLDAP( $ldap );

   ##---------------------------------------------------------------------------
   ## Connexion au serveur LDAP en tant qu'utilisateur
   ## pour vérifier le couple identifiant ($dn) / mot de passe ($secret)
   ##---------------------------------------------------------------------------
   my $message;
   if( ! defined( $ldap = connectLDAP( $dn, $secret, \$message ) ) )
   {
      # En cas de probleme de connexion, fin de la fonction
      # (la variable $message est alors modifiée par la fonction connectLDAP)
      return $message;
   }
   disconnectLDAP( $ldap );

   ##---------------------------------------------------------------------------
   ## Ici, tout est ok : l'utilisateur existe et le mot de passe est bon
   ##---------------------------------------------------------------------------

   ##---------------------------------------------------------------------------
   ## Création d'une nouvelle session
   ##---------------------------------------------------------------------------
   my  %session;
   tie %session, 'Apache::Session::Memorycached', undef,
      {
                servers        => $session,
 
      };

   ##---------------------------------------------------------------------------
   ## Positionnement de valeurs dans la session
   ##---------------------------------------------------------------------------
   $session{dn}            = $dn;
   $session{cn}            = $cn;
   $session{uid}           = $uid;
   $session{personaltitle} = $personaltitle;
   $session{departement}   = $departement;
   $session{mail}          = $mail;
   $session{codique}       = $codique;
   $session{grade}       = $grade;

   $session{fonction}       = $fonction;
   $session{igap}       = $igap;
   # construction tableau applidgcp
   foreach my $ligne (@mefiapplidgcp)
   {
      my @tab        = split ';' ,$ligne;
      my $cle        = 'APT_'.$tab[0];
      my $valeur     = $ligne;
      $session{$cle} = $valeur;
   }

   # on met en cache dans l apache les mefiattributs
   foreach my $ligne (@mefiappliapt)
   {
      my ($arg,$arg2) = ( $ligne =~ /^(.+?);(.+?)$/ );
      $arg =~ s/ //g;
      $session{dgcp}{$arg} = $arg2;
   }
   #$session{dgcp}{helios} = '<oo><velo><codique>013100</codique></velo><velo codique="013102"></velo></oo>';

   # mefiapplidgi
   foreach my $ligne (@mefiapplidgi)
   {
      my ($arg,$arg2,$arg3) = ( $ligne =~ /^(.+?);(.+?);(.+)/ );
      $arg=~ s/ //g;
      $session{dgi}{$arg} = $arg2.'#'.$arg3;
   }

   ##---------------------------------------------------------------------------
   ## Fin du travail sur la session
   ##---------------------------------------------------------------------------
   my $session_id = $session{_session_id};
   untie( %session );

   ##---------------------------------------------------------------------------
   ## Création du cookie
   ##---------------------------------------------------------------------------
   my $cookie = CGI::cookie(
                    -name   => $cookie_name,
                    -value  => $session_id,
                    -domain => $domain,
                    -path   => $path,
                );

   ##---------------------------------------------------------------------------
   ## Génération du HTML par le template
   ##---------------------------------------------------------------------------
   $urldc = $applications_list_url
      if( $urldc eq '' );

   my $data = {
     urldc   => $urldc,
     message => 'Session '.$session_id,
   };

   my $template=Template->new( $template_config );

   print CGI::header( -Refresh=>'1; URL='.$urldc, -cookie=>$cookie );
   $template->process( 'redirect.thtml', $data ) or die($template->error());

   exit( 0 );
}


##==============================================================================
## Programme principal
##==============================================================================

##------------------------------------------------------------------------------
## Gestion de l'URL demandée
##------------------------------------------------------------------------------
my $conf= Lemonldap::Config::Parameters->new ( 
  						file => "/opt/apache/portail/application_new.xml" , 
                                                cache => 'CONF' );
print STDERR "je passe ici $session\n";
my $config= $conf->getDomain('appli.cp') ;
print STDERR "je passe ici $session\n";
 $template_config=$config->{templates_options};
my $tempopt= 'templates_dir';
my $valeur= $config->{$tempopt};
my $templates_opt=$conf->formateLineHash($template_config,$tempopt,$valeur);
$template_config= $templates_opt;
$applications_list_url = $config->{menu};
$login= $config->{login}; 
$cookie_name= $config->{cookie};
$domain= $config->{name};
$path= $config->{path};
$ldap_server= $config->{ldap_server};
$ldap_port= $config->{ldap_port};
$dnmanager= $config->{DnManager} ;
$pass = $config->{passwordManager};
my $sessionrr= $conf->findParagraph('session','memcached');  
$session =$sessionrr->{servers} ;
print STDERR "je passe ici $session\n";
print STDERR "germangerman $ldap_server $ldap_port $dnmanager $pass\n";
my ($urlc,$urldc) = ('','');
if( defined ( $urlc = CGI::param('url') ) )
{
   $urldc = decode_base64($urlc);
   $urldc =~ s#:\d+/#/#;   # Suppression du numéro de port sur l'URL
   $urlc  = encode_base64($urldc,'');
}

##------------------------------------------------------------------------------
## Gestion des cas d'erreur possibles : message
##------------------------------------------------------------------------------
my $message = '';
my $paramOp = CGI::param('op');
if( defined( $paramOp ) and
             $paramOp eq 't' )
{
   $message = 'Votre connexion a expir&eacute; vous devez vous authentifier de nouveau';
}

my $paramIdentifiant = CGI::param('identifiant');
my $paramSecret      = CGI::param('secret');
if( defined( $paramIdentifiant ) or
    defined( $paramSecret ) )
{
   if( ! defined( $paramIdentifiant ) or
                  $paramIdentifiant eq '' or
       ! defined( $paramSecret ) or
                  $paramSecret      eq '' )
   {
      $message = 'Les champs &quot;Identifiant&quot; et &quot;Mot de passe&quot; '.
                 'doivent &ecirc;tre remplis';
   }
   else
   {
      $message = testUser( $paramIdentifiant, $paramSecret, $urldc );
      # En cas de problème, on revient de cette fonction avec un message à afficher.
      # Dans le cas où les infos d'authentification sont exactes,
      # la fonction s'occupe du HTML de redirection et le programme meurt (exit).
   }
}

##------------------------------------------------------------------------------
## Génération du HTML de la page de formulaire
##------------------------------------------------------------------------------
my $data = {
  'urlc'        => $urlc,
  'urldc'       => $urldc,
  'message'     => $message,
  'identifiant' => $paramIdentifiant,
};

my $template=Template->new( $template_config );

print CGI::header();

$template->process( 'login.thtml', $data ) or die($template->error());

##==============================================================================
## Fin du fichier
##==============================================================================
