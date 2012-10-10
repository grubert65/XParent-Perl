#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'XML::XParent' ) || print "Bail out!\n";
}

diag( "Testing XML::XParent $XML::XParent::VERSION, Perl $], $^X" );
