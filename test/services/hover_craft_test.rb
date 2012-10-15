require 'test_helper'

describe HoverCraftService do
  it "exists" do
    HoverCraft.service.wont_be_nil
  end

  describe '#determine_best_website' do

    describe 'given hc with website_url' do
      let(:hc) { HoverCraft.new(website_url: 'abc.com') }
      it 'returns website_url' do
        HoverCraft.service.determine_best_website(hc).must_equal hc.website_url
      end
    end 

    # context 'given yelp and twitter' do
    # end 

    # context 'given yelp and facebook' do
    # end 

    # context 'given twitter and facebook' do
    # end 

  end

end
