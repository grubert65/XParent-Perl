package XML::XParent::Schema::DBI;

use 5.006;
use strict;
use warnings;
use Log::Log4perl;
use XML::XParent::Elem;
use DBI;

=head1 NAME

XML::XParent::Schema::DBI - The DBI driver of the XML::XParent::Schema base class

=head1 VERSION

Version 0.01

=cut
our $VERSION = '0.01';
our $log     = Log::Log4perl->get_logger(__PACKAGE__);

=head1 SYNOPSIS

=head1 EXPORT

None by default.

=head1 SUBROUTINES/METHODS

=cut

#=============================================================
##########    G L O B A L     S T A T E M E N T S    #########

my $sth_select_id_from_label_path_where_path;
my $sth_select_did_from_element_where_path_id;
my $sth_select_value_from_data_where_path_did;
my $sth_select_cid_from_data_path_where_pid;

my $sth_clean_data;
my $sth_clean_element;
my $sth_clean_label_path;
my $sth_clean_data_path;

# my $query1_mysql; # MySQL version
my $query1;
my $query2;

my $query_s;

my $max_data      = 10000; 	# MAX SIZE FOR CACHE QUERY
my $size_data     = 0; 		# counter
my $size_datapath = 0;		# counter

#=============================================================

=head2 connect

=head3 INPUT

An array of connection params.

=head3 OUTPUT

A class object

=head3 DESCRIPTION

Class constructor.

=cut

#=============================================================
sub connect {

	my $package = shift;
	my $self = {};
	$self->{DBI} = DBI->connect(@_) or die ("Can't connect: ".$DBI::errstr."\n");

    $self->{DBI}->{RaiseError} = 1; # don't have to check for errors...

	$sth_select_id_from_label_path_where_path = $self->{DBI}->prepare("
        SELECT ID FROM LabelPath WHERE Path = ?
    ");
	$sth_select_cid_from_data_path_where_pid = $self->{DBI}->prepare("
        SELECT Cid FROM DataPath WHERE Pid = ?
    ");
	$query_s = $self->{DBI}->prepare("
        SELECT Path FROM LabelPath 
        WHERE Id = (SELECT PathId FROM Element WHERE Did = ?)
    ");
	$sth_select_did_from_element_where_path_id 	= $self->{DBI}->prepare("
        SELECT Did FROM Element WHERE PathId = ?
    ");
	$sth_select_value_from_data_where_path_did 	= $self->{DBI}->prepare("
        SELECT Value FROM Data WHERE Did = ?
    ");

	$sth_clean_element = $self->{DBI}->prepare(q{DELETE FROM element});
	$sth_clean_data	= $self->{DBI}->prepare(q{DELETE FROM data});
	$sth_clean_label_path = $self->{DBI}->prepare(q{DELETE FROM labelpath});
	$sth_clean_data_path = $self->{DBI}->prepare(q{DELETE FROM datapath});
	
	# $query1_mysql = $self->{DBI}->prepare('INSERT IGNORE INTO LabelPath (Path, Len) VALUES (?, ?)'); # MySQL version
	$query1 = $self->{DBI}->prepare("
        INSERT INTO LabelPath (Path, Len) VALUES ( ?, ? )
    ");

	$query2 = $self->{DBI}->prepare("
        INSERT INTO Element (PathId, Ordinal) VALUES (? , ?)
    ");

    $self->{global_data} 	= "INSERT INTO data(Did, PathID, Ordinal, Value) VALUES ";
    $self->{global_datapath}= "INSERT INTO datapath(Pid, Cid) VALUES ";
    $self->{datapath_cache} = [];
    
    # loading paths into labelpath_hash...
    $self->{labelpath_hash} = {};
    my $sth = $self->{DBI}->prepare("SELECT ID, Path from LabelPath");
    $sth->execute();
    $self->{labelpath_hash} = { map { $_->[1] => $_->[0] } @{$sth->fetchall_arrayref} };

    bless $self, $package;
}

#=============================================================

=head2 disconnect

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Disconnects from data source.

=cut

#=============================================================

sub disconnect {
    my $self = shift;
    $self->{DBI}->disconnect();
}

#=============================================================

=head2 clean

=head3 INPUT

=head3 OUTPUT

true.

=head3 DESCRIPTION

Cleans the data store...

=cut

#=============================================================
sub clean {
	my $self = shift;

	$sth_clean_data_path->execute();
	$sth_clean_data->execute();
	$sth_clean_element->execute();
	$sth_clean_label_path->execute();

    $self->{labelpath_hash} = {};

	return 1;
}

#=============================================================

=head2 get_path_ids

=head3 INPUT

    $path: the path to get the id...

=head3 OUTPUT

An arrayref.

=head3 DESCRIPTION

=cut

#=============================================================
sub get_path_ids {

	my ( $self, $path ) = @_;

	$sth_select_id_from_label_path_where_path->execute($path);
	my $ref_d = $sth_select_id_from_label_path_where_path->fetchrow_arrayref();
	return $ref_d;
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

	$query_s->execute($id);
	my $ref = $query_s->fetchrow_arrayref();

	return $ref;
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

	$sth_select_value_from_data_where_path_did->execute($id);
	my $poin = $sth_select_value_from_data_where_path_did->fetchrow_arrayref();

	return @$poin if defined $poin;
	return undef;
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
check input data first
get element path and value if not passed
creates a new XML::XParent::Elem record
get children ids
for each child:
- call build_elem() passing elem as parent...

=cut

#=============================================================
sub build_elem {

	my $self = shift;

	my $params = {@_};

	$params->{path} = $self->get_path( $params->{did} )  unless ( $params->{path} );
	$params->{value}= $self->get_value( $params->{did} ) unless ( $params->{value} );

	my $elem = XML::XParent::Elem->new(%$params) 
        or die "Error getting an XML::XParent::Elem obj";

	# get elem children
	my $did_d = $params->{did};
	$sth_select_cid_from_data_path_where_pid->execute($did_d);
	my $point = $sth_select_cid_from_data_path_where_pid->fetchrow_arrayref();

	# for each child:
	foreach my $child_id (@$point) {
		#- call build_elem() passing elem as parent...
		$self->build_elem(
			did    => $child_id,
			parent => $elem,
		);
	}
	return $elem;
}

#=============================================================

=head2 get_elem

=head3 INPUT

    $path: the element xpath

=head3 OUTPUT

An arrayref of XML::XParent::Elem objects or undef in case of error.

=head3 DESCRIPTION

Get the labelpath rec the match xpath.
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

	my @elements 	= ();
	my $ids 		= $self->get_path_ids($path) or return undef;

	foreach my $path_id (@$ids) {
		# Get the list of elements with this path
		my $elems = $self->get_elements_with_pathid($path_id);
		foreach my $elem_id (@$elems) {
			# set parent as undef
			my $elem_obj = $self->build_elem(
				did  => $elem_id,
				path => $path
			);
			push @elements, $elem_obj;
		}
	}
	return \@elements;
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
	$sth_select_did_from_element_where_path_id->execute($path_id);
	my $point = $sth_select_did_from_element_where_path_id->fetchrow_arrayref();

	return @$point;
}

#=============================================================

=head2 add_twig

Adds an XML::Twig::Elt element into the XParent db.

=head3 INPUT

    $elt: the XML::Twig::Elt object

=head3 OUTPUT

element id/undef in case of errors

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

	#-------------------------------------------------------------
	# if twig->{element_id} exists return it
	#-------------------------------------------------------------
	return if ( $twig->{element_id} );
	
	#-------------------------------------------------------------
	# get element path and add path to LabelPath (or get existent)
	#-------------------------------------------------------------
	my $element_path = $twig->path;
	return undef unless ($element_path);

	my $len = scalar( split /\//, $element_path ) - 1;
	
    my $path_id;
    if ( not $self->{labelpath_hash}->{ $element_path } ) {
    	# $query1_mysql->execute( $element_path, $len ); # MySQL version
    	$query1->execute( $element_path, $len );
        $path_id = $self->{DBI}->last_insert_id(undef, undef, 'labelpath', undef);
        $self->{labelpath_hash}->{ $element_path } = $path_id;
    }
    $path_id = $self->{labelpath_hash}->{ $element_path };
	
	#-------------------------------------------------------------
	# add element path id to the Element table,
	# add Element.id to elt obj
	#-------------------------------------------------------------
	$query2->execute( $path_id, $ordinal );
	$twig->{element_id} = $self->{DBI}->last_insert_id( undef, undef, 'element', undef );

	#-------------------------------------------------------------
	# add the element value
	#-------------------------------------------------------------
	my $value = $twig->text_only;

	if ($value) {
		if ( $size_data == $max_data ) {
			$self->flush_data();
			$self->{global_data}  = "INSERT INTO data(Did, PathID, Ordinal, Value) VALUES ";
			$self->{global_data} .= "($twig->{element_id}, $path_id, 1, '$value'),";
			$size_data = 0;
		}
		else {
			$self->{global_data} .= "($twig->{element_id}, $path_id, 1, '$value'),";
			$size_data++;
		}
	}

	#-------------------------------------------------------------
	#- add element attributes
	#-------------------------------------------------------------
    my $element_id = $twig->{element_id};
	my $attrs = $twig->atts;
	my $ord = 1;
	while ( my ( $k, $v ) = each(%$attrs) ) {

        return undef unless ( $k && $v && $element_id && $element_path );

		#- add attribute path to LabelPath table
		my $path = $element_path . '/@' . $k;
		my $lenn = scalar( split /\//, $path ) - 1;

		# $query1_mysql->execute( $path, $lenn); # MySQL version
        if ( not $self->{labelpath_hash}->{ $path } ) {
		    $query1->execute( $path, $lenn );
            $path_id = $self->{DBI}->last_insert_id(undef, undef, 'labelpath', undef);
            $self->{labelpath_hash}->{ $path } = $path_id;
        }
        $path_id = $self->{labelpath_hash}->{ $path };
		
		#- add attribute to Element table
		$ord = 1 unless $ord;

		$query2->execute( $path_id, $ord );
		my $did_of_element = $self->{DBI}->last_insert_id( undef, undef, 'element', undef );

		if ( $size_data == $max_data ) {
			$self->flush_data();
			$self->{global_data} = "INSERT INTO data(Did, PathID, Ordinal, Value) VALUES ";
			$self->{global_data} .= "($did_of_element, $path_id, $ord, '$v'),";
			$size_data = 0;
		}
		else {
			$self->{global_data} .= "($did_of_element, $path_id, $ord, '$v'),";
			$size_data++;
		}

		#- add parent, child ids into DataPath
        if ( $size_datapath == $max_data ) {
            $self->flush_datapath();
            $self->{global_datapath} = "INSERT INTO datapath(Pid, Cid) VALUES ";
            $self->{global_datapath} .= "($element_id, $did_of_element),";
            $size_datapath = 0;
        }
        else {
            $self->{global_datapath} .= "($element_id, $did_of_element),";
            $size_datapath++;
        }
        $ord++;
    }

	#-------------------------------------------------------------
	#- if cid is passed add element.id, cid to the DataPath table
	#-------------------------------------------------------------
	foreach my $x ( @{ $twig->{cid} } ) {
        if ( $size_datapath == $max_data ) {
            $self->flush_datapath();
            $self->{global_datapath}  = "INSERT INTO datapath(Pid, Cid) VALUES ";
            $self->{global_datapath} .= "($twig->{element_id}, $x),";
            $size_datapath    = 0;
        }
        else {
            $self->{global_datapath} .= "($twig->{element_id}, $x),";
            $size_datapath++;
        }
    }
	#-------------------------------------------------------------
	#- get twig parent and call add_twig if exists
	#-------------------------------------------------------------
	if ( defined $twig->parent ) {
		push @{ $twig->parent->{cid} }, $twig->{element_id};
	}
	return;
}

#=============================================================

=head2 flush_data

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Flush data.

=cut

#=============================================================
sub flush_data {
	my $self = shift;
    chop( $self->{global_data});
	my $tmp1 = $self->{DBI}->prepare($self->{global_data});
	$tmp1->execute();
}

#=============================================================

=head2 flush_datapath

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Flush datapath

=cut

#=============================================================
sub flush_datapath {
	my $self = shift;
    chop( $self->{global_datapath});
	my $tmp1 = $self->{DBI}->prepare($self->{global_datapath});
	$tmp1->execute();
}

=head1 AUTHOR

Aleksander Sadecki, C<< <a.sadecki at gmail.com> >>
Marco Masetti, C<< <grubert65 at gmail.com > >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-xparent-schema-dbi at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-XParent-Schema-DBI>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::XParent::Schema::DBI


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-XParent-Schema-DBI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-XParent-Schema-DBI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-XParent-Schema-DBI>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-XParent-Schema-DBI/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Aleksander Sadecki.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of XML::XParent::Schema::DBI
