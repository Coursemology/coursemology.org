class MissionConstraint
  def matches?
    a = Assessment.find_by_id(request.path_parameters[:assessment_id])
    a && a.is_mission?
  end
end