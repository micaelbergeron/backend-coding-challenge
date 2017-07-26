# coding: utf-8
require 'engine/redis'

RSpec.describe SinCity::Engine::GeoEngine do
  before(:example) do
    @engine = SinCity::Engine::GeoEngine.new
    @engine.startup()
  end 
  
  it "should startup" do
    expect { @engine.startup() }.not_to raise_error 
  end

  it "find quebec" do
    quebec = @engine.run({latitude: 46.829853, longitude: -71.254028}).first
    
    expect(quebec).to have_attributes(:geonameid => '6325494',
                                      :asciiname => 'Quebec',
                                      :distance => be_within(0.5).of(3.5))
  end
end
