#!/usr/bin/env perl 
use XML::XParent::Schema ();
use Getopt::Long            qw( GetOptions);
use YAML                    qw( Load LoadFile );

our $schema;

my ( $file, $config, $driver, $config_file );

GetOptions( 
        "config=s"  => \$config_file,
        "driver=s"  => \$driver,
);

# if no configuration file is passed
# we read default configuration session
# you can copy the __DATA__ session
# in a separate YAML file to pass
# custom configuration params
if ( ! $config_file ) {
    $/ = undef;
    my $data = <DATA>;
    $config = Load( $data );
} else {
    die "Config file not found " unless ( -e $config_file );
    $config = LoadFile ( $config_file )
}

print "Going to delete records from dsn: $config->{ schema_params }->[0] \n";
$schema = XML::XParent::Schema->create ( 
    -TYPE       => $driver,
    -CONNECT    => $config->{ schema_params } 
) or die "Error connecting to an XParent data store";

$schema->clean();

__DATA__
---
schema_params:
    - 'dbi:SQLite:./xparent.db'
#    - grubert
#    - grubert


