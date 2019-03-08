class Broot < Formula
  desc "An interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands"
  homepage "https://github.com/Canop/broot/"
  url "https://github.com/Canop/broot/archive/v0.7.1.tar.gz"
  sha256 "a16e471527fa7283e228946574ec55a2c73f951b7035801f671895815f348f68"
  head "https://github.com/Canop/broot.git"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    system "#{bin}/broot", "--help"
  end
end