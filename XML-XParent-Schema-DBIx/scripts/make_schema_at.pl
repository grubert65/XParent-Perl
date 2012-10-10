#!/usr/bin/env perl 
use strict;
use warnings;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $dbfile = '../data/xparent.db';

unlink $dbfile;

if ( not -e $dbfile ) {
    `sqlite3 $dbfile < ./sqlite/xparent.sql`;
}

make_schema_at(
    'XML::XParent::Schema::DBIx',
    { debug                     => 1,
      dump_directory            => '../lib',
      overwrite_modifications   => 1,
      skip_load_external        => 1,
      preserve_case             => 1,   #Usually column names are lowercased, this prevents this...

    },
    [ "dbi:SQLite:$dbfile" ],
);

