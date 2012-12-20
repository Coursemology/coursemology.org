module Requirable
  # it is an interface but ruby does not seems to have the 
  # concept of interface
  def get_req_short_desc
    raise NotImplementedError
  end
end
