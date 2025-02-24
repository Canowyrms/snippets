## Database Snippets

SQL and SQL-adjacent snippets. I'm no SQL expert, so even if a snippet is rather simple in nature, I don't care to rewrite it 🙂.


### Find duplicate postmeta keys

WordPress post meta is fun.

```sql
/* SIMPLE */

SELECT
	post_id,
	meta_key,
	GROUP_CONCAT(meta_id)
FROM
	wp_postmeta
GROUP BY
	post_id,
	meta_key
HAVING COUNT(*) > 1;


/* ADVANCED */

SELECT
	post_id,
	group_concat(distinct meta_id) as meta_ids,
	MIN (distinct meta_id) as primary_meta_id,
	meta_key,
	char_length(meta_value) as meta_length,
	COUNT (distinct meta_id) * char_length(meta_value) as total_size
FROM (
	SELECT
		meta_table_1.*
	FROM
		wp_postmeta meta_table_1,
		wp_postmeta meta_table_2
	WHERE (
    	meta_table_1.post_id = meta_table_2.post_id
		AND meta_table_1.meta_value = meta_table_2.meta_value
		AND meta_table_1.meta_key = meta_table_2.meta_key
	)
	ORDER BY meta_table_2.post_id
) Table_All_Duplicates
GROUP BY
	post_id,
	meta_key 
HAVING COUNT(*) > 1;
```



### Count posts by post-type

```sql
SELECT
	COUNT(*),
	post_type
FROM
	wp_posts
GROUP BY
	post_type;
```



### Get site transients

```sql
SELECT 
	`option_name`,
	`option_value`
FROM
	wp_options
WHERE
	`option_name` LIKE '%transient_%'
ORDER BY
	`option_name`;
```



### Optimize meta indices

> ℹ <br/>
> I don't remember the use-case for these, but archiving just in case.

```sql
/* Default indexes */
ALTER TABLE `wp_postmeta`
	ADD PRIMARY KEY (`meta_id`),
	ADD INDEX `post_id` (`post_id`),
	ADD INDEX `meta_key` (`meta_key`);

/* If you need the ability to have multiple meta keys with the same key name for one post, then use this solution. */
ALTER TABLE `wp_postmeta`
	DROP PRIMARY KEY,
	DROP INDEX `post_id`,
	ADD PRIMARY KEY (`post_id`, `meta_key`, `meta_id`), -- to allow dup meta_key for a post
	ADD INDEX `meta_id` (`meta_id`), -- to keep AUTO_INCREMENT happy
	ADD INDEX `meta_value` (`meta_value`(22));

/***/

/* Default indexes */
ALTER TABLE `wp_termmeta`
	ADD PRIMARY KEY (`meta_id`),
	ADD INDEX `term_id` (`term_id`),
	ADD INDEX `meta_key` (`meta_key`);

/* If you need the ability to have multiple meta keys with the same key name for one post, then use this solution. */
ALTER TABLE `wp_termmeta`
	DROP PRIMARY KEY,
	DROP INDEX `term_id`,
	ADD PRIMARY KEY (`term_id`, `meta_key`, `meta_id`), -- to allow dup meta_key for a post
	ADD INDEX `meta_id` (`meta_id`), -- to keep AUTO_INCREMENT happy
	ADD INDEX `meta_value` (`meta_value`(10));

/***/

/* Default indexes */
ALTER TABLE `wp_usermeta`
	ADD PRIMARY KEY (`umeta_id`),
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `meta_key` (`meta_key`);

/* If you need the ability to have multiple meta keys with the same key name for one user, then use this solution. */
ALTER TABLE `wp_usermeta`
	DROP PRIMARY KEY,
	DROP INDEX `user_id`,
	ADD PRIMARY KEY (`user_id`, `meta_key`, `umeta_id`), -- to allow dup meta_key for a post
	ADD INDEX `umeta_id` (`umeta_id`), -- to keep AUTO_INCREMENT happy
	ADD INDEX `meta_value` (`meta_value`(10));
```