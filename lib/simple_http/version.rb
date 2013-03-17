module SimpleHttp
  class Version
    MAJOR = 0 unless defined? Yammer::MAJOR
    MINOR = 1 unless defined? Yammer::MINOR
    PATCH = 0 unless defined? Yammer::PATCH
    PRE = nil unless defined? Yammer::PRE

    class << self

      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end

    end

  end
end
