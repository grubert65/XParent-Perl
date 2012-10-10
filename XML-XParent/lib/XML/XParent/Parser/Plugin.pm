package XML::XParent::Parser::Plugin;
use strict;
use warnings;
use Moose;

#=============================================================

=head2 action

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Fake action method, to be implemented by any plugin

=cut

#=============================================================

sub action {
    my ( $self, $params ) = @_;
}


no Moose;
__PACKAGE__->meta->make_immutable;
