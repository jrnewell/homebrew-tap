class MongodbCommunityAT36 < Formula
    desc "High-performance, schema-free, document-oriented database"
    homepage "https://www.mongodb.com/"

    # frozen_string_literal: true

    url "https://fastdl.mongodb.org/osx/mongodb-osx-ssl-x86_64-3.6.23.tgz"
    sha256 "f75883dae932590201b8e36b2591da4f267cf56cbc57755b389b76c1fe3d5b31"

    option "with-enable-test-commands", "Configures MongoDB to allow test commands such as failpoints"

    keg_only :versioned_formula

    def install
      prefix.install Dir["*"]
    end

    def post_install
      (var/"mongodb").mkpath
      (var/"log/mongodb").mkpath
      if !(File.exist?((etc/"mongod.conf"))) then
        (etc/"mongod.conf").write mongodb_conf
      end
    end

    def mongodb_conf
      cfg = <<~EOS
      systemLog:
        destination: file
        path: #{var}/log/mongodb/mongo.log
        logAppend: true
      storage:
        dbPath: #{var}/mongodb
      net:
        bindIp: 127.0.0.1, ::1
        ipv6: true
      EOS
      if build.with? "enable-test-commands"
        cfg += <<~EOS
        setParameter:
          enableTestCommands: 1
        EOS
      end
      cfg
    end

    plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/mongod</string>
          <string>--config</string>
          <string>#{etc}/mongod.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/mongodb/output.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/mongodb/output.log</string>
        <key>HardResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>64000</integer>
        </dict>
        <key>SoftResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>64000</integer>
        </dict>
      </dict>
      </plist>
    EOS
    end

    test do
      system "#{bin}/mongod", "--sysinfo"
    end
  end