#!/usr/bin/perl 
use strict;
my $user= shift||'nobody';
#first I look after semaphore
# I parse line and I find user in line
open  (COMMAND ,"/usr/bin/ipcs  -s -c |");
my @sem;
while (<COMMAND>) {
    my $ligne =$_;
    next unless $ligne=~ /$user/;
   (my $num)= $ligne=~ /^(\d+)/ ; 
    push @sem , $num;

}
close (COMMAND);
#I repeat again with segment
open  (COMMAND ,"/usr/bin/ipcs  -m -c |");
my @seg;
while (<COMMAND>) {
    my $ligne =$_;
    next unless $ligne=~ /$user/;
   (my $num)= $ligne=~ /^(\d+)/ ; 
    push @seg , $num;

}
close (COMMAND);
#now I can delete all
foreach (@seg) {
    `/usr/bin/ipcrm -m $_`;
}
foreach (@sem) {
    `/usr/bin/ipcrm -s $_`;
}
