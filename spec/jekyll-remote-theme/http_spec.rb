# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme::HTTP do
  let(:url) { "https://codeload.github.com/pages-themes/primer/zip/HEAD" }
  let(:uri) { Addressable::URI.parse(url) }
  let(:env) { {} }
  let(:proxy) { described_class.proxy_uri(uri, env) }

  context "proxy configuration" do
    it "returns nil when no proxy is set" do
      expect(proxy).to be_nil
    end

    context "with http_proxy" do
      let(:env) { { "http_proxy" => "http://proxy.example.com:8080" } }

      it "uses it for https URLs" do
        expect(proxy.host).to eq("proxy.example.com")
        expect(proxy.port).to eq(8080)
      end
    end

    context "with https_proxy" do
      let(:env) { { "https_proxy" => "http://secure-proxy.example.com:8443" } }

      it "uses it for https URLs" do
        expect(proxy.host).to eq("secure-proxy.example.com")
        expect(proxy.port).to eq(8443)
      end

      context "and an http URL" do
        let(:url) { "http://codeload.example.com/pages-themes/primer/zip/HEAD" }

        it "ignores it" do
          expect(proxy).to be_nil
        end
      end
    end

    context "with both http_proxy and https_proxy" do
      let(:env) do
        {
          "http_proxy"  => "http://proxy.example.com:8080",
          "https_proxy" => "http://secure-proxy.example.com:8443",
        }
      end

      it "prefers https_proxy for https URLs" do
        expect(proxy.host).to eq("secure-proxy.example.com")
      end
    end

    context "with credentials" do
      let(:env) { { "http_proxy" => "http://user:password@proxy.example.com:8080" } }

      it "parses them" do
        expect(proxy.user).to eq("user")
        expect(proxy.password).to eq("password")
      end
    end

    context "with uppercase variables" do
      let(:env) { { "HTTPS_PROXY" => "http://proxy.example.com:8080" } }

      it "uses them" do
        expect(proxy.host).to eq("proxy.example.com")
      end
    end

    context "with an invalid proxy URI" do
      let(:env) { { "http_proxy" => "://invalid" } }

      it "returns no proxy host" do
        expect(proxy&.host).to be_nil
      end
    end
  end

  context "starting a connection" do
    let(:env) { { "https_proxy" => "http://user:pass@proxy.example.com:8080" } }
    let(:http) { instance_double(Net::HTTP) }

    it "passes the proxy and timeouts to Net::HTTP" do
      expect(Net::HTTP).to receive(:start).with(
        "codeload.github.com", nil, "proxy.example.com", 8080, "user", "pass",
        :use_ssl      => true,
        :open_timeout => described_class::OPEN_TIMEOUT,
        :read_timeout => described_class::READ_TIMEOUT
      ).and_yield(http)

      expect { |b| described_class.start(uri, :env => env, &b) }.to yield_with_args(http)
    end
  end
end
