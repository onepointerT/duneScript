SELECT id AS uid, uname AS uname FROM users
SELECT desc AS descr from user_profiles WHERE user_profiles.uname == uname

SELECT uid, uname, descr INTO rq_user_what