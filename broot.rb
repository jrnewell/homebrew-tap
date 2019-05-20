class Broot < Formula
  desc "An interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands"
  homepage "https://github.com/Canop/broot/"
  url "https://github.com/Canop/broot/archive/v0.7.5.tar.gz"
  sha256 "65635be08f3959747f830ada0891cbb800353e8268e2260ea783ad519113a57e"
  head "https://github.com/Canop/broot.git"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    system "#{bin}/broot", "--help"
  end
end