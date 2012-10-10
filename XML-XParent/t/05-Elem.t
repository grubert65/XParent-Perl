use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok( 'XML::XParent::Elem' );
}

ok( my $o = XML::XParent::Elem->new(
    path    => '/foo/bar',
), 'new');
my $value = 'barbaz';
ok( my $c1 = XML::XParent::Elem->new(
    path    => '/foo/bar/@baz',
    parent  => $o,
    value   => $value ), 'new child');
is($c1->ordinal,1,'ok');
ok( my $c2 = XML::XParent::Elem->new(
    path    => '/foo/bar/@baz2',
    parent  => $o,
    value   => $value), 'new child');
is($c2->ordinal,2,'ok');

#should work even with almost all undef...
ok( my $c3 = XML::XParent::Elem->new(
    path    => '/foo/bar',
    value   => undef,
    parent  => undef,
    ), 'new child');
ok( $c3->dump, 'dump');

done_testing;



