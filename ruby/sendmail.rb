# coding: utf-8

require "mail"
require "mail-iso-2022-jp"

# 送信設定をセット
Mail.defaults do
 delivery_method :smtp, {
     :address => "example.com",
     :port => 465,
     :domain => "example.com",
     :user_name => "hoge@example.com",
     :password => "*******",
     :authentication => "login",
     :openssl_verify_mode => "none",
     :ssl => true
 }
end

# メール送信
Mail.new(:charset => 'ISO-2022-JP') do
 from "from@example.com"
 to "to@example.com"
 subject "rubyスクリプトでメール送信テスト"
 body "本文"
end.deliver

__END__
