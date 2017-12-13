class Node < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v9.3.0/node-v9.3.0.tar.xz"
  sha256 "b288075e2f09faf33046583271a4e85c34684b5b637973dd6eaa5445220c57cd"
  head "https://github.com/nodejs/node.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles"
    sha256 "17bc119bd070908aa80427bbdd98e4ed35764d30e14c4846f53c7589fad325a1" => :high_sierra
    sha256 "b4580965a8b9cff06d27eb109b77ddb32c88bf75eab8e2f6c3cb20dd83975c16" => :sierra
    sha256 "6736c632096bb82eef4e7800fc30cf6442f2e11e11849fb2a85ffcc21c483a6a" => :el_capitan
  end

  option "with-debug", "Build with debugger hooks"
  option "with-openssl", "Build against Homebrew's OpenSSL instead of the bundled OpenSSL"

  deprecated_option "enable-debug" => "with-debug"

  depends_on :python => :build if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "icu4c" => :recommended
  depends_on "openssl" => :optional

  conflicts_with "node@4", :because => "Differing versions of the same formulae."

  # Per upstream - "Need g++ 4.8 or clang++ 3.4".
  fails_with :clang if MacOS.version <= :snow_leopard
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.7").each do |n|
    fails_with :gcc => n
  end

  resource "icu4c" do
    url "https://ssl.icu-project.org/files/icu4c/58.1/icu4c-58_1-src.tgz"
    mirror "https://nuxi.nl/distfiles/third_party/icu4c-58_1-src.tgz"
    version "58.1"
    sha256 "0eb46ba3746a9c2092c8ad347a29b1a1b4941144772d13a88667a7b11ea30309"
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
