use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok('XML::XParent::Schema::DBI');
    use_ok('XML::XParent::Parser');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 3 unless ( 'SQLite' ~~ @drivers );

    ok (my $schema=XML::XParent::Schema::DBI->connect("dbi:SQLite:./data/xparent.db"), 'connect');
    $schema->clean();
    ok (my $parser=XML::XParent::Parser->new( 
        schema => $schema,
        verbose=> 1 
        ), 'new');
    ok ($parser->parse_file('./scripts/test.xml'), 'parse_file');
}
done_testing;
