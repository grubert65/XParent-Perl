package XML::XParent::Schema::DBIx::Result::DataPath;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

XML::XParent::Schema::DBIx::Result::DataPath

=cut

__PACKAGE__->table("DataPath");

=head1 ACCESSORS

=head2 Pid

  accessor: 'pid'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 Cid

  accessor: 'cid'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "Pid",
  {
    accessor       => "pid",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Cid",
  {
    accessor          => "cid",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
);
__PACKAGE__->set_primary_key("Cid");

=head1 RELATIONS

=head2 pid

Type: belongs_to

Related object: L<XML::XParent::Schema::DBIx::Result::Element>

=cut

__PACKAGE__->belongs_to(
  "pid",
  "XML::XParent::Schema::DBIx::Result::Element",
  { Did => "Pid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-22 14:29:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JRkWDxLMa/0i9zYD8IJ8TQ

# set parent column for DBIx::Class::Tree::AdjacencyList to work properly...
__PACKAGE__->load_components( qw( Tree::AdjacencyList) );
__PACKAGE__->parent_column('Pid');
1;
