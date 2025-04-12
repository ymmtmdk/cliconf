class Cliconf < Formula
  desc "Hierarchical Configuration Management Framework for Command-line Tools"
  homepage "https://github.com/ymmtmdk/cliconf"
  url "https://github.com/ymmtmdk/cliconf/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "..." # リリース作成後に実際のハッシュ値に置き換える
  license "MIT"

  depends_on "bash" => :run

  def install
    bin.install "cliconf.sh" => "cliconf"
    (share/"cliconf/scripts").install "scripts/cliconf_integrate.bash", "scripts/cliconf_integrate.fish"
    (share/"cliconf/examples").install Dir["examples/.*.conf"]
  end

  def caveats
    <<~EOS
      To install:
        brew install ymmtmdk/cliconf

      Then add one of the following lines to your shell configuration file:

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
    assert_match "cliconf version", shell_output("#{bin}/cliconf --version")
    assert_match "Configuration information: grep", shell_output("#{bin}/cliconf show grep")
  end
end