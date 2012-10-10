use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok ('XML::XParent::Schema::DBIx');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 9 unless ( 'SQLite' ~~ @drivers );

    ok( my $s = XML::XParent::Schema::DBIx->connect('dbi:SQLite:./data/xparent.db'), 'connect');

    $s->clean();
    $s->resultset('LabelPath')->create({ Path => '/foo/bar', len => 2 });
    $s->resultset('LabelPath')->create({ Path => '/foo/bar/baz', len => 3 });

    ok( my $p = $s->get_path_ids( '/foo/bar/b%' ), 'get_path_ids' );
    is( ref $p, 'ARRAY', 'got right data type back');
    is( $p->[0]->{id}, 2, 'got right data back');
    is( $p->[0]->{path}, '/foo/bar/baz', 'got right data back');
}
done_testing;

