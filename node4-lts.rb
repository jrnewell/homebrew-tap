class Node4Lts < Formula
  desc "JavaScript runtime built on Chrome's V8 engine"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v4.4.6/node-v4.4.6.tar.xz"
  sha256 "0f6bbfbea525469c91932b1aac35e0810e6bcda96f1c720e42a433942ee66106"
  head "https://github.com/nodejs/node.git", :branch => "v4.x-staging"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "e553c34ecfba8fe340d03f010978d01eabdf8084b1b25c63b9162f73daebd8fa" => :el_capitan
    sha256 "3ee21e7dd84e3388a3455ed37ab3dd70d2cabdae35166157b6fbbdb4f94c4173" => :yosemite
    sha256 "2ba2f0f9e60c6076cbe8e7afe9f18da018616fb6f503daba1f3e860e7fc4e6b7" => :mavericks
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
