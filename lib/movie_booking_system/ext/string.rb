# frozen_string_literal: true

class String
  def pluralize
    if end_with?("y") && !end_with?("ay", "ey", "iy", "oy", "uy")
      "#{self[0..-2]}ies"
    elsif end_with?("z")
      "#{self}zes"
    elsif end_with?("s", "x", "ch", "sh")
      "#{self}es"
    else
      "#{self}s"
    end
  end

  def singularize
    if end_with?("ies") && !end_with?("aies", "eies", "iies", "oies", "uies")
      "#{self[0..-4]}y"
    elsif end_with?("zes")
      (self[0..-4]).to_s
    elsif end_with?("es") && end_with?("ses", "xes", "ches", "shes")
      (self[0..-3]).to_s
    else
      end_with?("s") ? (self[0..-2]).to_s : self
    end
  end

  def underscore
    gsub("::", "/")
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end
end
