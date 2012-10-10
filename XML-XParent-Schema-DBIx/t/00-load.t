#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'XML::XParent::Schema::DBIx' ) || print "Bail out!\n";
}

diag( "Testing XML::XParent::Schema::DBIx $XML::XParent::Schema::DBIx::VERSION, Perl $], $^X" );
