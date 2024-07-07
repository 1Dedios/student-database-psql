#!/bin/bash
# Script to insert data from courses.csv and students.csv into students database

PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"

# COMMAND BELOW DROPS ALL DATA FROM THE TABLES - KEEP IN MIND TO ADD OR DELETE AS NECESSARY 
echo $($PSQL "TRUNCATE students, majors, courses, majors_courses")

cat courses.csv | while IFS="," read MAJOR COURSE
do
        if [[ $MAJOR != major ]]
        then
	        MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
        
		if [[ -z $MAJOR_ID ]]
        	then

                	INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) values('$MAJOR')")

                	if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
                	then
                        	echo Inserted into majors, $MAJOR
                	fi
                	
			MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
        	fi
                
		COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")
                # if not found
                if [[ -z $COURSE_ID ]]
                then
                        
			INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) values('$COURSE')")

                        if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]
                        then
                                echo Inserted into courses, $COURSE
                        fi
                        
			COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")

                fi
                
		INSERT_MAJORS_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses(major_id, course_id) values($MAJOR_ID, $COURSE_ID)")

                if [[ $INSERT_MAJORS_COURSES_RESULT == "INSERT 0 1" ]]
                then
                        echo Inserted into majors_courses, $MAJOR : $COURSE
                fi

        fi
done


cat students.csv | while IFS="," read FIRST LAST MAJOR GPA
do
        if [[ $FIRST != first_name ]]
        then
                
		MAJOR_ID=$($PSQL "SELECT major_id FROM majors where major='$MAJOR'")
                
		if [[ -z $MAJOR_ID ]]
                then
                        MAJOR_ID='null'
                fi

                INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO students(first_name, last_name, major_id, gpa) VALUES('$FIRST', '$LAST', $MAJOR_ID, $GPA)")
                
		if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
                then
                        echo Inserted into students, $FIRST $LAST
                fi
        fi
done
