# PHP Snippets

See also:
- [Modern WP config template](files/wp-config.php)

## Create new user

Place in theme's `functions.php`.

```php
add_action( 'init', function () {
	$user     = 'example';
	$password = '';
	$email    = 'hello@example.com';

	if ( ! username_exists( $user ) || ! email_exists( $email ) ) {
		$userID = wp_create_user( $user, $password, $email );
		$user = new WP_User( $userID );
		$user->set_role( 'administrator' );
	}
} );
```



## Reset user password

Place in theme's `functions.php`.

```php
add_action( 'init', function () {
	$user = get_user_by('email', 'hello@example.com');
	wp_set_password('', $user->ID);
} );
```