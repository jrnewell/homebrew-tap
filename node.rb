class Node < Formula
  desc "Platform built on Chrome's JavaScript runtime to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v5.1.0/node-v5.1.0.tar.gz"
  sha256 "25b2d3b7dd57fe47a483539fea240a3c6bbbdab4d89a45a812134cf1380ecb94"

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
