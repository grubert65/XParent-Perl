package XML::XParent::Schema::DBIx::Result::LabelPath;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

XML::XParent::Schema::DBIx::Result::LabelPath

=cut

__PACKAGE__->table("LabelPath");

=head1 ACCESSORS

=head2 ID

  accessor: 'id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 len

  data_type: 'integer'
  is_nullable: 0

=head2 Path

  accessor: 'path'
  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ID",
  {
    accessor          => "id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "len",
  { data_type => "integer", is_nullable => 0 },
  "Path",
  { accessor => "path", data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ID");
__PACKAGE__->add_unique_constraint("Path_unique", ["Path"]);

=head1 RELATIONS

=head2 elements

Type: has_many

Related object: L<XML::XParent::Schema::DBIx::Result::Element>

=cut

__PACKAGE__->has_many(
  "elements",
  "XML::XParent::Schema::DBIx::Result::Element",
  { "foreign.PathID" => "self.ID" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 datas

Type: has_many

Related object: L<XML::XParent::Schema::DBIx::Result::Data>

=cut

__PACKAGE__->has_many(
  "datas",
  "XML::XParent::Schema::DBIx::Result::Data",
  { "foreign.PathID" => "self.ID" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-08-22 14:29:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Xire3WKm1zw1GnGDr6oOug


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
