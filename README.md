# Skeleton laravel website

## Local setup

Steps, that should be done, to run project on the local environment

1. Clone repository locally
2. Copy file `.env.example` to `.env` at the project root, and fill all the required values
> _In some cases, it is also recommended to change the permissions for some files and directory:_
> ```sh
> sudo chmod -R 777 docker
> chmod 750 docker/mysql/my.cnf
> ```
> _Thus, you can be sure that the dock has access to all folders._
3. Run `docker compose build` (`docker-compose build` for older versions)
4. Run `docker compose up` (`docker-compose up` for older versions)
5. Using cli mode, enter the php container console (Example: `docker exec -u www-data -it projectcode-php-1 bash`)
6. Execute `composer install`
7. Set key values
    ```sh
    php artisan key:generate
    php artisan jwt:secret -f
    ```
8. On your host append to the hosts file:
	```
	# Project Name
	127.0.0.1 projectcode.local
	127.0.0.1 admin.projectcode.local
	127.0.0.1 static.projectcode.local
	127.0.0.1 profiler.projectcode.local
	```
9. Fill the database with executing the command `php artisan migrate`.
10. Config SSL certificates (example using the mkcert utility). The advantage is the installation of a root certificate at the system level, and support for browsers.
    1. Download [mkcert](https://github.com/FiloSottile/mkcert) for your OS
    2. Run `mkcert -install`
    3. Run `mkcert -cert-file /etc/nginx/certs/_wildcard.projectcode.local.pem -key-file /etc/nginx/certs/_wildcard.projectcode.local-key.pem "*.projectcode.local"`
11. To your local nginx config proxy (instead of 443 write the port from `.env` file, and replace `/path/to/project` with full project folder path).
    If necessary, enable the website (if the saving was in a separate file)
	```
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate /etc/nginx/certs/_wildcard.projectcode.local.pem;
        ssl_certificate_key /etc/nginx/certs/_wildcard.projectcode.local-key.pem;

        server_name projectcode.local admin.projectcode.local static.projectcode.local profiler.projectcode.local;
        location / {
            proxy_set_header   Host $http_host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $remote_addr;
            proxy_pass         "https://projectcode.local:443";
            proxy_ssl_certificate /path/to/project/docker/nginx/certs/projectcode.pem;
            proxy_ssl_certificate_key /path/to/project/docker/nginx/certs/projectcode-key.pem;
        }
    }
	```
12. Go to https://projectcode.local/

## Crons

All tasks for which Laravel is used are created by built-in planner
Laravel. Use crontab only in extra cases, or when the script is
console.

## Saving some values in database

### Finances

All amounts are stored in the smallest fractional part according to the standard [ISO 4217](https://en.wikipedia.org/wiki/iso_4217). For example:
| Value | Currency Code | Amount    |
| ----- | ------------- | --------- |
| 500   | USD           | $5.00     |
| 500   | JPY           | ¥500      |
| 500   | UAH           | 5.00 грн. |
| 500   | KWD           | ½ KD      |

For the simplicity of operations, the `moneyphp/money` package has been added, and the `\App\Components\Money.php` component was created.

All financial transactions in the code do taking into account the possibility of the currency difference.

### Date and time

For all dates and time values, use the date/datetime types and the UTC timezone (except for some cases when necessary). Fields `created_at` and `updated_at` should be created in this way:

```sql
`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
`updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
```
or
```php
$table->dateTime('created_at')->useCurrent();
$table->dateTime('updated_at')->useCurrent()->useCurrentOnUpdate();
```

With model generation remove `created_at` and `updated_at` from the
`$fillable` variable. **Do not change this values in the code!**

## Оформление кода

Mostly code should be formatted according to the [PSR-12](https://gist.github.com/zamaldinov28/77674c05345db6ae1977ba575306bfb5).

To simplify, a script was created, which must be launched as follows:
```sh
cd scripts/
make
```

In the comments to the arrays (docblock), ALWAYS write the type of contents. Examples:

- `array<string>` - `$a = ['qwe', 'rty', 'uio'];`
- `array<string,string>` - `$a = ['a' => 'qwe', 'b' => 'rty', 'c' => 'uio'];`
- `array<int|string,string>` - `$a = ['a' => 'qwe', 'b' => 'rty', 'uio'];`
- `array<Model>` - `$a = [new Model(), new Model()];`

## Exceptions

By default, only two types of errors are used:
- `\Exception` - for those cases when an error is on the backend, and requires the intervention/attention of the developers
- `\App\Components\Exceptions\DomainException` - for all cases when an error is not a systemic nature, but a user.

The use of these two errors is due to the fact that they have different processing logic.`Exception` gives the answer most often an incomprehensible code, and comes as notification to the developers. `DomainException` gives the reason for the error, and passes unnoticed by the developers.

## Logging

For logging, you need to use the standard facade `Illuminate\Support\Facades\Log`, in which the levels according to [RFC 5424](https://www.rfc-editor.org/rfc/rfc5424). Since not all problems need to be logged in with notification, it is necessary to use certain levels for certain situations:
- `Log::emergency()` - The system is unsuitable for use. Example: the system cannot start.
- `Log::alert()` - It requires immediate response, but some part of the system functions. Example: the inaccessibility of the database.
- `Log::critical()` - Critical situation. It should be solved throughout the day. Example: an error of maintaining the primary recording in the database.
- `Log::error()` - A mistake arose. Not a critical situation (does not affect the vital components of the system), which can be solved and eliminated in order. It is recommended to create a task with the highest or high priority. Example: error of maintaining a secondary recording in the database.
- `Log::warning()` - A warning arose. The message that so far there is no mistake, but without intervention it may occur soon. Or when there was an unexpected situation that should be processed. It is recommended to create a task with a high or medium priority. Example: the system is filled by 85%; A different date format from the data supplier came.
- `Log::notice()` - The standard behavior of the system, but the information is important.Example: a third-party refusal, interception of Fallback (when the system worked correctly, but something happened).
- `Log::info()` - Just information. There may be information useful for other departments with notification in telegram channels, mail, etc. Example: Logging of requests for third-party services, information about the state of the system.
- `Log::debug()` - Messages at the level of debugging. Use on a production env only in case of emergency. Example: Dumps of a variable, arguments of function, stack.

All messages with the level of `warning` and above require attention or intervention by the developers of the system. Everything that cannot be corrected on our side should not be higher then `notice`.

## Debugging

The php container has pre-installed xdebug.

To launch in CLI mode, it is necessary to set the env variables before the command (or at the container level):

`XDEBUG_MODE=debug XDEBUG_SESSION=1 php artisan test`.

For disabling just set `XDEBUG_MODE=off`.

For web-debug, it is recommended to install an [extension](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc) for the Google Chrome browser.

The IDE must be configured list with (example of configuration for VSCode):

```json
{
    "name": "Listen for Xdebug",
    "type": "php",
    "request": "launch",
    "pathMappings": {
        "/var/www/projectcode": "${workspaceRoot}"
    },
    "port": 9003
}
```

It is important to set the port 9003 (pay attention to the fact that there was a different port by default, so it is necessary to indicate explicitly), and the linking of the file system paths, otherwise the debugger will try to open the path from the container outside the container (and most likely it does not work out).

## Profiler

There is a [profiler](https://github.com/jkocik/laravel-profiler) installed for the project on the dev environment. By default is it already enabled, but it should be activated in `.env` file with the value `PROFILER_ENABLED=true`, and to go into to, just go to [this website](https://profiler.projectcode.local/). Feel free to manage to launching from `entrypoint.sh`. By default, he handled many events, but if you need to debug a specific part with the profiler, it is necessary to wrap the code in this way:

```php
profiler_start('my time metric name');

// my code to track execution time

profiler_finish('my time metric name');
```

After that, you can see the results in the browser.