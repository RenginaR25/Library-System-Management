---Library Management System Project-----
----Creating Brunch Table -------

DROP TABLE if exists brunch;
CREATE TABLE brunch
(
	branch_id varchar(10) PRIMARY KEY,
	manager_id varchar(10),
	branch_address	varchar(40),
	contact_no varchar(10)
);

DROP TABLE if exists employees;
CREATE TABLE employees
(
	emp_id	varchar(10) PRIMARY KEY,
	emp_name varchar(25),
	position varchar(15),
	salary	int,
	branch_id varchar(15) --FK
);

DROP TABLE if exists books;
CREATE TABLE books
(
	isbn varchar(20) PRIMARY KEY,
	book_title varchar(75),
	category varchar(20),
	rental_price float,
	status varchar(15),
	author varchar(35),
	publisher varchar(55)
);

DROP TABLE if exists members;
CREATE TABLE members
(
	member_id varchar(10) PRIMARY KEY,
	member_name varchar(20),
	member_address varchar(40),
	reg_date date
);

DROP TABLE if exists issued_status;
CREATE TABLE issued_status
(
	issued_id varchar(10) PRIMARY KEY,
	issued_member_id varchar(10), --FK
	issued_book_name varchar(75),	
	issued_date	date,
	issued_book_isbn varchar(25), --FK
	issued_emp_id varchar(10) --FK
);

DROP TABLE if exists return_status;
CREATE TABLE return_status
(
	return_id varchar(10) PRIMARY KEY,
	issued_id varchar(10), ---FK
	return_book_name varchar(75),	
	return_date	date,
	return_book_isbn varchar(20)	
	
);

---Foreign Key constraint---
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id)

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id)

ALTER TABLE employees
ADD CONSTRAINT fk_brunch
FOREIGN KEY (branch_id)
REFERENCES brunch(branch_id)

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id)

