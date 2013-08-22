module Enumerable

  def sum_e
    self.reduce(0){|accum, i| accum + i }
  end

  def mean
    self.sum_e/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.reduce(0){|accum, i| accum + (i-m)**2 }
    sum/self.length.to_f
  end

  def standard_deviation
     Math.sqrt(self.sample_variance)
  end

end