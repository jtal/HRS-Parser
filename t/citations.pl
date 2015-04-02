#!/usr/bin/env perl

use strict;
use warnings;
use lib '~/perl5/lib/perl5';
use lib '~/perl5/lib/perl5';
use lib '../lib';
use lib '../lib';

use Citation;
use Data::Dumper;

use Test::More tests => 21;
use Test::Deep;

use Storable;

my @combined_tests = ( @{get_citations_that_should_parse()}, @{get_citations_that_should_not_parse()} );
my $tests = \@combined_tests;

my $arg = $ARGV[0];

if ($arg && $arg =~ /refresh/) {
  refresh_test_data($tests);
  exit;
}

diag('Test ability to parse regular citations');

my $i = 0;
for my $test (@$tests) {
  my $tree = Citation::parse($test);

  my $fn = "data/froze.$i";
  my $answer = retrieve($fn);

  cmp_deeply($tree, $answer, $test); 
  $i++;
}

diag('Test repealed section parsing');
my $j = 0;
my $repeal_tests = get_repeal_tests();
for my $test (@$repeal_tests) {
  my $tree = Citation::extract_empowering_artifacts_from_repeal($test);
  $j++;
}


exit;


sub refresh_test_data {
  my ($tests) = @_;
  my $i = 0;
  for my $test (@$tests) { 
    my $tree = Citation::parse($test);

    my $fn = "data/froze.$i";
    print "$fn\n";
    store $tree, $fn;

    my $fn1 = "data/text.$i";
    print "$fn1\n";
    my $dumped = Dumper $tree;
    open(my $fh, ">$fn1");
    print $fh $dumped;
    close($fh);

    $i++;
  }
}

sub get_citations_that_should_parse {
return [
  '[L 2009, c 186, §12]',
  '[am L 1905, c 42, §5]',
  '[L 2009, c 186, pt of §3]',
  '[L 2009, c 186, §12; am L 2002, c 123, §45]',
  '[am L 2004, c 51, §5, c 220, §2, and c 221, §8]',
  '[am L 2004, c 51, §§5, 6]',
  '[am L 2004, c 51, §§5, 6, and 22, c 220, §2, and c 221, §8]',
  '[RL 1925, §915]',
  '[RL 1955, §90-13]',
  '[HRS §321-11]',
  '[L 1945, c 250, §12]',
  '[L 1945, c 250, §12; RL 1955, §90-13]',
  '[L 1945, c 250, §12; RL 1955, §90-13; HRS §377-12]',
  '[L 1945, c 250, §12; RL 1955, §90-13; HRS §377-12; am L 1985, c 251, §21]',
  '[PC 1869, c 59 §4]',
  '[PC 1869, c 88, §2]',
  '[PC 1869, c 59 §4-6]',
  '[PC 1869, c 88, §2; RL 1925, §1005; am L 1931, c 224, pt of §1; RL 1935, §1431;
RL 1945, §2951; am L 1945, c 139, §1(a); RL 1955, §53-1; am L Sp 1959 2d, c 1,
§19; HRS §330-1; am L 1986, c 179, §5; am L 2001, c 2, §1]',
  '[ren L 1972, c 10, §7(2); gen ch 1985]',
  '[L 1893-4, c 30, §§1, 2]',
  '[am L 1997, c 280, §1 and c 356, §6]'
];

}

sub get_repeal_tests {
  
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


#[Supp, §50A-1]

sub get_citations_that_should_not_parse{
  # a structure is still created with failed_to_parse element
  # but this is done in extract, not in parse
return [];

}


