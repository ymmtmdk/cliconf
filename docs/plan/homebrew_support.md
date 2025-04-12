# Homebrew対応計画

## 1. 目的

`cliconf` を Homebrew を使って簡単にインストールできるようにする。

## 2. 方針

-   Homebrew Formula (`cliconf.rb`) を作成する。
-   Formula は `cliconf` のインストールと基本的な設定情報の提供を行う。
-   ユーザーのホームディレクトリへの直接的なファイル配置や設定変更は行わない。
-   シェル統合や設定ファイルの配置は、インストール後のメッセージ (`caveats`) でユーザーに案内する。

## 3. Homebrew Formula (`cliconf.rb`) の作成

以下の内容を含む Formula を作成します。

```ruby
# Formula/cliconf.rb
class Cliconf < Formula
  desc "Hierarchical Configuration Management Framework for Command-line Tools"
  homepage "https://github.com/ymmtmdk/cliconf"
  # ↓↓↓ リリース作成後に実際のURLとsha256に置き換える ↓↓↓
  url "https://github.com/ymmtmdk/cliconf/archive/refs/tags/v0.1.0.tar.gz" # 仮のバージョン
  sha256 "..." # 仮のハッシュ値
  # ↑↑↑ リリース作成後に実際のURLとsha256に置き換える ↑↑↑
  license "MIT"

  depends_on "bash" => :run # 実行時依存

  def install
    # メインスクリプトをインストール
    bin.install "cliconf.sh" => "cliconf"

    # シェル統合スクリプトをインストール
    (share/"cliconf/scripts").install "scripts/cliconf_integrate.bash", "scripts/cliconf_integrate.fish"

    # サンプル設定ファイルをインストール
    (share/"cliconf/examples").install Dir["examples/.*.conf"]
  end

  def caveats
    <<~EOS
      Add the following line to your shell configuration file:

      Bash (~/.bashrc):
        source "#{opt_share}/cliconf/scripts/cliconf_integrate.bash"

      Fish (~/.config/fish/config.fish):
        source "#{opt_share}/cliconf/scripts/cliconf_integrate.fish"

      To use the sample configuration files, copy them to your config directory:
        mkdir -p ~/.config/cliconf
        cp -n #{opt_share}/cliconf/examples/.*.conf ~/.config/cliconf/

      cliconf stores global configurations in ~/.config/cliconf/.<command>.conf
    EOS
  end

  test do
    # cliconf --version が動作することを確認
    assert_match "cliconf version", shell_output("#{bin}/cliconf --version")

    # cliconf show コマンドが動作することを確認 (設定ファイルがなくてもエラーにならない)
    assert_match "Configuration information: grep", shell_output("#{bin}/cliconf show grep")
  end
end
```

*(注: `url` と `sha256` は、GitHubでv0.1.0などのタグを作成し、リリースを作成した後に、そのTarballの情報に置き換える必要があります。)*

## 4. `cliconf` 本体の修正（必要であれば）

-   現状の確認では特に修正は不要。

## 5. ドキュメント更新

-   `README.md` の Installation セクションに Homebrew でのインストール方法を追記する。

## 6. リリース準備

-   GitHub リポジトリでバージョンタグ (`v0.1.0` など) を作成し、リリースを作成する。

## 7. Homebrew Core への登録 (オプション)

-   (PoCのため今回は見送り)

## 処理フロー

```mermaid
graph TD
    A[ユーザー: brew install cliconf] --> B(Homebrew: Formula実行);
    B --> C{依存関係チェック};
    C -- OK --> D[ダウンロード &amp; 検証];
    D --> E[インストール処理];
    E --> F[bin/cliconf 配置];
    E --> G[share/cliconf/scripts 配置];
    E --> H[share/cliconf/examples 配置];
    E --> I[Caveats 表示];
    I --> J[ユーザー: シェル設定];
    I --> K[ユーザー: サンプル設定コピー (任意)];