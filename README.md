# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
Create database library_project;

-- Create table "Branch"
drop table if exists branch;
create table branch(
branch_id	varchar(10) primary key,
manager_id	varchar(10), -- fk
branch_address	varchar(55),
contact_no varchar(20)
);


-- Create table "Employee"
drop table if exists employee;
create table employee(
emp_id	varchar(10) primary key,
emp_name varchar(55),
position varchar(55),
salary	INT,
branch_id varchar(10) -- fk
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
drop table if exists members;
create table members(
member_id varchar(10) primary key,
member_name varchar(25),
member_address varchar(75),
reg_date date
);




-- Create table "IssueStatus"
drop table if exists issude_status;
create table issued_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10), -- fk
issued_book_name varchar(75), 
issued_date date,
issued_book_isbn varchar(25), -- fk
issued_emp_id varchar(10) -- fk
);



-- Create table "ReturnStatus"
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

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books values ("978-1-60129-456-2", 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address='Mg Road 1st street'
where member_id="C103";
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status 
WHERE
    issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT 
    *
FROM
    employee
WHERE
    emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
    issued_member_id, COUNT(*) AS count1
FROM
    issued_status
GROUP BY issued_member_id
HAVING count1 > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_count as (SELECT 
    b.isbn, b.book_title, COUNT(i.issued_book_isbn) AS total
FROM
    books AS b
        JOIN
    issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn , b.book_title);

select * from book_count;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT 
	category, COUNT(category) as total
FROM
    books
GROUP BY category;
select * from books where category='History';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category, sum(b.rental_price) AS income, count(*) as totalbooks_per_category
FROM
    books AS b
        JOIN
    issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT 
    *
FROM
    members
WHERE
    reg_date >= DATE_SUB(CURRENT_DATE, INTERVAL 180 DAY);

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e1.emp_name, e2.emp_name, b.*
FROM
    employee AS e1
        JOIN
    branch AS b ON e1.branch_id = b.branch_id
        JOIN
    employee AS e2 ON e2.emp_id = b.manager_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS (SELECT book_title, rental_price FROM
    books
WHERE
    rental_price > 7);
select * from expensive_books;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT distinct(ist.issued_book_name) FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

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

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - Rohith Puvvula

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:


- **LinkedIn**: [Connect with me professionally]((https://www.linkedin.com/in/rohith-puvvula-256670141/))


