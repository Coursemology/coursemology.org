class PythonEvaluator
  require 'fileutils'

  def self.get_asm_file_path(assign)
    "#{Rails.root}/#{assign.class.to_s}/#{assign.id}/files/"
  end

  def self.create_local_file_for_asm(asm, file)
    dir = get_asm_file_path(asm)

    FileUtils.mkdir_p(dir) unless File.exist?(dir)

    path = File.join(dir, file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
  end

  def self.get_tmp_file_name(dir, extension = "")
    rand_str = ''
    begin
      rand_str = (0...20).map{ ('a'..'z').to_a[rand(26)] }.join
      full_path = File.join(dir, rand_str + extension)
    end while File.exist?(full_path)
    full_path
  end

  def self.combine_code(c1, c2)
    c1 << '
' << c2
  end

  def self.add_importing_code(code)
    #change the default directory to current file's directory
'import os
os.chdir(os.path.dirname(os.path.realpath(__file__)))
' << code
  end

  def self.eval_python(dir, code, data, eval = false)
    file_path = PythonEvaluator.get_tmp_file_name(dir, ".py")
    code = add_importing_code(code)

    tests = {publicTests: data["publicTests"],
             privateTests:data["privateTests"],
             evalTests:   data["evalTests"]}

    time_limit = data["timeLimitInSec"]
    memory_limit = data["memoryLimitInMB"]

    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    summary ={publicTests: [],privateTests: [], evalTests: [],errors:[]}
    range = eval ? 2 : 1

    #user could print to stdout, use unique hash to filter out test results
    hash = Digest::MD5.hexdigest(file_path)

    for i in 0..range
      file = File.open(file_path, 'w+')
      #code = code % [memory_limit.to_i * 1024, memory_limit.to_i * 1024, time_limit, time_limit]
      if file
        file.write(code)
        case i
          when 0
            test_type = :publicTests
          when 1
            test_type = :privateTests
          else
            test_type = :evalTests
        end
        test_cases = tests[test_type]
        test_code = ''
        puts tests
        test_cases.each do |test|
          test_code << "\nprint('#{hash} %r' % (#{test["expression"]} == #{test["expected"]}))\n"
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
        puts "stdout",stdout
        results = stdout.split("\n").select{|r| r.include? hash }.map{|r| if r.gsub(hash + " ", '').gsub("\n",'') == "True" then true else false end}
        puts "results",results
        File.delete(file_path)

        exec_fail = (!status.success? and errors.length == 0)

        if  status.to_s.include?('(signal 24)')
          errors = "CPU time limit exceeded: running time limit set to #{time_limit} second to prevent possible infinite loop."
        end

        if exec_fail
          errors = "You might have an infinite loop or your recursion level is too deep."
        end

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

end