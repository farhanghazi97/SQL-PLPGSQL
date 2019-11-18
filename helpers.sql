-- COMP3311 19T3 Assignment 3
-- Helper views and functions (if needed)

CREATE OR REPLACE VIEW Q1a(id, code, title, quota) AS
	select c.id, s.code, s.title, c.quota from courses c 
	join subjects s on (c.subject_id = s.id)                                       
	join terms t on (c.term_id = t.id)                                             
	where t.name='19T3' and c.quota > 50;

CREATE OR REPLACE VIEW Q1b(code , quota, count) AS
	select q.code, q.quota, count(c.person_id) 
	from q1a q join course_enrolments c on (c.course_id = q.id)           
	group by q.code, q.quota
	order by q.code;

CREATE OR REPLACE VIEW Q1c(id, title, quota, count) AS
	select q1.code, q1.title, q1.quota, q2.count 
	from q1a q1
	join q1b q2 on (q1.code = q2.code)
	where q2.count > q1.quota
	order by q1.code;

CREATE OR REPLACE VIEW Q2a(code, count) AS
	select substring(code, 5, 4), count(substring(code, 5, 4)), string_agg(substring(code,0,5), ' ')                                                              from subjects                                                                                                                                                 group by substring(code, 5, 4)                                                                                                                                order by count(substring(code, 5, 4)) desc, substring(code,5,4) asc;

CREATE OR REPLACE VIEW Q3a(id, code, title, quota) AS
	select c.id, s.code, s.title, c.quota from courses c 
	join subjects s on (c.subject_id = s.id)                                      
	join terms t on (c.term_id = t.id)                                            
	where t.name='19T2'
	order by s.code;

CREATE TYPE CourseData AS (course_id integer, code character(8), title text);

CREATE OR REPLACE FUNCTION Q3b(letter_code text)
	RETURNS SETOF CourseData AS
$$
	DECLARE
		tuple RECORD;
		result CourseData;
		search_query text;
	BEGIN
		search_query := '%' || letter_code || '%';
		FOR tuple IN
			SELECT * FROM Q3a WHERE code ILIKE search_query
		LOOP
			result.course_id := tuple.id;
			result.code := tuple.code;
			result.title := tuple.title;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE CourseClassData AS (course_id integer, code character(8), title text, class_id integer);

CREATE OR REPLACE FUNCTION Q3c(letter_code text)
	RETURNS SETOF CourseClassData AS
$$
	DECLARE
		tuple RECORD;
		result CourseClassData;
	BEGIN 
		FOR tuple IN
			select q.course_id, q.code, q.title, c.id from q3b(letter_code) as q  
			join classes c on (c.course_id = q.course_id) 
			group by q.course_id, q.code, q.title, c.id 
			order by q.course_id
		LOOP
			result.course_id = tuple.course_id;
			result.code = tuple.code;
			result.title = tuple.title;
			result.class_id = tuple.id;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE CourseClassBuildingData AS (course_id integer, code character(8), title text, room_id integer, building_name text);

CREATE OR REPLACE FUNCTION Q3d(letter_code text)
	RETURNS SETOF CourseClassBuildingData AS
$$
	DECLARE
		tuple RECORD;
		result CourseClassBuildingData;
	BEGIN
		FOR tuple IN
			select distinct q.course_id, q.code, q.title, m.room_id, b.name from q3c(letter_code) as q
			join meetings m on (q.class_id = m.class_id)
			join rooms r on (m.room_id = r.id)
			join buildings b on (b.id = r.within)
			order by b.name
		LOOP
			result.course_id = tuple.course_id;
			result.code = tuple.code;
			result.title = tuple.title;
			result.room_id = tuple.room_id;
			result.building_name = tuple.name;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE CourseByLocation AS (list_of_courses text, location text);

CREATE OR REPLACE FUNCTION Q3e(letter_code text)
	RETURNS SETOF CourseByLocation AS
$$
	DECLARE
		tuple RECORD;
		result CourseByLocation;
	BEGIN
		FOR tuple IN
			select string_agg(code, ' ') as course_list, building_name from q3d(letter_code) group by building_name order by building_name
		LOOP
			result.list_of_courses := tuple.course_list;
			result.location := tuple.building_name;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE CourseDataByTerm AS (subject_id integer, term character(4), code character(8), title text, quota integer); 

CREATE OR REPLACE FUNCTION Q4a(letter_code text)
	RETURNS SETOF CourseDataByTerm AS
$$
	DECLARE
		search_query text; 
		tuple RECORD;
		result CourseDataByTerm;
	BEGIN
		search_query := '%' || letter_code || '%';
		FOR tuple IN
			select c.id, t.name, s.code, s.title, c.quota from courses c 
			join subjects s on (c.subject_id = s.id)                                      
			join terms t on (c.term_id = t.id)                                            
			where ((t.name='19T0' or t.name='19T1' or t.name='19T2' or t.name='19T3') AND (s.code ILIKE search_query))
			order by t.name
		LOOP
			result.subject_id := tuple.id;
			result.term := tuple.name;
			result.code := tuple.code;
			result.title := tuple.title;
			result.quota := tuple.quota;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE EnrolmentCountBySubject AS (term character(4), code character(8), quota integer, count integer);

CREATE OR REPLACE FUNCTION Q4b(letter_code text)
	RETURNS SETOF EnrolmentCountBySubject AS
$$
	DECLARE
		tuple RECORD;
		result EnrolmentCountBySubject;
	BEGIN
		FOR tuple IN
			select q.term, q.code, q.quota, count(c.person_id) as count, q.term 
			from q4a(letter_code) as q join course_enrolments c on (c.course_id = q.subject_id)                   
			group by q.code, q.quota, q.term                                                                                                                              order by q.term, q.code
		LOOP
			result.term := tuple.term;
			result.code := tuple.code;
			result.quota := tuple.quota;
			result.count := tuple.count;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION Q5a(course_code text)
	RETURNS SETOF CourseDataByTerm AS
$$
	DECLARE
		search_query text;
		tuple RECORD;
		result CourseDataByTerm;
	BEGIN
		search_query := '%' || course_code || '%';
		FOR tuple IN
			select c.id, t.name, s.code, s.title, c.quota from courses c 
			join subjects s on (c.subject_id = s.id)                                      
			join terms t on (c.term_id = t.id)                                            
			where t.name = '19T3' and s.code ILIKE search_query
		LOOP
			result.subject_id := tuple.id;
			result.term := tuple.name;
			result.code := tuple.code;
			result.title := tuple.title;
			result.quota := tuple.quota;
			RETURN NEXT result;
		END LOOP;
			
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE CourseAllClassData AS (subject_id integer, code character(8), title text, class_type text, enrol_count integer, quota integer, tag character(4));

CREATE OR REPLACE FUNCTION Q5b(course_code text)
	RETURNS SETOF CourseAllClassData AS
$$
	DECLARE
		tuple RECORD;
		result CourseAllClassData;
	BEGIN
		FOR tuple IN
			select q.subject_id, q.code, q.title, ct.name, count(ce.person_id) as student_count, c.quota, c.tag 
			from q5a(course_code) as q 
			join classes c on (q.subject_id = c.course_id) 
			join class_enrolments ce on (c.id = ce.class_id) 
			join classtypes ct on (c.type_id = ct.id)
			group by q.subject_id, q.code, q.title, ct.name, c.quota, c.tag
		LOOP
			result.subject_id := tuple.subject_id;
			result.code := tuple.code;
			result.title := tuple.title;
			result.class_type := tuple.name;
			result.enrol_count := tuple.student_count;
			result.quota := tuple.quota;
			result.tag := tuple.tag;
			RETURN NEXT result;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE ClassRoomData AS (room_id integer, room_code character(15), term character(4), day weekday, start_time daytime, end_time daytime, weeks text);

CREATE OR REPLACE FUNCTION Q7a(term_code character(4))
	RETURNS SETOF ClassRoomData AS
$$
	DECLARE
		tuple RECORD;
		result ClassRoomData;
	BEGIN
		FOR tuple IN
			select r.id, r.code, t.name, m.day, m.start_time, m.end_time, substring(m.weeks_binary, 1, 10) as weeks
    			from terms t
    			join courses c on (c.term_id = t.id)
    			join classes cl on (cl.course_id = c.id)
    			join meetings m on (m.class_id = cl.id)
    			join rooms r on (m.room_id = r.id)
    			where r.code ilike 'K-%' and t.name = term_code
    			order by t.name, r.code, m.day, m.start_time
		LOOP
			result.room_id := tuple.id;
			result.room_code := tuple.code;
			result.term := tuple.name;
			result.day := tuple.day;
			result.start_time := tuple.start_time;
			result.end_time := tuple.end_time;
			result.weeks := tuple.weeks;
			RETURN NEXT tuple;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE RoomData AS (room_id integer, room_code character(15), room_data text);

CREATE OR REPLACE FUNCTION Q7b(term_code character(4))
	RETURNS SETOF RoomData AS
$$
	DECLARE
		tuple RECORD;
		result RoomData;
	BEGIN
		FOR tuple IN
			select q.room_id, q.room_code, concat(q.start_time,';',q.end_time,';',q.weeks) as room_data
			from q7a(term_code) q
			order by q.room_id
		LOOP
			result.room_id := tuple.room_id;
			result.room_code := tuple.room_code;
			result.room_data := tuple.room_data;
			RETURN NEXT tuple;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE RoomUsageData AS (room_id integer, room_code character(15), room_usage_info text);

CREATE OR REPLACE FUNCTION Q7c(term_code character(4))
	RETURNS SETOF RoomUsageData AS
$$
	DECLARE
	 	tuple RECORD;
		result RoomUsageData;		
	BEGIN
		FOR tuple IN
			select q.room_id, q.room_code, string_agg(q.room_data, ' ') as room_usage_info
			from q7b(term_code) q
			group by q.room_id, q.room_code
			order by q.room_id
		LOOP
			result.room_id := tuple.room_id;
			result.room_code := tuple.room_code;
			result.room_usage_info := tuple.room_usage_info;
			RETURN NEXT tuple;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;

CREATE TYPE ClassData AS (course_id integer, class_id integer, term character(4), course_code character(8), course_title text, class_type text, day weekday, start_time daytime, end_time daytime);

CREATE OR REPLACE FUNCTION Q8a(course_code character(8))
	RETURNS SETOF ClassData AS
$$
	DECLARE
		tuple RECORD;
		result ClassData;
	BEGIN
		FOR tuple IN
			select c.id, m.class_id, t.name as term, s.code, s.title, ct.name as cls_type, m.day, m.start_time, m.end_time 
			from courses c 
			join classes cl on (cl.course_id = c.id) 
			join subjects s on (s.id = c.subject_id) 
			join terms t on (t.id = c.term_id) 
			join meetings m on (m.class_id = cl.id) 
			join classtypes ct on (ct.id = cl.type_id) 
			where t.name = '19T3' and s.code = course_code		
		LOOP
			result.course_id := tuple.id;
			result.class_id := tuple.class_id;
			result.term := tuple.term;
			result.course_code := tuple.code;
			result.course_title := tuple.title;
			result.class_type := tuple.cls_type;
			result.day := tuple.day;
			result.start_time := tuple.start_time;
			result.end_time := tuple.end_time;
			RETURN NEXT tuple;
		END LOOP;
	END;
$$
LANGUAGE PLPGSQL;
