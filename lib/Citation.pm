package Citation;

use strict;
use warnings;

use lib '~/perl5/lib/perl5';

use JSON;
use Parse::RecDescent;
use Data::Dumper;

use feature 'unicode_strings';

$::RD_ERRORS = 1; # Parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings- warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
#$::RD_TRACE  = 1;

our $tree = {};


sub parse {
  my ($t) = @_;

  undef $tree;
  $t =~ s/\n/ /g;
  $t =~ s/\\n/ /g;
  $tree = { original => $t };

  my $g = get_grammar();
  my $parser = Parse::RecDescent->new($g);
  $parser->root($t); 
  return $tree;
}

sub extract_title {
  my ($text) = @_;
  my ($title) = $text =~ /(?:\[)?\x{a7}\S+\s+([^.]+)/;
  return $title;
}

sub extract_empowering_artifacts {
  my ($original, $filename) = @_;

  my @can_parse; # properly parsed
  my @cant_parse;   # could not parse
  my $raw = $original;
  while ($raw =~ /(\[.*?\])(.*)/ms) {
    my $candidate = $1;
    $raw = $2;

    my $result = parse($candidate);
    if( $result && $result->{'citations'} ) {
        push @can_parse, $result;
    } else {
        push @cant_parse, $candidate;
    }
  }

  # ways to tell if a document wasnt parsed:
  # citations element is missiing
  # original element is missing!
  # failed_to_parse lists things that may have been citations
  my $num_candidates = scalar(@can_parse);
  if ( $num_candidates == 0 ) {
    return {
      failed_to_parse => \@cant_parse,
    };
  } elsif ( $num_candidates == 1) {
    return $can_parse[0];
  } else {
    print "WARN: Expected 1 citation but found $num_candidates for $filename\n";
    open(my $fh, "json/WARNINGS");
    print $fh "Found $num_candidates candidate citations for $filename\n";
    close($fh);
  }

}

sub extract_empowering_artifacts_from_repeal {
  my ($text, $filename) = @_;

  my @lines = split(/\n/,$text);
  for my $line (@lines) {
    my $g = get_grammar();
    my $parser = Parse::RecDescent->new($g);
    my $repeal = $parser->repeal($line);
    if ($repeal) {
      print "YEEEeeah\n";
      print Dumper $repeal;
    } else {
      print "no\n";
    }
  }
}

sub get_grammar {
  
  my $g = <<'CITATION_GRAMMAR';

#repeal : compact_section comma(?) to(?) number(?) repealed dot session_law
repeal : compact_section 


root : '[' citation(s /;/) ']'
  { 
    $Citation::tree->{citations} = $item{'citation(s)'}; 
  }

citation : session_law | revised_law | HRS | penal_code | gench | sup_law

penal_code : 'PC' year comma act comma(?) compact_section
  { $return = { section => $item{compact_section}->{section},
                    act => $item{act},
                   type => 'Penal Code',
                   year => $item{year},
              };
  }

HRS : 'HRS' compact_section
  { $return = { section => $item{compact_section}->{section}->[1],
                chapter => $item{compact_section}->{section}->[0],
                   type => 'Hawaii Revised Statues',
              };
  }

revised_law : 'RL' year comma revised_section
  { 
    my $tmp = {  year => $item{year},
                 type => 'Revised Law',
              };
    my $revised_section = $item{revised_section};
      print Data::Dumper::Dumper \%item;
      print "YES RS\n";

    if ($revised_section) {
      #$tmp->{section} = $item{revised_section};
    } else {
      print "UH OH WTF\n";
      print Data::Dumper::Dumper \%item;
    }
# jtal
    $return = $tmp;
  }

revised_section: compact_section | plural_section {
    print "IN revised_section\n";
    print Data::Dumper::Dumper \%item;
    print "done revised_section\n";
    $return = {  compact_section => $item{compact_section},
                 plural_section => $item{plural_section},
              };
}

session_law: session chapter_section(s /(?:,|and)/)
  { $return = {  year => $item{session},
               chunks => $item{'chapter_section(s)'},
                 type => 'Session Law',
              };
  }

sup_law : sup comma(?) compact_section

gench : gen ch year
  { $return = { year => $item{year},
                type => 'gench',
              }
  }

chapter_section : act comma section
  { $return = { 
          act => $item{act},
      section => $item{section},
    }; 
  }

compact_section : part(?) section_sign number dash(?) section_number(?)
  { # if section_number doesnt exist then number is the section
  print "COMPACT_SECTION start\n";
    my $tmp = {};
    if ( @{$item{'dash(?)'}} ) {
      my $sections = $item{'section_number(?)'};
      unshift @$sections, $item{number};
      $tmp->{section} = $sections;
    } else {
      $tmp->{section} = [ $item{number} ];
    }
    $return = $tmp;
  }

# what is ren? [ren L 1972, c 10, §7(2)]
session : ree(?) ren(?) am(?) L year comma
  { $return = $item{year} }

act: and(?) 'c' act_number

section : single_section(s) | plural_section

single_section : part(?) section_sign section_number

plural_section : section_sign section_sign section_number(s /, (?:and)?/)

dash : '-'

sup : 'Supp'

ree : 'ree'

L : 'L'

gen : 'gen'

ch: 'ch'

and : 'and'

ren: 'ren'

am : 'am'

part : 'pt of'

section_number : number paragraph(?)
  { $return = $item{number}; }

paragraph : /\(\w+\)/
  { $return = $item[1]; }

number : /\d+/

section_sign : /(\x{c2})?\x{a7}/

act_number : /\d+/

comma : ','

year : sp(?) year_number special_session(?)
  { $return = $item{year_number}; }

year_number : /\d{4}(-\d{1,4})?/

sp : 'Sp'

special_session : /([a-zA-Z0-9]+)/

to : 'to'

repealed : 'repealed'

dot : '.'

CITATION_GRAMMAR

  return $g;
}





1;


