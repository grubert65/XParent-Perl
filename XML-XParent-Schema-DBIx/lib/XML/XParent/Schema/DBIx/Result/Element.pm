package XML::XParent::Schema::DBIx::Result::Element;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

XML::XParent::Schema::DBIx::Result::Element

=cut

__PACKAGE__->table("Element");

=head1 ACCESSORS

=head2 Did

  accessor: 'did'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 PathID

  accessor: 'path_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 Ordinal

  accessor: 'ordinal'
  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "Did",
  {
    accessor          => "did",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "PathID",
  {
    accessor       => "path_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Ordinal",
  { accessor => "ordinal", data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("Did");

=head1 RELATIONS

=head2 data_paths

Type: has_many

Related object: L<XML::XParent::Schema::DBIx::Result::DataPath>

=cut

__PACKAGE__->has_many(
  "data_paths",
  "XML::XParent::Schema::DBIx::Result::DataPath",
  { "foreign.Pid" => "self.Did" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 path

Type: belongs_to

Related object: L<XML::XParent::Schema::DBIx::Result::LabelPath>

=cut

__PACKAGE__->belongs_to(
  "path",
  "XML::XParent::Schema::DBIx::Result::LabelPath",
  { ID => "PathID" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 datas

Type: has_many

Related object: L<XML::XParent::Schema::DBIx::Result::Data>

=cut

__PACKAGE__->has_many(
  "datas",
  "XML::XParent::Schema::DBIx::Result::Data",
  { "foreign.Did" => "self.Did" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-10-02 11:31:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S8Rhrb2uZFO3PbDym7XlaA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
