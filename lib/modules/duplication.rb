module Duplication

  class Duplicator
    def duplicate_asm_no_log(asm)
      clone = asm.dup
      # duplicate question and create new asm_qn links
      asm.asm_qns.each do |asm_qn|
        clone_qn = asm_qn.qn.dup
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
      clone = course.dup
      clone.title += ' (clone)'
      clone.creator = user
      user_course = clone.user_courses.build
      user_course.user = user
      user_course.role = Role.find_by_name(:lecturer)
      clone.save

      clone_map = {}

      # clone the entity
      (course.missions + course.trainings + course.quizzes).each do |asm|
        clone_asm = duplicate_asm_no_log(asm)
        clone_asm.course = clone
        clone_asm.save
        clone_map[asm] = clone_asm
      end

      (course.levels + course.achievements + course.tags + course.tag_groups).each do |obj|
        clone_obj = obj.dup
        clone_obj.course = clone
        clone_obj.save
        clone_map[obj] = clone_obj
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

      return clone
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
