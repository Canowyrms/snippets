<?php
/**
 * Modern WP Config
 */

/* Environment */
define('WP_ENVIRONMENT_TYPE', 'production');

/* Database */
/* Database connection */
define('DB_NAME',     '');
define('DB_USER',     '');
define('DB_PASSWORD', '');
define('DB_HOST',     '');
define('DB_CHARSET',  'utf8mb4');
define('DB_COLLATE',  '');
/* Tables */
$table_prefix = 'wp_';

/* Security */
/* Security Keys - https://api.wordpress.org/secret-key/1.1/salt/ */
define('AUTH_KEY',         '');
define('SECURE_AUTH_KEY',  '');
define('LOGGED_IN_KEY',    '');
define('NONCE_KEY',        '');
define('AUTH_SALT',        '');
define('SECURE_AUTH_SALT', '');
define('LOGGED_IN_SALT',   '');
define('NONCE_SALT',       '');

/* HTTPS */
//define('FORCE_SSL_LOGIN', true); // Force HTTPS on /wp-login.php
//define('FORCE_SSL_ADMIN', true); // Force HTTPS on /wp-admin

/* URL / Path */
//define('WP_SITEURL', 'http://site_url.tld');       // Force WordPress site URL.
//define('WP_HOME',    'http://core_files_url.tld'); // WordPress core files URL.

/* Content */
define('AUTOSAVE_INTERVAL', 30);    // Saves content editor changes every 30 seconds.
define('WP_POST_REVISIONS', 20);    // Limits maximum number of revisions per post.
define('MEDIA_TRASH',       true);  // Use trash for Media. WordPress default: disabled.
define('EMPTY_TRASH_DAYS',  14);    // WordPress default: 30
define('WP_MAIL_INTERVAL',  86400); // Who posts by mail? Check less frequently.

/* Updates */
define('AUTOMATIC_UPDATER_DISABLED', true); // Disables all automatic updates - core, plugins, etc.

/* File editing/modification */
define('DISALLOW_FILE_EDIT',   true); // Disables editing files through WP Admin.
//define('DISALLOW_FILE_MODS',   true); // Disables plugin and theme updates and installation from WP Admin.
// Overwrite the original image when editing images using the built-in image editor
// instead of creating a new image with the edits applied.
//define('IMAGE_EDIT_OVERWRITE', true);

/* Cron */
//define('DISABLE_WP_CRON', true);   // Use ONLY if you have an external method of triggering WordPress cron.
//define('ALTERNATE_WP_CRON', true); // Uses visitor redirects (instead of loopbacks) to trigger cron.

/* Memory */
//define('WP_MEMORY_LIMIT',     '256M'); // The memory limit WordPress adheres to by default.
//define('WP_MAX_MEMORY_LIMIT', '512M'); // The absolute maximum amount of memory WordPress can use during heavy tasks.

/* Debug */
define('WP_DEBUG', false);

if (defined('WP_DEBUG') && WP_DEBUG) {
	// wp-content/debug.log
	define('WP_DEBUG_LOG',     true);
	// Show debug output in the browser.
	define('WP_DEBUG_DISPLAY', false);

	// Get non-minified where possible.
	define('COMPRESS_CSS',        false);
	// Get non-minified where possible.
	define('COMPRESS_SCRIPTS',    false);
	// Does not use wp-load.php to serve assets.
	define('CONCATENATE_SCRIPTS', false);

	define('SCRIPT_DEBUG',        true);

	//define('SAVEQUERIES',  true);
	//define('QUERY_LOGFILE', 'siteurl.tld_' . date('Y-m-d') . '.log');
}

/* Any additional changes can be made below this line */





/* Do not change anything else after this line! Thank you! */

if (!defined('ABSPATH')) {
	define('ABSPATH', dirname(__FILE__).'/');
}

require_once ABSPATH.'wp-settings.php';
