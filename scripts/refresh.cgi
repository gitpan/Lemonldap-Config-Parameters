#!/usr/bin/perl -w
# this script is call by server SOAP  . 
# It must has owner (user and group) same of apache itself in order
# to manage IPC segment 
# It must be executable and placeid  in cgi-bin direcory
# 
#
#
# 
use Lemonldap::Config::Parameters;
use CGI;
my $glue= CGI::param('glue')||'CONF';
Lemonldap::Config::Parameters::f_reload($GLUE);

print CGI::header();
print CGI::start_html();
print "OK" ;
print CGI::end_html();





