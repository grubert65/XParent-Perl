use strict;
use warnings;

use Test::More;

use_ok('XML::XParent::Schema');

ok(my $s=XML::XParent::Schema->create(
    -TYPE => 'FakeDriver',
    -CONNECT    => [
        "dbi:SQLite:./data/xparent.db"
    ]), 'create');

is( ref $s, 'XML::XParent::Schema::FakeDriver', 'got right obj');
done_testing;



