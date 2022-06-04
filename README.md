# simoneappolloni.com

Install dependencies:
```
apt-get install sqlite3
bundle install
```

Run database migrations:
```
bundle exec rake db:migrate
```

Run console:
```
bundle exec rake console
```

Run database console:
```
sqlite3 database.sqlite
```

Sync database:
```
bundle exec rake sync
```
