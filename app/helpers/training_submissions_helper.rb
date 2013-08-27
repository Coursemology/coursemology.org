module TrainingSubmissionsHelper
  require 'open3'
  # To change this template use File | Settings | File Templates.
  @@path_temp_folder = "#{Rails.root}/paths/tmp/"
  def get_tmp_file_name
    rand_str = ''
    begin
      rand_str = (0...20).map{ ('a'..'z').to_a[rand(26)] }.join
      full_path = @@path_temp_folder + rand_str + '.py'
    end while File.exist?(full_path)

    full_path
  end

  def get_code_to_write(included_code,code_to_run)
'import resource
resource.setrlimit(resource.RLIMIT_AS, (1000, 1000))
resource.setrlimit(resource.RLIMIT_CPU, (2, 2))
resource.setrlimit(resource.RLIMIT_NOFILE, (0, 0))' <<'
' << code_to_run  << '
' << included_code

  end

  def eval_python(file_path,code, data)
    tests = {publicTests:data["publicTests"],
             privateTests:data["privateTests"]}
    timeLimit = data["timeLimitInSec"]
    memoryLimit = data["memoryLimitInMB"]
    FileUtils.mkdir_p(@@path_temp_folder) unless File.exist?(@@path_temp_folder)
    summary ={publicTests:[],privateTests:[],errors:[]}
    for i in 0..1
      file = File.open(file_path, 'w+')
      #code = code % [memoryLimit.to_i * 1024, memoryLimit.to_i * 1024, timeLimit, timeLimit]
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

        #stdout,stderr,status = Open3.capture3("time python3 #{file_path}")
        #puts "out: ", stdout
        #puts "err: ", stderr
        #puts "status: ", status
        #@stdin,@stdout,@stderr = Open3.pipeline_start("python3 #{file_path}") {|ts|
        #  sleep 2
        #  t = ts[0]
        #  Process.kill("TERM", t.pid)
        #  p t.value #=> #<Process::Status: pid 911 SIGTERM (signal 15)>
        #}
        #@stderr, @stderw = IO.pipe
        @stdout,@stderr, status = Open3.capture3("python3 #{file_path}")
        errors = @stderr
        stdout = @stdout
        results = stdout.split("\n").map{|r| if r.gsub("\n",'') == "True" then true else false end}
        File.delete(file_path)

        exec_fail = !status.success?

        if  status.to_s.include?('(signal 24)')
          errors = "CPU time limit exceeded: running time limit set to #{timeLimit} second to prevent possible infinite loop."
        end

        puts '----', status.success?, status.to_s
        unless status.success?
           errors = "You might have an infinite loop or your recursion level is too deep."
        end

        test_type = if i == 0 then :publicTests else :privateTests end
        summary[test_type] = results
        if errors.length > 0
          error_message = errors.scan(/", line \d*.(.*)/m).map{ |m| m}
          error_array = errors.split("\n")
          if error_array.length > 10
            #don't display super long error message
            error_message = error_array.last.split("\n")
          end
          summary[:errors] = exec_fail ? errors : error_message.join
          break
        end

      end
    end
    summary
  end

  def eval_python2(file_path, code, data)
    tests = {publicTests:data["publicTests"],
             privateTests:data["privateTests"]}
    timeLimit = data["timeLimitInSec"]
    memoryLimit = data["memoryLimitInMB"]
    FileUtils.mkdir_p(@@path_temp_folder) unless File.exist?(@@path_temp_folder)
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

        @stdin,@stdout,@stderr = Open3.popen3("python3 #{@@path_temp_folder}#{"exec.py -t "<< timeLimit << " -m "<<memoryLimit << " "<< file_path}")
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
