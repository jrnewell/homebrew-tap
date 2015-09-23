class Node < Formula
  desc "Platform built on Chrome's JavaScript runtime to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v4.1.1/node-v4.1.1.tar.gz"
  sha256 "6a610935ff52de713cf2af6a26002322e24fd7933a444436f0817a2b84e15a58"

  option "with-debug", "Build with debugger hooks"
  option "with-icu4c", "Build with Intl (icu4c) support"

  depends_on "pkg-config" => :build
  depends_on "icu4c" => :optional
  depends_on :python => :build if MacOS.version <= :snow_leopard

  def install
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"
    args << "--with-intl=system-icu" if build.with? "icu4c"

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
      Homebrew did NOT install npm.  Please install and configure npm manually.
    EOS
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/node #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus
  end
end
