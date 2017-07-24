# coding: utf-8
require 'lib/levenshtein_damerau'
require "byebug"

RSpec.describe Text::LevenshteinDamerau do
  it "A is A" do
    expect(Text::LevenshteinDamerau.distance('a', 'a')).to eq(0)
  end

  it "supports diacritics" do
    expect(Text::LevenshteinDamerau.distance('Montreal', 'Montréal')).to eq(1)
    expect(Text::LevenshteinDamerau.distance('Montréal', 'Montreal')).to eq(1)
  end
end
