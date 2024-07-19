# frozen_string_literal: true

RSpec.describe MovieBookingSystem::Validation do # rubocop:disable RSpec/SpecFilePathFormat
  let(:file_path) { "spec/tmp/test_validation.csv" }

  class UserTestModel < MovieBookingSystem::CSVModel # rubocop:disable RSpec/LeakyConstantDeclaration,Lint/ConstantDefinitionInBlock
    field :name, required: true, unique: true
    field :age, type: :integer

    csv_filename file_path
  end

  # after do
  #   FileUtils.rm_f(file_path)
  # end

  context "when attributes are valid" do
    let(:valid_attributes) { { name: "John Doe", age: 30 } }

    it "returns true" do
      model = UserTestModel.new(valid_attributes)
      expect(model).to be_valid
    end

    it "does not add errors" do
      model = UserTestModel.new(valid_attributes)
      model.valid?
      expect(model.errors).to be_empty
    end
  end

  context "when required field is missing" do
    let(:invalid_attributes) { { age: 30 } }

    it "returns false" do
      model = UserTestModel.new(invalid_attributes)
      expect(model.valid?).to be(false)
    end

    it "adds errors" do
      model = UserTestModel.new(invalid_attributes)
      model.valid?
      expect(model.errors).not_to be_empty
      expect(model.errors).to include("name cannot be blank")
    end
  end

  context "when unique field is duplicate" do
    before do
      UserTestModel.create({ name: "John Doe", age: 30 })
    end

    let(:invalid_attributes) { { name: "John Doe", age: 31 } }

    it "returns false" do
      model = UserTestModel.new(invalid_attributes)
      expect(model.valid?).to be(false)
    end

    it "adds errors" do
      model = UserTestModel.new(invalid_attributes)
      model.valid?
      expect(model.errors).not_to be_empty
      expect(model.errors).to include("name must be unique")
    end
  end

  context "when type is invalid" do
    let(:invalid_attributes) { { name: "John Doe", age: "abc" } }

    it "returns false" do
      model = UserTestModel.new(invalid_attributes)
      expect(model.valid?).to be(false)
    end

    it "adds errors" do
      model = UserTestModel.new(invalid_attributes)
      model.valid?
      expect(model.errors).not_to be_empty
      expect(model.errors).to include("age must be an integer")
    end
  end
end
