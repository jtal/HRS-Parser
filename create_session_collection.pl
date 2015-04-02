
use strict;
use warnings;

use lib '/home/jlolofie/perl5/lib/perl5';
use lib '/home/jtal/perl5/lib/perl5';

use JSON;
use Data::Dumper;


my @a = qw/
Vol01_Ch0001-0042F
Vol02_Ch0046-0115
Vol03_Ch0121-0200D
Vol04_Ch0201-0257
Vol05_Ch0261-0319
Vol06_Ch0321-0344
Vol07_Ch0346-0398
Vol08_Ch0401-0429
Vol09_Ch0431-0435E
Vol10_Ch0436-0474
Vol11_Ch0476-0490
Vol12_Ch0501-0588
Vol13_Ch0601-0676
Vol14_Ch0701-0853
/;

my $toc = {};
my $session_sort_order = '2013-1';
my $session_name = '2013 regular session';

for my $a (@a) {
  my ($v, $s, $e) = $a =~ /Vol(\d\d)_Ch(\d{4})-(\d+)/;
  my $vol = {
    start => $s,
    end => $e,
    name => $a,
    url => '/hrscurrent/' . $a,
  };
  $toc->{$session_sort_order}->{'volumes'}->{$v} = $vol;
}

$toc->{$session_sort_order}->{'name'} = $session_name;

my $json = JSON->new->pretty();
print $json->encode($toc);


