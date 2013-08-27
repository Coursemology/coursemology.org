class AsmQnsController < ApplicationController

  def reorder
    # binding.pry
    params['asm-qn'].each_with_index do |id, index|
      # binding.pry
      AsmQn.update_all("pos = #{index}", "id = #{id}");
    end
    # binding.pry

    render nothing: true
  end

end
