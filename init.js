db.auth('admin', 'password')

db = db.getSiblingDB('db')

db.createUser({
  user: 'user',
  pwd: 'password',
  roles: [
    {
      role: 'root',
      db: 'database',
    },
  ],
});