class Float
  def signif num_digits
    require 'flt'
    Flt::DecNum.context.precision = num_digits
    (+Flt::DecNum(self.to_s)).to_f
  end
end