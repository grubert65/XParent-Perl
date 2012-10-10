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
    $schema->resultset('LabelPath')->create({
        ID      => 23,
        Path    => '/var/www',
        len     => 2,
    });
    
    my $elem = $schema->resultset('Element')->create({
        PathID  => 23,
        Ordinal => 1,
    });
    
    is($schema->get_path( $elem->did ), '/var/www', 'got right data back...');
}

done_testing;
