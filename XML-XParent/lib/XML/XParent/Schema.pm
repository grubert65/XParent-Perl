package XML::XParent::Schema;
#============================================================= -*-perl-*-

=head1 NAME

XML::XParent::Schema - Interface class that implements the XParent model. 

=head2 SYNOPSIS

    use XML::XParent::Schema ();

    my $schema = XML::XParent::Schema->create( -TYPE => 'DBI', -CONNECT => [...] )
        or die ("Error getting the DBI driver");

=head2 DESCRIPTION

Base interface class. Should be used to get a driver object back.
Implements the Driver/Interface pattern.

=head2 EXPORT

None by default.

=head2 SUPPORT

You can find documentation for this module with the perldoc command:

    perldoc <module>

=head2 AUTHOR

Marco Masetti <masetti at linux dot it>

=head2 COPYRIGHT and LICENSE

Copyright (C) 2012, Marco Masetti.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose

=head1 FUNCTIONS

=cut

#========================================================================
use Moose::Role;
use vars qw($VERSION);
use Carp;
use Data::Dumper qw( Dumper );
$VERSION = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf "%d."."%d"x$#r,@r };

#=============================================================

=head2 create

=head3 INPUT

    -TYPE   : the driver type the caller wants back
    @params : (not mandatory) parameters passed to driver constructor

=head3 OUTPUT

A driver type object.

=head3 DESCRIPTION

Just creates and gives back a driver object...

=cut

#=============================================================
sub create {
    my $package = shift;
    my ($params) = rearrangeAsHash([-TYPE, -CONNECT],[-TYPE],@_);
    my $type = $params->{-TYPE};

    my $class = getDriver($package, $type) or
        Carp::croak("$package type '$type' is not supported");
            
    # hand-off to specific implementation sub-class
    $class->connect( @{ $params->{-CONNECT} } );
}

#=============================================================

=head2 rearrangeAsHash

=head3 INPUT

$ra_order       : arrayref of ordered parameters
$ra_required    : arrayref or required parameters
@param          : array of input params

=head3 OUTPUT

ARRAY ($out_hash, @leftover)

=head3 DESCRIPTION

Takes the input array and tries to rearrange as an hash, 
keeping first param as a list of ordered keys, the second as
a list of required keys, warns if required are missing.

=cut

#=============================================================
sub rearrangeAsHash {
    my ($ra_order, $ra_required, @param) = @_;

    my %return_hash;
    my @leftover;

    if (@param % 2) {
        confess("An even number of named parameters were not " .
                "passed. Perhaps you forgot a comma between " .
                "one of them. Here is the list: " . 
                join(",\n" , @param));
    }

    my %known;
    @known{@$ra_order} = ();
    my %param_hash = @param;
    @return_hash{@$ra_order} = @param_hash{@$ra_order};
    my $key;
    foreach $key (grep { !exists($known{$_}) } keys %param_hash) {
        push @leftover, $key, $param_hash{$key};
    }

    my @missing = grep { !defined($return_hash{$_}) } @$ra_required;
    __required(\@missing, $ra_order, \@param) if @missing;

    return (\%return_hash, @leftover);
}

#=============================================================

=head2 getDriver

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

Gets a driver object out of a driver type.
User by the DriverInterface pattern

=cut

#=============================================================
sub getDriver {
    my $driver_type   = shift;
    my $driver_source = shift;

    # --- load the code
    eval "use ${driver_type}::$driver_source;";
    if ($@) {
        my $advice = "";
        if ($@ =~ /Can't find loadable object/) {
           $advice = "Perhaps ${driver_type}::$driver_source was statically "
                 . "linked into a new perl binary."
                 . "\nIn which case you need to use that new perl binary."
                 . "\nOr perhaps only the .pm file was installed but not "
                 . "the shared object file."
        }
        elsif ($@ =~ /Can't locate.*?$driver_type\/$driver_source\.pm/) {
          $advice = "Perhaps the ${driver_type}::$driver_source perl module "
                     . "hasn't been installed,\n"
                     . "or perhaps the capitalization of '$driver_source' "
                     . "isn't right.\n";
        }
        Carp::croak("_getDriver() failed: $@: $advice\n");
    }

    "${driver_type}::$driver_source";
} 

#=============================================================

=head2 __required

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

__required complains about required parameters not
being passed properly to _rearrange methods.

=cut

#=============================================================
sub __required {
    my $ra_required_params = shift;
    my $ra_order           = shift;
    my $params             = shift;

    my $error = "";

    my $required;
    foreach $required (@$ra_required_params) {
        if ($required eq "0") {
            croak("One of your required params was a 0. This usually means " .
                  "that you forgot a comma between two parameters so " .
                  "that one of the -PARAM values looks like the string " .
                  "PARAM is being subtracted from the prior value in the " .
                  "list of parameters. Go back and check that you properly " .
                  "delimited all your paramter -PARAM => VALUE pairs with " .
                  "commas");
        }
        $error .= 
           "Required Parameter: $required was missing from a method call!\n";
    }
    $error .= "Possible Parameters Are: " . join(",\n\t", @$ra_order) . ".\n";

    if ( $params ) {
        $error .= "\nThis is what passed:\n";
        $error .= Dumper ( $params );
    }

    confess($error);

} # end of __required

#=============================================================

=head2 flush_data

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

In case the driver caches records for the Data table,
should implement this method to flush queued records at 
process end.

=cut

#=============================================================
sub flush_data { return 1; };

#=============================================================

=head2 flush_datapath

=head3 INPUT

=head3 OUTPUT

=head3 DESCRIPTION

In case the driver caches records for the DataPath table,
should implement this method to flush queued records at 
process end.

=cut

#=============================================================
sub flush_datapath { return 1; };

1;
