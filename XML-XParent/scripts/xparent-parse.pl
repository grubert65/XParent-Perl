#!/usr/bin/env perl 
use Modern::Perl;
use XML::Twig;
use XML::XParent::Schema;
use XML::XParent::Parser;
use Getopt::Long qw( GetOptions);
use YAML qw( Load LoadFile );
use Log::Log4perl qw( :easy );
use Time::HiRes qw(gettimeofday tv_interval);

our $elt_num = 0;
our $schema;
our $driver  = 'DBI';
our $verbose = 0;
our $compact = 0;
our $clean   = 0;

Log::Log4perl->easy_init($DEBUG);

my ( $file, $config, $config_file );

die(
"Usage: $0 -i <xml file> --driver <Schema driver> [--config <config file>] [--verbose] [--compact] [--clean]"
  ) unless (@ARGV);

GetOptions(
	"i=s"      => \$file,
	"driver=s" => \$driver,
	"verbose"  => \$verbose,
	"compact"  => \$compact,
	"clean"    => \$clean,
	"config=s" => \$config_file
);

die "File not found or not readable" unless ( -e $file );

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

$schema = XML::XParent::Schema->create(
	-TYPE    => $driver,
	-CONNECT => $config->{schema_params}
  )
  or die "Error connecting to an XParent data store";
$schema->clean() if ($clean);

my $parser;
if ($compact) {
	require "XML/XParent/Parser/Compact.pm";
	$parser = XML::XParent::Parser::Compact->new(
		schema  => $schema,
		verbose => $verbose,
	);
}
else {
	$parser = XML::XParent::Parser->new(
		schema  => $schema,
		verbose => $verbose,
        plugins => $config->{plugins},
	);
}

my $t0 = [gettimeofday];
$parser->parse_file($file);
$schema->flush_data(); # TODO SADECKI
$schema->flush_datapath(); # TODO SADECKI
my $t1 = [gettimeofday];
my $t0_t1 = tv_interval $t0, $t1;
print "Execution time: $t0_t1 with driver $driver\n";

__DATA__
---
schema_params:
    - 'dbi:SQLite:./xparent.db'
#    - grubert
#    - grubert
plugins:
    'SLMS::Redis::ParserPlugin': 
        'tag': 'MovingRegion'

