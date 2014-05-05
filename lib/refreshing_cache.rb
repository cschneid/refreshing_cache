require 'delegate'

class RefreshingCache < DelegateClass(Hash)
  VERSION = "0.0.1"

  def initialize(timeout: timeout, check_proc: check_proc, value_proc: value_proc)
    @timeout = timeout

    @check_proc = check_proc
    @refresh_proc = value_proc

    # Stores key => timeout info
    @timeouts = {}

    # Actual underlying data we're caching
    @hash = {}
    super(@hash)
  end

  def [](key)
    self[key] = refresh!(key) if regenerate_value?(key)
    super
  end

  def refresh!(key)
    val = refresh_proc.call(key, timeouts[key])
    timeouts[key] = Time.now
    val
  end

  protected
  attr_reader :check_proc, :refresh_proc, :timeout, :timeouts

  def regenerate_value?(key)
    # No timeout info? We need to generate values.
    return true unless timeouts.has_key?(key)

    # If we've timed out, force a check
    return false if timeouts[key] + timeout > Time.now

    check_proc.call(key, timeouts[key])
  end
end
