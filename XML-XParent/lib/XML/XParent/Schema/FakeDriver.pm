package XML::XParent::Schema::FakeDriver;
use strict;
use warnings;

#=============================================================

=head2 connect

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

A fake connect method...

=cut

#=============================================================

sub connect { bless {}, $_[0]; };

1;

