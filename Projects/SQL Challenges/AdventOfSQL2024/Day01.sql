WITH colors AS (
	SELECT
		child_id,
	    unnest(
	        regexp_split_to_array(
	            REPLACE(REPLACE(REPLACE(wl.wishes->>'colors', '[', ''), ']', ''), '"', ''),
	            ','
	        )
	    )  AS cleaned_colors
	FROM wish_lists wl
),

distinct_colors AS (
	SELECT
		child_id
		,COUNT(DISTINCT cleaned_colors) AS color_count
	FROM colors
	GROUP BY child_id
)

SELECT
	c.name
	,wl.wishes->>'first_choice' AS primary_wish
	,wl.wishes->>'second_choice' AS backup_wish
	,wl.wishes->'colors'->>0 AS favourite_color
	,dc.color_count
	,CASE
		WHEN t.difficulty_to_make = 1 THEN 'Simple Gift'
		WHEN t.difficulty_to_make = 2 THEN 'Moderate Gift'
		ELSE 'Complex Gift'
	END AS gift_complexity
	,CASE
		WHEN t.category = 'outdoor' THEN 'Outside Workshop'
		WHEN t.category = 'educational' THEN 'Learning Workshop'
		ELSE 'General Workshop'
	END AS workshop_assignment
FROM wish_lists AS wl
INNER JOIN distinct_colors AS dc
	ON dc.child_id = wl.child_id
LEFT OUTER JOIN children AS c
	ON c.child_id = wl.child_id
LEFT OUTER JOIN toy_catalogue AS t
	ON t.toy_name = wl.wishes->>'first_choice'
ORDER BY c.name ASC
LIMIT 5;
