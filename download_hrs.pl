
use strict;
use warnings;

use WWW::Mechanize;
use Data::Dumper;
use File::Basename;
use File::Path;

# specify what you'd like to copy and where to copy to locally
my $remote_base = 'http://www.capitol.hawaii.gov';
my $local_base = '/tmp/crawler';
my $start = '/hrscurrent';


my $i = 0;
my $urls = {};

my $mech = WWW::Mechanize->new() || die 'cant create www mech obj';
$mech->agent_alias('Linux Mozilla');

process($start);

exit;




sub process {
  my ($relative_path_original) = @_;
  my $relative_path = $relative_path_original;

  if ($i++ > 20000) {
    die "$i is enough";
  }

  if ($i % 100 == 0) {
    print "$i: $relative_path_original\n";
  }

  my $remote_file = join("/",$remote_base, $relative_path);
  $mech->get($remote_file);
  if ($mech->status != 200) {
    die "ERROR: response state " . $mech->status . " for GET $remote_file";
  }

  my $c = $mech->content(format => 'text');

  if (isDirectoryListing($c)) {
    # write the directory listing before following children
    # make up the filename index.html since it doesnt have one remotely
    writeFile(join('/', $relative_path, 'index.html'), $c);
    doneProcessing($relative_path);

    # for my $line (split(/\<br\>/,$c)) {
    LINE:
    for my $link ($mech->links()) { 

#      if ($line =~ /\[To Parent Directory\]/) { next LINE; }
#      my $link_url = extractLink($line);

#      if (!$link_url) {
#        print "WARN: no link extracted from: $line\n";
#        next;
#      }

      my $link_url = $link->url();
      next if $link_url eq '/';
      if (! alreadyProcessed($link_url)) {
        process($link_url);
      } else {
#        print "SKIPPING $link_url\n";
      }
    }

  } else {
    writeFile($relative_path, $c);
    doneProcessing($relative_path);
  }

}

sub writeFile {
  my ($relative_path, $c) = @_;
  my $local_file = join("/",$local_base,$relative_path);
  my $path = dirname($local_file);
  if (! -d $path) {
    File::Path::make_path($path);
  }
  open(my $fh, ">$local_file") || die "ERROR: Cant open file $local_file: $!";
  print $fh $c;
  close($fh);

  return 1;
}


sub extractLink {
  my ($line) = @_;
  my ($link) = $line =~ /HREF="([^"]+)"/i;
  return $link;
}

sub doneProcessing {
  my ($url) = @_;
  $urls->{$url}++;
}

sub alreadyProcessed {
  my ($url) = @_;
  return $urls->{$url};
}

sub isDirectoryListing {
  my ($c) = @_;
  my $s = '^www.capitol.hawaii.gov - ';
  if ($c =~ /$s/) { return 1; }
  return 0;
}



