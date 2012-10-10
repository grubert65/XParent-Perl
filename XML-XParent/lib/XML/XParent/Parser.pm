package XML::XParent::Parser;
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
use Modern::Perl;
use Moose;
use MooseX::UndefTolerant;
use XML::Twig;

has 'twig'  => (
    is      => 'ro',
    isa     => 'XML::Twig',
    lazy    => 1,
    default => sub {
        XML::Twig->new;
    },
);

has 'schema'    => (
    is      => 'rw',
    isa     => 'Any',
    default => sub {
        #creates a xparent.db sqlitedb where action happens...
        # TODO
    },
);

has 'verbose' => (
    is      => 'rw',
    isa     => 'Bool',
    default => sub { 0 },
);

has 'elt_num' => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 1 },
);

has 'plugins' => (
    is      => 'rw',
    isa     => 'HashRef',
);

#=============================================================

=head2 BUILD

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Class constructor
Initialize twig handlers
Parameters should be passed at construction time, as an hashref 
of this form:
{
    'plugins'   => {
        < tag plugin class> => {
            'tag' => '<tag>',# or _all_ for all
            ....other plugin class params....
        }
    }
}

=cut

#=============================================================
sub BUILD {
    my $self = shift;
    if ( $self->verbose ) {
        $self->twig->setTwigHandlers({
            _all_ => sub { $self->load_elt( @_ ) },
        });
    } else {
        $self->twig->setTwigHandlers({
            _all_ => sub { $self->add_twig( @_ ) },
        });
    }

    # TODO
    # for each tag plugin class => tag
    # get a tag_plugin object
    #   call setTwigHandlers { tag => sub { $tag_plugin_obj->action( @_ ) } }
    if ( $self->plugins ) {
        while ( my ( $class, $params ) = each %{$self->plugins} ) {
            eval "require $class"; next if ( $@ );
            my $plugin_obj = $class->new( $params ) or next;
            next unless ( $params->{tag} && $plugin_obj->can('action') );
            $self->twig->setTwigHandlers({
                $params->{tag} => sub { $plugin_obj->action( @_, $params ) },
                _all_ => sub { $self->add_twig( @_ ) },
            });
        }
    }
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

    $self->twig->parsefile( $filename );
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

    $self->add_twig( $twig, $elt );
    $self->dump_elt ( $elt );
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

    my $ordinal = 1;
    if ( defined $elt->parent )  {
        $ordinal = $elt->parent->{childrens} // 1;
        $elt->parent->{childrens} = $ordinal+1;
    }
    $self->schema->add_twig( $elt, $ordinal ) if ( $self->schema );
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

    say "[ ".$self->{elt_num}++." ]--------------------------------------";
    say "TAG:               ".$elt->tag;
    say "ID:                ".$elt->{element_id};
    say "XPATH:             ".$elt->xpath;
    say "LEVEL:             ".$elt->level;
    if ( defined $elt->parent )  {
        say "Parent TAG:        ".$elt->parent->tag;
        say "Ordinal:           ".$elt->parent->{childrens} || 1;
    }
    say "number of children: ".$elt->children_count;
    my $attrs = $elt->atts;
    while ( my ( $k, $v ) = each ( %$attrs ) ) {
        say "\tATTR name:  $k\n\tATTR value: $v";
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

__DATA__
---
schema_params:
    - 'dbi:SQLite:./xparent.db'
#    - grubert
#    - grubert
