package XML::XParent::Elem;
#============================================================= -*-perl-*-

=head1 NAME

XML::XParent::Elem - a simple class to handle an XML element...

=head2 SYNOPSIS

    use XML::XParent::Elem;

    my $elem = XML::XParent::Elem->new();

    my $elem = XML::XParent::Elem->new(
        path    => '/foo/bar',
        value   => 'baz',
        parent  => $parent,
    );

    my $children = $elem->children();
    my $xml_string = $elem->dump_as_xml();

=head2 DESCRIPTION

A simple class to handle an XML element

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
use File::Basename qw( basename );

has 'name'  => (
    is  => 'rw',
    isa => 'Str',
);

has 'path' => (
    is  => 'rw',
    isa => 'Str',
);

has 'value' => (
    is  => 'rw',
    isa => 'Str',
);

has 'ordinal' => (
    is  => 'rw',
    isa => 'Int',
);

has 'is_attr' => (
    is      => 'rw',
    isa     => 'Bool',
    default => sub { 0 },
);

has 'children' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

has 'parent' => (
    is      => 'rw',
    isa     => 'XML::XParent::Elem',
);

#=============================================================

=head2 BUILD

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Class constructor
Adds current object to parent children list if parent is passed.

=cut

#=============================================================
sub BUILD {
    my $self = shift;

    if ( $self->path && not $self->name ) {
        $self->name( basename( $self->path ) );
    }
    $self->is_attr(1) if ( $self->path =~ /@/ );
    if ( $self->parent ) {
        push @{ $self->parent->children }, $self;
        $self->ordinal ( scalar @{$self->parent->children} );
    } else {
        $self->ordinal(1);
    }
}

#=============================================================

=head2 dump

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Dumps current element on output

=cut

#=============================================================
sub dump {
    my $self = shift;

    say "---------------------------------------------------------";
    say "Elem name:    ".$self->name||"NO NAME";
    say "Elem path:    ".$self->path;
    say "Elem value:   ".$self->value if ( $self->value );
    say "Attribute?:   ".$self->is_attr;
    if ( $self->children ) {
        foreach my $child ( @{ $self->children } ) {
            $child->dump();
        }
    }
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;




