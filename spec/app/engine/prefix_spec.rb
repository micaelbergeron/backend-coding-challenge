# coding: utf-8
require 'engine/prefix'

include SinCity::Engine

RSpec.describe PrefixEngine do
  before(:all) do
    @engine = PrefixEngine.new
    @engine.startup()
  end 
  
  it "should startup" do
    expect { @engine.startup() }.not_to raise_error 
  end

  let(:query) { Query.new("queb" ) }
  let(:query_skip) { Query.new }

  subject { @engine.run(query) }

  describe "should normalize the query" do
    it { expect(@engine.pre_process(Query.new 'quebec')).to have_attributes(q: 'quebec') }
    it { expect(@engine.pre_process(Query.new 'québec')).to have_attributes(q: 'québec') }
    it { expect(@engine.pre_process(Query.new 'Quebec')).to have_attributes(q: 'quebec') }
    it { expect(@engine.pre_process(Query.new 'QuÉb #$!@')).to have_attributes(q: 'québ #$!@') }
  end

  describe "should skip malformed queries" do
    ['\r\n', '#@!$!', ''].each do |q|
      it { expect(@engine.pre_process(Query.new q)).to eq(SKIP) }
    end
  end

  describe "with a 0-distance query" do
    subject { @engine.run(Query.new 'Quebec') }
    it { is_expected.to include(City::QUEBEC => 0) }

    it "should support diacritics" do
      pending("diacritic support")
      expect(@engine.run(Query.new 'québec')).to include(City::QUEBEC => 0)
    end
  end

  describe "with a 1-distance query" do
    subject { @engine.run(Query.new 'Quebe') }

    it { is_expected.to include(City::QUEBEC) }
  end

  describe "with a 2-distance query" do
    subject { @engine.run(Query.new 'Lev') }

    it { is_expected.to include(City::LEVIS) }
  end

  describe "with a N-distance query" do
    subject { @engine.run(Query.new 'M') }

    it { is_expected.to include(City::MONTREAL) }
  end
  
  # Correct results are hard to determine because it depends on the overall
  # search result. The order within the search set is used to determine to score.
  describe "searching should yield correct results" do
    it { is_expected.to be_a(Hash) }
    
    # those are near samplescity:6325494
    it { expect(@engine.run(Query.new("qu"))).to include(City::QUEBEC) } # quabec
    it { expect(@engine.run(Query.new("queb"))).to include(City::QUEBEC) } # quabec
    it { expect(@engine.run(Query.new("mon"))).to include(City::MONTREAL) } # quabec
    it { expect(@engine.run(Query.new("las"))).to_not include(City::LAS_VEGAS) }

    # these are very far and should not be included
    it { is_expected.not_to include(%w[5506956 5475433]) } # las vegas
    it { is_expected.not_to include(%w[4190598 5722064 4684888]) } # dallas
    it { is_expected.not_to include(%w[4190598 5722064 4684888]) } # dallas
    it { is_expected.not_to include('5913490') } # calgary
  end
  
end
