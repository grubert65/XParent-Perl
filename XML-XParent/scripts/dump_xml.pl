#!/usr/bin/perl 
use Modern::Perl;
use XML::Twig;

our $elt_num = 0;

my $file = $ARGV[0]
    or die "Usage: $0 <xml file>";

die "File not found or not readable" unless ( -e $file );

my $twig = XML::Twig->new(
    twig_handlers   => {
        _all_ => \&dump_elt,
    },
);

$twig->parsefile( $file );
#$twig->flush();

sub dump_elt {
    my ($twig, $elt) = @_;
    $elt->{element_id} = int(rand(1000));
    say "[ ".$elt_num++." ]--------------------------------------";
    say "TAG:               ".$elt->tag;
    say "ELEMENT ID         ".$elt->{element_id};
    say "XPATH:             ".$elt->xpath;
    say "LEVEL:             ".$elt->level;
    say "TEXT:              ".$elt->text_only if ( $elt->text_only );
    if ( defined $elt->parent )  {
        my $ordinal = $elt->parent->{childrens} // 1;
        $elt->parent->{childrens} = $ordinal+1;
        say "Father TAG:        ".$elt->parent->tag;
        say "CHILD ORDINAL:     ".$ordinal;
    }
    say "number of children: ".$elt->children_count;
    my @children = $elt->children;
    foreach my $child ( @children ) {
        say "\t CHILD TAG: ".$child->tag.", CHILD TEXT: ".$child->text_only if ( $child->text_only );
    }
    my $attrs = $elt->atts;
    while ( my ( $k, $v ) = each ( %$attrs ) ) {
        say "\tATTR name:  $k\n\tATTR value: $v";
    }
}
