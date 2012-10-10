package XML::XParent::Parser::Compact;
#============================================================= -*-perl-*-

=head1 NAME

XML::XParent::Parser - a parser to load XML files and snippets into
an XParent data store.

=head2 SYNOPSIS

use XML::XParent::Parser;

my $parser = XML::XParent::Parser->new();
$parser->parse_file( $filename );

=head2 DESCRIPTION

This class implements a parser to load stuff into an XParent model data store.

=head2 EXPORT

None by default.

=head2 SUPPORT

You can find documentation for this module with the perldoc command:

    perldoc <module>

=head2 SEE ALSO

=head2 AUTHOR

Marco Masetti <masetti at linux dot it>

=head2 COPYRIGHT and LICENSE

Copyright (C) 2012, Marco Masetti.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose

=head1 FUNCTIONS

=cut

#========================================================================
use XML::Twig;

#=============================================================

=head2 new

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Class constructor

=cut

#=============================================================
sub new {
    my $package = shift;
    my ($self) = {@_};
    $self->{twig} = XML::Twig->new;
    if ( $self->{verbose} ) {
        $self->{twig}->setTwigHandlers({
                    _all_ => sub { $self->load_elt( @_ ) },
        });
    } else {
        $self->{twig}->setTwigHandlers({
                    _all_ => sub { $self->add_twig( @_ ) },
        });
    }

    bless $self, $package;
}

#=============================================================

=head2 parse_file

=head3 INPUT

    $filename

=head3 OUTPUT

1/undef in case of errors

=head3 DESCRIPTION

Parse the passed file, storing all elements, attributes into the
configured XParent data store.

=cut

#=============================================================
sub parse_file {
    my ( $self, $filename ) = @_;

    $self->{twig}->parsefile( $filename );
}

#=============================================================

=head2 load_elt

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

=cut

#=============================================================
sub load_elt {
    my ($self, $twig, $elt) = @_;

    if ( $elt->text_only || keys %{ $elt->atts } ) {
        $self->{schema}->add_twig( $elt );
        $self->dump_elt ( $elt );
    } else {
        push @{ $elt->parent->{cid} }, @{ $elt->{cid} }
            if ( $elt->parent && $elt->{cid} );
    }
}

#=============================================================

=head2 add_twig

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

=cut

#=============================================================
sub add_twig {
    my ($self, $twig, $elt) = @_;
    $DB::single=1;
    if ( $elt->text_only || keys %{ $elt->atts } ) {
        my $ordinal = 1;
        if ( defined $elt->parent )  {
            $ordinal = $elt->parent->{childrens} // 1;
            $elt->parent->{childrens} = $ordinal+1;
        }
        $self->{schema}->add_twig( $elt, $ordinal );
    } else {
        push @{ $elt->parent->{cid} }, @{ $elt->{ cid } }
            if ( $elt->parent && $elt->{ cid } );
    }
}

#=============================================================

=head2 dump_elt

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

=cut

#=============================================================
sub dump_elt {
    my ( $self, $elt ) = @_;

    print "[ ".$self->{elt_num}++." ]--------------------------------------\n";
    print "TAG:               \n".$elt->tag;
    print "ID:                \n".$elt->{element_id};
    print "XPATH:             \n".$elt->xpath;
    print "LEVEL:             \n".$elt->level;
    if ( defined $elt->parent )  {
        print "Parent TAG:        \n".$elt->parent->tag;
    }
    print "number of children: \n".$elt->children_count;
    my $attrs = $elt->atts;
    while ( my ( $k, $v ) = each ( %$attrs ) ) {
        print "\tATTR name:  $k\n\tATTR value: $v\n";
    }
}

1;
