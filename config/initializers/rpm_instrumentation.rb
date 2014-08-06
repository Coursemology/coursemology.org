require 'new_relic/agent/method_tracer'

Assessment::TrainingSubmissionsController.class_eval do
  include ::NewRelic::Agent::MethodTracer

  add_method_tracer :submit
  add_method_tracer :submit_mcq
  add_method_tracer :submit_code
end  
