use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok('XML::XParent::Schema::DBIx');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 2 unless ( 'SQLite' ~~ @drivers );

    ok (my $schema=XML::XParent::Schema::DBIx->connect("dbi:SQLite:./data/xparent.db"), 'connect');
    $schema->clean();
    
    my $elem = $schema->resultset('Element')->create({
        PathID  => 23,
        Ordinal => 1,
    });
    
    $schema->resultset('Data')->create({
        Did     => $elem->did,
        PathID  => 23,
        Value   => 1234,
    });
    
    is($schema->get_value( $elem->did ), '1234', 'got right data back...');
}
done_testing;

