$: << File.dirname(__FILE__) + "../"
require 'refreshing_cache'

# Sorry for the sleeps, it's the easiest way to test this without overmocking.
describe RefreshingCache do
  before do
    @check_proc_return_value = true
    @check_proc_call_count = 0
    @value_proc_call_count = 0
  end

  let!(:timeout) { 0.3 }
  let!(:check_proc) { ->(key, time) { @check_proc_call_count += 1; @check_proc_return_value } }
  let!(:value_proc) { ->(key, time) { @value_proc_call_count += 1; "calculated_value_for_#{key}_#{@value_proc_call_count}" } }

  subject(:cache) { RefreshingCache.new(timeout: timeout, check_proc: check_proc, value_proc: value_proc) }

  describe "#[]" do
    it "doesn't call check_proc if there is no cached value" do
      cache["test"]
      expect(@check_proc_call_count).to eq(0)
    end

    it "returns the value returned by the value_proc" do
      expect(cache["test"]).to eq("calculated_value_for_test_1")
    end

    describe "with a cached value" do
      before { cache["test"] }

      # TODO: A more clever way to do this, probably by reaching in and tweaking the timeouts hash
      def expire!(key)
        sleep(0.5)
      end

      it "doesn't call the check_proc if the cached value is within the timeout" do
        cache["test"]
        expect(@check_proc_call_count).to eq(0)
      end

      it "doesn't call the value_proc if the cached value is within the timeout" do
        cache["test"]
        expect(@value_proc_call_count).to eq(1)
      end

      it "calls the check_proc if the timeout has expired" do
        expire!("test")
        cache["test"]
        expect(@check_proc_call_count).to eq(1)
      end

      it "returns the value in the cache" do
        expect(cache["test"]).to eq("calculated_value_for_test_1")
      end

      context "when the check proc returns true" do
        before { @check_proc_return_value = true }

        it "after expiration, it calls the value_proc" do
          expire!("test")
          cache["test"]
          expect(@value_proc_call_count).to eq(2)
        end

        it "returns the new value_proc result" do
          expire!("test")
          expect(cache["test"]).to eq("calculated_value_for_test_2")
        end
      end

      context "When the check proc returns false" do
        before { @check_proc_return_value = false }
      end
    end
  end
end
