# coding: utf-8
require 'engine/geo'

include SinCity::Engine

RSpec.describe GeoEngine do
  let(:query) { Query.new(nil, -71.254028, 46.829853) }
  let(:query_skip) { Query.new }
  
  subject { @engine.run(query) }

  before(:example) do
    @engine = GeoEngine.new
    @engine.startup()
  end 
  
  it "should startup" do
    expect { @engine.startup() }.not_to raise_error 
  end

  it "should pre_process" do
    expect(@engine.pre_process(query)).to eq(query)
  end

  it "should skip malformed queries" do
    expect(@engine.pre_process(query_skip)).to eq(SKIP)
  end

  it "doesn't go further than the search radius" do
    is_expected.to all(satisfy { |_, dist| dist < @engine.config[:radius] })
  end
  
  describe "searching should yield correct results" do
    it { is_expected.to be_a(Hash) }
    
    # Those are near samples
    it { is_expected.to include(City::QUEBEC => be_within(0.5).of(3.5)) } # Quebec
    it { is_expected.to include(City::LEVIS => be_within(0.5).of(6.5)) } # Lévis
    it { is_expected.to include(City::MONTREAL => be_within(10).of(230)) }  # Montreal

    # These are very far and should not be included
    it { is_expected.not_to include(City::LAS_VEGAS) } # Las Vegas
    it { is_expected.not_to include(City::DALLAS) } # Dallas
    it { is_expected.not_to include(City::CALGARY) } # Calgary
  end
end
