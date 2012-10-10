package XML::XParent::Schema::DBIx;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base qw( DBIx::Class::Schema XML::XParent::Schema );

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-22 14:29:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xc1myk1CPT5hvU9QicOx5A


#============================================================= -*-perl-*-

=head1 NAME

XML::XParent::Schema::DBIx - A DBIx::Class class to handle the XParent schema.

=head2 SYNOPSIS

    use XML::XParent::Schema;

    # connect to a datasource...
    my $o = XML::XParent::Schema->connect(...);

    # add an element...

=head2 DESCRIPTION

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
use XML::XParent::Elem;
use Log::Log4perl;

# HISTORY
# 0.01: 22/08/2012: first implementation
# 0.02: 02/10/2012: bulk loading of Data and DataPath
# 0.03: 07/10/2012: paths cached...

use vars qw( $VERSION $log );
$VERSION    ='0.03';
$log        = Log::Log4perl->get_logger( __PACKAGE__ );

#=============================================================

=head2 connect

=head3 INPUT

An array of data source connection params

=head3 OUTPUT

=head3 DESCRIPTION

Overload connect method to set local members.

=cut

#=============================================================
sub connect {
    my $class = shift;
    my $self = $class->SUPER::connect( @_ );

    $self->{labelpath_hash} = {};
    $self->{MAX_CACHE}      = 10000;
    $self->{data_cache}     = [];
    $self->{datapath_cache} = [];

    # get all LabelPath records  into cache...
    my $rs = eval { $self->resultset('LabelPath')->search(); };
    if ( $@ ) {
        $log->error( "Error searching: $@" );
        die ( "Error searching: $@" );
    }
    if ( $rs->count ) {
        $self->{labelpath_hash} = { map { $_->path => $_->id } $rs->all };
    }

    return $self;
}

#=============================================================

=head2 add_twig

Adds an XML::Twig::Elt element into the XParent db.

=head3 INPUT

    $twig: the XML::Twig::Elt object

=head3 OUTPUT

1/undef in case of errors

=head3 DESCRIPTION

#Workflow:
#- if twig->{element_id} exists return it
#- get element path and add path to LabelPath (or get existent)
#- add element path id to the Element table, add Element.id to elt obj
#- get element value and add it to Data table if existent
#- add element attributes
#- if cid is passed add element.id, cid to the DataPath table
#- get twig parent and call add_twig if exists

=cut

#=============================================================
sub add_twig {
    my ( $self, $twig, $ordinal ) = @_;

    return undef unless $twig;
    return 1 if ( $twig->{element_id} );

#-------------------------------------------------------------
# get element path and add path to LabelPath (or get existent)
#-------------------------------------------------------------
    my $path_id = $self->add_label_path( $twig->path );

#-------------------------------------------------------------
# add element path id to the Element table, 
# add Element.id to elt obj
#-------------------------------------------------------------
    $twig->{element_id} = $self->add_element( $path_id, $ordinal );

#-------------------------------------------------------------
# add the element value
#-------------------------------------------------------------
    my $value = $twig->text_only;
    $self->add_value({ 
        Did     => $twig->{element_id}, 
        PathID  => $path_id ,
        Value   => $value, 
        Ordinal => 1
    }) if ( $value );
    
#-------------------------------------------------------------
#- add element attributes
#-------------------------------------------------------------
    my $attrs = $twig->atts;
    my $ord = 1;
    while ( my ( $k, $v ) = each ( %$attrs ) ) {
        $self->add_twig_attr( $k, $v, $twig->{element_id}, $twig->path, $ord++ );
    }

#-------------------------------------------------------------
#- if element has some children, fix data path...
#-------------------------------------------------------------
    foreach my $cid ( @{ $twig->{cid} } ) {
        $self->add_data_path( $twig->{element_id}, $cid );
    }

#-------------------------------------------------------------
#- get twig parent and call add_twig if exists
#-------------------------------------------------------------
    if ( defined $twig->parent )  {
        push @{ $twig->parent->{cid} }, $twig->{element_id};
    }

    return 1;
}

#=============================================================

=head2 add_data_path

=head3 INPUT

    $pid: parent
    $cid: child

=head3 OUTPUT

1/undef in case or errors

=head3 DESCRIPTION

Add a record in the DataPath table

=cut

#=============================================================
sub add_data_path {
    my ( $self, $pid, $cid ) = @_;

    # pid can be 0...
    return undef unless ( defined $pid && defined $cid );

    if ( scalar @{$self->{datapath_cache}} == $self->{MAX_CACHE} ) {
        $self->flush_datapath();
    }
    push @{$self->{datapath_cache}}, [ $pid, $cid ];
}

#=============================================================

=head2 add_value

=head3 INPUT

    $value:   the element value
    $element_id: the element_id
    $path_id: the element path id
    $ordinal: the element ordinal 

=head3 OUTPUT

1/undef in case of errors

=head3 DESCRIPTION

Add record to Data table

=cut

#=============================================================
sub add_value {
    my ( $self, $rec ) = @_;

    if ( scalar @{$self->{data_cache}} == $self->{MAX_CACHE} ) {
        $self->flush_data();
    }
    push @{$self->{data_cache}}, [ 
        $rec->{Did}, 
        $rec->{PathID}, 
        $rec->{Ordinal}, 
        $rec->{Value} 
    ];
}

#=============================================================

=head2 add_element

=head3 INPUT

    $path_id: the id of the path of the element to add

=head3 OUTPUT

The element id

=head3 DESCRIPTION

We set ordinal to 0, we should even delete column in schema.
Elements order can be guessed by did.

=cut

#=============================================================
sub add_element {
    my ( $self, $path_id, $ordinal ) = @_;

    return undef unless $path_id;

    my $rec = $self->resultset('Element')->create({
        PathID  => $path_id,
        Ordinal => $ordinal,
    });

    return $rec->did;
}

#=============================================================

=head2 add_label_path

=head3 INPUT

    $path: the path to add

=head3 OUTPUT

The path id.

=head3 DESCRIPTION

Look for path id in cache, otherwise creates path record.

=cut

#=============================================================
sub add_label_path {
    my ( $self, $path ) = @_;

    return undef unless ( $path );

    if ( not $self->{labelpath_hash}->{ $path } ) {
        my $len = scalar ( split /\//, $path ) -1 ;
        my $rec = $self->resultset('LabelPath')->create({
                Path    => $path,
                len     => $len,
            },
            { key => 'Path_unique' }
        );
        $self->{labelpath_hash}->{ $path } = $rec->id;
    }

    return ( $self->{labelpath_hash}->{ $path } );
}

#=============================================================

=head2 add_twig_attr

Adds an element attribute

=head3 INPUT

    $k: the attribute name
    $v: the attribute value
    $element_id: the parent id
    $element_path: the element_path
    $ordinal: the attribute ordinal


=head3 OUTPUT

new element id / undef in case of errors

=head3 DESCRIPTION

Workflow:
- add attribute path to LabelPath table
- add attribute to Element table
- add attr value to Data table
- add parent, child ids into DataPath

=cut

#=============================================================
sub add_twig_attr {
    my ( $self, $k, $v, $element_id, $element_path, $ordinal ) = @_;

    return undef unless ( $k && $v && $element_id && $element_path );

#- add attribute path to LabelPath table
    my $path = $element_path.'/@'.$k;

    my $label_path_id = $self->add_label_path( $path );

#- add attribute to Element table
    my $element_rec = $self->resultset('Element')->create({
        PathID  => $label_path_id,
        Ordinal => $ordinal || 1,
    });

#- add attr value to Data table
    $self->add_value({
        Did     => $element_rec->did,
        PathID  => $label_path_id,
        Value   => $v,
        Ordinal => $ordinal || 1,
    });

#- add parent, child ids into DataPath
    $self->add_data_path( $element_id, $element_rec->did );

    return $element_rec->did;
}

#=============================================================

=head2 clean

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Clean all XParent db tables

=cut

#=============================================================
sub clean {
    my $self = shift;

    foreach ( qw( 
        Data
        DataPath
        Element
        LabelPath
        )) {

        my $rs = $self->resultset( $_ )->search ();
        $rs->delete();
    }
    $self->{labelpath_hash} = {};

    return 1;
}

#=============================================================

=head2 get_elem

=head3 INPUT

    $path: the element path sql regex 

=head3 OUTPUT

An arrayref of XML::XParent::Elem objects or undef in case of error.

=head3 DESCRIPTION

Get the labelpath rec that match path regex.
Get the list of elements with this path
for each element:
- create an XML::XParent::Element object
- get the element tree from DataPath
- for each tree item:
-- get the element path from the element pathid
-- get the element/attribute value

=cut

#=============================================================
sub get_elem {
    my ( $self, $path ) = @_;

    return undef unless $path;

    my @elements = ();

    my $paths = $self->get_path_ids( $path )
        or return undef;

    foreach my $path ( @$paths ) {
        # Get the list of elements with this path
        my $elems = $self->get_elements_with_pathid ( $path->{id} );

        foreach my $elem_id ( @$elems ) {
            # set parent as undef
            my $elem_obj = $self->build_elem(
                did     => $elem_id,
                path    => $path->{path}
            );
            push @elements, $elem_obj;
        } 
    }
    return \@elements;
}

#=============================================================

=head2 build_elem

=head3 INPUT

An hashref with keys:
    did:    the element unique id (mandatory)
    path:   the element path 
    parent: the XML::XParent::Elem obj of parent
    value:  the element value

=head3 OUTPUT

An XML::XParent::Elem object or undef in case or errors

=head3 DESCRIPTION

Workflow:
- check input data first
- get element path and value if not passed
- creates a new XML::XParent::Elem record
- get children ids
- for each child:
-   call build_elem() passing elem as parent...

=cut

#=============================================================
sub build_elem {
    my $self = shift;

    my $params = { @_ };
    $params->{path} = $self->get_path( $params->{did} )
        unless ( $params->{path} );
    $params->{value} = $self->get_value( $params->{did} )
        unless ( $params->{value} );

    my $elem = XML::XParent::Elem->new( %$params )
        or die "Error getting an XML::XParent::Elem obj";

    # get elem children
    my @children = ();
    my $elem_datapath_rs = $self->resultset('DataPath')->search({
        Pid => $params->{did}
    });

    @children = map { $_->cid } $elem_datapath_rs->all 
        if ( $elem_datapath_rs );

    #for each child:
    foreach my $child_id ( @children ) {
        #- call build_elem() passing elem as parent...
        $self->build_elem(
            did     => $child_id,
            parent  => $elem,
        );
    }

    return $elem;
}

#=============================================================

=head2 get_path

=head3 INPUT

    $id: the element id

=head3 OUTPUT

The path of the element

=head3 DESCRIPTION

Returns the path of the element.

=cut

#=============================================================
sub get_path {
    my ( $self, $id ) = @_;

    my $elem_rec;

    my $rs = $self->resultset('Element')->search({
        Did => $id
    });

    if ( $rs->count ) {
        $elem_rec = $rs->first;
    }

    return $elem_rec->path->path;
}

#=============================================================

=head2 get_value

=head3 INPUT

    $id

=head3 OUTPUT

=head3 DESCRIPTION

Returns the element value in string format or undef.

=cut

#=============================================================
sub get_value {
    my ( $self, $id ) = @_;

    my $rs = $self->resultset('Data')->search({
        Did => $id
    });

    if ( $rs->count ) {
        return $rs->first->value;
    }

    return undef;
}

#=============================================================

=head2 get_elements_with_pathid

=head3 INPUT

    $path_id : the id of the path

=head3 OUTPUT

An arrayref

=head3 DESCRIPTION

Returns the list of the elements ids that belong to this path.

=cut

#=============================================================
sub get_elements_with_pathid {
    my ( $self, $path_id ) = @_;

    my @all = $self->resultset('Element')->search({
        PathID => $path_id,
    })->all();

    return undef unless @all;
    return [ map { $_->did } @all ];
}

#=============================================================

=head2 get_path_ids

=head3 INPUT

    $path: the path to query for...

=head3 OUTPUT

An ArrayRef

=head3 DESCRIPTION

Returns an arrayref of hashes with keys:
id      => the path id
path    => the path string

=cut

#=============================================================
sub get_path_ids {
    my ( $self, $path ) = @_;

    my @all = $self->resultset('LabelPath')->search({
        Path => { 'like', $path },
    })->all();

    return undef unless @all;
    return [ map { {
        id   => $_->{_column_data}->{ID},
        path => $_->{_column_data}->{Path},
    } } @all ];
}

#=============================================================

=head2 flush_data

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Populates DB with all Data records in cache

=cut

#=============================================================
sub flush_data {
    my $self = shift;

    $self->populate( 'Data', [ 
        [ qw( Did PathID Ordinal Value ) ], 
        @{$self->{data_cache}} 
    ]);
    $self->{data_cache} = [];
}

#=============================================================

=head2 flush_datapath

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Populates DB with all DataPath records in cache

=cut

#=============================================================
sub flush_datapath {
    my $self = shift;

    $self->populate( 'DataPath', [ 
        [ qw( Pid Cid) ], 
        @{$self->{datapath_cache}} 
    ]);
    $self->{datapath_cache} = [];
}

#=============================================================

=head2 disconnect

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

=cut

#=============================================================

sub disconnect {
    my $self = shift;
    $self->storage->dbh->disconnect();
}

1;
