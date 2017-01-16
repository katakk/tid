# tid [![Build Status](https://travis-ci.org/katakk/tid.svg?branch=master)](https://travis-ci.org/katakk/tid) [![codecov.io](https://codecov.io/github/katakk/tid/coverage.svg?branch=master)](https://codecov.io/github/katakk/tid?branch=master)

しょぼいカレンダーのTIDからアニメタイトル引っ張ってくるやつ

アクセスする前に一度ローカルdbにあるかどうか問い合わせてなければ問い合わせ。

    tid.db を読みます。
    なければ tid を問い合わせます。httpで
    tid.db を保存
    
   
## インストール

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
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
    ご注文はうさぎですか？
