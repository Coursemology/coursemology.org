module TrainingSubmissionsHelper
  require 'open3'
  # To change this template use File | Settings | File Templates.

  def get_tmp_path
    "#{Rails.root}/paths/tmp/"
  end

  def get_code_to_write(included_code, code_to_run)
included_code << '
import resource
#resource.setrlimit(resource.RLIMIT_AS, (1000, 1000))
resource.setrlimit(resource.RLIMIT_CPU, (4, 4))' <<'
' << code_to_run

  end

  def eval_python2(file_path, code, data)
    tests = {publicTests:data["publicTests"],
             privateTests:data["privateTests"]}
    timeLimit = data["timeLimitInSec"]
    memoryLimit = data["memoryLimitInMB"]
    FileUtils.mkdir_p(path_temp_folder) unless File.exist?(path_temp_folder)
    summary ={publicTests:[],privateTests:[],errors:[]}
    for i in 0..1
      file = File.open(file_path, 'w+')
      if file
        file.write(code)
        case i
          when 0
            test_type = tests[:publicTests]
          when 1
            test_type = tests[:privateTests]
        end
        test_code = ''
        test_type.each do |test|
          test_code << "\nprint(#{test["expression"]} == #{test["expected"]})\n"
        end
        file.write(test_code)
        file.close

        @stdin,@stdout,@stderr = Open3.popen3("python3 #{path_temp_folder}#{"exec.py -t "<< timeLimit << " -m "<<memoryLimit << " "<< file_path}")
        output = @stdout.readlines
        @stdin.close
        @stderr.close
        @stdout.close
        File.delete(file_path)


        if output.size == 1
          summary[:errors] = "Your solution was rejected as it exceeded the time limit for this question."
          break
        end

        trace = JSON.parse(output.join)["trace"]

        if trace["event"] != "return"
          summary[:errors] = trace["event"] << "\n  " << trace["exception_msg"]
          break
        end

        results = trace["stdout"].split("\n")
        test_type = if i == 0 then :publicTests else :privateTests end
        summary[test_type] = results.map {|r| if r == 'False' then false else true end }

      end
    end
    summary
  end
end
