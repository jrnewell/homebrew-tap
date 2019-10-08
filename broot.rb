class Broot < Formula
  desc "An interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands"
  homepage "https://github.com/Canop/broot/"
  url "https://github.com/Canop/broot/archive/v0.9.6.tar.gz"
  sha256 "af8b36d5d4242ec1bd86925f0f664a610e7e94309686ef0874df6bc0867a0c3e"
  head "https://github.com/Canop/broot.git"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    system "#{bin}/broot", "--help"
  end
end