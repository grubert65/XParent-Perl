#!/usr/bin/perl 
use strict;
use warnings;
use XML::XParent::Schema ();
use XML::XParent::Elem   ();
use YAML                 qw( LoadFile );
use Getopt::Long         qw( GetOptions );
use Log::Log4perl        qw( :easy );
use Time::HiRes          qw(gettimeofday tv_interval);

Log::Log4perl->easy_init($DEBUG);

my ( $config, $config_file, $driver, $path );

die(
"Usage: $0 --driver <Schema driver> --path <path> [--config <config file>]\n"
  ) unless (@ARGV);

GetOptions(
    "path=s"    => \$path,
	"driver=s"  => \$driver,
	"config=s"  => \$config_file
);

# if no configuration file is passed
# we read default configuration session
# you can copy the __DATA__ session
# in a separate YAML file to pass
# custom configuration params
if ( !$config_file ) {
	$/ = undef;
	my $data = <DATA>;
	$config = Load($data);
}
else {
	die "Config file not found " unless ( -e $config_file );
	$config = LoadFile($config_file);
}

my $schema = XML::XParent::Schema->create(
	-TYPE    => $driver,
	-CONNECT => $config->{schema_params}
  )
  or die "Error connecting to an XParent data store";

my $t0 = [gettimeofday];
my $elems = $schema->get_elem( $path );
my $t1 = [gettimeofday];
my $t0_t1 = tv_interval $t0, $t1;
print "Execution time: $t0_t1 with driver $driver\n";

foreach my $elem ( @$elems ) {
    $elem->dump();
}

__DATA__
---
schema_params:
    - 'dbi:SQLite:./xparent.db'
#    - grubert
#    - grubert
