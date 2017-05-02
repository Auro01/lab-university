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

-- Inserts

INSERT INTO student (pid, firstName, lastName, dob, status, major) VALUES
    (1, "Eduardo", "Ancira", '1994-02-08', 'senior', 1),
    (2, "Javier", "Meza", '1997-02-08', 'junior', 1),
    (3, "Fernando", "Pompa", '1997-24-07', 'junior', 1),
    (4, "David", "Martinez", '1997-10-07', 'junior', 1),
    (5, "Lizzie", "Cañamar", '1996-26-12', 'sophomore', 1),
    (6, "Samantha", "Solis", '1997-30-06', 'sophomore', 1),
    (7, "Carolina", "Gómez", '1997-27-01', 'sophomore', 5),
    (8, "Mariana", "Sevilla", '1996-23-04', 'sophomore', 5),
    (9, "Ana", "Viveros", '1997-03-04', 'sophomore', 5),
    (10, "Iván", "Ramírez", '1996-27-12', 'sophomore', 5),
    (11, "Uriel", "Salazar", '1996-12-07', 'sophomore', 5),
    (12, "Alan", "Velasco", '1997-12-01', 'sophomore', 5),
    (13, "Ana", "Villarreal", '1997-23-04', 'sophomore', 5),
    (14, "Jonathan", "Cárdenas", '1997-15-06', 'sophomore', 5),
    (15, "Eduardo", "Trujillo", '1997-20-01', 'sophomore', 5),
    (16, "Oliver", "Gómez", '1997-17-05', 'sophomore', 5),
    (17, "Johan", "Kennedy", '1997-24-02', 'sophomore', 5),
    (18, "Astrid", "Cañamar", '1999-12-09', 'freshman', 5),
    (19, "Tamara", "Cavazos", '1997-20-09', 'sophomore', 5),
    (20, "Rolando", "Ruiz", '1995-19-02', 'senior', 5),
    (21, "Luis", "Regalado", '1994-03-01', 'senior', 5),
    (22, "Adrian", "Gonzalez", '1996-17-12', 'junior', 5),
    (23, "Abraham", "Alvarez", '1996-22-03', 'junior', 5),
    (24, "Sergio", "Cruz", '1995-22-09', 'sophomore', 5),
    (25, "Alan", "Valdez", '1994-16-10', 'senior', 5),
    (26, "Eli", "Santiago", '1992-10-03', 'senior', 5),
    (27, "Omar", "Manjarrez", '1994-25-04', 'senior', 5),
    (28, "Noemi", "Herrera", '1996-02-08', 'junior', 5),
    (29, "Miriam", "Rodriguez", '1998-22-12', 'freshman', 5),
    (30, "Elizabeth", "Cantu", '1998-22-12', 'freshman', 5);




INSERT INTO faculty (pid, firstName, lastName, dob, rank, salary,works_in) VALUES
    (1, "Luis", "Humberto", '1974-10-03', 'titular', 50000, 1),
    (2, "Juan Carlos", "Lavariega", '1964-16-09', 'titular', 60000, 1),
    (3, "Rafael", "Salazar", '1960-17-03', 'instructor', 70000, 1),
    (4, "Armando", "Albert", '1974-12-02', 'titular', 50000, 2),
    (5, "Gabriel", "Cruz", '1984-10-03', 'asistente', 20000, 2),
    (6, "Mariana", "Garza", '1974-10-03', 'instructor', 55000, 2);

    INSERT INTO department (code, name, dept_chair) VALUES
    (1, "Technologias Comptacionales"),
    (2, "Negocios", "6");


    INSERT INTO campus_club (cid, name, location, phone, advisor) VALUES
    (1, "Ajedrez", ROW('Luis Elizondo','Au7','402'), '811553620', 4),
    (2, "Competitive Programming", ROW('Eugenio Garza Sada','Au3','310'), '811553620', 4),
    (4, "WISSE", ROW('Eugenio Garza Sada','Au3','307'), '811553625', 6);


    INSERT INTO student_campus_club (student_id, campus_club_id) VALUES
    (29,1),
    (29,2),
    (29,3),
    (30,1),
    (30,2),
    (30,3),
    (1,1),
    (1,2),
    (2,1),
    (2,2),
    (3,1),
    (3,2),
    (4,1),
    (4,2),
    (5,2),
    (6,2),
    (19,1)
    (6,3),
    (7,3),
    (5,3),
    (8,3),
    (9,3),
    (13,3),
    (18,3),
    (25,2),
    (27,2),
    (21,1),
    (19,3),
    (28,3),
    (14,3),
    (17,3),
    (15,3),
    (10,3),
    (16,1)
    (18,1);
