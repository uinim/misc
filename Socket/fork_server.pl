#!/usr/bin/perl -w

# $Id: echo-server-fork.pl,v 1.2 2002/02/17 11:07:27 68user Exp $

use Socket;
$port = 5000;

# ソケット生成
socket(CLIENT_WAITING, PF_INET, SOCK_STREAM, 0)
     or die "ソケットを生成できません。$!";

# ソケットオプション設定
setsockopt(CLIENT_WAITING, SOL_SOCKET, SO_REUSEADDR, 1)
     or die "setsockopt に失敗しました。$!";

# ソケットにアドレス(＝名前)を割り付ける
bind(CLIENT_WAITING, pack_sockaddr_in($port, INADDR_ANY))
     or die "bind に失敗しました。$!";

# ポートを見張る
listen(CLIENT_WAITING, SOMAXCONN)
     or die "listen: $!";

print "親プロセス($$): ポート $port を見張ります。\n";

# while(1)することで、1つの接続が終っても次の接続に備える
while (1){
    $paddr = accept(CLIENT, CLIENT_WAITING);

    # ホスト名、IPアドレス、クライアントのポート番号を取得
    ($client_port, $client_iaddr) = unpack_sockaddr_in($paddr);
    $client_hostname = gethostbyaddr($client_iaddr, AF_INET);
    $client_ip = inet_ntoa($client_iaddr);

    print "接続: $client_hostname ($client_ip) ポート $client_port\n";

    # forkで子プロセスを生成
    if ( $pid = fork() ){
        # こちらは親プロセス
        print "親プロセス($$): 引続きポート $port を見張ります。\n";
        print "親プロセス($$): クライアントの相手はプロセス $pid が行います。\n";

        # 親プロセスはソケットをクローズ
        close(CLIENT);
        next;
    } else {
        # こっちは子プロセス

        # クライアントに対してバッファリングしない
        #select(CLIENT); $|=1; select(STDOUT);
        while (<CLIENT>){
            print "子プロセス($$): メッセージ $_";
            # クライアントにメッセージを返す
            print CLIENT $_;
        }
        close(CLIENT);
        print "子プロセス($$): 接続が切れました。終了します。\n";
        # ポートの監視は親プロセスが行っているので、
        # クライアントとのやりとりが終了すれば exit
        exit;
    }
}
