require File.expand_path('../spec_helper', __FILE__)

describe SimpleHttp::Connection do

  subject do
    @conn = SimpleHttp::Connection.new('https://example.com')
  end

  context "with user options" do
    before do
      @options = {
        :headers => {
          'Accept'         => 'application/json',
          'User-Agent'     => "Simple HTTP gem #{SimpleHttp::Version}",
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
        },
        :ssl => {:verify => false},
        :max_redirects => 2
      }
      @conn = SimpleHttp::Connection.new('https://microsoft.com', @options)
    end

    it "overrides default options" do
      opts = SimpleHttp::Connection.default_options
      opts.keys.each do |key|
        expect(@conn.instance_variable_get(:"@#{key}")).to eq @options[key]
      end
    end
  end

  describe "#default_headers" do
    it "returns user_agent and response format" do
      expect(subject.default_headers).to eq ({
        "Accept"          => "application/json", 
        "User-Agent"      => "Simple HTTP gem #{SimpleHttp::Version}",
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
      })
    end
  end

  describe "#scheme" do
    it "returns the http scheme" do
      expect(subject.scheme).to eq 'https'
    end
  end

  describe "#scheme" do
    context "scheme is unsupported" do
      it "raises an error" do
        expect { subject.scheme = 'ftp'}.to raise_error(SimpleHttp::Connection::UnsupportedSchemeError)
      end
    end

    context "scheme is http" do
      it "sets the scheme" do
        subject.scheme = 'http'
        expect(subject.scheme).to eq 'http'
      end
    end

    context "scheme is https" do
      it "sets the scheme" do
        subject.scheme = 'https'
        expect(subject.scheme).to eq 'https'
      end
    end
  end

  describe "#host" do
    it "returns the host server" do
      expect(subject.host).to eq 'example.com'
    end
  end

  describe "#port" do
    it "returns the port" do
      expect(subject.port).to eq 443
    end
  end

  describe "#ssl?" do
    context "scheme is https" do
      it "returns true" do
        subject.scheme = 'https'
        expect(subject.ssl?).to eq true
      end
    end

    context "scheme is http" do
      it "returns false" do
        subject.scheme = 'http'
        expect(subject.ssl?).to eq false
      end
    end
  end

  describe "#http_connection" do
    it "behaves like HTTP client" do
      expect(subject.http_connection).to respond_to(:get)
      expect(subject.http_connection).to respond_to(:post)
      expect(subject.http_connection).to respond_to(:put)
      expect(subject.http_connection).to respond_to(:delete)
    end
  end

  describe "#absolute_url" do
    context "with no parameters" do
      it "returns a uri without path" do
        expect(subject.absolute_url).to eq "https://example.com"
      end
    end

    context "with parameters" do
      it "returns a uri with path" do
        expect(subject.absolute_url('/oauth/v2/authorize')).to eq "https://example.com/oauth/v2/authorize"
      end
    end
  end

  describe "#configure_ssl" do
  end

  describe "#redirect_limit_reached?" do
  end

  describe "#ssl_verify_mode" do
    context "ssl verify set to true" do
      it "returns OpenSSL::SSL::VERIFY_PEER" do
        subject.ssl = { :verify => true }
        expect(subject.send(:ssl_verify_mode)).to eq OpenSSL::SSL::VERIFY_PEER
      end
    end

    context "ssl verify set to false" do
      it "returns OpenSSL::SSL::VERIFY_NONE" do
        subject.ssl = { :verify => false }
        expect(subject.send(:ssl_verify_mode)).to eq OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  describe "ssl_cert_store" do
  end

  describe "#send_request" do
    before do
      @http_ok = OpenStruct.new(
        :code    => '200',
        :body    => 'success',
        :headers => {'Content-Type' => "application/json"}
      )
      @http_redirect = OpenStruct.new(
        :code    => '301',
        :body    => 'redirect',
        :headers => {'Location' => "https://example.com/members"}
      )
    end

    context "when method is not supported" do
      it "raises an error" do
        expect {subject.send_request(:patch, '/')}.to raise_error(SimpleHttp::Connection::UnhandledHTTPMethodError)
      end
    end

    context "when method is get" do
      it "returns an http response" do
        stub_get('/oauth/authorize').with(
          :query => {:client_id => '001337', :client_secret => 'abcxyz'},
          :headers => subject.default_headers
        )
        subject.send_request(:get, '/oauth/authorize', :params => {:client_id => '001337', :client_secret => 'abcxyz'})
      end
    end

    context "when method is delete" do
      it "returns an http response" do
        stub_delete('/users/1').with(
          :headers => subject.default_headers
        )
        subject.send_request(:delete, '/users/1')
      end
    end

    context "when method is post" do
      it "returns an http response" do
        stub_post('/users').with(
          :body => {:first_name => 'john', :last_name => 'smith'},
          :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
        )
        subject.send_request(:post, '/users', :params => {:first_name => 'john', :last_name => 'smith'})
      end
    end

    context "when method is put" do
      it "returns an http response" do
        stub_put('/users/1').with(
          :body => {:first_name => 'jane', :last_name => 'doe'},
          :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
        )
        subject.send_request(:put, '/users/1', :params => {:first_name => 'jane', :last_name => 'doe'})
      end
    end

    it "follows redirect" do

      stub_post('/users').with(
        :body => {:first_name => 'jane', :last_name => 'doe'},
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      ).to_return(
        :status => 301,
        :body   => 'redirect',
        :headers => {'Location' => "https://example.com/members"}
      )

      stub_post('/members').with(
        :body => {:first_name => 'jane', :last_name => 'doe'},
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      ).to_return(
        :status => 200,
        :body   => 'sucess'
      )

      subject.send_request(:post, '/users', :params => {:first_name => 'jane', :last_name => 'doe'})
    end

    it "respects the redirect limit " do
      subject.max_redirects = 1

      stub_post('/users').with(
        :body => {:first_name => 'jane', :last_name => 'doe'},
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      ).to_return(
        :status => 301,
        :body   => 'redirect',
        :headers => {'Location' => "https://example.com/members"}
      )

      stub_post('/members').with(
        :body => {:first_name => 'jane', :last_name => 'doe'},
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      ).to_return(
        :status => 301,
        :body   => 'redirect',
        :headers => {'Location' => "https://example.com/profiles"}
      )

      subject.send_request(:post, '/users', :params => {:first_name => 'jane', :last_name => 'doe'})
    end

    it "modifies http 303 redirect from POST to GET " do

      stub_post('/users').with(
        :body => {:first_name => 'jane', :last_name => 'doe'},
        :headers => {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      ).to_return(
        :status => 303,
        :body   => 'redirect',
        :headers => {'Location' => "https://example.com/members"}
      )

      stub_get('/members').with(
        :headers => subject.default_headers
      ).to_return(
        :status => 200,
        :body   => ''
      )
      response = subject.send_request(:post, '/users', :params => {:first_name => 'jane', :last_name => 'doe'})

    end
  end
end