SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM members
SELECT * FROM issued_status
SELECT * FROM return_status

-----------Project Tasks------------------------------------------------------------------
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'All we ever wanted', 'Fiction', 6.00, 'yes', 'Emily Giffin', 'J.B. Lippincott & Co.')"
INSERT into books(isbn, book_title, category, rental_price, status, author, publisher)
values
('978-1-60129-456-2', 'All we ever wanted', 'Fiction', 6.00, 'yes', 'Emily Giffin', 'J.B. Lippincott & Co.')

--Task 2. Update an Existing Member's Address
update members
set member_address ='125 Main St'
where member_id = 'C101'

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE from issued_status
where issued_id = 'IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101'

--Task 5: List members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
with Issued_More_book as (
	select issued_member_id, count(*) as Issued_Book
	from issued_status
	group by issued_member_id 
	order by count(*) DESC
) 
SELECT issued_member_id, Issued_Book
from Issued_More_book

---CTAS (Create Table As Select)------------------
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE books_counts
AS 
select b.isbn, b.book_title, count(ist.issued_id) as no_issued
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn 
group by 1, 2;

SELECT * from books_counts

----Data Analysis & Findings----------------
--Task 7. Retrieve All Books in a Specific Category:
SELECT * 
from books
where category = 'Classic'

--Task 8. Find Total Rental Income by Category:
select b.category, sum(b.rental_price) as Total, count(*) as no_times_issued
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1

--Task 9. List Members Who Registered in the Last 180 Days:
insert into members(member_id,member_name, member_address, reg_date)
values
('C120', 'Jane Doe', '132 My Street', '2025-06-15'),
('C121', 'Brian Wacker', '969 Cox Rd',	'2025-07-01')

SELECT CURRENT_DATE;
SELECT * from members
where members.reg_date >=  CURRENT_DATE - INTERVAL '180 days'

--Task 10. List Employees with their Branch Manager's Name and their branch details:
select emp1.*, 
br.branch_address, br.manager_id, 
emp2.emp_name as Manager_name
from employees as emp1
join branch as br
on br.branch_id = emp1.branch_id
join
employees as emp2
on br.manager_id = emp2.emp_id

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold of $7:
CREATE Table BooksWithThreshold_Rental_Price
AS
SELECT * 
from books
where rental_price > 7

SELECT * 
from BooksWithRental_Price

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT DISTINCT iss.issued_book_name
from issued_status as iss
left join return_status as ret
on iss.issued_id = ret.issued_id

--Task 13: Identify Members with Overdue Books (assume a 30-day return period)
ALTER TABLE issued_status
	ADD Borrowing_limit	date;

UPDATE issued_status
  SET Borrowing_limit = '2024-05-01';

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

--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

Select * from books
where isbn = '978-0-451-52993-5'
 
Update books
set status = 'no'
where isbn = '978-0-451-52993-5'

select *
from return_status
where issued_id = 'IS130'

Alter Table return_status
Add book_quality varchar(10)
insert into return_status (return_id, issued_id, return_date, book_quality)
values ('RS125', 'IS130', CURRENT_DATE, 'Good')

Update books
set status = 'yes'
where isbn = '978-0-451-52993-5'

------Store Procedures
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

CALL add_return_records('RS138', 'IS135', 'Good');

--Task 15: Branch Performance Report
---Create a query that generates a performance report for each branch, showing the number of books issued, 
---the number of books returned, and the total revenue generated from book rentals.
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

--Task 16: CTAS: Create a Table of Active Members
---Use CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
---members who have issued at least one book.
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

--Task 17: Find Employees with the Most Book Issues Processed
---Write a query to find the top 3 employees who have processed the most book issues. 
--Display the employee name, number of books processed, and their branch.

Select member_id, member_name, member_address, reg_date, count(issued_id) as Active_member 
from Active_Members
group by member_id, member_name, member_address, reg_date
order by 5 desc
limit 3

---Task 18: Stored Procedure 
--Objective: Create a stored procedure to manage the status of books in a library system. 
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). If the book is available, 
--it should be issued, and the status in the books table should be updated to 'no'. 
--If the book is not available (status = 'no'), 
--the procedure should return an error message indicating that the book is currently not available.books.

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

CALL book_status('978-0-553-29698-2', 'IS155', 'C108',  'E104');

---Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify 
--overdue books and calculate fines.
--Description: Write a CTAS query to create a new table that lists each member and the books they have issued but
--not returned within 30 days. The table should include: The number of overdue books. The total fines, with each 
--day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: 

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



