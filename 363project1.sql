#Item 1: creating Person table
create table Person (
Name char (20),
ID char (9) not null,
Address char (30),
DOB date,
Primary key (ID));

#Item 2: creating Instructor table
create table Instructor (
InstructorID char(9) not null references Person(ID),
Rank char(12),
Salary int,
Primary key (InstructorID));

#Item 3: creating Student table
create table Student (
StudentID char(9) not null references Person(ID),
Classification char(10),
GPA double,
MentorID char(9) references Instructor(InstructorID),
CreditHours int);

#Item 4: creating Course table
create table Course (
CourseCode char(6) not null,
CourseName char(50),
PreReq char(6));

#Item 5: creating Offering table
create table Offering (
CourseCode char(6) not null,
SectionNo int not null,
InstructorID char(9) not null references Instructor(InstructorID),
Primary key (CourseCode, SectionNo));

#Item 6: creating Enrollment table
create table Enrollment (
CourseCode char(6) not null,
SectionNo int not null,
StudentID char(9) not null references Student,
Grade char(4) not null,
Primary key (CourseCode, StudentID),
Foreign key (CourseCode, SectionNo) references Offering(CourseCode, SectionNo));

#Item 7: populating Person table
load xml local infile '/Users/samanthawilliams/coms363/Person.xml'
into table Person
rows identified by '<Person>';

#Item 8: populating Instructor table
load xml local infile '/Users/samanthawilliams/coms363/Instructor.xml'
into table Instructor
rows identified by '<Instructor>';

#Item 9: populating Student table
load xml local infile '/Users/samanthawilliams/coms363/Student.xml'
into table Student
rows identified by '<Student>';

#Item 10: populating Course table
load xml local infile '/Users/samanthawilliams/coms363/Course.xml'
into table Course
rows identified by '<Course>';

#Item 11: populating Offering table
load xml local infile '/Users/samanthawilliams/coms363/Offering.xml'
into table Offering
rows identified by '<Offering>';

#Item 12: populating Enrollment table
load xml local infile '/Users/samanthawilliams/coms363/Enrollment.xml'
into table Enrollment
rows identified by '<Enrollment>';

#Item 13
select s.StudentID, s.MentorID
from Student s
	where (s.Classification = "Junior" or s.Classification = "Senior")
    and s.GPA > 3.8;
    
#Item 14
select distinct e.CourseCode, e.SectionNo
from Enrollment e, Student s
	where s.Classification = "Sophomore" 
	and s.StudentID = e.StudentID;
    
#Item 15
select p.Name, i.Salary
from Instructor i, Person p
	where p.ID = i.InstructorID 
	and i.InstructorID in ( select s.MentorID
							from Student s
                            where s.Classification = "Freshman");
                            
#Item 16
select sum(i.Salary)
from Instructor i
	where i.InstructorID not in (select o.InstructorID from Offering o);
    
#Item 17
select p.Name, p.DOB
from Person p
	where Year(p.DOB) = 1976 
    and p.ID in (select s.StudentID
				from Student s);
                
#Item 18
select p.Name, i.Rank
from Person p, Instructor i
	where p.ID = i.InstructorID
    and i.InstructorID not in (select o.InstructorID from Offering o)
    and i.InstructorID not in (select s.MentorID from Student s);
    
#Item 19	
select p.ID, p.Name, p.DOB
from Person p, Student s
	where p.ID = s.StudentID
    and p.DOB in (select max(p.DOB)
   						from Person p);


#Item 20
select p.ID, p.DOB, p.Name
from Person p
	where p.ID not in (select s.StudentID
						from Student s)
	and p.ID not in (select i.InstructorID
						from Instructor i);
                        
#Item 21
select p.Name, 
	(select count(*)
	from Student s, Instructor i
	where s.MentorID = i.InstructorID
    and i.InstructorID = p.ID)
from Person p
	where p.ID in (select i.InstructorID
					from Instructor i);
                    
#Item 22
select s.Classification, count(s.Classification), format(avg(s.GPA), 2)
from Student s
	group by s.Classification;
    
#Item 23
select s.cc, min(s.myCount)
from (select e.CourseCode as cc, count(e.StudentID) as myCount
		from Enrollment e
        group by e.CourseCode) s;

#Item 24
select s.StudentID, s.MentorID
from Student s
	where s.StudentID in (select e.StudentID
							from Enrollment e
								where e.CourseCode in (select o.CourseCode
														from Offering o
															where o.InstructorID = s.MentorID));

#Item 25
select s.StudentID, p.name, s.CreditHours
from Student s, Person p
	where s.StudentID = p.ID
    and Year(p.DOB) >= 1976
    and s.Classification = "Freshman";
    
#Item 26
insert into Person(Name, ID, Address, DOB)
values("Briggs Jason", "480293439", "215 North Hyland Avenue", '1975-01-15');
insert into Student(StudentID, Classification, GPA, MentorID, CreditHours)
values("480293439", "Junior", 3.48, "201586985", 75);
insert into Enrollment(CourseCode, SectionNo, StudentID, Grade)
values("CS311", 2, "480293439", "A");
insert into Enrollment(CourseCode, SectionNo, StudentID, Grade)
values("CS330", 1, "480293439", "A-");

select *
from Person p
	where p.Name = "Briggs Jason";
select *
from Student s
	where s.StudentID = "480293439";
select *
from Enrollment e
	where e.StudentID = "480293439";
    
#Item 27
delete from Enrollment
	where StudentID in (select s.StudentID
						from Student s
							where s.GPA < 0.5);
delete from Student
	where GPA < 0.5;

select *
from Student s
	where s.GPA < 0.5;
    
#Item 28
#Check his previous salary and how many distinct students have an A in his courses
select p.Name, i.Salary, count(distinct e.StudentID)
from Instructor i, Person p, Enrollment e
	where p.Name = "Ricky Ponting"
    and i.InstructorID = p.ID
    and e.CourseCode in (select o.CourseCode
						 from Offering o
							where o.InstructorID = i.InstructorID)
	and e.SectionNo in (select o.SectionNo
						 from Offering o
							where o.InstructorID = i.InstructorID)
	and e.Grade = "A";
    
#Update his salary if there are at least 5 different students with an A in his courses
update Instructor
set Salary = Salary + (Salary * 0.1)
	where InstructorID in (select p.ID
							from Person p
							where p.Name = "Ricky Ponting"
                            and 5<=(select count(distinct e.StudentID)
								 from Enrollment e
									where e.CourseCode in (select o.CourseCode
															from Offering o
															where o.InstructorID = p.ID)
									and e.SectionNo in (select o.SectionNo
														from Offering o
														where o.InstructorID = p.ID)
									and e.Grade = "A"));
#Check to see his new salary
select p.Name, i.Salary
from Instructor i, Person p
	where p.Name = "Ricky Ponting"
    and i.InstructorID = p.ID;           
				
#Item 29
#Insert Trevor
insert into Person(Name, ID, Address, DOB)
values("Trevor Horns", "000957303", "23 Canberra Street", '1964-11-23');
#Query to check
select *
from Person p
	where p.Name = "Trevor Horns";
    
#Item 30
#Delete Jan from Enrollment & Student, but not Person
delete from Enrollment
	where StudentID = (select p.ID
						from Person p
							where p.Name = "Jan Austin");
delete from Student
	where StudentID = (select p.ID
						from Person p
							where p.Name = "Jan Austin");
#Check that Jan has been deleted from appropriate tables
select *
from Person p
	where p.Name = "Jan Austin";
select *
from Student s
	where s.StudentID in (select p.ID
							from Person p
							where p.Name = "Jan Austin");
select *
from Enrollment e
	where e.StudentID in (select p.ID
							from Person p
							where p.Name = "Jan Austin");