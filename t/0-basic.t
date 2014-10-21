#!/usr/bin/env perl

use strict;
use Test::More tests => 14;

use_ok('WWW::Scraper::ISBN::TWSrbook_Driver');

ok($WWW::Scraper::ISBN::TWSrbook_Driver::VERSION) if $WWW::Scraper::ISBN::TWSrbook_Driver::VERSION or 1;

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

$scraper->drivers("TWSrbook");
my $isbn = "9864175351";
my $record = $scraper->search($isbn);

SKIP: {
	skip($record->error."\n", 11) unless($record->found);

	is($record->found, 1);
	is($record->found_in, 'TWSrbook');

	my $book = $record->book;
	is($book->{'isbn'}, '9864175351');
	is($book->{'title'}, '�Ů������ж}�еL�H�v�������s����');
	is($book->{'author'}, '������B���B��');
	is($book->{'pages'}, '368');
	is($book->{'book_link'}, 'http://www.srbook.com.tw/web/showbook.dox?id=9864175351');
	is($book->{'image_link'}, 'http://www.srbook.com.tw/web/show_pic_s.dox?id=9864175351');
	is($book->{'pubdate'}, '�褸2005�~08��');
	is($book->{'publisher'}, '�ѤU');
	is($book->{'price_list'}, '450');
}
