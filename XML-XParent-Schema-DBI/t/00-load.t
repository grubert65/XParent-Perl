#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'XML::XParent::Schema::DBI' ) || print "Bail out!\n";
}

diag( "Testing XML::XParent::Schema::DBI $XML::XParent::Schema::DBI::VERSION, Perl $], $^X" );
