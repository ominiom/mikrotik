require 'helper'

describe Mikrotik::Protocol::Parser do

  before :each do
    @parser = Mikrotik::Protocol::Parser.new
  end

  describe '#get_length_size' do

    it "returns 7 for 1 byte lengths" do
      @parser.instance_variable_set(:@data, 0b01111111.chr)
      @parser.send(:get_length_size).should eq(7)
    end

    it "returns 14 for 2 byte lengths" do
      @parser.instance_variable_set(:@data, 0b10111111.chr)
      @parser.send(:get_length_size).should eq(14)
    end

    it "returns 21 for 3 byte lengths" do
      @parser.instance_variable_set(:@data, 0b11011111.chr)
      @parser.send(:get_length_size).should eq(21)
    end

    it "returns 28 for 28 bit lengths" do
      @parser.instance_variable_set(:@data, 0b11101111.chr)
      @parser.send(:get_length_size).should eq(28)
    end

    it "returns 32 for 32 bit lengths" do
      @parser.instance_variable_set(:@data, 0b11110000.chr)
      @parser.send(:get_length_size).should eq(32)
    end

  end

  describe '#get_length' do
    
    it "handles 7 bit lengths" do
      @parser.instance_variable_set(:@data, 0b01111101.chr)
      @parser.send(:get_length).should eq(0b1111101)
    end

    it "handles 14 bit lengths" do
      @parser.instance_variable_set(:@data, 0b10111111.chr + 0b11111111.chr)
      @parser.send(:get_length).should eq(63 * 256 + 255)
    end

  end

end
