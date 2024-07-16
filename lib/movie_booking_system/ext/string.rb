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
end
