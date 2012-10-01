package Define;

use strict;
use warnings;

my $vars = {
    # テンプレートディレクトリ
    TEMPLATE_DIR => "./template",
    
    # テンプレートHTML
    TEMPLATE_INDEX                     => "index.html",
    TEMPLATE_SEARCH_ARTIST_LIST        => "search_artist_list.html",
    TEMPLATE_SEARCH_ARTIST_DETAIL_LIST => "search_artist_detail_list.html",
    
    # Napster API
    API_SEARCH_ARTIST        => "http://www.napster.jp/music/searchXML/artist/",
    API_SEARCH_ARTIST_DETAIL => "http://www.napster.jp/music/lookupXML/artist/",
    
    # Split Page Number
    PAGER_COUNT => 20,
};

sub new { return bless $vars, shift; }

1;