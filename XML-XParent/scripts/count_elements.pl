#!/usr/bin/perl 
use strict;
use warnings;
use XML::Twig;

my $file = $ARGV[0] or die "Usage: $0 <file>";
die unless ( -e $file );

my $count=0;

my $twig = XML::Twig->new(
    twig_handlers => {
        _all_ => sub { $count++ },
    },
    );

$twig->parsefile( $file );

print "Total number of xml elements: $count\n";

