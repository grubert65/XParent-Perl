use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok('XML::XParent::Schema::DBIx');
    use_ok('XML::XParent::Parser');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 6 unless ( 'SQLite' ~~ @drivers );

    ok (my $schema=XML::XParent::Schema::DBIx->connect("dbi:SQLite:./data/xparent.db"), 'connect');
    $schema->clean();
    ok (my $parser=XML::XParent::Parser->new( 
        schema => $schema,
        verbose=> 1 
        ), 'new');
    ok ($parser->parse_file('./scripts/test.xml'), 'parse_file');
    $schema->flush_data();
    $schema->flush_datapath();
    
    ok(my $elems = $schema->get_elem('/Mpeg7/DescriptionMetadata'), 'get_elem');
    is(scalar @$elems, 1, 'got right number of objects back');
    is($elems->[0]->path, '/Mpeg7/DescriptionMetadata', 'ok...');
}

done_testing;
