require 'test_helper'

describe Web do
  it "exists" do
    Web.wont_be_nil
  end

  describe '.provider_for_href' do
    before do
      @providers = [:facebook, :twitter, :yelp, :webpage]
    end

    describe '(provider_url) -> :provider' do
      describe 'no http' do
        it 'handles naked domain' do
          @providers.each {|provider| Web.provider_for_href("#{provider}.com").must_equal provider }
        end
        it 'handles www domain' do
          @providers.each {|provider| Web.provider_for_href("www.#{provider}.com").must_equal provider }
        end
      end
      describe 'with http' do
        it 'handles naked domain' do
          @providers.each {|provider| Web.provider_for_href("http://#{provider}.com").must_equal provider }
        end
        it 'handles www domain' do
          @providers.each {|provider| Web.provider_for_href("http://www.#{provider}.com").must_equal provider }
        end
      end
      describe 'with https' do
        it 'handles naked domain' do
          @providers.each {|provider| Web.provider_for_href("https://#{provider}.com").must_equal provider }
        end
        it 'handles www domain' do
          @providers.each {|provider| Web.provider_for_href("https://www.#{provider}.com").must_equal provider }
        end
      end
    end

  end

end