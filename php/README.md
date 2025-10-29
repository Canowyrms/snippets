# PHP Snippets

## className - React-like CSS class string builder

One thing from React I thought was pretty helpful.

> ⚠ TODO<br/>
> phpdoc has `@uses esc_attr()` but actual code does not; re-implement `esc_attr()` or use in WordPress, which provides `esc_attr()`.

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



## 'jsonify' output, debug it in javascript console

Mostly used this for debugging Twig/Timber context objects, because that was just easier to do in the browser's js console. Can easily be adapted for any kind of object/array.

```php
?>
<pre class="jsonify" data-name="something-useful"><?php
	echo esc_html(json_encode($context));
?></pre>


/**
 * JSONIFY PHP Function. Converts PHP objects/arrays to JSON and outputs the results to the DOM.
 * 
 * @param $data PHP array or object.
 * @param string $name Meaningful name of what we're JSONIFY-ing.
 * 
 * @return string The completed markup.
 */
function jsonify ( $data, string $name ) {
	ob_start();

	?>
	<pre class="jsonify" data-name="<?php echo $name; ?>"><?php
		echo esc_html( json_encode( $data ) );
	?></pre>
	<?php

	$output = ob_get_clean();

	return $output;
}
```

```js
document.querySelectorAll('.jsonify')?.forEach((element, index) => {
	let name = element.getAttribute('data-name') ?? `#${index}`;

	console.log(`JSONIFY | ${name}:`);
	try {
		console.log(JSON.parse(element.textContent));
	} catch (error) {
		console.warn(`JSONIFY | ${name} could not be parsed.`);
	}
});
```
