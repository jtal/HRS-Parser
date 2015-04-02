#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;


use lib '~/perl5/lib/perl5';
use lib '../src/archive/crawler/lib';

use JSON;
use File::Find::Rule;
use File::Slurp;
use HTML::FormatText;
use HTML::TreeBuilder;

use Citation;

my $path_to_hrs = '/tmp/crawler';
my $hrs_current = 'hrs2013';

# print debug output as utf-8
# cant remember why you needed this but including it screws things up
# -- wide characters start showing up as 2 characters in Citation.pm
binmode(STDOUT, ":utf8");

my @files = get_hrs_section_files($path_to_hrs);
my $sections = process_files(@files);

exit;


sub get_hrs_section_files {
  my ($path) = @_;

  my $includes = File::Find::Rule->file()->name('*.htm');
  my $excludes = File::Find::Rule->file()->name('*-.htm')->prune()->discard();
  # order matters -- excludes before includes yo
  return File::Find::Rule->file()
                        ->or($excludes, $includes)
                        ->in(($path));
}

sub remove_nav_links {
  my @l = @_;

  if (   $l[-6] eq ''
      && $l[-5] eq 'Previous'
      && $l[-4] eq ''
      && $l[-3] =~ /Vol/
      && $l[-2] eq ''
      && $l[-1] eq 'Next') {
    return splice(@l, 0, -6);
  } else {
    die "Error: Something is different about nav links for this one.";
  }
  exit;
}

sub get_formatted_text_from_file {
  my ($filename) = @_;

  # read input as utf-8
  open(my $fh,  "<:encoding(UTF-8)",  $filename) or die $!;
  my $c = read_file($fh, binmode=>':utf8');

  my $tree = HTML::TreeBuilder->new->parse_content($c);
  my $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 80);

  return $formatter->format($tree);
}

sub clean_lines_from_text {
  my ($t) = @_;
  my @l = remove_nav_links(split(/\n/,$t));
  return @l; 
}

sub get_meta {
  my ($filename, $text) = @_;

  my @missing;
# many records do not have the section listing in [brackets] so just looking at filename instead
  my ($chapter, $section) = ('','');
  ($chapter, $section) = split(/HRS_([^-]+)\-(\w+)$/,$filename);
  my ($volume) = $filename =~ /\/Vol(\d+)_/;

  my $title = Citation::extract_title($text);

  my ($session) = $filename =~ /\/([^\/]+)\/Vol\d/;
  if ($session eq 'hrscurrent') {
    $session = $hrs_current;
  }

  if (!$session) { push @missing, 'session'; } 
  if (!$volume)  { push @missing, 'volume';  } 
  if (!$chapter) { push @missing, 'chapter'; } 
  if (!$title)   { push @missing, 'title';   }

  my $empowering_artifacts = Citation::extract_empowering_artifacts($text, $filename);
  if (!$empowering_artifacts) { 
    $empowering_artifacts = Citation::extract_empowering_artifacts_from_repeal($text, $filename);
  } 

  if (!$empowering_artifacts) { push @missing, 'empowering artifacts'; } 
  if (@missing) {
    print 'MISSING: ' . join(',', @missing) . " for $filename\n";
  }

  return {
    session => $session,
    volume =>  $volume,
    chapter =>  $chapter,
    section => $section,
    title => $title,
    filename => $filename,
    empowering => $empowering_artifacts,
  };
}

sub process_files {
  my (@f) = @_;
  my $sections = [];

  my $i = 0;
  for my $f (@f) {
    my $t = get_formatted_text_from_file($f);
    my @lines = clean_lines_from_text($t);
    my $meta = get_meta($f, $t);

    push @$sections, {
      session  => $meta->{'session'},
      volume   => $meta->{'volume'},
      chapter  => $meta->{'chapter'},
      section  => $meta->{'section'},
      title    => $meta->{'title'},
      filename => $f,
    empowering => $meta->{'empowering'},
      text     => \@lines
    };

    # print out chunks at a time so its not one giant ass file
    if ( ++$i % 200 == 0 ) {
      my $fn = "json/section_$i.json";
      print "Writing $fn\n";
      open(my $fh,  ">:encoding(UTF-8)", $fn) or die $!;
      my $json = JSON->new->pretty();
      print $fh $json->encode($sections);
      close($fh);
      $sections = [];
    }

    exit if $i >= 1000;
  }

  return $sections;
}





