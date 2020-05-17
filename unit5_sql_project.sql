/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name AS 'facilities with member fee'
   FROM country_club.Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(facid) AS count_without_fee
   FROM country_club.Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,
       name AS 'facility name',
       membercost AS 'member cost',
       monthlymaintenance AS 'monthly maintenance'
   FROM country_club.Facilities
WHERE  membercost > 0
  AND  membercost < (monthlymaintenance * 0.2)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
   FROM country_club.Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance AS 'monthly maintenance cost',
       CASE WHEN monthlymaintenance < 100 THEN 'cheap'
            ELSE 'expensive' END AS price_class
   FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT mem.firstname 'first name',
       mem.surname AS 'last name'
   FROM country_club.Members mem
WHERE mem.joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT bookfac.name AS 'court name',
	   CONCAT(mem.firstname, ' ', mem.surname) AS 'member name'	 
	FROM(
          SELECT books.*,
		   		 fac.name
   		    FROM country_club.Bookings books
            JOIN country_club.Facilities fac
     		  ON fac.facid = books.facid
  		     WHERE fac.name LIKE 'Tennis%'
    		   AND books.memid != 0		
    										) bookfac
    JOIN country_club.Members mem
	  ON mem.memid = bookfac.memid
ORDER BY 2 

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility,
	   CONCAT(m.firstname, ' ', m.surname) AS member_name,
	   CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
	        ELSE b.slots * f.membercost END AS cost
   FROM country_club.Bookings b, country_club.Facilities f, country_club.Members m
WHERE b.starttime LIKE '2012-09-14%'
  AND b.facid = f.facid
  AND b.memid = m.memid
  AND (CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
	        ELSE b.slots * f.membercost END) > 30
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT bookfac.name AS facility,
	   CONCAT(m.firstname, ' ', m.surname) AS member_name,
	   CASE WHEN bookfac.memid = 0 THEN bookfac.slots * bookfac.guestcost
	        ELSE bookfac.slots * bookfac.membercost END AS cost
FROM country_club.Members m
JOIN (
      SELECT  f.facid,
	   		  f.name,
	          f.membercost,
	          f.guestcost,
	          b.memid,
	          b.slots,
    	  	  b.starttime
          FROM country_club.Bookings b
          JOIN country_club.Facilities f
            ON b.facid = f.facid
                                          ) bookfac
  ON m.memid = bookfac.memid
WHERE bookfac.starttime LIKE '2012-09-14%'
  AND (CASE WHEN bookfac.memid = 0 THEN bookfac.slots * bookfac.guestcost
	        ELSE bookfac.slots * bookfac.membercost END) > 30
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facrev.facility_name,
	   facrev.revenue
FROM (SELECT bookfac.facility_name,
	   SUM(bookfac.cost) - bookfac.monthlymaintenance AS revenue
FROM (SELECT b.bookid AS booking_id,
	   b.facid AS facility_id,
	   f.name AS facility_name,
       f.monthlymaintenance,
	   CASE WHEN b.memid = 0 THEN b.slots * f.guestcost
	        ELSE b.slots * f.membercost END AS cost
   FROM country_club.Bookings b
   JOIN country_club.Facilities f
     ON b.facid=f.facid) bookfac
GROUP BY 1) facrev
WHERE facrev.revenue < 1000
ORDER BY 2