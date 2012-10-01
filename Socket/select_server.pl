#!/usr/bin/perl -w

use strict;
no strict 'refs';
use warnings;

use Socket;

my $port = 5000;
my $socket_receiver = "CLIENT_WAITING"; #"CLIENT_WAITING"

# ソケット生成
socket($socket_receiver, PF_INET, SOCK_STREAM, 0) or die "ソケットを生成できません。$!";

# ソケットオプション設定
setsockopt($socket_receiver, SOL_SOCKET, SO_REUSEADDR, 1) or die "setsockopt に失敗しました。$!";

# ソケットにアドレス(＝名前)を割り付ける
bind($socket_receiver, pack_sockaddr_in($port, INADDR_ANY)) or die "bind に失敗しました。$!";

# ポートを見張る
listen($socket_receiver, SOMAXCONN) or die "listen: $!";

print "ポート $port を見張ります。\n";

my %data_sockets = ();  # 現在有効なデータコネクション用のハッシュテーブル
my $client_num = 0;     # クライアントの通し番号

my $rin = &set_bits($socket_receiver);  # ビット列を生成

while (1) {
    my $ret = select(my $rout = $rin, undef, undef, undef);
    printf("\$ret=$ret \$rout=%s,\$rin=%s\n", &to_bin($rout), &to_bin($rin));
    
    if ( vec($rout, fileno($socket_receiver), 1) ){   # 新たにクライアントがやってきた

        # ソケット名は毎回違う名前にする
        my $new_socket = sprintf("CLIENT_%s", $client_num);
        my $sockaddr = accept($new_socket, $socket_receiver);

        # ホスト名、IPアドレス、クライアントのポート番号を取得
        my ($client_port, $client_iaddr) = unpack_sockaddr_in($sockaddr);
        my $client_hostname = gethostbyaddr($client_iaddr, AF_INET);
        my $client_ip = inet_ntoa($client_iaddr);

        print "接続: $client_hostname ($client_ip) ポート $client_port\n";
        print "ソケット $new_socket を生成します。\n";

        # クライアントに対してバッファリングしない
        select($new_socket); $|=1; select(STDOUT);

        # 接続中のクライアントをテーブルに登録
        $data_sockets{$new_socket} = 1;

        # select に渡すビット列を更新
        $rin = &set_bits($socket_receiver, keys %data_sockets);
        $client_num++;

    } elsif ( $ret ){ # 接続中のクライアントから、データが送信されてきた

        my $in;
        foreach my $sock ( sort keys %data_sockets ){  # どのクライアントかを一つずつ確かめる
            print "  check... $sock\n";
            
            if ( vec($rout, fileno($sock), 1) ){
                if ( $in = <$sock> ){            # 1行読んでそのまま返す
                    print "    $sock からの入力 .. $in";
                    #print $sock "$in";
                } else {                         # エラー発生＝コネクション切断
                    print "    コネクション切断 $sock\n";
                    close($sock);                # ファイルハンドルを close
                    delete $data_sockets{$sock}; # テーブルから削除
                    # select に渡すビット列を更新
                    $rin = &set_bits($socket_receiver, keys %data_sockets);
                }
            }
        }
        
        # 疑似ブロードキャストのためのコード
        if ($in){
            foreach my $sock ( sort keys %data_sockets ){
                print $sock "broadcast: $in";
            }
        }
    }
}

#----------------------------------------------------
# 1個以上のファイルハンドルを受け取り、fileno で各ファイルハンドルの
# ディスクリプタ番号を調べ、それに対応するビットを立てたデータを返す。
# 例えば
#   fileno(CLIENT_WAITING) == 3
#   fileno(CLIENT_1)      == 4
#   fileno(CLIENT_3)      == 6
# のとき、
#   &set_bits(CLIENT_WAITING, CLIENT_1, CLIENT_3)
# は
#   01011000
# というデータを返す。

sub set_bits {
    my @sockets = @_;

    print "select に渡すビット列 \$rin を生成します。\n";
    my $rin = "";
    foreach my $sock (@sockets){
        # $rin の、右から数えて fileno($sock) 番目のビットを1にする。
        vec($rin, fileno($sock), 1) = 1;
        printf("  fileno($sock) は %d なので \$rin は %s になります。\n",
               fileno($sock),
               &to_bin($rin),
              );
    }
    return $rin;
}


#----------------------------------------------------
# 引数を受け取り、2進数の文字列(010111...)に変換して返す。

sub to_bin {
    return unpack "B*", $_[0];
}
