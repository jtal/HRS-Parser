#!/usr/bin/env perl


use strict;
use warnings;
use Data::Dumper;


use lib '~/perl5/lib/perl5';

$::RD_ERRORS = 1; # Parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings- warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
#$::RD_TRACE  = 1;

use lib '../src/archive/crawler/lib';

use Citation;

#my $text = $ARGV[0] || 'RL 1925, §1005; am L 1931, c 224, pt of §1; RL 1935, §1431;
#RL 1945, §2951; am L 1945, c 139, §1(a); RL 1955, §53-1; am L Sp 1959 2d, c 1,
#§19; HRS §330-1; am L 1986, c 179, §5; am L 2001, c 2, §1';

my $text = $ARGV[0] || die 'USAGE: validate_citation.pl "[L 1941, c 12, §7]"';

($text) = $text =~ /\[(.+)\]/;

# Citation grammar splits on semicolon but doing it here manually
# to figure out which porition is the problem citation 
my @texts = split(/\s*;\s*/,$text);

for my $t (@texts) {
  $t = "[$t]"; # putting each part in its own brackets
  print "Trying $t...\n";
  my $tree = Citation::parse($t);
  print Dumper $tree;
  print "\n";

  if (!$tree->{'citations'}) {
    print "This is the broken one.\n";
    exit;
  }
}


print "Done. They all seemed to parse.\n";

