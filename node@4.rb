class NodeAT4 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v4.8.7/node-v4.8.7.tar.xz"
  sha256 "03479a8ce6affedde75d80a6c8c351a7afb5a85b8d7e5119ab6f349100e641f8"
  head "https://github.com/nodejs/node.git", :branch => "v4.x-staging"

  bottle do
    root_url "https://homebrew.bintray.com/bottles"
    sha256 "8dae44c7d34843c03af6606db7315f93dbf1730a5541ceaa6e2125b62700967c" => :high_sierra
    sha256 "a7cceeb30fefe85695c2ad57ad2c03d2e1dbfc93f3ef998edd32a44532dc5f2f" => :sierra
    sha256 "17570799d5b9e0e89f5a80b331544fd758ba33b93360c5f1db7c56266e846fea" => :el_capitan
  end

  option "with-debug", "Build with debugger hooks"
  option "with-full-icu", "Build with full-icu (all locales) instead of small-icu (English only)"

  depends_on :python => :build if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "openssl" => :optional

  conflicts_with "node", :because => "Differing versions of the same formula"

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
