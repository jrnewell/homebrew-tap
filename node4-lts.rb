class Node4Lts < Formula
  desc "JavaScript runtime built on Chrome's V8 engine"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v4.6.1/node-v4.6.1.tar.xz"
  sha256 "fe2a85df8758001878abb5bbaf17a6b6cdc12b3e465b1d3bace83b37fdf0345a"
  head "https://github.com/nodejs/node.git", :branch => "v4.x-staging"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "82de98d5ca42e5f71fef5c4d5655d37db011d98ad518681bbbdbf64c1a8c9918" => :sierra
    sha256 "749a25212f0ccbd66a8495ec38c4cc5511a3c8c9f22c7ddb143c1d779b003121" => :el_capitan
    sha256 "0ec397f44934a7080c7bbfbe294da3b67c471c50f6bb9ec8360d2e5d0e7b7181" => :yosemite
  end

  option "with-debug", "Build with debugger hooks"
  option "with-full-icu", "Build with full-icu (all locales) instead of small-icu (English only)"

  depends_on :python => :build if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "openssl" => :optional

  conflicts_with "node", :because => "Differing versions of the same formula"

  fails_with :llvm do
    build 2326
  end

  resource "icu4c" do
    url "https://ssl.icu-project.org/files/icu4c/56.1/icu4c-56_1-src.tgz"
    version "56.1"
    sha256 "3a64e9105c734dcf631c0b3ed60404531bce6c0f5a64bfe1a6402a4cc2314816"
  end

  def install
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"
    args << "--shared-openssl" if build.with? "openssl"

    if build.with? "full-icu"
      args << "--with-intl=full-icu"
    else
      args << "--with-intl=small-icu"
    end
    args << "--tag=head" if build.head?

    resource("icu4c").stage buildpath/"deps/icu"

    system "./configure", *args
    system "make", "install"
  end

  def post_install
    rm_rf "#{prefix}/etc"
    rm_rf "#{etc}/bash_completion.d/npm"
    rm_rf "#{prefix}/libexec"
  end

  def caveats
    s = ""

    s += <<-EOS.undent
      Homebrew did NOT install npm.  Please install and configure npm manually.
    EOS

    s
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output
  end
end
