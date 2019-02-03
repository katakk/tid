# tid [![Build Status](https://travis-ci.org/katakk/tid.svg?branch=master)](https://travis-ci.org/katakk/tid) [![codecov.io](https://codecov.io/github/katakk/tid/coverage.svg?branch=master)](https://codecov.io/github/katakk/tid?branch=master)

しょぼいカレンダーのTIDからアニメタイトル引っ張ってくるやつ
[http://cal.syoboi.jp/db.php](https://sites.google.com/site/syobocal/spec/db-php)

アクセスする前に一度SQLite3にあるかどうか問い合わせてなければしょぼカルに問い合わせ。
表示はcp932

## インストール

    # sudo apt install libwww-perl libxml-perl libxml-simple-perl libdbi-perl libdbd-pg-perl libdbd-sqlite3-perl

    $ chmod 755 ./tid 
    $ cp ./tid /usr/local/bin/
    
       
## 使い方

    $ tid 3893
    ご注文はうさぎですか？？
    $ tid 3324 3893
    ご注文はうさぎですか？
    ご注文はうさぎですか？？
    $ cd /home/foltia/php/tv/3324.localized/mp4
    $ tid *
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    
    
