class Node < Formula
  desc "Platform built on the V8 JavaScript runtime to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v7.0.0/node-v7.0.0.tar.xz"
  sha256 "e16c3c76c2d6756bbfd711189cbdaf5676049b443e6817007bb537f243ca899a"
  head "https://github.com/nodejs/node.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles"
    sha256 "494ccc8ea6fa68e8ceace33ad6ced5a9efa24a964d720412cca381a036d28764" => :sierra
    sha256 "f8bf2da4c0e453603d022ba931cd4a0175f2c7cc0adea63793996ae5f00bf9ec" => :el_capitan
    sha256 "12595bb720032f50bb984e33342e9fc00362a263b5aa8b1fabaea2e3feae4b7e" => :yosemite
  end

  option "with-debug", "Build with debugger hooks"
  option "with-openssl", "Build against Homebrew's OpenSSL instead of the bundled OpenSSL"
  option "with-full-icu", "Build with full-icu (all locales) instead of small-icu (English only)"

  deprecated_option "enable-debug" => "with-debug"
  deprecated_option "with-icu4c" => "with-full-icu"

  depends_on :python => :build if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "openssl" => :optional

  # Per upstream - "Need g++ 4.8 or clang++ 3.4".
  fails_with :clang if MacOS.version <= :snow_leopard
  fails_with :llvm
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.7").each do |n|
    fails_with :gcc => n
  end

  resource "icu4c" do
    url "https://ssl.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz"
    mirror "https://fossies.org/linux/misc/icu4c-57_1-src.tgz"
    version "57.1"
    sha256 "ff8c67cb65949b1e7808f2359f2b80f722697048e90e7cfc382ec1fe229e9581"
  end

  def install
    # Never install the bundled "npm", always prefer our
    # installation from tarball for better packaging control.
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"
    args << "--shared-openssl" if build.with? "openssl"
    args << "--tag=head" if build.head?

    if build.with? "full-icu"
      resource("icu4c").stage buildpath/"deps/icu"
      args << "--with-intl=full-icu"
    end

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

    if build.without? "full-icu"
      s += <<-EOS.undent
        Please note by default only English locale support is provided. If you need
        full locale support you should either rebuild with full icu:
          `brew reinstall node --with-full-icu`
        or add full icu data at runtime following:
          https://github.com/nodejs/node/wiki/Intl#using-and-customizing-the-small-icu-build
      EOS
    end

    s
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output
    if build.with? "full-icu"
      output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
      assert_equal "1.234,56", output
    end
  end
end
