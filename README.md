# Jump
Jump
====

Overview

Jump は、linuxコマンドライン環境にて使用する便利ツールです。
任意のディレクトリパスにニックネームをつけて保存し、またそれを呼び出してcdコマンドを実行します。
"ディレクトリを対象としたブックマーク機能" をイメージして頂けると幸いです。

## Description

Jump は、cdコマンドを補強する目的で作成しました。
コマンドラインでの作業中、あちこちのディレクトリに移動するのは骨が折れることです。
これをラクにすることが、Jumpコマンドの意義です。
例えば 'jump --add CURRENT' とすることで、現在のディレクトリを CURRENT という名前で保存します。
保存後は 'jump CURRENT' とすることで、いつでもそのディレクトリに移動することができます。
（その後、`jump --back` とすると、ひとつ前にいたディレクトリに戻れます）
また 'jump --path CURRENT' とすることで、ディレクトリを移動する代わりに CURRENT のパスを表示します。
これはスクリプト系の作業をする際に便利です。
登録したリストは 'jump --list' コマンド（もしくは単に 'jump'）で一覧できます。
実際、リストは "~/.jump" ファイルにテキストとして保存されているだけなので、これを直接編集することもできます。
（"#" を用いたコメントも記述できます）

## Status

Jump は、現在まだ作り込み途中のコマンドです。
作者は、実際にこのコマンドを自分の作業に用い、助けられています。
また、新しく欲しくなったオプションを思いつきで追加等している状態です。

## Demo

```
# いまいるのは、ホームディレクトリ
$ cd ~ ; pwd
> /home/Your/

# あるディレクトリに移動し、作業する
$ cd /etc/init.d && pwd
> /etc/init.d

# このディレクトリを、リストに追加
$ jump --add INIT `pwd`
$ jump --list
> INIT  /etc/init.d

# ホームディレクトリに帰ってくる
$ cd ~ ; pwd
> /home/Your/

# 先ほど登録したディレクトリに移動する
$ jump INIT ; pwd
> /etc/init.d

# 一つ前のディレクトリに帰ってくる
$ jump --back ; pwd
> /home/Your/


```

## VS.

T.B.D.

## Requirement

Jump は bash環境を前提として作られています。

## Usage

### 使い方／バージョンを見る

jump --version  # バージョンを確認します。
jump --usage    # 使い方を表示します。

### パスをリストに登録する

jump --add HOME # "HOME" という名称で、カレントディレクトリを登録します。（パスを省略した場合、カレントディレクトリを指定したことになります。
jump --add INIT /etc/init.d/ # もちろん、パスを指定することも可能です。この例では、 INIT という名称で /etc/init.d/ を登録します。

### リストを表示する

jump --list # 登録されているショートカットのリストを表示します。
jump # オプションを省略した場合、--list と同等の動きをします。

### リストを編集する

jump --modified # リストファイルをエディタで開き、直接編集します。（エディタは 環境変数JUMP_EDITOR で指定可能です）

### 指定パスに移動する

jump HOME # HOMEという名称で登録したパスに移動します。なお、リストがHOMEとHENGの２件で構成されている場合、'jump HO'でHOMEと特定し移動できます。

### ひとつ前のディレクトリに移動する

jump --back # 'cd -' と同じ感覚で、一つ前にジャンプしたディレクトリに移動します。

### 移動するのではなく、指定パスを標準出力する

jump --path HOME # 標準出力で、HOMEと名称づけられたパスを表示します。

### エイリアス設定

'/etc/profile.d/jump_init.sh' にて、エイリアスを定義しています。
alias j="jump"
alias jm="jump -m"  # Modify jumpfile.
alias jb="jump -b"  # Jump to the Back.
alias jp="jump -p"  # Show the path instead of change directory.

### 環境変数

JUMP_FILE：jumpコマンドが参照するリストファイルです。デフォルトおよび未定義時は ~/.jump となります。 
JUMP_BACK:「ひとつ前にjumpコマンドで移動したディレクトリのパス」を保持します。
JUMP_EDITOR: 編集モード（jump --modified）で起動するエディタを指定します。デフォルトはvimです。

### 作業ファイル
~/.jump
  jumpコマンドが参照／追記する、リストファイルです。
  手に馴染んだリストが出来上がったら、リポジトリ管理に組み込むと良いでしょう。
  （~/.jump は、デフォルトのリストファイルです。環境変数 JUMP_FILE を設定することで、他のファイルを参照することも可能です。）

~/.jump_backpath
  前回jumpコマンドにて移動したディレクトリパスを記録しておく一時ファイルです。

~/.jump_cdpath
  jump にてディレクトリ移動をするための作業ファイルです。

~/.jump_modified
  jump --modified にてエディタを起動するための作業ファイルです。

## Install

Jump を使う際は、以下の手順を踏んでください。
1. gitリポジトリをクローンし、プロジェクトリポジトリに移動する。
2. 'sudo make install' を実行。
3. シェルを再起動する（/etc/profile.d/ 配下を再読込するため）。
4. jump --version で結果を確認。

## Unnstall

1. gitリポジトリをクローンし、プロジェクトリポジトリに移動する。
2. 'make cleanup' を実行。
  ホームディレクトリ配下の作業ファイルが削除される。（省略しても良い）
3. 'sudo make uninstall' を実行。
4. シェルを再起動する。

## Contribution

-

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[tcnksm](https://github.com/tcnksm)

