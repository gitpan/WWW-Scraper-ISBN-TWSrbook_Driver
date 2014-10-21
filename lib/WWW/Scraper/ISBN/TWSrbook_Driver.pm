# ex:ts=8

package WWW::Scraper::ISBN::TWSrbook_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.01';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::TWSrbook_Driver - Search driver for TWSrbook's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the TWSrbook's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;

use Data::Dumper;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	QUERY	=> 'http://www.srbook.com.tw/web/showbook.dox?id=%s';

#--------------------------------------------------------------------------

###########################################################################
#Inheritence                                                              #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Srbook
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  title
  author
  pages
  book_link
  image_link
  pubdate
  publisher
  price_list
  price_sell

The book_link and image_link refer back to the Books website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $url = sprintf(QUERY, $isbn);
	my $mechanize = WWW::Mechanize->new();
	$mechanize->get( $url );
	return undef unless($mechanize->success());

	# The Search Results page
	my $template = <<END;
<STRONG>[% title %]</STRONG>[% ... %]
�@�̡G[% ... %]<FONT size=2> [% author %]��</FONT>[% ... %]
ISBN�X�G</FONT><FONT size=2> [% isbn %]</FONT>[% ... %]
�X�����G[% ... %]<FONT size=2> [% publisher %]</FONT>[% ... %]
���ơG[% ... %]<FONT size=2> [% pages %]</FONT>[% ... %]
�w���G[% ... %]<FONT size=2> [% price_list %]</FONT>[% ... %]
�S���G[% ... %]<FONT size=4 color=red>[% price_sell %]</FONT>[% ... %]
�X���~��G[% ... %]<FONT size=2> [% pubdate %] </FONT>
END

	my $extract = Template::Extract->new;
	my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from TWSrbook result page.")
		unless(defined $data);

	$data->{price_sell} =~ s/^\$\s*(\d+)\s*$/$1/;

	my $bk = {
		'isbn'		=> $data->{isbn},
		'title'		=> $data->{title},
		'author'	=> $data->{author},
		'pages'		=> $data->{pages},
		'book_link'	=> $mechanize->uri(),
		'image_link'	=> "http://www.srbook.com.tw/web/show_pic_s.dox?id=$isbn",
		'pubdate'	=> $data->{pubdate},
		'publisher'	=> $data->{publisher},
		'price_list'	=> $data->{price_list},
		'price_sell'	=> $data->{price_sell},
	};

	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

=head1 COPYRIGHT

Copyright (C) 2005 Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
