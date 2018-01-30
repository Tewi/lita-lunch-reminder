
require "spec_helper"
require 'pry'
require 'dotenv/load'

describe Lita::Services::LunchAssigner, lita: true do
  
  # Test helper class 
  # Each new instance now has an isolated worksheet
  class SpreadsheetWriterTest < Lita::Services::SpreadsheetWriter
    @@written_files = []
    def initialize
      super
      test_name = "test-#{rand.to_s[-8..-1]}"
      @ws = @spreadsheet.add_worksheet(test_name)
      @@written_files << test_name
    end  

    def self.written_files
      @@written_files
    end
  end

  # Clean up the test worksheets from the drive when done  
  after(:all) do 
    spreadsheet = Lita::Services::SpreadsheetWriter.new.spreadsheet
    worksheets = spreadsheet.worksheets
    worksheets.select { |w| SpreadsheetWriterTest.written_files.include? w.title }
              .each(&:delete)
  end
  
  context "on a new empty worksheet" do
    let!(:spreadsheetWriter) { SpreadsheetWriterTest.new }
    let!(:spreadsheet) { spreadsheetWriter.spreadsheet }
    let!(:worksheet) { spreadsheetWriter.worksheet }

    describe "#write_new_row" do
      context "when given an array with values" do 
        it "should write the array in the last row, each value in it's own column" do
          array = [*0..5]
          write_flag = spreadsheetWriter.write_new_row(array)
          expect(write_flag).to eq(true)
          expect(worksheet.rows.last).to eq(array.map(&:to_s))
        end
      end

      context "given an empty array" do
        it "should not write in the worksheet and return false" do 
          write_flag = spreadsheetWriter.write_new_row([]) 
          expect(write_flag).to eq(false)
        end
      end
    end
  end
end
