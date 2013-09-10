delete from seen_by_users where id not in 
	(select * from 
		(select distinct(del.id) from (
			select id, obj_id, obj_type, user_course_id, MAX(created_at) as created_at 
			from seen_by_users 
			group by obj_id, obj_type, user_course_id) 
		as del INNER JOIN seen_by_users AS hs ON
		hs.obj_type=del.obj_type
		AND hs.obj_id = del.obj_id
		AND hs.user_course_id=del.user_course_id
		AND hs.created_at = del.created_at) as we)