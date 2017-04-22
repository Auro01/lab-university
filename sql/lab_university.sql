CREATE TYPE location_t AS (
    street varchar(30),
    bldg varchar(5),
    room varchar(5)
);

CREATE TYPE rank_t AS ENUM (
    'instructor',
    'asistente',
    'asociado',
    'titular'
);

CREATE TYPE status_t AS ENUM (
    'freshman',
    'sophomore',
    'junior',
    'senior'
);

CREATE TABLE person (
    pid serial,
    firstName varchar(20),
    lastName varchar(20),
    dob date,
    PRIMARY KEY (pid)
);

CREATE TABLE department (
    code serial,
    name varchar(40),
    dept_chair integer,
    PRIMARY KEY (code)
);

CREATE TABLE faculty (
    rank rank_t,
    salary decimal,
    works_in integer,
    PRIMARY KEY (pid),
    FOREIGN KEY (works_in) REFERENCES department(code)
) INHERITS (person);

ALTER TABLE department ADD FOREIGN KEY (dept_chair) REFERENCES faculty(pid);

CREATE TABLE student (
    status status_t,
    major integer,
    PRIMARY KEY (pid),
    FOREIGN KEY (major) REFERENCES department(code)
) INHERITS (person);

CREATE TABLE campus_club (
    cid serial,
    name varchar(50),
    location location_t UNIQUE,
    phone varchar(12),
    advisor integer,
    PRIMARY KEY (cid)
);

CREATE TABLE student_campus_club (
    student_id integer,
    campus_club_id integer,
    PRIMARY KEY (student_id, campus_club_id),
    FOREIGN KEY (student_id) REFERENCES student(pid),
    FOREIGN KEY (campus_club_id) REFERENCES campus_club(cid)
);

-- TRIGGERS

-- 3

CREATE OR REPLACE FUNCTION validate_chair() RETURNS trigger AS $validate_chair$
    DECLARE
    BEGIN
        IF EXISTS (SELECT * FROM faculty WHERE id = new.dept_chair AND works_in = new.code) THEN
            return new;
        END IF;

        return null;
    END;
$validate_chair$ LANGUAGE plpgsql;

CREATE TRIGGER validate_chair BEFORE UPDATE OR INSERT 
    ON department FOR EACH ROW
    EXECUTE PROCEDURE validate_chair();
    
-- 4

CREATE OR REPLACE FUNCTION faculty_promotion() RETURNS trigger AS $faculty_promotion$
    DECLARE
    BEGIN
        IF old.rank = 'asistente' AND new.rank = 'asociado' THEN
            UPDATE faculty SET salary = new.salary * 1.1 WHERE pid = new.pid;
        END IF;

        return new;
    END;
$faculty_promotion$ LANGUAGE plpgsql;

CREATE TRIGGER faculty_promotion AFTER UPDATE 
    ON faculty FOR EACH ROW
    EXECUTE PROCEDURE faculty_promotion();
    
-- 5

CREATE OR REPLACE FUNCTION faculty_transfer() RETURNS trigger AS $faculty_transfer$
    DECLARE
    BEGIN
        IF EXISTS (SELECT * FROM deparment WHERE dept_chair = old.pid) THEN
            UPDATE department set dept_chair = null WHERE dept_chair = old.pid;
        END IF;

        return new;
    END;
$faculty_transfer$ LANGUAGE plpgsql;

CREATE TRIGGER faculty_transfer BEFORE UPDATE 
    ON faculty FOR EACH ROW
    EXECUTE PROCEDURE faculty_transfer();
    
-- 7
CREATE OR REPLACE FUNCTION delete_student() RETURNS trigger AS $delete_student$
    DECLARE
    BEGIN
        DELETE FROM student_campus_club WHERE student_id = old.pid;
    END;
$delete_student$ LANGUAGE plpgsql;

CREATE TRIGGER delete_student BEFORE DELETE 
    ON student FOR EACH ROW
    EXECUTE PROCEDURE delete_student();

