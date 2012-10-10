use strict;
use warnings;
use Test::More; 

BEGIN {
    use_ok('XML::XParent::Parser');
    use_ok('XML::XParent::Parser::Plugin');
}

ok (my $parser=XML::XParent::Parser->new( 
    verbose=> 1,
    plugins => {
        'XML::XParent::Parser::Plugin' => {
            'tag' => '_all_',
        }
    }), 'new');
ok ($parser->parse_file('./scripts/test.xml'), 'parse_file');

done_testing;

