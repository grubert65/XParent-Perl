use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok ('XML::XParent::Schema::DBI');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 9 unless ( 'SQLite' ~~ @drivers );

    # prepare db...
    my $dbh = DBI->connect ('dbi:SQLite:./data/xparent.db')
        or die ("Can't connect: ".$DBI::errstr."\n");
    $dbh->do("DELETE FROM LabelPath");
    $dbh->do("INSERT INTO LabelPath (Path, len) VALUES ( '/foo/bar', 2)");
    $dbh->do("INSERT INTO LabelPath (Path, len) VALUES ( '/foo/bar/baz', 3)");
    $dbh->disconnect;

    ok( my $s = XML::XParent::Schema::DBI->connect('dbi:SQLite:./data/xparent.db'), 'connect');
    ok( my $p = $s->get_path_ids( '/foo/bar/baz' ), 'get_path_ids' );
    is( ref $p, 'ARRAY', 'got right data type back');
    is( $p->[0], 2, 'got right data back');
}
done_testing;

