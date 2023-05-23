describe Jets::Cfn::Resource::Nested::Api::Gateway do
  let(:resource) do
    Jets::Cfn::Resource::Nested::Api::Gateway.new(s3_bucket: "s3-bucket")
  end

  describe "resource" do
    it "contains child stack info" do
      allow(Jets).to receive(:s3_bucket).and_return("s3-bucket")
      expect(resource.logical_id).to eq "ApiGateway"
      properties = resource.properties
      expect(properties[:TemplateURL]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/shas//api-gateway.yml"
    end
  end
end
