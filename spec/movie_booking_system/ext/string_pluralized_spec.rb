# frozen_string_literal: true

RSpec.describe String do
  describe "#pluralize" do
    it 'adds "s" to regular words' do
      expect("cat".pluralize).to eq("cats")
      expect("dog".pluralize).to eq("dogs")
    end

    it 'adds "es" to words ending with "s", "x", "z", "ch", "sh"' do
      expect("bus".pluralize).to eq("buses")
      expect("box".pluralize).to eq("boxes")
      expect("quiz".pluralize).to eq("quizzes")
      expect("church".pluralize).to eq("churches")
      expect("brush".pluralize).to eq("brushes")
    end

    it 'changes "y" to "ies" if the word ends with "y" and is not preceded by a vowel' do
      expect("baby".pluralize).to eq("babies")
      expect("lady".pluralize).to eq("ladies")
    end

    it 'adds "s" to words ending with "y" preceded by a vowel' do
      expect("toy".pluralize).to eq("toys")
      expect("key".pluralize).to eq("keys")
    end
  end
end
