package XML::XParent;

use 5.006;
use strict;
use warnings;

=head1 NAME

XML::XParent - A perl module to store XML document on a DBMS schema.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

    use XML::XParent;

    # programmatic usage to load an xml document...
    use XML::XParent::Parser ();
    use XML::XParent::Schema ();

    my $schema = XML::XParent::Schema->connect ( $dsn );
    my $parser = XML::XParent::Parser->new( 
        schema => $schema,
        verbose=> 1 
        );
    $parser->parse_file('./scripts/test.xml');

    # ...or via utility scripts....
    perl xparent-parse.pl [--config="/path/to/config/file"] [--verbose] -i=/path/to/xml/file

    # programmatic usage to query a stored xml document...
    my $o = XML::XParent::Schema->connect( $dsn )
        or die "Error getting an XML::XParent::Schema object: $@";

    my $xmlResult = $o->get_elem($XPath_query);

    #....or via utility script....
    perl xparent-query.pl [--config="/path/to/config/file"] "XPath query"

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head1 AUTHOR

Marco Masetti, C<< <marco.masetti at softeco.it> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-xparent at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-XParent>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::XParent


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-XParent>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-XParent>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-XParent>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-XParent/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Marco Masetti.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of XML::XParent
