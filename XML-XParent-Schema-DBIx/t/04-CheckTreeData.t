use strict;
use warnings;
use Test::More;
use DBI;

BEGIN {
    use_ok('XML::XParent::Schema::DBIx');
}

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 9 unless ( 'SQLite' ~~ @drivers );

    ok (my $schema=XML::XParent::Schema::DBIx->connect("dbi:SQLite:./data/xparent.db"), 'connect');
    $schema->clean();
    $schema->resultset('DataPath')->create({ Pid => 0, Cid => 1 });
    $schema->resultset('DataPath')->create({ Pid => 1, Cid => 2 });
    $schema->resultset('DataPath')->create({ Pid => 1, Cid => 3 });
    $schema->resultset('DataPath')->create({ Pid => 2, Cid => 4 });
    $schema->resultset('DataPath')->create({ Pid => 3, Cid => 5 });
    $schema->resultset('DataPath')->create({ Pid => 3, Cid => 6 });
    
    ok(my $root = $schema->resultset('DataPath')->find({Cid => 1}), 'get root');
    ok(my $rs = $root->children(), 'got children');
    
    my @children = map { $_->cid } $rs->all;
    is(scalar @children, 2, 'got right number of children');
    is($children[0],2, 'got right children id');
    is($children[1],3, 'got right children id');
    
    ok( my @a = $root->children, 'got children array');
    
    ok(my $child6 = $schema->resultset('DataPath')->find({Cid => 6}), 'get root');
    ok(my @anc6 = $child6->ancestors, 'got ancestors');
}
done_testing;
