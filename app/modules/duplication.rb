module Duplication

  class Duplicator

    def duplicate_qn_no_log(qn)
      clone_qn = qn.dup
      if qn.is_a?(Mcq)
        qn.mcq_answers.each do |ma|
          clone_ma = ma.dup
          clone_qn.mcq_answers << clone_ma
        end
      end
      return clone_qn
    end

    def duplicate_asm_no_log(asm)
      clone = asm.dup
      # duplicate question and create new asm_qn links
      asm.asm_qns.each do |asm_qn|
        clone_qn = duplicate_qn_no_log(asm_qn.qn)
        new_link = asm_qn.dup
        new_link.qn = clone_qn
        clone.asm_qns << new_link
      end
      return clone
    end

    # duplicate an assignment and its question
    def duplicate_asm(user, asm, origin_course, dest_course)
      clone = duplicate_asm_no_log(asm)
      clone.course = dest_course
      clone.save

      # log the duplication
      dl = DuplicateLog.new
      dl.user = user
      dl.origin_course = origin_course
      dl.origin_obj = asm
      dl.dest_course = dest_course
      dl.dest_obj = clone
      dl.save

      return clone
    end

    # deep duplicate a course, return the cloned course
    def duplicate_course(user, course)
      Course.skip_callback(:create, :before, :populate_preference)
      Course.skip_callback(:create, :after, :create_materials_root)
      clone = course.dup
      clone.title += ' (clone)'
      clone.creator = user
      user_course = clone.user_courses.build
      user_course.user = user
      user_course.role = Role.find_by_name(:lecturer)
      clone.save
      Course.set_callback(:create, :before, :populate_preference)
      Course.set_callback(:create, :after, :create_materials_root)

      clone_map = {}

      # clone the entity
      (course.missions + course.trainings).each do |asm|
        clone_asm = duplicate_asm_no_log(asm)
        clone_asm.course = clone
        clone_asm.save
        clone_map[asm] = clone_asm
      end

      (course.levels + course.achievements + course.tag_groups).each do |obj|
        clone_obj = obj.dup
        clone_obj.course = clone
        clone_obj.save
        clone_map[obj] = clone_obj
      end

      course.tag_groups.each do |tg|
        tg.tags.each do |tag|
          clone_obj = tag.dup
          clone_obj.course = clone
          clone_obj.tag_group = clone_map[tg]
          clone_obj.save
          clone_map[tag] = clone_obj
        end
      end

      course.course_preferences.each do |pref|
        clone_pref = pref.dup
        clone_pref.course = clone
        clone_pref.save
      end

      # log the duplication
      dl = DuplicateLog.new
      dl.user = user
      dl.origin_course = course
      dl.origin_obj = course
      dl.dest_course = clone
      dl.dest_obj = clone
      dl.save

      # now clone the link
      course.tags.each do |tag|
        tag.asm_tags.each do |asm_tag|
          clone_link = asm_tag.clone
          clone_link.tag = clone_map[asm_tag.tag]
          clone_link.asm = clone_map[asm_tag.asm]
          clone_link.save
        end
      end

      course.achievements.each do |ach|
        ach.requirements.ach_req.each do |ar|
          clone_link = ar.dup
          clone_link.obj = clone_map[ach]
          clone_link.req = clone_map[ar.req]
          clone_link.save
        end

        ach.requirements.asm_req.each do |ar|
          clone_link = ar.dup
          clone_link.obj = clone_map[ach]
          clone_asm_req = ar.req.dup
          clone_asm_req.asm = clone_map[ar.req.asm]
          clone_link.req = clone_asm_req
          clone_link.save
        end
      end

      #clone materials
      course.material_folder.dup_course(clone, clone_map)

      #clone lesson plan milestone
      course.lesson_plan_milestones.each do |milestone|
        clone_milestone = milestone.dup
        clone_milestone.course = clone
        clone_milestone.save
      end

      #clone lesson plan entries
      course.lesson_plan_entries.each do |entry|
        clone_entry = entry.dup
        clone_entry.course = clone
        clone_entry.save

        entry.resources.each do |entry_resource|
          clone_er = entry_resource.dup
          clone_er.lesson_plan_entry = clone_entry
          if clone_map.has_key? entry_resource.obj
            clone_er.obj = clone_map[entry_resource.obj]
          end
          clone_er.save
        end
        end

      clone
    end
  end

  def Duplication.duplicate_asm(user, asm, origin_course, dest_course)
    d = Duplicator.new
    return d.duplicate_asm(user, asm, origin_course, dest_course)
  end

  def Duplication.duplicate_course(user, course)
    d = Duplicator.new
    return d.duplicate_course(user, course)
  end
end
