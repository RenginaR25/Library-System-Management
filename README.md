# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/RenginaR25/Library-System-Management/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/RenginaR25/Library-System-Management/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

[DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
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
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id)

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id)

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**

```sql
INSERT into books(isbn, book_title, category, rental_price, status, author, publisher)
values
('978-1-60129-456-2', 'All we ever wanted', 'Fiction', 6.00, 'yes', 'Emily Giffin', 'J.B. Lippincott & Co.')
```

**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address ='125 Main St'
where member_id = 'C101'
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE from issued_status
where issued_id = 'IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```

**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
with Issued_More_book as (
	select issued_member_id, count(*) as Issued_Book
	from issued_status
	group by issued_member_id 
	order by count(*) DESC
) 
SELECT issued_member_id, Issued_Book
from Issued_More_book
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE books_counts
AS 
select b.isbn, b.book_title, count(ist.issued_id) as no_issued
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn 
group by 1, 2;

SELECT * from books_counts
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql

SELECT * from books
where category = 'Classic'

```

8. **Task 8: Find Total Rental Income by Category**:

```sql

select b.category, sum(b.rental_price) as Total, count(*) as no_times_issued
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1

```

9. **List Members Who Registered in the Last 180 Days**:
```sql

SELECT CURRENT_DATE;
SELECT * from members
where members.reg_date >=  CURRENT_DATE - INTERVAL '180 days'

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql

select emp1.*, 
br.branch_address, br.manager_id, 
emp2.emp_name as Manager_name
from employees as emp1
join branch as br
on br.branch_id = emp1.branch_id
join
employees as emp2
on br.manager_id = emp2.emp_id

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql

SELECT DISTINCT iss.issued_book_name
from issued_status as iss
left join return_status as ret
on iss.issued_id = ret.issued_id

```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql

SELECT ist.issued_member_id, 
mem.member_name, 
ist.issued_book_name,ist.issued_date,
(ist.Borrowing_limit - ist.issued_date)  as over_dues_days
from issued_status as ist
join members as mem
on ist.issued_member_id = mem.member_id
left join
return_status as ret
on ret.issued_id = ist.issued_id
where 
	ret.return_date is NULL
	AND
 	(ist.Borrowing_limit - ist.issued_date) > 30
order by 1

```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql
CREATE or Replace Procedure add_return_records(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(10))
Language plpgsql
As $$
DECLARE
	v_isbn varchar(25);
	v_book_title varchar(75);
BEGIN
	-----All Logic and code
	---Insert into the return_status table based in the user input
	insert into return_status (return_id, issued_id, return_date, book_quality)
	values (p_return_id,p_issued_id, CURRENT_DATE, p_book_quality);

	select issued_book_isbn, issued_book_name
	into v_isbn, v_book_title
	from issued_status	
	where issued_id = p_issued_id;

	Update books
	set status = 'yes'
	where isbn = v_isbn;
	RAISE NOTICE 'Thank for returning the book: %', v_book_title;
END;
$$

-----Testing---------
CALL add_return_records('RS138', 'IS135', 'Good');
```
**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

DROP TABLE if exists Total_Reveneu_by_Branch;
CREATE TABLE Total_Reveneu_by_Branch
AS
SELECT emp.branch_id, emp.emp_id, ist.issued_id, bk.isbn, bk.rental_price, bk.status
from employees as emp
join issued_status as ist
	on emp.emp_id = ist.issued_emp_id
join books as bk
	on ist.issued_book_isbn = bk.isbn
--	where bk.status = 'yes'
order by 1

Select branch_id, count(issued_id) as Total_books_issued, 
count(status) as Total_books_returned, sum(rental_price) as total_revenue
from Total_Reveneu_by_Branch 
group by branch_id
order by 1

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table, active_members, containing members who have issued at least one book in the last 2 months.

```sql

DROP TABLE if exists Active_Members;
CREATE TABLE Active_Members
AS
SELECT mem.member_id, mem.member_name, mem.member_address, mem.reg_date, ist.issued_id
from members as mem
join issued_status as ist
	on mem.member_id = ist.issued_member_id
order by 1

Select member_id, member_name, member_address, reg_date, count(issued_id) as Active_member 
from Active_Members
group by member_id, member_name, member_address, reg_date
order by 5 desc

```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql

Select member_id, member_name, member_address, reg_date, count(issued_id) as Active_member 
from Active_Members
group by member_id, member_name, member_address, reg_date
order by 5 desc
limit 3

```

**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE or Replace Procedure book_status(p_isbn varchar(20), p_issued_id varchar(10), 
p_issued_member_id varchar(10), p_issued_emp_id varchar(10))
Language plpgsql
As $$
DECLARE
	v_status varchar(10);
	v_book_title varchar(75);
BEGIN
	-----All Logic and code
	---Insert into the return_status table based in the user input
	select status, book_title
		into v_status, v_book_title
	from books 
	where isbn = p_isbn;
	
	IF v_status = 'yes' THEN
		insert into issued_status (issued_id, issued_member_id, issued_book_name, 
		issued_date, issued_book_isbn,issued_emp_id)
		values (p_issued_id, p_issued_member_id,
		v_book_title, Current_date, p_isbn, p_issued_emp_id );
		RAISE NOTICE 'Book records added successfully for book isbn : %', p_isbn;
		
		Update books
			set status = 'no'
		where isbn = p_isbn;
	else
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_isbn;
	end if ;		
END;
$$

```
-- Testing the function
CALL book_status('978-0-553-29698-2', 'IS155', 'C108',  'E104');

**Task 19: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

```sql

Select ist.issued_member_id, ist.issued_book_name,
(ist.borrowing_limit - ist.issued_date)*0.50 as total_fines 
from issued_status as ist
left join return_status as ret
on ist.issued_id = ret.issued_id
where 
	ret.return_date is NULL
	AND
 	(ist.Borrowing_limit - ist.issued_date)> 30
group by ist.issued_member_id, ist.borrowing_limit, ist.issued_date, ist.issued_book_name

```

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/RenginaR25/Library-System-Management.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Rengina Rahman


