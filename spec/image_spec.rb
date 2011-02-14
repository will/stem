require 'spec_helper'

describe Stem::Image do

  context "describe" do
    use_vcr_cassette

    it { should respond_to :describe }

    it "should return nil when the ami doesn't exist" do
      Stem::Image.describe("ami-aaaaaaaa").should be_nil
    end

    it "should return the AMI details hash when the ami exists" do
      h = Stem::Image.describe("ami-e67a8a8f")
      h["imageId"].should == "ami-e67a8a8f"
    end
  end

  context "tagged" do
    use_vcr_cassette

    it { should respond_to :tagged }

    it "should return nil if an empty hash is passed in" do
      Stem::Image.tagged([]).should be_nil
    end

    it "should return nil if an empty array is passed in" do
      Stem::Image.tagged([]).should be_nil
    end

    it "should return an empty array when no images exist with the specified tags" do
      Stem::Image.tagged(:faketag => 'does_not_exist').should == []
    end

    it "should retun an array of ami IDs when 2 images exist with the specified tags" do
      Stem::Image.tagged(:slot => 'logplex', :architecture => 'x86_64')
    end
  end

  context "describe_tagged" do
    use_vcr_cassette

    it { should respond_to :describe_tagged }

    it "should convert the input tags to filters" do
      tags = { "family" => "postgres" }
      Stem::Image.should_receive(:tags_to_filter).with(tags).and_return({
        "Filter.0.Name" => "tag:family",
        "Filter.0.Value.0" => "postgres"
      })
      Stem::Image.swirl.stub!(:call).and_return("imagesSet" => [])
      Stem::Image.describe_tagged(tags)
    end

    it "should call swirl with the correct filters" do
      tags = { "family" => "postgres" }
      Stem::Image.swirl.should_receive(:call).with("DescribeImages", {
        "Owner" => "self",
        "Filter.0.Name" => "tag:family",
        "Filter.0.Value.0" => "postgres"
      }).and_return("imagesSet" => [])
      Stem::Image.describe_tagged(tags)
    end

    it "should return an empty array when the ami doesn't exist" do
      Stem::Image.describe_tagged("family" => "fake_family").should == []
    end

    it "should return the AMI tags at the first level of the image hash" do
      images = Stem::Image.describe_tagged("family" => "postgres")
      images.first["tags"].should include("family" => "postgres")
    end
  end
end

# tags
# :family => "postgresql",
# :release => "production",
# :created_at => "10/10/10 10:10",
