#!/usr/bin/perl

use strict;
use warnings;

use lib qw(./lib);
use Common;
use Define;

# debug
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;

# オブジェクト生成
my $common = Common->new();

# メイン処理
sub main;
exit main();

sub main {
    
    # テンプレート初期値をセット
    my $template = "TEMPLATE_INDEX";
    
    # データ取得
    my %in = $common->getQuery;
    
    if ($in{'search'} eq 'artist') {
        # URLエンコード
        $in{'keyword'} = $common->Encode_URL($in{'keyword'});
        
        # データ取得
        my $uri = $common->define->{API_SEARCH_ARTIST} . $in{'keyword'};
        my @data = getArtistList($uri);
        
        # Pager処理
        my @pager = makePager(\@data, $common->define->{PAGER_COUNT});
        $in{'pager'} = \@pager;
        $in{'page'}  = 1 if (!$in{'page'});
        
        # データセット
        $in{'all_count'} = @data;
        if ($common->define->{PAGER_COUNT} < $#data) {
            @data = splitDataForPage(\@data, $in{'page'}, $common->define->{PAGER_COUNT});
        }
        $in{'data'} = \@data;
        
        $template = "TEMPLATE_SEARCH_ARTIST_LIST";
    }
    elsif ($in{'search'} eq 'artist_detail') {
        # データ取得
        my $uri = $common->define->{API_SEARCH_ARTIST_DETAIL} . $in{'artist_id'};
        my @data = getArtistDetailList($uri);
        
        # Pager処理
        my @pager = makePager(\@data, $common->define->{PAGER_COUNT});
        $in{'pager'} = \@pager;
        $in{'page'}  = 1 if (!$in{'page'});
        
        # データセット
        $in{'all_count'} = @data;
        if ($common->define->{PAGER_COUNT} < $#data) {
            @data = splitDataForPage(\@data, $in{'page'}, $common->define->{PAGER_COUNT});
        }
        $in{'data'} = \@data;
        $in{'artist_name'} = $data[0]->{'artist_name'};
        
        $template = "TEMPLATE_SEARCH_ARTIST_DETAIL_LIST";
    }
    
    # データセット
    my $vars = {
        form  => \%in,
    };
    
    # HTML出力
    $common->HtmlOutput($common->define->{$template}, $vars);
}

# ------------------------------------------------------------------------------
#   説　明：アーティスト情報の取得
#   引　数：
#   戻り値：
# ------------------------------------------------------------------------------
sub getArtistList {
    my $uri  = shift;
    my @data;
    
    my $dom = $common->XML_Parse($uri);
    
    foreach my $node ($dom->findnodes('result')) {
        push @data, {
            artist_id   => $common->Encode_UTF8($node->findvalue('@artist_id')),
            artist_name => $common->Encode_UTF8($node->findvalue('@artist_name')),
        };
    }
    return @data;
}

# ------------------------------------------------------------------------------
#   説　明：アーティスト詳細情報の取得
#   引　数：
#   戻り値：
# ------------------------------------------------------------------------------
sub getArtistDetailList {
    my $uri  = shift;
    my @data;
    
    my $dom = $common->XML_Parse($uri);
    
    foreach my $node ($dom->findnodes('result')) {
        push @data, {
            artist_name  => $common->Encode_UTF8($node->findvalue('@artist_name')),
            downloadable => $common->Encode_UTF8($node->findvalue('@downloadable')),
            album        => $common->Encode_UTF8($node->findvalue('@album')),
            track        => $common->Encode_UTF8($node->findvalue('@track')),
        };
    }
    
    return @data;
}

# ------------------------------------------------------------------------------
#   説　明：アーティスト詳細情報の取得
#   引　数：
#   戻り値：
# ------------------------------------------------------------------------------
sub splitDataForPage {
    my @data = shift;
    my $page = shift;
    my $unit = shift;
    my @result;
    
    my ($max, $init);
    if ($page <= 1) {
        $init = 0;
        $max  = $unit;
    } else {
        $init = ($page -1) * $unit;
        $max  = $page * $unit;
    }
    
    for (my $i = $init; $i < $max; $i++) {
        push @result, $data[0]->[$i];
    }
    
    return @result;
}

# ------------------------------------------------------------------------------
#   説　明：Pagerの作成
#   引　数：
#   戻り値：
# ------------------------------------------------------------------------------
sub makePager {
    my @data = shift;
    my $unit = shift;
    my @result;
    
    my $all = @{ $data[0] };
    for (my $i = 1; $i <= $common->dataAdvancing($all / $unit); $i++) {
        push @result, $i;
    }
    
    return @result;

}

exit;