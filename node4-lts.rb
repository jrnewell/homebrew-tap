class Node4Lts < Formula
  desc "JavaScript runtime built on Chrome's V8 engine"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v4.6.0/node-v4.6.0.tar.xz"
  sha256 "42910dbd34e49bfc40580e06753947c30d31101455a38e9f0343a23d67c0c694"
  head "https://github.com/nodejs/node.git", branch: "v4.x-staging"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "3f557c2b949b8d8dd3c439d92cc4de6b6960f4680928bd96fe2c85f2c6477ad1" => :sierra
    sha256 "4b71f385abea0decd7209767e4fdcc19f1f13bf11e16c6f961bb860c2a485fde" => :el_capitan
    sha256 "440893ae9469d1de212867dd762617488112699580f5eacdea7680acd597c3de" => :yosemite
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
