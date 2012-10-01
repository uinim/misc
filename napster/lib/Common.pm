package Common;

use strict;
use warnings;

use lib qw( /path/to/lib );
use CGI;
use Template;
use XML::LibXML;
use Encode;
use POSIX;
use Define;

# debug
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
        define => Define->new(),
        cgi    => CGI->new(),
        libxml => XML::LibXML->new(),
    };
    return bless $self, $class;
}

sub define {
    my $self = shift;
    return $self->{define};
}

sub cgi {
    my $self = shift;
    return $self->{cgi};
}

sub libxml {
    my $self = shift;
    return $self->{libxml};
}

# ------------------------------------------------------------------------------
#   説　明：フォームデータの取得
#   引　数：-
#   戻り値：フォームデータのハッシュ
# ------------------------------------------------------------------------------
sub getQuery {
    my $self = shift;
    return $self->cgi->Vars;
}

# ------------------------------------------------------------------------------
#   説　明：HTTPヘッダー出力
#   引　数：-
#   戻り値：HTTPヘッダー
# ------------------------------------------------------------------------------
sub header {
    my $self = shift;
    print "Content-type: text/html" . "\n\n";
}

# ------------------------------------------------------------------------------
#   説　明：HTMLファイル出力
#   引　数：テンプレートファイル, 値
#   戻り値：HTML出力
# ------------------------------------------------------------------------------
sub HtmlOutput {
    my $self = shift;
    my ($template, $vars) = @_;
    
    my $config = {
        INCLUDE_PATH => $self->define->{TEMPLATE_DIR},
        INTERPOLATE  => 1,
        POST_CHOMP   => 1,
        EVAL_PERL    => 1,
    };
    my $tt = Template->new($config);
    
    my $output;
    $tt->process($template, $vars, \$output) || die $tt->error();
    
    $self->header;
    print $output;
}

# ------------------------------------------------------------------------------
#   説　明：XMLDOMの取得
#   引　数：XMLファイルパス
#   戻り値：libxmlインスタンス
# ------------------------------------------------------------------------------
sub XML_Parse {
    my $self = shift;
    my $uri  = shift;
    
    my $dom  = $self->libxml->parse_file($uri);
    return $dom->getDocumentElement;
    
}

# ------------------------------------------------------------------------------
#   説　明：URLエンコード
#   引　数：文字列
#   戻り値：エンコード後文字列
# ------------------------------------------------------------------------------
sub Encode_URL {
    my $self = shift;
    my $str  = shift;
    $str =~ s/\s/+/g;
    $str =~ s/([^\w])/sprintf("%%%02X", unpack("C", $1))/eg;
    return $str;
}

# ------------------------------------------------------------------------------
#   説　明：URLエンコード
#   引　数：文字列
#   戻り値：エンコード後文字列
# ------------------------------------------------------------------------------
sub Encode_UTF8 {
    my $self = shift;
    my $str  = shift;
    return Encode::encode('utf8', $str);
}

# ------------------------------------------------------------------------------
#   説　明：値の繰上げ
#   引　数：値
#   戻り値：繰上げ後値
# ------------------------------------------------------------------------------
sub dataAdvancing {
    my $self = shift;
    return ceil(@_);
}

1;
