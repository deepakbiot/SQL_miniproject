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

SELECT name FROM `Facilities` 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) AS zero_fee_facilities
FROM `Facilities`
WHERE membercost =0
LIMIT 0 , 30

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost >0
AND membercost < ( 0.20 * monthlymaintenance )
LIMIT 0 , 30

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 )
LIMIT 0 , 30

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT CASE WHEN monthlymaintenance <100
THEN 'cheap'
WHEN monthlymaintenance >100
THEN 'expensive'
END AS classification, name, monthlymaintenance
FROM `Facilities`
LIMIT 0 , 30

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

/* This query gives Guest members also. */
SELECT firstname, surname, max(joindate) FROM `Members`  

/* This query removes Guest members. */
SELECT firstname, surname, MAX( joindate )
FROM `Members`
WHERE firstname <> 'GUEST'

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(b.firstname, ' ', b.surname) AS Member_name, c.name AS Facility_name
FROM `Bookings` a
JOIN `Members` b ON a.memid = b.memid
JOIN `Facilities` c ON a.facid = c.facid
WHERE c.name LIKE 'Tennis court%'
ORDER BY Name
LIMIT 0 , 30

SELECT DISTINCT CONCAT(b.firstname, ' ', b.surname) AS Member_name, c.name AS Facility_name
FROM `Bookings` a
JOIN `Members` b ON a.memid = b.memid
JOIN `Facilities` c ON a.facid = c.facid
WHERE c.facid in (1,0)
ORDER BY Member_name
LIMIT 0 , 30

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT c.name as Facility_name, CONCAT(b.firstname, ' ', b.surname) AS Member_name, 
case when a.memid = 0 and a.slots * c.guestcost > 30 then a.slots * c.guestcost 
when a.memid <> 0 and a.slots * c.membercost > 30 then a.slots * c.membercost 
end as total_cost
FROM  `Bookings` a
JOIN `Members` b ON a.memid = b.memid
JOIN `Facilities` c ON a.facid = c.facid
WHERE a.starttime > '2012-09-14'
AND a.starttime < '2012-09-15'
AND (((a.memid =0) AND (c.guestcost * a.slots >30))
OR ((a.memid !=0) AND (c.membercost * a.slots >30)))
order by total_cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT *
FROM (
SELECT c.name AS Facility_name, CONCAT( b.firstname, ' ', b.surname ) AS Member_name,
CASE WHEN a.memid =0
AND a.slots * c.guestcost >30
THEN a.slots * c.guestcost
WHEN a.memid <>0
AND a.slots * c.membercost >30
THEN a.slots * c.membercost
END AS total_cost
FROM `Bookings` a
JOIN `Members` b ON a.memid = b.memid
JOIN `Facilities` c ON a.facid = c.facid
WHERE a.starttime > '2012-09-14'
AND a.starttime < '2012-09-15'
ORDER BY total_cost DESC
)tmp
WHERE total_cost >30

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select * from (SELECT b.name, SUM(
CASE WHEN a.memid =0 THEN a.slots * b.guestcost
WHEN a.memid <>0 THEN a.slots * b.membercost
END) AS total_revenue 
FROM `Bookings` a
join `Facilities` b on a.facid = b.facid
group by b.name
order by 2 ) temp
where temp.total_revenue < 1000