USE publications;

SELECT * FROM sales;
SELECT * FROM titles;
SELECT * FROM authors;
SELECT * FROM stores;
SELECT * FROM titleauthor;

-- CHALLENGE 1
-- Step 1
SELECT 
    ta.title_id,
    ta.au_id,
    (t.advance * ta.royaltyper / 100) AS Advance,
    (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM
    titleauthor ta,
    titles t,
    sales s;
    
-- Step 2
    
SELECT 
    a_sr.au_id,
    a_sr.title_id,
    SUM(advance_au),
    SUM(sales_royalty)
FROM
    (SELECT 
        ta.au_id,
            ta.title_id,
            (t.advance * ta.royaltyper / 100) AS advance_au,
            (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
    FROM
        titles t, titleauthor ta, sales s) a_sr
GROUP BY a_sr.au_id , a_sr.title_id;

-- Step 3

SELECT 
    step2.au_id, SUM(total_pre) AS Total
FROM
    (SELECT 
        step1.au_id,
            step1.title_id,
            SUM(advance_au) + SUM(sales_royalty) AS total_pre
    FROM
        (SELECT 
        ta.au_id,
            ta.title_id,
            (t.advance * ta.royaltyper / 100) AS advance_au,
            (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
    FROM
        titles t, titleauthor ta, sales s) step1
    GROUP BY step1.au_id , step1.title_id) step2
GROUP BY step2.au_id
ORDER BY Total DESC
LIMIT 3;

-- CHALLENGE 2

CREATE TEMPORARY TABLE step1
SELECT
	ta.au_id,	
    ta.title_id,
    (t.advance * ta.royaltyper/100) AS advance_au,
    (t.price*s.qty*t.royalty/100*ta.royaltyper/100) AS sales_royalty
FROM
	titles t,
    titleauthor ta,
    sales s;

CREATE TEMPORARY TABLE step2
SELECT step1.au_id, step1.title_id, SUM(advance_au) + SUM(sales_royalty) as total_pre FROM step1
GROUP BY step1.au_id, step1.title_id;

SELECT 
    step2.au_id, SUM(total_pre) AS Total
FROM
    step2
GROUP BY step2.au_id
ORDER BY Total DESC
LIMIT 3;

-- CHALLENGE 3

DROP TABLE IF EXISTS most_profiting_authors;
CREATE TABLE IF NOT EXISTS most_profiting_authors AS SELECT step2.au_id, SUM(total_pre) AS Total FROM
    step2
GROUP BY step2.au_id
ORDER BY Total DESC
LIMIT 3;

SELECT * FROM most_profiting_authors;



































select au_id, sum(revenue) as revenue
from
	(select title_id, au_id, sum(sales_royalty)+sum(advance) as revenue
	from
		(select titleauthor.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as sales_royalty
		from titleauthor
		inner join titles
		on titles.title_id = titleauthor.title_id
		inner join sales on
		sales.title_id=titleauthor.title_id) as step1
	group by au_id, title_id
	order by revenue desc) as step2
group by au_id
order by revenue desc
limit 3;