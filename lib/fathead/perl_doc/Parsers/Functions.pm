#!/usr/bin/env perl
use strict;
use warnings;
binmode STDOUT, ":utf8";
use IO::All;
use Mojo::DOM;
use Data::Dumper;
use Term::ProgressBar;
use Cwd qw( getcwd );
use Util qw( get_row trim_abstract);

my @pages = glob(getcwd(). "/../download/functions/*.html");
my $skip = qr/To get the best experience. |Please note: Many features/;

foreach my $page (@pages){
    my $html < io($page);
    $html =~ s/\Q<a.+?href=".+?>(.+)<\/>\E/$1/g;
    $html =~ s/<strong>//g;
    $html =~ s/<\/strong>//g;

    my $dom = Mojo::DOM->new($html);

    my $title = $dom->at('title')->text;
    $title =~ s/\s-\s.*//;

    my $hint = $dom->at('b')->text;

    $dom = $dom->at('div[id="content_body"]');

    my $description;
    foreach my $n ($dom->find('p')->each){
        next unless $n->content;
        next if $n->content =~ /$skip/;
        $description .= $n->content;
    }
    $description = trim_abstract($description, 100);

    $page =~ s/^.*download\///;
    $page =~ s/\.html$//;

    printf("%s\n", get_row($title, $description, "http://perldoc.perl.org/$page", 'A'));
}
