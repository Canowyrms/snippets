# PHP Snippets

## className - React-like CSS class string builder

One thing from React I thought was pretty helpful.

> ℹ <br/>
> 

```php
/**
 * A React-like function that takes an associative array of
 *   (string) classname => true/false entries and returns
 *   a string of space-delimited classes of those classes that
 *   evaluated to true.
 *
 * Example usage:
 * ```php
 * $classes = Utilities::className([
 *   'class-one'   => true,
 *   'class-two'   => someCondition(), // assume `false`
 *   'class-three' => true,
 * ]);
 *
 * // Result: 'class-one class-three'
 * ```
 *
 * @param array $classes Associative array of class => bool entries
 *
 * @uses esc_attr()
 *
 * @return string Escaped string of space-delimited classes.
 */
function className (array $classes) : string {
	$filtered = array_filter(
		$classes,
		fn ($k) => (bool) $k
	);

	return esc_attr(
		implode(' ', array_keys($filtered))
	);
}
```
