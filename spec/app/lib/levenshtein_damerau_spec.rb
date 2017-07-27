# coding: utf-8
require 'lib/levenshtein_damerau'
require "byebug"

include Text::LevenshteinDamerau

RSpec.describe  do
  it "A is A" do
    expect(distance('a', 'a')).to eq(0)
    expect(distance('patate', 'patate')).to eq(0)
    expect(distance('', '')).to eq(0)
  end

  describe "should support substitution" do
    it { expect(distance('a', 'b')).to eq(1) }
    it { expect(distance('a', 'A')).to eq(1) }
    it { expect(distance('a', '$')).to eq(1) }
    it { expect(distance('abc', 'pfk')).to eq(3) }
    it { expect(distance('patate', 'potato')).to eq(2) }
  end

  describe "should support deletion" do
    it { expect(distance('a', '')).to eq(1) }
    it { expect(distance('patate', 'patte')).to eq(1) }
    it { expect(distance('pool', 'pl')).to eq(2) }
  end

  describe "should support insertion" do
    it { expect(distance('a', '')).to eq(1) }
    it { expect(distance('patate', 'patte')).to eq(1) }
    it { expect(distance('pool', 'pl')).to eq(2) }
  end

  describe "should support permutation" do
    pending "correct damerau calculation" do
      it { expect(distance('abc', 'acb')).to eq(1) }
      it { expect(distance('abc', 'cba')).to eq(2) }
      it { expect(distance('patate', 'paatte')).to eq(1) }
      it { expect(distance('loop', 'pool')).to eq(3) }
    end
  end

  it "supports diacritics" do
    pending "diacritic support"
    expect(distance('Montreal', 'Montréal')).to eq(0)
    expect(distance('Montréal', 'Montreal')).to eq(0)
  end
end
