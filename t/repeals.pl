
#!/usr/bin/env perl

use strict;
use warnings;
use lib '~perl5/lib/perl5';
use lib '~perl5/lib/perl5';
use lib '../src/archive/crawler/lib';
use lib '../src/archive/crawler/lib';

use Test::More tests => 7;
use Test::Deep;

use Data::Dumper
use Storable;

use Citation;


my $tests = get_tests();

if ($arg && $arg =~ /refresh/) {
  refresh_test_data($tests);
  exit;
}

diag('Test repealed sections parsing');

for my $t (@$tests) {
  my $reference = extract_repeal_info($t);

  my $fn = "data/repeal/froze.$i";
  my $answer = retrieve($fn);
}


exit;

sub get_tests {
  
return [
  ["§§321-245, 246 REPEALED. L 2007, c 105, §5."],
  ["§321-244 REPEALED. L 1981, c 200, §3."],
  ["§321-52.5 REPEALED. L 1986, c 10, §2."],
  ["§321-380 REPEALED. L 2009, c 130, §10."],
  ["§328-2.1 REPEALED. L 1977, c 58, §44 and c 200, §3."],
  ["§§328-81 to 89 REPEALED. L 1972, c 10, §§7, 8."],
  [ "PART V. DRUG ABUSE, CONTROL--REPEALED",
    "",
    "§§328-81 to 89 REPEALED. L 1972, c 10, §§7, 8.",
    "",
    "Cross References",
    "",
    "For present provisions, see chapter 321, part XVI, and chapter 329."]
];

}



sub refresh_test_data {
  my ($tests) = @_;
  my $i = 0;
  for my $test (@$tests) { 
    my $tree = Citation::parse($test);

    my $fn = "data/repeal/froze.$i";
    print "$fn\n";
    store $tree, $fn;

    my $fn1 = "data/repeal/text.$i";
    print "$fn1\n";
    my $dumped = Dumper $tree;
    open(my $fh, ">$fn1");
    print $fh $dumped;
    close($fh);

    $i++;
  }
}






