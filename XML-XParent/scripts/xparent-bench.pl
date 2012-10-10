#!/usr/bin/perl 
use strict;
use warnings;
use Benchmark qw( :hireswallclock cmpthese timethese);
use Getopt::Long qw( GetOptions);
use YAML qw(LoadFile);

use XML::XParent::Parser;
use XML::XParent::Schema;

my ( $file, $config_file );

GetOptions(
	"i=s"      => \$file,
	"config=s" => \$config_file
);

die "File not found or not readable" unless ( -e $file );
die "Config file not found " unless ( -e $config_file );
my $config = LoadFile($config_file);

my $res = timethese ( 5, {
    'DBI'       =>  sub { &parse(
                    'file'      => $file,
                    'driver'    => 'DBI',
                    'schema_params' => $config->{schema_params},
                    ) },
    'DBI-compact'   => sub { &parse(
                    'file'      => $file,
                    'driver'    => 'DBI',
                    'schema_params' => $config->{schema_params},
                    'compact'   => 1, 
                    ) },
    'DBIx'          => sub { &parse(
                    'file'      => $file,
                    'driver'    => 'DBIx',
                    'schema_params' => $config->{schema_params},
                    ) },
    'DBIx-compact'  => sub { &parse(
                    'file'      => $file,
                    'driver'    => 'DBIx',
                    'schema_params' => $config->{schema_params},
                    'compact'   => 1, 
                    ) },
} );

cmpthese( $res );

sub parse {
    my %params = @_;

    my $schema = XML::XParent::Schema->create(
    	-TYPE    => $params{driver},
    	-CONNECT => $params{schema_params}
    ) or die "Error connecting to an XParent data store";

    my $parser;
    if ( $params{compact} ) {
        require "XML/XParent/Parser/Compact.pm";
        $parser = XML::XParent::Parser::Compact->new( schema => $schema );
    } else {
        $parser = XML::XParent::Parser->new( schema => $schema );
    }

    $schema->clean();
    $parser->parse_file($params{file});
    $schema->flush_data();
    $schema->flush_datapath();
    $schema->disconnect();
}
