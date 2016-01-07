class PythonEvaluator
  require 'fileutils'
  require 'open3'

  def self.get_asm_file_path(assign)
    "#{Rails.root}/#{assign.class.to_s}/#{assign.id}/files/"
  end

  def self.get_exec_path
    "#{Rails.root}/python/sandbox/"
  end

  def self.get_sandbox_file
    "#{Rails.root}/python/sandbox/cos_sandbox.py"
  end

  def self.create_local_file_for_asm(asm, file)
    dir = get_asm_file_path(asm)

    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    path = File.join(dir, file.original_name)
    file.file.copy_to_local_file :original, path
  end

  def self.get_tmp_file_name(dir, extension = "")
    rand_str = ''
    begin
      rand_str = (0...20).map{ ('a'..'z').to_a[rand(26)] }.join
      full_path = File.join(dir, rand_str + extension)
    end while File.exist?(full_path)
    full_path
  end

  def self.combine_code(a)
    a.join("\n")
  end

  def self.eval_python(dir, code, qn, eval = false)
    file_path = PythonEvaluator.get_tmp_file_name(dir, ".py")

    data = qn.data_hash
    tests = {public: data["public"],
             private:data["private"],
             eval:   data["eval"]}

    time_limit = qn.time_limit
    # memory_limit = qn.memory_limit * 1024
    sandbox = File.open(get_sandbox_file, 'r')
    code = combine_code([sandbox.read, code])
    cmd = qn.language.cmd

    #if resource_limit
    #  code = combine_code(resource_limit(memory_limit, time_limit), code)
    #end


    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    summary ={public: [],private: [], eval: [],errors:[]}
    range = eval ? 2 : 1
    times = eval ? 1 : 0

    #user could print to stdout, use unique hash to filter out test results
    hash = Digest::MD5.hexdigest(rand().to_s)
    # Hash used for marking exceptions in private tests
    error_hash = Digest::MD5.hexdigest(rand().to_s)

    for time in 0..times
      for i in 0..range
        file = File.open(file_path, 'w+')
        #code = code % [memory_limit.to_i * 1024, memory_limit.to_i * 1024, time_limit, time_limit]
        unless file
          next
        end
        file.write(code)
        need_std_answer = time == 1
        case i
          when 0
            test_type = :public
            result_type = :publicResults
          when 1
            test_type = :private
            result_type = :privateResults
          else
            test_type = :eval
            result_type = :evalResults
        end

        test_cases = tests[test_type]
        test_code = ''
        if eval
          test_cases.each do |test|
            exp =  need_std_answer ? "#{test["expression"]}" : "(#{test["expression"]}) == (#{test["expected"]})"
            exp_excep = need_std_answer ? "e" : "False"
            test_code << "\ntry:\n"
            test_code << "    print('#{hash} {0}'.format(#{exp}))\n"
            test_code << "except Exception as e:\n"
            test_code << "    print('#{hash} {0}'.format(#{exp_excep}))\n"
          end
        else
          test_cases.each do |test|
            exp = "(#{test["expression"]}) == (#{test["expected"]})"
            if test_type == :private
              test_code << "\ntry:\n"
              test_code << "    print('#{hash} {0}'.format(#{exp}))\n"
              test_code << "except Exception as e:\n"
              test_code << "    print('#{hash} #{error_hash}')\n"
            else
              test_code << "\nprint('#{hash} {0}'.format(#{exp}))\n"
            end
          end
        end

        file.write(test_code)
        file.close

        Dir.chdir(dir){
          @stdout,@stderr, @status = Open3.capture3("#{cmd} #{file_path}")
        }
        errors = @stderr
        stdout = @stdout
        status = @status
        # puts "status", status
        # puts "stdout",stdout
        # puts "error", errors
        print_outs = stdout.split("\n").select{|r| r.include? hash }.map{|r| r.gsub(hash + " ", '').gsub("\n",'') }
        if need_std_answer
          #assuming a correct result no longer than 1000 characters
          results = print_outs.map{|r| r[0..1000]}
        else
          results = print_outs.map{|r| r == "True" ? true : false }
        end
        File.delete(file_path)

        exec_fail = (!status.success? and errors.length == 0)

        if status.to_s.include?('(signal 24)')
          summary[:errors] = "CPU time limit exceeded: running time limit set to #{time_limit} second to prevent possible infinite loop."
          break
        end

        if exec_fail
          errors = "You might have an infinite loop or your recursion level is too deep."
        end

        if errors == "" && @stdout && @stdout.include?(error_hash)
          errors = 'You answer raised an exception when running private test cases'
        end

        summary[need_std_answer ? result_type : test_type] = results
        if errors.length > 0
          error_array = errors.split("\n")

          err_len = error_array.length
          if err_len > 10
            #don't display super long error message, first 5  and last 5
            error_message = (error_array[0..5] + ["...\n"] + error_array[(err_len - 5)..-1]).join("\n")
          else
            error_message = errors.gsub(/File "(.+?)", line \d*[\n,]/m, '')
          end

          summary[:errors] = exec_fail ? errors : error_message
          break
        end
      end
    end
    summary
  end

end
