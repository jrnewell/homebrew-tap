class Node < Formula
  desc "Platform built on the V8 JavaScript runtime to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v6.2.1/node-v6.2.1.tar.xz"
  sha256 "dbaeb8fb68a599e5164b17c74f66d24f424ee4ab3a25d8de8a3c6808e5b42bfb"
  head "https://github.com/nodejs/node.git"

  bottle do
    sha256 "ecbb784426f302bf25916a803215e39159ad67611864a543e6538dde24879dd7" => :el_capitan
    sha256 "3a1d21d7dcf372f8c41ace82f6d368d851023bba8d862cf8a87858345ee2b14e" => :yosemite
    sha256 "11b66415b774ab750a517475d0514cd2652b4be4680e3fcb5278fcef9af4754c" => :mavericks
  end

  option "with-debug", "Build with debugger hooks"
  option "with-openssl", "Build against Homebrew's OpenSSL instead of the bundled OpenSSL"
  option "with-full-icu", "Build with full-icu (all locales) instead of small-icu (English only)"

  deprecated_option "enable-debug" => "with-debug"
  deprecated_option "with-icu4c" => "with-full-icu"

  depends_on :python => :build if MacOS.version <= :snow_leopard

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

  def caveats
    s = <<-EOS.undent
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

    output = `#{bin}/node #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus
  end
end
