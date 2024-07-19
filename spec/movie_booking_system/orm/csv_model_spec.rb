# frozen_string_literal: true

RSpec.describe MovieBookingSystem::CSVModel do # rubocop:disable RSpec/SpecFilePathFormat
  let(:file_path) { "spec/tmp/test_model_data.csv" }
  let(:attributes) { { title: "Inception", genre: "Sci-Fi", duration: 148 } }

  class TestModel < described_class # rubocop:disable Lint/ConstantDefinitionInBlock,RSpec/LeakyConstantDeclaration
    field :title
    field :genre
    field :duration, type: :integer

    csv_filename file_path
  end

  describe ".create" do
    it "creates a new instance and saves it to the CSV" do
      model = TestModel.create(attributes)
      expect(model).to be_a(TestModel)
      expect(model[:id]).to eq(1)
      expect(TestModel.all).to eq([model])
    end

    it "auto-increments the ID" do
      model1 = TestModel.create(attributes)
      model2 = TestModel.create(title: "The Matrix", genre: "Sci-Fi", duration: 136)
      expect(model1[:id]).to eq(1)
      expect(model2[:id]).to eq(2)
    end
  end

  describe ".find" do
    it "finds an instance by ID" do
      model = TestModel.create(attributes)
      found_model = TestModel.find(model[:id])
      expect(found_model).to eq(model)
    end

    it "returns nil if not found" do
      expect(TestModel.find(999)).to be_nil
    end
  end

  describe ".all" do
    it "returns all instances" do
      TestModel.create(attributes)
      TestModel.create(title: "The Matrix", genre: "Sci-Fi", duration: 136)
      expect(TestModel.all.size).to eq(2)
    end

    it "returns an empty array if there are no instances" do
      expect(TestModel.all).to eq([])
    end
  end

  describe ".where" do
    before do
      TestModel.create(attributes)
      TestModel.create(title: "The Matrix", genre: "Sci-Fi", duration: 136)
    end

    it "filters instances based on conditions" do
      filtered_models = TestModel.where(genre: "Sci-Fi")
      expect(filtered_models.size).to eq(2)
    end

    it "returns an empty array if no match" do
      filtered_models = TestModel.where(genre: "Comedy")
      expect(filtered_models).to eq([])
    end
  end

  describe "#save" do
    it "saves a new instance to the CSV" do
      model = TestModel.new(attributes)
      expect(model.save).to be_truthy
      expect(TestModel.all).to eq([model])
    end

    it "updates an existing instance in the CSV" do
      model = TestModel.create(attributes)
      model[:title] = "Updated Title"
      expect(model.save).to be_truthy
      expect(TestModel.find(model[:id])[:title]).to eq("Updated Title")
    end
  end

  describe "#update" do
    it "updates attributes and saves" do
      model = TestModel.create(attributes)
      model.update(title: "Updated Title")
      expect(model[:title]).to eq("Updated Title")
      expect(TestModel.find(model[:id])[:title]).to eq("Updated Title")
    end
  end

  describe "#destroy" do
    it "deletes the instance from the CSV" do
      model = TestModel.create(attributes)
      model.destroy
      expect(TestModel.all).to eq([])
    end
  end

  describe "type conversion" do
    it "converts integer fields" do
      model = TestModel.create(duration: "148")
      expect(model[:duration]).to be_a(Integer)
    end
  end

  describe "csv_filename" do
    it "allows setting a custom filename" do
      custom_path = "spec/tmp/custom_movies.csv"
      TestModel.csv_filename(custom_path)
      expect(TestModel.file_path).to eq(custom_path)
    end
  end
end
