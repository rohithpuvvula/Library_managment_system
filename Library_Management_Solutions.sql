-- Library management system
USE library_project;
-- Creating the database
Create database library_project;
-- Using the database
Use library_project;

-- Creating the branch table
drop table if exists branch;
create table branch(
branch_id	varchar(10) primary key,
manager_id	varchar(10), -- fk
branch_address	varchar(55),
contact_no varchar(20)
);
-- Creating employees table
drop table if exists employee;
create table employee(
emp_id	varchar(10) primary key,
emp_name varchar(55),
position varchar(55),
salary	INT,
branch_id varchar(10) -- fk
);

-- Creating books table
drop table if exists books;
create table books(
isbn varchar(10) primary key,	
book_title varchar(75),	
category varchar(10),	
rental_price float,	
status varchar(15),	
author	varchar(35),
publisher varchar(55)
);

-- Creating memebers table
drop table if exists members;
create table members(
member_id varchar(10) primary key,
member_name varchar(25),
member_address varchar(75),
reg_date date
);

-- Creating issued_status table
drop table if exists issude_status;
create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10), -- fk
issued_book_name varchar(75), 
issued_date date,
issued_book_isbn varchar(25), -- fk
issued_emp_id varchar(10) -- fk
);

-- Creating return_status table
drop table if exists return_status;
create table return_status(
return_id varchar(10) primary key,
issued_id varchar(10),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(10)
);

-- Adding Foreign keys
alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employee(emp_id);

alter table employee
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);

alter table books
modify column isbn varchar(20);

alter table books
modify column category varchar(20);


select * from books;
select* from branch;
select * from employee;
select * from issued_status;
select * from members;
select * from return_status;

delete from books where coalesce(isbn,book_title,category) is null;
select * from books where coalesce(isbn,book_title,category) is null;

-- Task 1
-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books values ("978-1-60129-456-2", 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books where isbn="978-1-60129-456-2";

-- Task 2
-- Update an Existing Member's Address
update members
set member_address='Mg Road 1st street'
where member_id="C103";

-- Task 3
-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status where issued_id="IS121";

-- Task 4
-- Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from employee where emp_id='E101';

-- Task 5
-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_member_id,count(*) as count1 from issued_status group by issued_member_id having count1>1;

-- Task 6 
-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_count as (SELECT 
    b.isbn, b.book_title, COUNT(i.issued_book_isbn) AS total
FROM
    books AS b
        JOIN
    issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn , b.book_title);

select * from book_count;

-- Task 7

-- Finding the total by category
SELECT 
	category, COUNT(category) as total
FROM
    books
GROUP BY category;
-- Retrieve All Books in a Specific Category:
select * from books where category='History';

-- Task 8
-- Find Total Rental Income by Category:
select * from issued_status;
select * from books;
SELECT 
    b.category, sum(b.rental_price) AS income, count(*) as totalbooks_per_category
FROM
    books AS b
        JOIN
    issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY 1;

-- Task 9
	

-- inserted values 
insert into members values ('C120','david','125 happy st','2024-12-31'),('C121','Mario','150 valley st','2025-1-31');

select * from members WHERE reg_date >= date_sub(CURRENT_DATE , interval 180 day );

-- Task 10
-- List Employees with Their Branch Manager's Name and their branch details:
select * from employee;
select * from branch;
SELECT 
    e1.emp_name, e2.emp_name, b.*
FROM
    employee AS e1
        JOIN
    branch AS b ON e1.branch_id = b.branch_id
        JOIN
    employee AS e2 ON e2.emp_id = b.manager_id;

-- Task 11    
-- Create a Table of Books with Rental Price Above a Certain Threshold:
create table expensive_books as (select book_title,rental_price from books where rental_price>7);
select * from expensive_books;

-- Task 12
-- Retrieve the List of Books Not Yet Returned
SELECT distinct(ist.issued_book_name) FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id WHERE rs.return_id IS NULL;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT 
    m.member_id,
    m.member_name,
    s.issued_book_name,
    s.issued_date,
    (r.return_date) - date_add(s.issued_date,interval 30 day) AS days_overdue
FROM
    members AS m
		JOIN
    issued_status AS s ON m.member_id = s.issued_member_id
        LEFT JOIN
    return_status AS r ON s.issued_id = r.issued_id
    where  (r.return_date - s.issued_date) 
    order by m.member_id;
 
 
-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
-- books - issued_status-return_status

-- Manually
select * from books where isbn='978-0-06-112241-5';
select * from issued_status;

update books set status='no' where isbn='978-0-06-112241-5';

select * from issued_status where issued_book_isbn='978-0-06-112241-5';

select * from return_status where issued_id='IS125';

insert into return_status (return_id,issued_id,return_date,return_book_isbn)values('RS125','IS125',current_date(),'Good');

select * from return_status where issued_id='IS125';

update books set status='yes' where isbn='978-0-06-112241-5';

-- Stored Procedure
drop procedure add_return_status;
delimiter $$ 
create procedure add_return_status(IN p_return_id varchar(10),in p_issued_id varchar(10),in p_return_book_isbn varchar(10))
	
begin
	DECLARE v_book_id varchar(50);
    DECLARE v_book_name varchar(80);
    DECLARE v_message varchar(255);
	insert into return_status (return_id,issued_id,return_date,return_book_isbn)
    values(p_return_id,p_issued_id,current_date(),p_return_book_isbn);
    select issued_book_isbn,issued_book_name into v_book_id,v_book_name from issued_status where issued_id=p_issued_id;
    update books set status='yes' where isbn=v_book_id;
    set v_message=concat( 'Thank you for returning the book ',v_book_name);
    select v_message;
end$$
delimiter ;

-- test functions
select * from issued_status where issued_id='IS135';
select * from books where isbn='978-0-307-58837-1';
select * from return_status where issued_id='IS135';

call add_return_status();
call add_return_status('RS140','IS135','Good');
select * from add_return_status;

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.

-- Branch issued_books return books
Create table branch_report as (SELECT 
    b.branch_id,b.manager_id,count(s.issued_book_isbn) as no_of_book_issued ,count(r.return_id) as returned_books,sum(bk.rental_price) as rental_revenue
FROM
    branch AS b
        JOIN
    employee AS e ON b.branch_id = e.branch_id
        JOIN
    issued_status AS s ON s.issued_emp_id = e.emp_id
		left JOIN
	return_status as r on r.issued_id=s.issued_id
		JOIN
	books as bk on s.issued_book_isbn=bk.isbn
    group by 1,2);
    
select * from branch_report;


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
-- who have issued at least one book in the last 2 months.
create table active_members as SELECT 
    e.emp_id, COUNT(s.issued_book_isbn) AS book_count
FROM
    employee AS e
        JOIN
    issued_status AS s ON e.emp_id = s.issued_emp_id
WHERE
    issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
GROUP BY 1
HAVING book_count > 1;

select * from active_members;

-- Task 17: Find -- Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_id, b.*, COUNT(s.issued_book_isbn) AS book_count
FROM
    employee AS e
        JOIN
    issued_status AS s ON e.emp_id = s.issued_emp_id
        JOIN
    branch AS b ON e.branch_id = b.branch_id
GROUP BY e.emp_id
ORDER BY 5 DESC
LIMIT 3;

-- Task 19: Stored Procedure 
-- Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that 
-- the book is currently not available.
drop procedure issue_book;
delimiter $$
create procedure issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))


BEGIN
-- all the code
    -- checking if book is available 'yes'
    DECLARE
-- all the variabable
    v_status VARCHAR(10);
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
		select concat( 'Book records added successfully for book isbn : %', p_issued_book_isbn) as message1;


    ELSE
		select concat('Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn) as message2;
    END IF;
end $$
delimiter ;

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status where issued_book_isbn = '978-0-375-41398-8';

CALL issue_book('IS157', 'C108', '978-0-525-47535-5', 'E104');
CALL issue_book('IS158', 'C108', '978-0-525-47535-5', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'


