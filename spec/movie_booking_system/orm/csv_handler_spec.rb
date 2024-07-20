# frozen_string_literal: true

RSpec.describe MovieBookingSystem::CSVHandler do # rubocop:disable RSpec/SpecFilePathFormat
  let(:csv_handler) { described_class.new(file_path, headers) }

  let(:file_path) { "spec/tmp/test_data.csv" }
  let(:headers) { %i[id title genre duration] }

  shared_examples "csv data operations" do
    it "writes rows to the CSV" do
      data.each { |row| csv_handler.write_row(row) }
      expect(csv_handler.load_all).to eq(expected_data)
    end

    it "finds a row by ID" do
      csv_handler.write_row(data[0]) # Add one row for testing
      expect(csv_handler.find_by_id(data[0][:id])).to eq(data[0])
    end

    it "updates a row by ID" do
      csv_handler.write_row(data[0]) # Add one row for testing
      csv_handler.update_row(data[0][:id], { title: "Updated Title" })
      expect(csv_handler.find_by_id(data[0][:id])[:title]).to eq("Updated Title")
    end
  end

  describe "with no existing file" do
    let(:data) do
      [
        { title: "The Shawshank Redemption", genre: "Drama", duration: 142 },
        { title: "The Godfather", genre: "Crime", duration: 175 }
      ]
    end
    let(:expected_data) { data.map.with_index { |row, i| row.merge(id: i + 1) } }

    include_examples "csv data operations"
  end

  describe "with an existing file" do
    before do
      CSV.open(file_path, "wb") do |csv|
        csv << headers
        csv << [1, "Pulp Fiction", "Crime", 154]
      end
    end

    let(:data) do
      [
        { title: "The Shawshank Redemption", genre: "Drama", duration: 142 },
        { title: "The Godfather", genre: "Crime", duration: 175 }
      ]
    end
    let(:expected_data) do
      [
        { id: 1, title: "Pulp Fiction", genre: "Crime", duration: 154 }
      ] + data.map.with_index { |row, i| row.merge(id: i + 2) }
    end

    include_examples "csv data operations"

    it "deletes a row by ID" do
      csv_handler.delete_row(1)
      expect(csv_handler.load_all).to eq([])
    end
  end
end
