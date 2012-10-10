use 5.010;
use strict;
use warnings;
use Log::Log4perl qw( :easy );
use Test::More;
use XML::Twig;
use File::Path;
use DBI;

Log::Log4perl->easy_init( $DEBUG );

BEGIN {
    use_ok ( 'XML::XParent::Schema::DBIx' );
};

my $dbfile = './data/xparent.db';

my @drivers = DBI->available_drivers();

SKIP: {
    skip "SQLite driver not found", 17 unless ( 'SQLite' ~~ @drivers );

    #-------------------------------------------------------------
    # connect....
    #-------------------------------------------------------------
    ok (my $s=XML::XParent::Schema::DBIx->connect("dbi:SQLite:$dbfile"), 'connect');
    ok ( $s->clean(), 'clear datastore');
    
    #-------------------------------------------------------------
    # add a path to LabelPath table...
    #-------------------------------------------------------------
    ok (my $path_id = $s->add_label_path('/Mpeg7'), 'add_label_path');
    is ( $path_id, 1, 'got right data back');
    # check if returns existent path...
    ok ($path_id = $s->add_label_path('/Mpeg7'), 'add_label_path');
    is ( $path_id, 1, 'got right data back');
    
    #-------------------------------------------------------------
    # add a path id to the element table, see if ordinal 
    # increments while keep adding...
    #-------------------------------------------------------------
    ok ( my $elem_id = $s->add_element( $path_id, 1 ), 'add_element' );
    is ( $elem_id, 1, 'got right data back');

    #-------------------------------------------------------------
    # add element value...
    #-------------------------------------------------------------
    ok ( $s->add_value({
        Value   => 'foo', 
        Did     => $elem_id, 
        PathID  => $path_id,
        Ordinal => 1
    }), 'add_value');

    #-------------------------------------------------------------
    # add element attribute...
    #-------------------------------------------------------------
    ok( my $attr_id = $s->add_twig_attr(
        'foo',
        'bar',
        $elem_id,
        '/Mpeg7', 
        1
    ), 'add_twig_attr');
    #-------------------------------------------------------------
    # add a data path record...
    #-------------------------------------------------------------
    ok( $s->add_data_path( 0, 100 ), 'add_data_path');
}

done_testing;



