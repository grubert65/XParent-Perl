package XML::XParent::Schema::DBIx::Result::Data;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

XML::XParent::Schema::DBIx::Result::Data

=cut

__PACKAGE__->table("Data");

=head1 ACCESSORS

=head2 Did

  accessor: 'did'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 PathID

  accessor: 'path_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 Ordinal

  accessor: 'ordinal'
  data_type: 'integer'
  is_nullable: 1

=head2 Value

  accessor: 'value'
  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "Did",
  {
    accessor       => "did",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "PathID",
  {
    accessor       => "path_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Ordinal",
  { accessor => "ordinal", data_type => "integer", is_nullable => 1 },
  "Value",
  { accessor => "value", data_type => "text", is_nullable => 1 },
);

=head1 RELATIONS

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

=head2 did

Type: belongs_to

Related object: L<XML::XParent::Schema::DBIx::Result::Element>

=cut

__PACKAGE__->belongs_to(
  "did",
  "XML::XParent::Schema::DBIx::Result::Element",
  { Did => "Did" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-22 14:29:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:85BEFTu3m1d2F/ZaRhIo6w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
