#### ATTENTION: You do not need to run or use this file!  The install.php script does everything for you!
#### Install script for PostgreSQL 8.0.1

#
# Create PostgreSQL functions.
# Some taken from http://www.xach.com/aolserver/mysql-functions.sql and http://pgfoundry.org/projects/mysqlcompat/.
# IP Regex in inet_aton from http://www.mkyong.com/database/regular-expression-in-postgresql/.

CREATE OR REPLACE FUNCTION FROM_UNIXTIME(integer) RETURNS timestamp AS
  'SELECT timestamp ''epoch'' + $1 * interval ''1 second'' AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (text, text) RETURNS text AS
  'SELECT COALESCE($1, $2) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (int4, int4) RETURNS int4 AS
  'SELECT COALESCE($1, $2) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (int8, int8) RETURNS int8 AS
  'SELECT COALESCE($1, $2) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (character varying, character varying) RETURNS character varying AS
  'SELECT COALESCE($1, $2) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (character varying, boolean) RETURNS character varying AS
  'SELECT COALESCE($1, CAST(CAST($2 AS int) AS varchar)) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION IFNULL (int, boolean) RETURNS int AS
  'SELECT COALESCE($1, CAST($2 AS int)) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION INET_ATON(text) RETURNS bigint AS '
  SELECT
  CASE WHEN
    $1 !~ ''^[0-9]?[0-9]?[0-9]?\.[0-9]?[0-9]?[0-9]?\.[0-9]?[0-9]?[0-9]?\.[0-9]?[0-9]?[0-9]?$'' THEN 0
  ELSE
    split_part($1, ''.'', 1)::int8 * (256 * 256 * 256) +
    split_part($1, ''.'', 2)::int8 * (256 * 256) +
    split_part($1, ''.'', 3)::int8 * 256 +
    split_part($1, ''.'', 4)::int8
  END AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION INET_NTOA(bigint) RETURNS text AS '
  SELECT
    (($1 >> 24) & 255::int8) || ''.'' ||
    (($1 >> 16) & 255::int8) || ''.'' ||
    (($1 >> 8) & 255::int8) || ''.'' ||
    ($1 & 255::int8) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION FIND_IN_SET(needle text, haystack text) RETURNS integer AS '
  SELECT i AS result
  FROM generate_series(1, array_upper(string_to_array($2,'',''), 1)) AS g(i)
  WHERE (string_to_array($2,'',''))[i] = $1
    UNION ALL
  SELECT 0
  LIMIT 1'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION FIND_IN_SET(needle integer, haystack text) RETURNS integer AS '
  SELECT i AS result
  FROM generate_series(1, array_upper(string_to_array($2,'',''), 1)) AS g(i)
  WHERE  (string_to_array($2,'',''))[i] = CAST($1 AS text)
    UNION ALL
  SELECT 0
  LIMIT 1'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION FIND_IN_SET(needle smallint, haystack text) RETURNS integer AS '
  SELECT i AS result
  FROM generate_series(1, array_upper(string_to_array($2,'',''), 1)) AS g(i)
  WHERE  (string_to_array($2,'',''))[i] = CAST($1 AS text)
    UNION ALL
  SELECT 0
  LIMIT 1'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION LEFT (text, int4) RETURNS text AS
  'SELECT SUBSTRING($1 FROM 0 FOR $2) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION add_num_text (text, integer) RETURNS text AS
  'SELECT CAST ((CAST($1 AS integer) + $2) AS text) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION YEAR (timestamp) RETURNS integer AS
  'SELECT CAST (EXTRACT(YEAR FROM $1) AS integer) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION MONTH (timestamp) RETURNS integer AS
  'SELECT CAST (EXTRACT(MONTH FROM $1) AS integer) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION day(date) RETURNS integer AS
  'SELECT EXTRACT(DAY FROM DATE($1))::integer AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION DAYOFMONTH (timestamp) RETURNS integer AS
  'SELECT CAST (EXTRACT(DAY FROM $1) AS integer) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION HOUR (timestamp) RETURNS integer AS
  'SELECT CAST (EXTRACT(HOUR FROM $1) AS integer) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION DATE_FORMAT (timestamp, text) RETURNS text AS '
  SELECT
    REPLACE(
        REPLACE($2, ''%m'', to_char($1, ''MM'')),
    ''%d'', to_char($1, ''DD'')) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION TO_DAYS (timestamp) RETURNS integer AS
  'SELECT DATE_PART(''DAY'', $1 - ''0001-01-01bc'')::integer AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION CONCAT (text, text) RETURNS text AS
  'SELECT $1 || $2 AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION INSTR (text, text) RETURNS integer AS
  'SELECT POSITION($2 in $1) AS result'
LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION bool_not_eq_int (boolean, integer) RETURNS boolean AS
  'SELECT CAST($1 AS integer) != $2 AS result'
LANGUAGE 'sql';

#
# Create PostgreSQL operators.
#

CREATE OPERATOR + (PROCEDURE = add_num_text, LEFTARG = text, RIGHTARG = integer);
CREATE OPERATOR != (PROCEDURE = bool_not_eq_int, LEFTARG = boolean, RIGHTARG = integer);

#
# Sequence for table `admin_info_files`
#

CREATE SEQUENCE {$db_prefix}admin_info_files_seq START WITH 4;

#
# Table structure for table `admin_info_files`
#

CREATE TABLE {$db_prefix}admin_info_files (
  id_file smallint default nextval('{$db_prefix}admin_info_files_seq'),
  filename varchar(255) NOT NULL,
  path varchar(255) NOT NULL,
  parameters varchar(255) NOT NULL,
  data text NOT NULL,
  filetype varchar(255) NOT NULL,
  PRIMARY KEY (id_file)
);

#
# Indexes for table `admin_info_files`
#

CREATE INDEX {$db_prefix}admin_info_files_filename ON {$db_prefix}admin_info_files (filename);

#
# Sequence for table `antispam_questions`
#

CREATE SEQUENCE {$db_prefix}antispam_questions_seq;

#
# Table structure for table `antispam_questions`
#

CREATE TABLE {$db_prefix}antispam_questions (
  id_question int default nextval('{$db_prefix}antispam_questions_seq'),
  question text NOT NULL,
  answer text NOT NULL,
  language varchar(50) NOT NULL,
  PRIMARY KEY (id_question)
);

#
# Indexes for table `antispam_questions`
#

CREATE INDEX {$db_prefix}antispam_questions_language ON {$db_prefix}antispam_questions (language);

#
# Table structure for table `approval_queue`
#

CREATE TABLE {$db_prefix}approval_queue (
  id_msg int NOT NULL default '0',
  id_attach int NOT NULL default '0',
  id_event smallint NOT NULL default '0'
);

#
# Sequence for table `attachments`
#

CREATE SEQUENCE {$db_prefix}attachments_seq;

#
# Table structure for table `attachments`
#

CREATE TABLE {$db_prefix}attachments (
  id_attach int default nextval('{$db_prefix}attachments_seq'),
  id_thumb int NOT NULL default '0',
  id_msg int NOT NULL default '0',
  id_member int NOT NULL default '0',
  id_folder smallint NOT NULL default '1',
  attachment_type smallint NOT NULL default '0',
  filename varchar(255) NOT NULL,
  file_hash varchar(40) NOT NULL default '',
  fileext varchar(8) NOT NULL default '',
  size int NOT NULL default '0',
  downloads int NOT NULL default '0',
  width int NOT NULL default '0',
  height int NOT NULL default '0',
  mime_type varchar(20) NOT NULL default '',
  approved smallint NOT NULL default '1',
  PRIMARY KEY (id_attach)
);

#
# Indexes for table `attachments`
#

CREATE UNIQUE INDEX {$db_prefix}attachments_id_member ON {$db_prefix}attachments (id_member, id_attach);
CREATE INDEX {$db_prefix}attachments_id_msg ON {$db_prefix}attachments (id_msg);
CREATE INDEX {$db_prefix}attachments_attachment_type ON {$db_prefix}attachments (attachment_type);
CREATE INDEX {$db_prefix}attachments_id_thumb ON {$db_prefix}attachments (id_thumb);

#
# Sequence for table `ban_groups`
#

CREATE SEQUENCE {$db_prefix}ban_groups_seq;

#
# Table structure for table `ban_groups`
#

CREATE TABLE {$db_prefix}ban_groups (
  id_ban_group int default nextval('{$db_prefix}ban_groups_seq'),
  name varchar(20) NOT NULL default '',
  ban_time int NOT NULL default '0',
  expire_time int,
  cannot_access smallint NOT NULL default '0',
  cannot_register smallint NOT NULL default '0',
  cannot_post smallint NOT NULL default '0',
  cannot_login smallint NOT NULL default '0',
  reason varchar(255) NOT NULL,
  notes text NOT NULL,
  PRIMARY KEY (id_ban_group)
);

#
# Sequence for table `ban_items`
#

CREATE SEQUENCE {$db_prefix}ban_items_seq;

#
# Table structure for table `ban_items`
#

CREATE TABLE {$db_prefix}ban_items (
  id_ban int default nextval('{$db_prefix}ban_items_seq'),
  id_ban_group smallint NOT NULL default '0',
  ip_low1 smallint NOT NULL default '0',
  ip_high1 smallint NOT NULL default '0',
  ip_low2 smallint NOT NULL default '0',
  ip_high2 smallint NOT NULL default '0',
  ip_low3 smallint NOT NULL default '0',
  ip_high3 smallint NOT NULL default '0',
  ip_low4 smallint NOT NULL default '0',
  ip_high4 smallint NOT NULL default '0',
  ip_low5 smallint NOT NULL default '0',
  ip_high5 smallint NOT NULL default '0',
  ip_low6 smallint NOT NULL default '0',
  ip_high6 smallint NOT NULL default '0',
  ip_low7 smallint NOT NULL default '0',
  ip_high7 smallint NOT NULL default '0',
  ip_low8 smallint NOT NULL default '0',
  ip_high8 smallint NOT NULL default '0',
  hostname varchar(255) NOT NULL,
  email_address varchar(255) NOT NULL,
  id_member int NOT NULL default '0',
  hits int NOT NULL default '0',
  PRIMARY KEY (id_ban)
);

#
# Indexes for table `ban_items`
#

CREATE INDEX {$db_prefix}ban_items_id_ban_group ON {$db_prefix}ban_items (id_ban_group);

#
# Table structure for table `board_permissions`
#

CREATE TABLE {$db_prefix}board_permissions (
  id_group smallint NOT NULL default '0',
  id_profile smallint NOT NULL default '0',
  permission varchar(30) NOT NULL default '',
  add_deny smallint NOT NULL default '1',
  PRIMARY KEY (id_group, id_profile, permission)
);

#
# Dumping data for table `board_permissions`
#

INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (-1, 1, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'remove_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_add_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_edit_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'postby_email');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 1, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 1, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 1, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (-1, 2, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'remove_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'postby_email');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 2, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 2, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 2, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (-1, 3, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'remove_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 3, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 3, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 3, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (-1, 4, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (0, 4, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (2, 4, 'view_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'like_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'moderate_board');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_new');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_autosave_draft');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_reply_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_reply_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_unapproved_topics');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_unapproved_replies_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_unapproved_replies_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_unapproved_attachments');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_post');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_add_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_view');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_vote');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'poll_edit_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'report_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'lock_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'send_topic');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'mark_any_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'mark_notify');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'delete_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'modify_own');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'make_sticky');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'lock_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'remove_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'move_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'merge_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'split_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'delete_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'modify_any');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'approve_posts');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'post_attachment');
INSERT INTO {$db_prefix}board_permissions (id_group, id_profile, permission) VALUES (3, 4, 'view_attachments');
# --------------------------------------------------------

#
# Sequence for table `boards`
#

CREATE SEQUENCE {$db_prefix}boards_seq START WITH 2;

#
# Table structure for table `boards`
#

CREATE TABLE {$db_prefix}boards (
  id_board smallint default nextval('{$db_prefix}boards_seq'),
  id_cat smallint NOT NULL default '0',
  child_level smallint NOT NULL default '0',
  id_parent smallint NOT NULL default '0',
  board_order smallint NOT NULL default '0',
  id_last_msg int NOT NULL default '0',
  id_msg_updated int NOT NULL default '0',
  member_groups varchar(255) NOT NULL default '-1,0',
  id_profile smallint NOT NULL default '1',
  name varchar(255) NOT NULL,
  description text NOT NULL,
  num_topics int NOT NULL default '0',
  num_posts int NOT NULL default '0',
  count_posts smallint NOT NULL default '0',
  id_theme smallint NOT NULL default '0',
  override_theme smallint NOT NULL default '0',
  unapproved_posts smallint NOT NULL default '0',
  unapproved_topics smallint NOT NULL default '0',
  redirect varchar(255) NOT NULL default '',
  deny_member_groups varchar(255) NOT NULL default '',
  PRIMARY KEY (id_board)
);

#
# Indexes for table `ban_items`
#

CREATE UNIQUE INDEX {$db_prefix}boards_categories ON {$db_prefix}boards (id_cat, id_board);
CREATE INDEX {$db_prefix}boards_id_parent ON {$db_prefix}boards (id_parent);
CREATE INDEX {$db_prefix}boards_id_msg_updated ON {$db_prefix}boards (id_msg_updated);
CREATE INDEX {$db_prefix}boards_member_groups ON {$db_prefix}boards (member_groups);

#
# Dumping data for table `boards`
#

INSERT INTO {$db_prefix}boards
	(id_board, id_cat, board_order, id_last_msg, id_msg_updated, name, description, num_topics, num_posts, member_groups)
VALUES (1, 1, 1, 1, 1, '{$default_board_name}', '{$default_board_description}', 1, 1, '-1,0,2');
# --------------------------------------------------------

#
# Sequence for table `calendar`
#

CREATE SEQUENCE {$db_prefix}calendar_seq;

#
# Table structure for table `calendar`
#

CREATE TABLE {$db_prefix}calendar (
  id_event smallint default nextval('{$db_prefix}calendar_seq'),
  start_date date NOT NULL default '0001-01-01',
  end_date date NOT NULL default '0001-01-01',
  id_board smallint NOT NULL default '0',
  id_topic int NOT NULL default '0',
  title varchar(255) NOT NULL default '',
  id_member int NOT NULL default '0',
  PRIMARY KEY (id_event)
);

#
# Indexes for table `calendar`
#

CREATE INDEX {$db_prefix}calendar_start_date ON {$db_prefix}calendar (start_date);
CREATE INDEX {$db_prefix}calendar_end_date ON {$db_prefix}calendar (end_date);
CREATE INDEX {$db_prefix}calendar_topic ON {$db_prefix}calendar (id_topic, id_member);

#
# Sequence for table `calendar_holidays`
#

CREATE SEQUENCE {$db_prefix}calendar_holidays_seq;

#
# Table structure for table `calendar_holidays`
#

CREATE TABLE {$db_prefix}calendar_holidays (
  id_holiday smallint default nextval('{$db_prefix}calendar_holidays_seq'),
  event_date date NOT NULL default '0001-01-01',
  title varchar(255) NOT NULL default '',
  PRIMARY KEY (id_holiday)
);

#
# Indexes for table `calendar_holidays`
#

CREATE INDEX {$db_prefix}calendar_holidays_event_date ON {$db_prefix}calendar_holidays (event_date);

#
# Dumping data for table `calendar_holidays`
#

INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('New Year''s', '0004-01-01');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Christmas', '0004-12-25');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Valentine''s Day', '0004-02-14');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('St. Patrick''s Day', '0004-03-17');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('April Fools', '0004-04-01');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Earth Day', '0004-04-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('United Nations Day', '0004-10-24');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Halloween', '0004-10-31');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2010-05-09');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2011-05-08');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2012-05-13');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2013-05-12');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2014-05-11');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2015-05-10');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2016-05-08');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2017-05-14');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2018-05-13');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2019-05-12');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Mother''s Day', '2020-05-10');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2010-06-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2011-06-19');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2012-06-17');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2013-06-16');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2014-06-15');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2015-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2016-06-19');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2017-06-18');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2018-06-17');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2019-06-16');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Father''s Day', '2020-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2010-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2011-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2012-06-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2013-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2014-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2015-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2016-06-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2017-06-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2018-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2019-06-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Summer Solstice', '2020-06-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2010-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2011-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2012-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2013-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2014-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2015-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2016-03-19');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2017-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2018-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2019-03-20');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Vernal Equinox', '2020-03-19');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2010-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2011-12-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2012-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2013-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2014-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2015-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2016-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2017-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2018-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2019-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Winter Solstice', '2020-12-21');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2010-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2011-09-23');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2012-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2013-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2014-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2015-09-23');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2016-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2017-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2018-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2019-09-23');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Autumnal Equinox', '2020-09-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Independence Day', '0004-07-04');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Cinco de Mayo', '0004-05-05');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Flag Day', '0004-06-14');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Veterans Day', '0004-11-11');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Groundhog Day', '0004-02-02');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2010-11-25');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2011-11-24');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2012-11-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2013-11-28');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2014-11-27');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2015-11-26');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2016-11-24');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2017-11-23');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2018-11-22');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2019-11-28');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Thanksgiving', '2020-11-26');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2010-05-31');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2011-05-30');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2012-05-28');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2013-05-27');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2014-05-26');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2015-05-25');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2016-05-30');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2017-05-29');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2018-05-28');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2019-05-27');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Memorial Day', '2020-05-25');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2010-09-06');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2011-09-05');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2012-09-03');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2013-09-02');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2014-09-01');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2015-09-07');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2016-09-05');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2017-09-04');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2018-09-03');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2019-09-02');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('Labor Day', '2020-09-07');
INSERT INTO {$db_prefix}calendar_holidays (title, event_date) VALUES ('D-Day', '0004-06-06');
# --------------------------------------------------------

#
# Sequence for table `categories`
#

CREATE SEQUENCE {$db_prefix}categories_seq START WITH 2;

#
# Table structure for table `categories`
#

CREATE TABLE {$db_prefix}categories (
  id_cat smallint default nextval('{$db_prefix}categories_seq'),
  cat_order smallint NOT NULL default '0',
  name varchar(255) NOT NULL,
  can_collapse smallint NOT NULL default '1',
  PRIMARY KEY (id_cat)
);

#
# Dumping data for table `categories`
#

INSERT INTO {$db_prefix}categories
VALUES (1, 0, '{$default_category_name}', 1);
# --------------------------------------------------------

#
# Table structure for table `collapsed_categories`
#

CREATE TABLE {$db_prefix}collapsed_categories (
  id_cat smallint NOT NULL default '0',
  id_member int NOT NULL default '0',
  PRIMARY KEY (id_cat, id_member)
);

#
# Sequence for table `custom_fields`
#

CREATE SEQUENCE {$db_prefix}custom_fields_seq;

#
# Table structure for table `custom_fields`
#

CREATE TABLE {$db_prefix}custom_fields (
  id_field smallint default nextval('{$db_prefix}custom_fields_seq'),
  col_name varchar(12) NOT NULL default '',
  field_name varchar(40) NOT NULL default '',
  field_desc varchar(255) NOT NULL,
  field_type varchar(8) NOT NULL default 'text',
  field_length smallint NOT NULL default '255',
  field_options text NOT NULL,
  mask varchar(255) NOT NULL,
  show_reg smallint NOT NULL default '0',
  show_display smallint NOT NULL default '0',
  show_memberlist smallint NOT NULL default '0',
  show_profile varchar(20) NOT NULL default 'forumprofile',
  private smallint NOT NULL default '0',
  active smallint NOT NULL default '1',
  bbc smallint NOT NULL default '0',
  can_search smallint NOT NULL default '0',
  default_value varchar(255) NOT NULL,
  enclose text NOT NULL,
  placement smallint NOT NULL default '0',
  vieworder smallint NOT NULL default '0',
  PRIMARY KEY (id_field)
);

#
# Indexes for table `custom_fields`
#

CREATE UNIQUE INDEX {$db_prefix}custom_fields_col_name ON {$db_prefix}custom_fields (col_name);

#
# Dumping data for table `custom_fields`
#

INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_aim', 'AOL Instant Messenger', 'This is your AOL Instant Messenger nickname.', 'text', 50, '', 'regex~[a-z][0-9a-z.-]{1,31}~i', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a class="aim" href="aim:goim?screenname={INPUT}&message=Hello!+Are+you+there?" target="_blank" title="AIM - {INPUT}"><img src="{IMAGES_URL}/profile/aim.png" alt="AIM - {INPUT}"></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_icq', 'ICQ', 'This is your ICQ number.', 'text', 12, '', 'regex~[1-9][0-9]{4,9}~i', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a class="icq" href="http://www.icq.com/whitepages/about_me.php?uin={INPUT}" target="_blank" title="ICQ - {INPUT}"><img src="http://status.icq.com/online.gif?img=5&icq={INPUT}" alt="ICQ - {INPUT}" width="18" height="18"></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_skye', 'Skype', 'This is your Skype account name', 'text', 32, '', 'regex~[a-z][0-9a-z.-]{1,31}~i', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a href="skype:{INPUT}?call"><img src="http://mystatus.skype.com/smallicon/{INPUT}" alt="Skype - {INPUT}" title="Skype - {INPUT}" /></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_fbook', 'Facebook Profile', 'Enter your Facebook username.', 'text', 50, '', 'regex~[a-z][0-9a-z.-]{1,31}~i', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a target="_blank" href="https://www.facebook.com/{INPUT}"><img src="{DEFAULT_IMAGES_URL}/profile/facebook.png" alt="{INPUT}" /></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_twitt', 'Twitter Profile', 'Enter your Twitter username.', 'text', 50, '', 'regex~[a-z][0-9a-z.-]{1,31}~i', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a target="_blank" href="https://www.twitter.com/{INPUT}"><img src="{DEFAULT_IMAGES_URL}/profile/twitter.png" alt="{INPUT}" /></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_linked', 'LinkedIn Profile', 'Set your LinkedIn Public profile link. You must set a Custom public url for this to work.', 'text', 255, '', 'nohtml', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a target={INPUT}"><img src="{DEFAULT_IMAGES_URL}/profile/linkedin.png" alt="LinkedIn profile" /></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_gplus', 'Google+ Profile', 'This is your Google+ profile url.', 'text', 255, '', 'nohtml', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a target="_blank" href="{INPUT}"><img src="{DEFAULT_IMAGES_URL}/profile/gplus.png" alt="G+ profile" /></a>', 1);
INSERT INTO {$db_prefix}custom_fields
	(col_name, field_name, field_desc, field_type, field_length, field_options, mask, show_reg, show_display, show_profile, private, active, bbc, can_search, default_value, enclose, placement)
VALUES
	('cust_yim', 'Yahoo! Messenger', 'This is your Yahoo! Instant Messenger nickname.', 'text', 50, '', 'email', 0, 1, 'forumprofile', 0, 1, 0, 0, '', '<a class="yim" href="http://edit.yahoo.com/config/send_webmesg?.target={INPUT}" target="_blank" title="Yahoo! Messenger - {INPUT}"><img src="http://opi.yahoo.com/online?m=g&t=0&u={INPUT}" alt="Yahoo! Messenger - {INPUT}"></a>', 1);

#
# Table structure for table `custom_fields_data`
#

CREATE TABLE {$db_prefix}custom_fields_data (
  id_member int NOT NULL default '0',
  variable varchar(255) NOT NULL default '',
  value text NOT NULL,
  PRIMARY KEY (id_member, variable)
);

#
# Indexes for table `custom_fields_data`
#

CREATE INDEX {$db_prefix}custom_fields_data_id_member ON {$db_prefix}custom_fields_data (id_member);

#
# Table structure for table `group_moderators`
#

CREATE TABLE {$db_prefix}group_moderators (
  id_group smallint NOT NULL default '0',
  id_member int NOT NULL default '0',
  PRIMARY KEY (id_group, id_member)
);

#
# Table structure for table `follow_ups`
#

CREATE TABLE {$db_prefix}follow_ups (
  follow_up int NOT NULL default '0',
  derived_from int NOT NULL default '0',
  PRIMARY KEY (follow_up, derived_from)
);

#
# Sequence for table `log_actions`
#

CREATE SEQUENCE {$db_prefix}log_actions_seq;

#
# Table structure for table `log_actions`
#

CREATE TABLE {$db_prefix}log_actions (
  id_action int default nextval('{$db_prefix}log_actions_seq'),
  id_log smallint NOT NULL default '1',
  log_time int NOT NULL default '0',
  id_member int NOT NULL default '0',
  ip char(16) NOT NULL default '                ',
  action varchar(30) NOT NULL default '',
  id_board smallint NOT NULL default '0',
  id_topic int NOT NULL default '0',
  id_msg int NOT NULL default '0',
  extra text NOT NULL,
  PRIMARY KEY (id_action)
);

#
# Indexes for table `log_actions`
#

CREATE INDEX {$db_prefix}log_actions_log_time ON {$db_prefix}log_actions (log_time);
CREATE INDEX {$db_prefix}log_actions_id_member ON {$db_prefix}log_actions (id_member);
CREATE INDEX {$db_prefix}log_actions_id_board ON {$db_prefix}log_actions (id_board);
CREATE INDEX {$db_prefix}log_actions_id_msg ON {$db_prefix}log_actions (id_msg);
CREATE INDEX {$db_prefix}log_actions_id_log ON {$db_prefix}log_actions (id_log);

#
# Table structure for table `log_activity`
#

CREATE TABLE {$db_prefix}log_activity (
  date date NOT NULL default '0001-01-01',
  hits int NOT NULL default '0',
  topics smallint NOT NULL default '0',
  posts smallint NOT NULL default '0',
  registers smallint NOT NULL default '0',
  most_on smallint NOT NULL default '0',
  pm smallint NOT NULL default '0',
  email smallint NOT NULL default '0',
  PRIMARY KEY (date)
);

#
# Indexes for table `log_activity`
#
CREATE INDEX {$db_prefix}log_activity_most_on ON {$db_prefix}log_activity (most_on);

#
# Sequence for table `log_badbehavior`
#

CREATE SEQUENCE {$db_prefix}log_badbehavior_seq;

#
# Table structure for table `log_badbehavior`
#

CREATE TABLE {$db_prefix}log_badbehavior (
  id int default nextval('{$db_prefix}log_badbehavior_seq'),
  ip char(19) NOT NULL,
  date int NOT NULL default '0',
  request_method varchar(255) NOT NULL,
  request_uri varchar(255) NOT NULL,
  server_protocol varchar(255) NOT NULL,
  http_headers text NOT NULL,
  user_agent varchar(255) NOT NULL,
  request_entity varchar(255) NOT NULL,
  valid varchar(255) NOT NULL,
  id_member int NOT NULL,
  session char(64) NOT NULL default '',
  PRIMARY KEY (id)
);

#
# Indexes for table `log_badbehavior`
#

CREATE INDEX {$db_prefix}ip ON {$db_prefix}log_badbehavior (ip);
CREATE INDEX {$db_prefix}user_agent ON {$db_prefix}log_badbehavior (user_agent);

#
# Sequence for table `log_banned`
#

CREATE SEQUENCE {$db_prefix}log_banned_seq;

#
# Table structure for table `log_banned`
#

CREATE TABLE {$db_prefix}log_banned (
  id_ban_log int default nextval('{$db_prefix}log_banned_seq'),
  id_member int NOT NULL default '0',
  ip char(16) NOT NULL default '                ',
  email varchar(255) NOT NULL,
  log_time int NOT NULL default '0',
  PRIMARY KEY (id_ban_log)
);

#
# Indexes for table `log_banned`
#

CREATE INDEX {$db_prefix}log_banned_log_time ON {$db_prefix}log_banned (log_time);

#
# Table structure for table `log_boards`
#

CREATE TABLE {$db_prefix}log_boards (
  id_member int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  id_msg int NOT NULL default '0',
  PRIMARY KEY (id_member, id_board)
);

#
# Sequence for table `log_comments`
#

CREATE SEQUENCE {$db_prefix}log_comments_seq;

#
# Table structure for table `log_comments`
#

CREATE TABLE {$db_prefix}log_comments (
  id_comment int default nextval('{$db_prefix}log_comments_seq'),
  id_member int NOT NULL default '0',
  member_name varchar(80) NOT NULL default '',
  comment_type varchar(8) NOT NULL default 'warning',
  id_recipient int NOT NULL default '0',
  recipient_name varchar(255) NOT NULL,
  log_time int NOT NULL default '0',
  id_notice int NOT NULL default '0',
  counter smallint NOT NULL default '0',
  body text NOT NULL,
  PRIMARY KEY (id_comment)
);

#
# Indexes for table `log_comments`
#

CREATE INDEX {$db_prefix}log_comments_id_recipient ON {$db_prefix}log_comments (id_recipient);
CREATE INDEX {$db_prefix}log_comments_log_time ON {$db_prefix}log_comments (log_time);
CREATE INDEX {$db_prefix}log_comments_comment_type ON {$db_prefix}log_comments (comment_type);

#
# Table structure for table `log_digest`
#

CREATE TABLE {$db_prefix}log_digest (
  id_topic int NOT NULL,
  id_msg int NOT NULL,
  note_type varchar(10) NOT NULL default 'post',
  daily smallint NOT NULL default '0',
  exclude int NOT NULL default '0'
);

#
# Sequence for table `log_errors`
#

CREATE SEQUENCE {$db_prefix}log_errors_seq;

#
# Table structure for table `log_errors`
#

CREATE TABLE {$db_prefix}log_errors (
  id_error int default nextval('{$db_prefix}log_errors_seq'),
  log_time int NOT NULL default '0',
  id_member int NOT NULL default '0',
  ip varchar(16) NOT NULL default '',
  url text NOT NULL,
  message text NOT NULL,
  session char(64) NOT NULL default '                                                                ',
  error_type varchar(15) NOT NULL default 'general',
  file varchar(255) NOT NULL,
  line int NOT NULL default '0',
  PRIMARY KEY (id_error)
);

#
# Indexes for table `log_errors`
#

CREATE INDEX {$db_prefix}log_errors_log_time ON {$db_prefix}log_errors (log_time);
CREATE INDEX {$db_prefix}log_errors_id_member ON {$db_prefix}log_errors (id_member);
CREATE INDEX {$db_prefix}log_errors_ip ON {$db_prefix}log_errors (ip);

#
# Table structure for table `log_floodcontrol`
#

CREATE TABLE {$db_prefix}log_floodcontrol (
  ip char(16) NOT NULL default '                ',
  log_time int NOT NULL default '0',
  log_type varchar(10) NOT NULL default 'post',
  PRIMARY KEY (ip, log_type)
);

#
# Sequence for table `log_group_requests`
#

CREATE SEQUENCE {$db_prefix}log_group_requests_seq;

#
# Table structure for table `log_group_requests`
#

CREATE TABLE {$db_prefix}log_group_requests (
  id_request int default nextval('{$db_prefix}log_group_requests_seq'),
  id_member int NOT NULL default '0',
  id_group smallint NOT NULL default '0',
  time_applied int NOT NULL default '0',
  reason text NOT NULL,
  PRIMARY KEY (id_request)
);

#
# Indexes for table `log_group_requests`
#

CREATE UNIQUE INDEX {$db_prefix}log_group_requests_id_member ON {$db_prefix}log_group_requests (id_member, id_group);

#
# Table structure for table `log_karma`
#

CREATE TABLE {$db_prefix}log_karma (
  id_target int NOT NULL default '0',
  id_executor int NOT NULL default '0',
  log_time int NOT NULL default '0',
  action smallint NOT NULL default '0',
  PRIMARY KEY (id_target, id_executor)
);

#
# Indexes for table `log_karma`
#

CREATE INDEX {$db_prefix}log_karma_log_time ON {$db_prefix}log_karma (log_time);

#
# Table structure for table `log_likes`
#

CREATE TABLE {$db_prefix}log_likes (
  action char(1) NOT NULL default '0',
  id_target int NOT NULL default '0',
  id_member int NOT NULL default '0',
  log_time int NOT NULL default '0',
  PRIMARY KEY (id_target, id_member)
);

#
# Indexes for table `log_likes`
#

CREATE INDEX {$db_prefix}log_likes_log_time ON {$db_prefix}log_likes (log_time);

#
# Table structure for table `log_mark_read`
#

CREATE TABLE {$db_prefix}log_mark_read (
  id_member int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  id_msg int NOT NULL default '0',
  PRIMARY KEY (id_member, id_board)
);

#
# Sequence for table `log_member_notices`
#

CREATE SEQUENCE {$db_prefix}log_member_notices_seq;

#
# Table structure for table `log_member_notices`
#

CREATE TABLE {$db_prefix}log_member_notices (
  id_notice int default nextval('{$db_prefix}log_member_notices_seq'),
  subject varchar(255) NOT NULL,
  body text NOT NULL,
  PRIMARY KEY (id_notice)
);

#
# Sequence for table `log_mentions`
#

CREATE SEQUENCE {$db_prefix}log_mentions_id_mention_seq;

#
# Table structure for table `log_mentions`
#

CREATE TABLE IF NOT EXISTS {$db_prefix}log_mentions (
  id_mention int default nextval('{$db_prefix}log_mentions_id_mention_seq'),
  id_member int NOT NULL DEFAULT '0',
  id_msg int NOT NULL DEFAULT '0',
  status int NOT NULL DEFAULT '0',
  id_member_from int NOT NULL DEFAULT '0',
  log_time int NOT NULL DEFAULT '0',
  mention_type varchar(5) NOT NULL DEFAULT '',
  PRIMARY KEY (id_mention)
);

#
# Indexes for table `log_mentions`
#

CREATE INDEX {$db_prefix}log_mentions_id_member ON {$db_prefix}log_mentions (id_member, status);

#
# Table structure for table `log_notify`
#

CREATE TABLE {$db_prefix}log_notify (
  id_member int NOT NULL default '0',
  id_topic int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  sent smallint NOT NULL default '0',
  PRIMARY KEY (id_member, id_topic, id_board)
);

#
# Indexes for table `log_notify`
#

CREATE INDEX {$db_prefix}log_notify_id_topic ON {$db_prefix}log_notify (id_topic, id_member);

#
# Table structure for table `log_online`
#

CREATE TABLE {$db_prefix}log_online (
  session varchar(64) NOT NULL default '',
  log_time int NOT NULL default '0',
  id_member int NOT NULL default '0',
  id_spider smallint NOT NULL default '0',
  ip bigint NOT NULL default '0',
  url text NOT NULL,
  PRIMARY KEY (session)
);

#
# Indexes for table `log_online`
#

CREATE INDEX {$db_prefix}log_online_log_time ON {$db_prefix}log_online (log_time);
CREATE INDEX {$db_prefix}log_online_id_member ON {$db_prefix}log_online (id_member);

#
# Sequence for table `log_packages`
#

CREATE SEQUENCE {$db_prefix}log_packages_seq;

#
# Table structure for table `log_packages`
#

CREATE TABLE {$db_prefix}log_packages (
  id_install int default nextval('{$db_prefix}log_packages_seq'),
  filename varchar(255) NOT NULL,
  package_id varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  version varchar(255) NOT NULL,
  id_member_installed int NOT NULL default '0',
  member_installed varchar(255) NOT NULL,
  time_installed int NOT NULL default '0',
  id_member_removed int NOT NULL default '0',
  member_removed varchar(255) NOT NULL,
  time_removed int NOT NULL default '0',
  install_state smallint NOT NULL default '1',
  failed_steps text NOT NULL,
  themes_installed varchar(255) NOT NULL,
  db_changes text NOT NULL,
  credits varchar(255) NOT NULL,
  PRIMARY KEY (id_install)
);

#
# Indexes for table `log_packages`
#

CREATE INDEX {$db_prefix}log_packages_filename ON {$db_prefix}log_packages (filename);

#
# Table structure for table `log_polls`
#

CREATE TABLE {$db_prefix}log_polls (
  id_poll int NOT NULL default '0',
  id_member int NOT NULL default '0',
  id_choice smallint NOT NULL default '0'
);

#
# Indexes for table `log_polls`
#

CREATE INDEX {$db_prefix}log_polls_id_poll ON {$db_prefix}log_polls (id_poll, id_member, id_choice);

#
# Sequence for table `log_reported`
#

CREATE SEQUENCE {$db_prefix}log_reported_seq;

#
# Table structure for table `log_reported`
#

CREATE TABLE {$db_prefix}log_reported (
  id_report int default nextval('{$db_prefix}log_reported_seq'),
  id_msg int NOT NULL default '0',
  id_topic int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  id_member int NOT NULL default '0',
  membername varchar(255) NOT NULL,
  subject varchar(255) NOT NULL,
  body text NOT NULL,
  time_started int NOT NULL default '0',
  time_updated int NOT NULL default '0',
  num_reports int NOT NULL default '0',
  closed smallint NOT NULL default '0',
  ignore_all smallint NOT NULL default '0',
  PRIMARY KEY (id_report)
);

#
# Indexes for table `log_reported`
#

CREATE INDEX {$db_prefix}log_reported_id_member ON {$db_prefix}log_reported (id_member);
CREATE INDEX {$db_prefix}log_reported_id_topic ON {$db_prefix}log_reported (id_topic);
CREATE INDEX {$db_prefix}log_reported_closed ON {$db_prefix}log_reported (closed);
CREATE INDEX {$db_prefix}log_reported_time_started ON {$db_prefix}log_reported (time_started);
CREATE INDEX {$db_prefix}log_reported_id_msg ON {$db_prefix}log_reported (id_msg);

#
# Sequence for table `log_reported_comments`
#

CREATE SEQUENCE {$db_prefix}log_reported_comments_seq;

#
# Table structure for table `log_reported_comments`
#

CREATE TABLE {$db_prefix}log_reported_comments (
  id_comment int default nextval('{$db_prefix}log_reported_comments_seq'),
  id_report int NOT NULL default '0',
  id_member int NOT NULL,
  membername varchar(255) NOT NULL,
  email_address varchar(255) NOT NULL,
  member_ip varchar(255) NOT NULL,
  comment varchar(255) NOT NULL,
  time_sent int NOT NULL,
  PRIMARY KEY (id_comment)
);

#
# Indexes for table `log_reported_comments`
#

CREATE INDEX {$db_prefix}log_reported_comments_id_report ON {$db_prefix}log_reported_comments (id_report);
CREATE INDEX {$db_prefix}log_reported_comments_id_member ON {$db_prefix}log_reported_comments (id_member);
CREATE INDEX {$db_prefix}log_reported_comments_time_sent ON {$db_prefix}log_reported_comments (time_sent);

#
# Sequence for table `log_scheduled_tasks`
#

CREATE SEQUENCE {$db_prefix}log_scheduled_tasks_seq;

#
# Table structure for table `log_scheduled_tasks`
#

CREATE TABLE {$db_prefix}log_scheduled_tasks (
  id_log int default nextval('{$db_prefix}log_scheduled_tasks_seq'),
  id_task smallint NOT NULL default '0',
  time_run int NOT NULL default '0',
  time_taken float NOT NULL default '0',
  PRIMARY KEY (id_log)
);

#
# Table structure for table `log_search_messages`
#

CREATE TABLE {$db_prefix}log_search_messages (
  id_search smallint NOT NULL default '0',
  id_msg int NOT NULL default '0',
  PRIMARY KEY (id_search, id_msg)
);

#
# Table structure for table `log_search_results`
#

CREATE TABLE {$db_prefix}log_search_results (
  id_search smallint NOT NULL default '0',
  id_topic int NOT NULL default '0',
  id_msg int NOT NULL default '0',
  relevance smallint NOT NULL default '0',
  num_matches smallint NOT NULL default '0',
  PRIMARY KEY (id_search, id_topic)
);

#
# Table structure for table `log_search_subjects`
#

CREATE TABLE {$db_prefix}log_search_subjects (
  word varchar(20) NOT NULL default '',
  id_topic int NOT NULL default '0',
  PRIMARY KEY (word, id_topic)
);

#
# Indexes for table `log_search_subjects`
#

CREATE INDEX {$db_prefix}log_search_subjects_id_topic ON {$db_prefix}log_search_subjects (id_topic);

#
# Table structure for table `log_search_topics`
#

CREATE TABLE {$db_prefix}log_search_topics (
  id_search smallint NOT NULL default '0',
  id_topic int NOT NULL default '0',
  PRIMARY KEY (id_search, id_topic)
);

#
# Sequence for table `log_spider_hits`
#

CREATE SEQUENCE {$db_prefix}log_spider_hits_seq;

#
# Table structure for table `log_spider_hits`
#

CREATE TABLE {$db_prefix}log_spider_hits (
  id_hit int default nextval('{$db_prefix}log_spider_hits_seq'),
  id_spider smallint NOT NULL default '0',
  log_time int NOT NULL default '0',
  url varchar(255) NOT NULL,
  processed smallint NOT NULL default '0',
  PRIMARY KEY (id_hit)
);

#
# Indexes for table `log_spider_hits`
#

CREATE INDEX {$db_prefix}log_spider_hits_id_spider ON {$db_prefix}log_spider_hits (id_spider);
CREATE INDEX {$db_prefix}log_spider_hits_log_time ON {$db_prefix}log_spider_hits (log_time);
CREATE INDEX {$db_prefix}log_spider_hits_processed ON {$db_prefix}log_spider_hits (processed);

#
# Table structure for table `log_spider_stats`
#

CREATE TABLE {$db_prefix}log_spider_stats (
  id_spider smallint NOT NULL default '0',
  page_hits smallint NOT NULL default '0',
  last_seen int NOT NULL default '0',
  stat_date date NOT NULL default '0001-01-01',
  PRIMARY KEY (stat_date, id_spider)
);

#
# Sequence for table `log_subscribed`
#

CREATE SEQUENCE {$db_prefix}log_subscribed_seq;

#
# Table structure for table `log_subscribed`
#

CREATE TABLE {$db_prefix}log_subscribed (
  id_sublog int default nextval('{$db_prefix}log_subscribed_seq'),
  id_subscribe smallint NOT NULL default '0',
  id_member int NOT NULL default '0',
  old_id_group int NOT NULL default '0',
  start_time int NOT NULL default '0',
  end_time int NOT NULL default '0',
  status smallint NOT NULL default '0',
  payments_pending smallint NOT NULL default '0',
  pending_details text NOT NULL,
  reminder_sent smallint NOT NULL default '0',
  vendor_ref varchar(255) NOT NULL default '',
  PRIMARY KEY (id_sublog)
);

#
# Indexes for table `log_subscribed`
#

CREATE INDEX {$db_prefix}log_subscribed_id_subscribe ON {$db_prefix}log_subscribed (id_subscribe, id_member);
CREATE INDEX {$db_prefix}log_subscribed_end_time ON {$db_prefix}log_subscribed (end_time);
CREATE INDEX {$db_prefix}log_subscribed_reminder_sent ON {$db_prefix}log_subscribed (reminder_sent);
CREATE INDEX {$db_prefix}log_subscribed_payments_pending ON {$db_prefix}log_subscribed (payments_pending);
CREATE INDEX {$db_prefix}log_subscribed_status ON {$db_prefix}log_subscribed (status);
CREATE INDEX {$db_prefix}log_subscribed_id_member ON {$db_prefix}log_subscribed (id_member);

#
# Table structure for table `log_topics`
#

CREATE TABLE {$db_prefix}log_topics (
  id_member int NOT NULL default '0',
  id_topic int NOT NULL default '0',
  id_msg int NOT NULL default '0',
  unwatched int NOT NULL default '0',
  PRIMARY KEY (id_member, id_topic)
);

#
# Indexes for table `log_topics`
#

CREATE INDEX {$db_prefix}log_topics_id_topic ON {$db_prefix}log_topics (id_topic);

#
# Sequence for table `mail_queue`
#

CREATE SEQUENCE {$db_prefix}mail_queue_seq;

#
# Table structure for table `mail_queue`
#

CREATE TABLE {$db_prefix}mail_queue (
  id_mail int default nextval('{$db_prefix}mail_queue_seq'),
  time_sent int NOT NULL default '0',
  recipient varchar(255) NOT NULL,
  body text NOT NULL,
  subject varchar(255) NOT NULL,
  headers text NOT NULL,
  send_html smallint NOT NULL default '0',
  priority smallint NOT NULL default '1',
  private smallint NOT NULL default '0',
  message_id varchar(12) NOT NULL default '',
  PRIMARY KEY (id_mail)
);

#
# Indexes for table `mail_queue`
#

CREATE INDEX {$db_prefix}mail_queue_time_sent ON {$db_prefix}mail_queue (time_sent);
CREATE INDEX {$db_prefix}mail_queue_mail_priority ON {$db_prefix}mail_queue (priority, id_mail);

#
# Sequence for table `membergroups`
#

CREATE SEQUENCE {$db_prefix}membergroups_seq START WITH 9;

#
# Table structure for table `membergroups`
#

CREATE TABLE {$db_prefix}membergroups (
  id_group smallint default nextval('{$db_prefix}membergroups_seq'),
  group_name varchar(80) NOT NULL default '',
  description text NOT NULL,
  online_color varchar(20) NOT NULL default '',
  min_posts int NOT NULL default '-1',
  max_messages smallint NOT NULL default '0',
  icons varchar(255) NOT NULL,
  group_type smallint NOT NULL default '0',
  hidden smallint NOT NULL default '0',
  id_parent smallint NOT NULL default '-2',
  PRIMARY KEY (id_group)
);

#
# Indexes for table `membergroups`
#

CREATE INDEX {$db_prefix}membergroups_min_posts ON {$db_prefix}membergroups (min_posts);

#
# Dumping data for table `membergroups`
#

INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons, group_type) VALUES (1, '{$default_administrator_group}', '', '#CD0000', -1, '5#iconadmin.png', 1);
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (2, '{$default_global_moderator_group}', '', '#0066FF', -1, '5#icongmod.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (3, '{$default_moderator_group}', '', '', -1, '5#iconmod.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (4, '{$default_newbie_group}', '', '', 0, '1#icon.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (5, '{$default_junior_group}', '', '', 50, '2#icon.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (6, '{$default_full_group}', '', '', 100, '3#icon.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (7, '{$default_senior_group}', '', '', 250, '4#icon.png');
INSERT INTO {$db_prefix}membergroups (id_group, group_name, description, online_color, min_posts, icons) VALUES (8, '{$default_hero_group}', '', '', 500, '5#icon.png');
# --------------------------------------------------------

#
# Sequence for table `members`
#

CREATE SEQUENCE {$db_prefix}members_seq;

#
# Table structure for table `members`
#

CREATE TABLE {$db_prefix}members (
  id_member int default nextval('{$db_prefix}members_seq'),
  member_name varchar(80) NOT NULL default '',
  date_registered int NOT NULL default '0',
  posts int NOT NULL default '0',
  id_group smallint NOT NULL default '0',
  lngfile varchar(255) NOT NULL,
  last_login int NOT NULL default '0',
  real_name varchar(255) NOT NULL,
  personal_messages smallint NOT NULL default '0',
  mentions smallint NOT NULL default '0',
  unread_messages smallint NOT NULL default '0',
  new_pm smallint NOT NULL default '0',
  buddy_list text NOT NULL,
  pm_ignore_list varchar(255) NOT NULL,
  pm_prefs int NOT NULL default '2',
  mod_prefs varchar(20) NOT NULL default '',
  message_labels text NOT NULL,
  passwd varchar(64) NOT NULL default '',
  openid_uri text NOT NULL,
  email_address varchar(255) NOT NULL,
  personal_text varchar(255) NOT NULL,
  gender smallint NOT NULL default '0',
  birthdate date NOT NULL default '0001-01-01',
  website_title varchar(255) NOT NULL,
  website_url varchar(255) NOT NULL,
  location varchar(255) NOT NULL,
  hide_email smallint NOT NULL default '0',
  show_online smallint NOT NULL default '1',
  time_format varchar(80) NOT NULL default '',
  signature text NOT NULL,
  time_offset float NOT NULL default '0',
  avatar varchar(255) NOT NULL,
  pm_email_notify smallint NOT NULL default '0',
  karma_bad smallint NOT NULL default '0',
  karma_good smallint NOT NULL default '0',
  likes_given int NOT NULL default '0',
  likes_received int NOT NULL default '0',
  usertitle varchar(255) NOT NULL,
  notify_announcements smallint NOT NULL default '1',
  notify_regularity smallint NOT NULL default '1',
  notify_send_body smallint NOT NULL default '0',
  notify_types smallint NOT NULL default '2',
  member_ip varchar(255) NOT NULL,
  member_ip2 varchar(255) NOT NULL,
  secret_question varchar(255) NOT NULL,
  secret_answer varchar(64) NOT NULL default '',
  id_theme smallint NOT NULL default '0',
  is_activated smallint NOT NULL default '1',
  validation_code varchar(10) NOT NULL default '',
  id_msg_last_visit int NOT NULL default '0',
  additional_groups varchar(255) NOT NULL,
  smiley_set varchar(48) NOT NULL default '',
  id_post_group smallint NOT NULL default '0',
  total_time_logged_in int NOT NULL default '0',
  password_salt varchar(255) NOT NULL default '',
  ignore_boards text NOT NULL,
  warning smallint NOT NULL default '0',
  passwd_flood varchar(12) NOT NULL default '',
  receive_from smallint NOT NULL default '1',
  PRIMARY KEY (id_member)
);

#
# Indexes for table `members`
#

CREATE INDEX {$db_prefix}members_member_name ON {$db_prefix}members (member_name);
CREATE INDEX {$db_prefix}members_real_name ON {$db_prefix}members (real_name);
CREATE INDEX {$db_prefix}members_date_registered ON {$db_prefix}members (date_registered);
CREATE INDEX {$db_prefix}members_id_group ON {$db_prefix}members (id_group);
CREATE INDEX {$db_prefix}members_birthdate ON {$db_prefix}members (birthdate);
CREATE INDEX {$db_prefix}members_posts ON {$db_prefix}members (posts);
CREATE INDEX {$db_prefix}members_last_login ON {$db_prefix}members (last_login);
CREATE INDEX {$db_prefix}members_lngfile ON {$db_prefix}members (lngfile);
CREATE INDEX {$db_prefix}members_id_post_group ON {$db_prefix}members (id_post_group);
CREATE INDEX {$db_prefix}members_warning ON {$db_prefix}members (warning);
CREATE INDEX {$db_prefix}members_total_time_logged_in ON {$db_prefix}members (total_time_logged_in);
CREATE INDEX {$db_prefix}members_id_theme ON {$db_prefix}members (id_theme);


#
# Sequence for table `member_logins`
#

CREATE SEQUENCE {$db_prefix}member_logins_seq;

#
# Table structure for table `member_logins`
#

CREATE TABLE {$db_prefix}member_logins (
  id_login int default nextval('{$db_prefix}member_logins_seq'),
  id_member int NOT NULL default '0',
  time int NOT NULL default '0',
  ip varchar(255) NOT NULL default '0',
  ip2 varchar(255) NOT NULL default '0',
  PRIMARY KEY (id_login)
);

#
# Indexes for table `member_logins`
#
CREATE INDEX {$db_prefix}member_logins_id_member ON {$db_prefix}member_logins (id_member);
CREATE INDEX {$db_prefix}member_logins_time ON {$db_prefix}member_logins (time);


#
# Sequence for table `message_icons`
#

CREATE SEQUENCE {$db_prefix}message_icons_seq;

#
# Table structure for table `message_icons`
#

CREATE TABLE {$db_prefix}message_icons (
  id_icon smallint default nextval('{$db_prefix}message_icons_seq'),
  title varchar(80) NOT NULL default '',
  filename varchar(80) NOT NULL default '',
  id_board smallint NOT NULL default '0',
  icon_order smallint NOT NULL default '0',
  PRIMARY KEY (id_icon)
);

#
# Indexes for table `message_icons`
#

CREATE INDEX {$db_prefix}message_icons_id_board ON {$db_prefix}message_icons (id_board);

#
# Dumping data for table `message_icons`
#

# // !!! i18n
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('xx', 'Standard', '0');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('thumbup', 'Thumb Up', '1');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('thumbdown', 'Thumb Down', '2');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('exclamation', 'Exclamation point', '3');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('question', 'Question mark', '4');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('lamp', 'Lamp', '5');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('smiley', 'Smiley', '6');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('angry', 'Angry', '7');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('cheesy', 'Cheesy', '8');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('grin', 'Grin', '9');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('sad', 'Sad', '10');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('wink', 'Wink', '11');
INSERT INTO {$db_prefix}message_icons (filename, title, icon_order) VALUES ('poll', 'Poll', '12');
# --------------------------------------------------------

#
# Table structure for table `message_likes`
#

CREATE TABLE {$db_prefix}message_likes (
	id_member int NOT NULL default '0',
	id_msg int NOT NULL default '0',
	id_poster int NOT NULL default '0',
	PRIMARY KEY (id_msg, id_member)
);

#
# Indexes for table `message_likes`
#

CREATE INDEX {$db_prefix}message_likes_id_member ON {$db_prefix}message_likes (id_member);
CREATE INDEX {$db_prefix}message_likes_id_poster ON {$db_prefix}message_likes (id_poster);

#
# Sequence for table `messages`
#

CREATE SEQUENCE {$db_prefix}messages_seq START WITH 2;

#
# Table structure for table `messages`
#

CREATE TABLE {$db_prefix}messages (
  id_msg int default nextval('{$db_prefix}messages_seq'),
  id_topic int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  poster_time int NOT NULL default '0',
  id_member int NOT NULL default '0',
  id_msg_modified int NOT NULL default '0',
  subject varchar(255) NOT NULL,
  poster_name varchar(255) NOT NULL,
  poster_email varchar(255) NOT NULL,
  poster_ip varchar(255) NOT NULL,
  smileys_enabled smallint NOT NULL default '1',
  modified_time int NOT NULL default '0',
  modified_name varchar(255) NOT NULL,
  body text NOT NULL,
  icon varchar(16) NOT NULL default 'xx',
  approved smallint NOT NULL default '1',
  PRIMARY KEY (id_msg)
);

#
# Indexes for table `messages`
#

CREATE UNIQUE INDEX {$db_prefix}messages_topic ON {$db_prefix}messages (id_topic, id_msg);
CREATE UNIQUE INDEX {$db_prefix}messages_id_board ON {$db_prefix}messages (id_board, id_msg);
CREATE UNIQUE INDEX {$db_prefix}messages_id_member ON {$db_prefix}messages (id_member, id_msg);
CREATE INDEX {$db_prefix}messages_approved ON {$db_prefix}messages (approved);
CREATE INDEX {$db_prefix}messages_ip_index ON {$db_prefix}messages (poster_ip, id_topic);
CREATE INDEX {$db_prefix}messages_participation ON {$db_prefix}messages (id_member, id_topic);
CREATE INDEX {$db_prefix}messages_show_posts ON {$db_prefix}messages (id_member, id_board);
CREATE INDEX {$db_prefix}messages_id_topic ON {$db_prefix}messages (id_topic);
CREATE INDEX {$db_prefix}messages_id_member_msg ON {$db_prefix}messages (id_member, approved, id_msg);
CREATE INDEX {$db_prefix}messages_current_topic ON {$db_prefix}messages (id_topic, id_msg, id_member, approved);
CREATE INDEX {$db_prefix}messages_related_ip ON {$db_prefix}messages (id_member, poster_ip, id_msg);

#
# Dumping data for table `messages`
#

INSERT INTO {$db_prefix}messages
	(id_msg, id_msg_modified, id_topic, id_board, poster_time, subject, poster_name, poster_email, poster_ip, modified_name, body, icon)
VALUES (1, 1, 1, 1, {$current_time}, '{$default_topic_subject}', 'Elkarte', 'info@elkarte.net', '127.0.0.1', '', '{$default_topic_message}', 'xx');
# --------------------------------------------------------

#
# Table structure for table `moderators`
#

CREATE TABLE {$db_prefix}moderators (
  id_board smallint NOT NULL default '0',
  id_member int NOT NULL default '0',
  PRIMARY KEY (id_board, id_member)
);

#
# Table structure for table `openid_assoc`
#

CREATE TABLE {$db_prefix}openid_assoc (
  server_url text NOT NULL,
  handle varchar(255) NOT NULL,
  secret text NOT NULL,
  issued int NOT NULL default '0',
  expires int NOT NULL default '0',
  assoc_type varchar(64) NOT NULL,
  PRIMARY KEY (server_url, handle)
);

#
# Indexes for table `openid_assoc`
#

CREATE INDEX {$db_prefix}openid_assoc_expires ON {$db_prefix}openid_assoc (expires);

#
# Sequence for table `package_servers`
#

CREATE SEQUENCE {$db_prefix}package_servers_seq;

#
# Table structure for table `package_servers`
#

CREATE TABLE {$db_prefix}package_servers (
  id_server smallint default nextval('{$db_prefix}package_servers_seq'),
  name varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  PRIMARY KEY (id_server)
);

#
# Dumping data for table `package_servers`
#

INSERT INTO {$db_prefix}package_servers
	(name, url)
VALUES ('ElkArte Third-party Add-ons Site', 'https://github.com/elkarte/addons/tree/master/packages');
# --------------------------------------------------------

#
# Sequence for table `permission_profiles`
#

CREATE SEQUENCE {$db_prefix}permission_profiles_seq START WITH 5;

#
# Table structure for table `permission_profiles`
#

CREATE TABLE {$db_prefix}permission_profiles (
  id_profile smallint default nextval('{$db_prefix}permission_profiles_seq'),
  profile_name varchar(255) NOT NULL,
  PRIMARY KEY (id_profile)
);

#
# Dumping data for table `permission_profiles`
#

INSERT INTO {$db_prefix}permission_profiles (id_profile, profile_name) VALUES (1, 'default');
INSERT INTO {$db_prefix}permission_profiles (id_profile, profile_name) VALUES (2, 'no_polls');
INSERT INTO {$db_prefix}permission_profiles (id_profile, profile_name) VALUES (3, 'reply_only');
INSERT INTO {$db_prefix}permission_profiles (id_profile, profile_name) VALUES (4, 'read_only');
# --------------------------------------------------------

#
# Table structure for table `permissions`
#

CREATE TABLE {$db_prefix}permissions (
  id_group smallint NOT NULL default '0',
  permission varchar(30) NOT NULL default '',
  add_deny smallint NOT NULL default '1',
  PRIMARY KEY (id_group, permission)
);

#
# Dumping data for table `permissions`
#

INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (-1, 'search_posts');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (-1, 'calendar_view');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (-1, 'view_stats');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (-1, 'profile_view_any');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'view_mlist');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'search_posts');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_view_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_view_any');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'pm_read');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'pm_send');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'calendar_view');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'view_stats');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'who_view');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_identity_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_extra_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_remove_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_server_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_upload_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_remote_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'profile_gravatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'send_email_to_members');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (0, 'karma_edit');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'view_mlist');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'search_posts');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_view_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_view_any');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'pm_read');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'pm_send');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'pm_draft');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'pm_autosave_draft');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'calendar_view');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'view_stats');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'who_view');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_identity_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_extra_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_remove_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_server_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_upload_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_remote_avatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_gravatar');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'send_email_to_members');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'profile_title_own');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'calendar_post');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'calendar_edit_any');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'karma_edit');
INSERT INTO {$db_prefix}permissions (id_group, permission) VALUES (2, 'access_mod_center');
# --------------------------------------------------------

#
# Sequence for table `personal_messages`
#

CREATE SEQUENCE {$db_prefix}personal_messages_seq;

#
# Table structure for table `personal_messages`
#

CREATE TABLE {$db_prefix}personal_messages (
  id_pm int default nextval('{$db_prefix}personal_messages_seq'),
  id_pm_head int NOT NULL default '0',
  id_member_from int NOT NULL default '0',
  deleted_by_sender smallint NOT NULL default '0',
  from_name varchar(255) NOT NULL,
  msgtime int NOT NULL default '0',
  subject varchar(255) NOT NULL,
  body text NOT NULL,
  PRIMARY KEY (id_pm)
);

#
# Indexes for table `personal_messages`
#

CREATE INDEX {$db_prefix}personal_messages_id_member ON {$db_prefix}personal_messages (id_member_from, deleted_by_sender);
CREATE INDEX {$db_prefix}personal_messages_msgtime ON {$db_prefix}personal_messages (msgtime);
CREATE INDEX {$db_prefix}personal_messages_id_pm_head ON {$db_prefix}personal_messages (id_pm_head);

#
# Table structure for table `pm_recipients`
#

CREATE TABLE {$db_prefix}pm_recipients (
  id_pm int NOT NULL default '0',
  id_member int NOT NULL default '0',
  labels varchar(60) NOT NULL default '-1',
  bcc smallint NOT NULL default '0',
  is_read smallint NOT NULL default '0',
  is_new smallint NOT NULL default '0',
  deleted smallint NOT NULL default '0',
  PRIMARY KEY (id_pm, id_member)
);

#
# Indexes for table `pm_recipients`
#

CREATE UNIQUE INDEX {$db_prefix}pm_recipients_id_member ON {$db_prefix}pm_recipients (id_member, deleted, id_pm);

#
# Sequence for table `pm_rules`
#

CREATE SEQUENCE {$db_prefix}pm_rules_seq;

#
# Table structure for table `pm_rules`
#

CREATE TABLE {$db_prefix}pm_rules (
  id_rule int default nextval('{$db_prefix}pm_rules_seq'),
  id_member int NOT NULL default '0',
  rule_name varchar(60) NOT NULL,
  criteria text NOT NULL,
  actions text NOT NULL,
  delete_pm smallint NOT NULL default '0',
  is_or smallint NOT NULL default '0',
  PRIMARY KEY (id_rule)
);

#
# Indexes for table `pm_rules`
#

CREATE INDEX {$db_prefix}pm_rules_id_member ON {$db_prefix}pm_rules (id_member);
CREATE INDEX {$db_prefix}pm_rules_delete_pm ON {$db_prefix}pm_rules (delete_pm);

#
# Sequence for table `polls`
#

CREATE SEQUENCE {$db_prefix}polls_seq;

#
# Table structure for table `polls`
#

CREATE TABLE {$db_prefix}polls (
  id_poll int default nextval('{$db_prefix}polls_seq'),
  question varchar(255) NOT NULL,
  voting_locked smallint NOT NULL default '0',
  max_votes smallint NOT NULL default '1',
  expire_time int NOT NULL default '0',
  hide_results smallint NOT NULL default '0',
  change_vote smallint NOT NULL default '0',
  guest_vote smallint NOT NULL default '0',
  num_guest_voters int NOT NULL default '0',
  reset_poll int NOT NULL default '0',
  id_member int NOT NULL default '0',
  poster_name varchar(255) NOT NULL,
  PRIMARY KEY (id_poll)
);

#
# Table structure for table `poll_choices`
#

CREATE TABLE {$db_prefix}poll_choices (
  id_poll int NOT NULL default '0',
  id_choice smallint NOT NULL default '0',
  label varchar(255) NOT NULL,
  votes smallint NOT NULL default '0',
  PRIMARY KEY (id_poll, id_choice)
);

#
# Table structure for table `postby_emails`
#

CREATE TABLE {$db_prefix}postby_emails (
  id_email varchar(50)  NOT NULL default '',
  time_sent int NOT NULL default '0',
  email_to varchar(50) NOT NULL default '',
  PRIMARY KEY (id_email)
);

#
# Sequence for table `postby_emails_error`
#

CREATE SEQUENCE {$db_prefix}postby_emails_error_seq;

#
# Table structure for table `postby_emails_error`
#

CREATE TABLE {$db_prefix}postby_emails_error (
  id_email int default nextval('{$db_prefix}postby_emails_error_seq'),
  error varchar(255) NOT NULL default '',
  data_id varchar(255) NOT NULL default '0',
  subject varchar(255) NOT NULL default '',
  id_message int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  email_from varchar(50) NOT NULL default '',
  message_type char(10) NOT NULL default '',
  message text NOT NULL,
  PRIMARY KEY (id_email)
);

#
# Sequence for table `postby_emails_filters`
#

CREATE SEQUENCE {$db_prefix}postby_emails_filters_seq;

#
# Table structure for table `postby_emails_filters`
#

CREATE TABLE {$db_prefix}postby_emails_filters (
  id_filter int default nextval('{$db_prefix}postby_emails_filters_seq'),
  filter_style char(5) NOT NULL default '',
  filter_type varchar(255) NOT NULL default '',
  filter_to varchar(255) NOT NULL default '',
  filter_from varchar(255) NOT NULL default '',
  filter_name varchar(255) NOT NULL default '',
  filter_order int NOT NULL default '0',
  PRIMARY KEY (id_filter)
);

#
# Sequence for table `scheduled_tasks`
#

CREATE SEQUENCE {$db_prefix}scheduled_tasks_seq START WITH 16;

#
# Table structure for table `scheduled_tasks`
#

CREATE TABLE {$db_prefix}scheduled_tasks (
  id_task smallint default nextval('{$db_prefix}scheduled_tasks_seq'),
  next_time int NOT NULL default '0',
  time_offset int NOT NULL default '0',
  time_regularity smallint NOT NULL default '0',
  time_unit varchar(1) NOT NULL default 'h',
  disabled smallint NOT NULL default '0',
  task varchar(24) NOT NULL default '',
  PRIMARY KEY (id_task)
);

#
# Indexes for table `scheduled_tasks`
#

CREATE INDEX {$db_prefix}scheduled_tasks_next_time ON {$db_prefix}scheduled_tasks (next_time);
CREATE INDEX {$db_prefix}scheduled_tasks_disabled ON {$db_prefix}scheduled_tasks (disabled);
CREATE UNIQUE INDEX {$db_prefix}scheduled_tasks_task ON {$db_prefix}scheduled_tasks (task);

#
# Dumping data for table `scheduled_tasks`
#

INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (1, 0, 0, 2, 'h', 0, 'approval_notification');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (2, 0, 0, 7, 'd', 0, 'auto_optimize');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (3, 0, 60, 1, 'd', 0, 'daily_maintenance');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (5, 0, 0, 1, 'd', 0, 'daily_digest');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (6, 0, 0, 1, 'w', 0, 'weekly_digest');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (7, 0, 0, 1, 'd', 1, 'birthdayemails');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (8, 0, 0, 1, 'w', 0, 'weekly_maintenance');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (9, 0, 120, 1, 'd', 1, 'paid_subscriptions');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (10, 0, 120, 1, 'd', 0, 'remove_temp_attachments');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (11, 0, 180, 1, 'd', 0, 'remove_topic_redirect');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (12, 0, 240, 1, 'd', 0, 'remove_old_drafts');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (13, 0, 0, 6, 'h', 0, 'remove_old_followups');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (14, 0, 360, 10, 'm', 1, 'maillist_fetch_IMAP');
INSERT INTO {$db_prefix}scheduled_tasks	(id_task, next_time, time_offset, time_regularity, time_unit, disabled, task) VALUES (15, 0, 30, 1, 'h', 0, 'user_access_mentions');
# --------------------------------------------------------

#
# Table structure for table `settings`
#

CREATE TABLE {$db_prefix}settings (
  variable varchar(255) NOT NULL,
  value text NOT NULL,
  PRIMARY KEY (variable)
);

#
# Dumping data for table `settings`
#

INSERT INTO {$db_prefix}settings (variable, value) VALUES ('elkVersion', '{$current_version}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('news', '{$default_news}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('detailed-version.js', 'https://elkarte.github.io/Elkarte/site/detailed-version.js');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('compactTopicPagesContiguous', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('compactTopicPagesEnable', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableStickyTopics', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('todayMod', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('likes_enabled', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('likeDisplayLimit', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('likeMinPosts', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaMode', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaTimeRestrictAdmins', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enablePreviousNext', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('pollMode', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableVBStyleLogin', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableCompressedOutput', '{$enableCompressedOutput}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaWaitTime', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaMinPosts', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaLabel', '{$default_karmaLabel}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaSmiteLabel', '{$default_karmaSmiteLabel}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('karmaApplaudLabel', '{$default_karmaApplaudLabel}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentSizeLimit', '128');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentPostLimit', '192');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentNumPerPostLimit', '4');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentDirSizeLimit', '10240');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentDirFileLimit', '1000');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentUploadDir', '{BOARDDIR}/attachments');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentExtensions', 'doc,gif,jpg,mpg,pdf,png,txt,zip');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentCheckExtensions', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentShowImages', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentEnable', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentEncryptFilenames', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentThumbnails', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentThumbWidth', '150');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachmentThumbHeight', '150');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('use_subdirectories_for_attachments', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('censorIgnoreCase', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mostOnline', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mostOnlineToday', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mostDate', {$current_time});
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('allow_disableAnnounce', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('trackStats', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('userLanguage', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('titlesEnable', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('topicSummaryPosts', '15');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableErrorLogging', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('max_image_width', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('max_image_height', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('onlineEnable', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_enabled', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_maxyear', '2020');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_minyear', '2008');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_daysaslink', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_defaultboard', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_showholidays', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_showbdays', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_showevents', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_showweeknum', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_maxspan', '7');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smtp_host', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smtp_port', '25');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smtp_username', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smtp_password', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mail_type', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('timeLoadPageEnable', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('totalMembers', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('totalTopics', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('totalMessages', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('censor_vulgar', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('censor_proper', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enablePostHTML', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('theme_allow', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('theme_default', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('theme_guests', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('xmlnews_enable', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('xmlnews_limit', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('xmlnews_maxlen', '255');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('hotTopicPosts', '15');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('hotTopicVeryPosts', '25');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('registration_method', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('send_validation_onChange', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('send_welcomeEmail', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('allow_editDisplayName', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('admin_session_lifetime', '10');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('allow_hideOnline', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('spamWaitTime', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('pm_spam_settings', '10,5,20');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reserveWord', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reserveCase', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reserveUser', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reserveName', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reserveNames', '{$default_reserved_names}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('autoLinkUrls', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('banLastUpdated', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smileys_dir', '{BOARDDIR}/smileys');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smileys_url', '{$boardurl}/smileys');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_default', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_directory', '{BOARDDIR}/avatars');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_url', '{$boardurl}/avatars');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_max_height_external', '65');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_max_width_external', '65');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_action_too_large', 'option_html_resize');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_max_height_upload', '65');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_max_width_upload', '65');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_resize_upload', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_download_png', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('gravatar_rating', 'g');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('failed_login_threshold', '3');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('oldTopicDays', '120');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('edit_wait_time', '90');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('edit_disable_time', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('autoFixDatabase', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('allow_guestAccess', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('time_format', '{$default_time_format}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('number_format', '1234.00');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableBBC', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('max_messageLength', '20000');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('signature_settings', '1,300,0,0,0,0,0,0:');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('autoOptMaxOnline', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('defaultMaxMessages', '15');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('defaultMaxTopics', '20');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('defaultMaxMembers', '30');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableParticipation', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableFollowup', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('recycle_enable', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('recycle_board', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('maxMsgID', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enableAllMessages', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('fixLongWords', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('knownThemes', '1,2,3');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('who_enabled', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('time_offset', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cookieTime', '60');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('jquery_source', 'local');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('lastActive', '15');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smiley_sets_known', 'default');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smiley_sets_names', '{$default_smileyset_name}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('smiley_sets_default', 'default');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cal_days_for_index', '7');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('requireAgreement', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('unapprovedMembers', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('default_personal_text', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('package_make_backups', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('databaseSession_enable', '{$databaseSession_enable}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('databaseSession_loose', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('databaseSession_lifetime', '2880');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_cache_size', '50');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_results_per_page', '30');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_weight_frequency', '30');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_weight_age', '25');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_weight_length', '20');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_weight_subject', '15');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_weight_first_message', '10');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_max_results', '1200');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('search_floodcontrol_time', '5');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('permission_enable_deny', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('permission_enable_postgroups', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mail_next_send', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mail_recent', '0000000000|0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('settings_updated', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('next_task_time', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('warning_settings', '1,20,0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('warning_watch', '10');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('warning_moderate', '35');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('warning_mute', '60');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('admin_features', '');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('last_mod_report_action', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('pruningOptions', '30,180,180,180,30,7,0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('cache_enable', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('reg_verification', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('visual_verification_type', '3');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('visual_verification_num_chars', '6');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enable_buddylist', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('birthday_email', 'happy_birthday');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('dont_repeat_theme_core', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('dont_repeat_smileys_20', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('dont_repeat_buddylists', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachment_image_reencode', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachment_image_paranoid', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('attachment_thumb_png', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_reencode', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('avatar_paranoid', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('enable_unwatch', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mentions_enabled', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mentions_buddy', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('mentions_dont_notify_rlike', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_enabled', '0');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_logging', '1');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_ip_wl', 'a:3:{i:2;s:10:"10.0.0.0/8";i:5;s:13:"172.16.0.0/12";i:6;s:14:"192.168.0.0/16";}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_ip_wl_desc', 'a:3:{i:2;s:18:"RFC 1918 addresses";i:5;s:18:"RFC 1918 addresses";i:6;s:18:"RFC 1918 addresses";}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_url_wl', 'a:1:{i:0;s:18:"/subscriptions.php";}');
INSERT INTO {$db_prefix}settings (variable, value) VALUES ('badbehavior_url_wl_desc', 'a:1:{i:0;s:15:"Payment Gateway";}');
# --------------------------------------------------------

#
# Table structure for table `sessions`
#

CREATE TABLE {$db_prefix}sessions (
  session_id char(64) NOT NULL,
  last_update int NOT NULL,
  data text NOT NULL,
  PRIMARY KEY (session_id)
);

#
# Sequence for table `smileys`
#

CREATE SEQUENCE {$db_prefix}smileys_seq;

#
# Table structure for table `smileys`
#

CREATE TABLE {$db_prefix}smileys (
  id_smiley smallint default nextval('{$db_prefix}smileys_seq'),
  code varchar(30) NOT NULL default '',
  filename varchar(48) NOT NULL default '',
  description varchar(80) NOT NULL default '',
  smiley_row smallint NOT NULL default '0',
  smiley_order smallint NOT NULL default '0',
  hidden smallint NOT NULL default '0',
  PRIMARY KEY (id_smiley)
);

#
# Dumping data for table `smileys`
#

INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':)', 'smiley.gif', '{$default_smiley_smiley}', 0, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (';)', 'wink.gif', '{$default_wink_smiley}', 1, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':D', 'cheesy.gif', '{$default_cheesy_smiley}', 2, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (';D', 'grin.gif', '{$default_grin_smiley}', 3, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('>:(', 'angry.gif', '{$default_angry_smiley}', 4, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':(', 'sad.gif', '{$default_sad_smiley}', 5, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':o', 'shocked.gif', '{$default_shocked_smiley}', 6, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('8)', 'cool.gif', '{$default_cool_smiley}', 7, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('???', 'huh.gif', '{$default_huh_smiley}', 8, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('::)', 'rolleyes.gif', '{$default_roll_eyes_smiley}', 9, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':P', 'tongue.gif', '{$default_tongue_smiley}', 10, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':-[', 'embarrassed.gif', '{$default_embarrassed_smiley}', 11, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':-X', 'lipsrsealed.gif', '{$default_lips_sealed_smiley}', 12, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':-\\', 'undecided.gif', '{$default_undecided_smiley}', 13, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':-*', 'kiss.gif', '{$default_kiss_smiley}', 14, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':''(', 'cry.gif', '{$default_cry_smiley}', 15, 0);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('>:D', 'evil.gif', '{$default_evil_smiley}', 16, 1);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('^-^', 'azn.gif', '{$default_azn_smiley}', 17, 1);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('O0', 'afro.gif', '{$default_afro_smiley}', 18, 1);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES (':))', 'laugh.gif', '{$default_laugh_smiley}', 19, 1);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('C:-)', 'police.gif', '{$default_police_smiley}', 20, 1);
INSERT INTO {$db_prefix}smileys	(code, filename, description, smiley_order, hidden) VALUES ('O:)', 'angel.gif', '{$default_angel_smiley}', 21, 1);
# --------------------------------------------------------

#
# Sequence for table `spiders`
#

CREATE SEQUENCE {$db_prefix}spiders_seq;

#
# Table structure for table `spiders`
#

CREATE TABLE {$db_prefix}spiders (
  id_spider smallint NOT NULL default nextval('{$db_prefix}spiders_seq'),
  spider_name varchar(255) NOT NULL,
  user_agent varchar(255) NOT NULL,
  ip_info varchar(255) NOT NULL,
  PRIMARY KEY (id_spider)
);

#
# Dumping data for table `spiders`
#

INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (1, 'Google', 'googlebot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (2, 'Yahoo!', 'Yahoo! Slurp', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (3, 'MSN', 'msnbot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (4, 'Bing', 'bingbot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (5, 'Google (Mobile)', 'Googlebot-Mobile', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (6, 'Google (Image)', 'Googlebot-Image', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (7, 'Google (AdSense)', 'Mediapartners-Google', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (8, 'Google (Adwords)', 'AdsBot-Google', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (9, 'Yahoo! (Mobile)', 'YahooSeeker/M1A1-R2D2', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (10, 'Yahoo! (Image)', 'Yahoo-MMCrawler', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (11, 'Yahoo! (Blogs)', 'Yahoo-Blogs', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (12, 'Yahoo! (Feeds)', 'YahooFeedSeeker', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (13, 'MSN (Mobile)', 'MSNBOT_Mobile', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (14, 'MSN (Media)', 'msnbot-media', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (15, 'Cuil', 'twiceler', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (16, 'Ask', 'Teoma', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (17, 'Baidu', 'Baiduspider', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (18, 'Gigablast', 'Gigabot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (19, 'InternetArchive', 'ia_archiver-web.archive.org', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (20, 'Alexa', 'ia_archiver', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (21, 'Omgili', 'omgilibot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (22, 'EntireWeb', 'Speedy Spider', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (23, 'Yandex', 'YandexBot', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (24, 'Yandex (Images)', 'YandexImages', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (25, 'Yandex (Video)', 'YandexVideo', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (26, 'Yandex (Blogs)', 'YandexBlogs', '');
INSERT INTO {$db_prefix}spiders (id_spider, spider_name, user_agent, ip_info) VALUES (27, 'Yandex (Media)', 'YandexMedia', '');
# --------------------------------------------------------

#
# Sequence for table `subscriptions`
#

CREATE SEQUENCE {$db_prefix}subscriptions_seq;

#
# Table structure for table `subscriptions`
#

CREATE TABLE {$db_prefix}subscriptions(
  id_subscribe smallint NOT NULL default nextval('{$db_prefix}subscriptions_seq'),
  name varchar(60) NOT NULL,
  description varchar(255) NOT NULL,
  cost text NOT NULL,
  length varchar(6) NOT NULL,
  id_group int NOT NULL default '0',
  add_groups varchar(40) NOT NULL,
  active smallint NOT NULL default '1',
  repeatable smallint NOT NULL default '0',
  allow_partial smallint NOT NULL default '0',
  reminder smallint NOT NULL default '0',
  email_complete text NOT NULL,
  PRIMARY KEY (id_subscribe)
);

#
# Indexes for table `subscriptions`
#

CREATE INDEX {$db_prefix}subscriptions_active ON {$db_prefix}subscriptions (active);

#
# Table structure for table `themes`
#

CREATE TABLE {$db_prefix}themes (
  id_member int NOT NULL default '0',
  id_theme smallint NOT NULL default '1',
  variable varchar(255) NOT NULL,
  value text NOT NULL,
  PRIMARY KEY (id_theme, id_member, variable)
);

#
# Indexes for table `themes`
#

CREATE INDEX {$db_prefix}themes_id_member ON {$db_prefix}themes (id_member);

#
# Dumping data for table `themes`
#

INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'name', '{$default_theme_name}');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'theme_url', '{$boardurl}/themes/default');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'images_url', '{$boardurl}/themes/default/images');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'theme_dir', '{BOARDDIR}/themes/default');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_bbc', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_latest_member', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_modify', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_user_images', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_blurb', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_gender', '0');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'number_recent_posts', '0');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_member_bar', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'linktree_link', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_profile_buttons', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_mark_read', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_stats_index', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'show_board_desc', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'newsfader_time', '5000');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'allow_no_censored', '0');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'additional_options_collapsable', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'use_image_buttons', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'enable_news', '1');
INSERT INTO {$db_prefix}themes (id_theme, variable, value) VALUES (1, 'forum_width', '90%');
INSERT INTO {$db_prefix}themes (id_member, id_theme, variable, value) VALUES (-1, 1, 'display_quick_reply', '2');
INSERT INTO {$db_prefix}themes (id_member, id_theme, variable, value) VALUES (-1, 1, 'posts_apply_ignore_list', '1');
INSERT INTO {$db_prefix}themes (id_member, id_theme, variable, value) VALUES (-1, 1, 'drafts_autosave_enabled', '1');
# --------------------------------------------------------

#
# Sequence for table `topics`
#

CREATE SEQUENCE {$db_prefix}topics_seq START WITH 2;

#
# Table structure for table `topics`
#

CREATE TABLE {$db_prefix}topics (
  id_topic int default nextval('{$db_prefix}topics_seq'),
  is_sticky smallint NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  id_first_msg int NOT NULL default '0',
  id_last_msg int NOT NULL default '0',
  id_member_started int NOT NULL default '0',
  id_member_updated int NOT NULL default '0',
  id_poll int NOT NULL default '0',
  id_previous_board smallint NOT NULL default '0',
  id_previous_topic int NOT NULL default '0',
  num_replies int NOT NULL default '0',
  num_views int NOT NULL default '0',
  num_likes int NOT NULL default '0',
  locked smallint NOT NULL default '0',
  redirect_expires int NOT NULL default '0',
  id_redirect_topic int NOT NULL default '0',
  unapproved_posts smallint NOT NULL default '0',
  approved smallint NOT NULL default '1',
  PRIMARY KEY (id_topic)
);

#
# Indexes for table `topics`
#

CREATE UNIQUE INDEX {$db_prefix}topics_last_message ON {$db_prefix}topics (id_last_msg, id_board);
CREATE UNIQUE INDEX {$db_prefix}topics_first_message ON {$db_prefix}topics (id_first_msg, id_board);
CREATE UNIQUE INDEX {$db_prefix}topics_poll ON {$db_prefix}topics (id_poll, id_topic);
CREATE INDEX {$db_prefix}topics_is_sticky ON {$db_prefix}topics (is_sticky);
CREATE INDEX {$db_prefix}topics_approved ON {$db_prefix}topics (approved);
CREATE INDEX {$db_prefix}topics_id_board ON {$db_prefix}topics (id_board);
CREATE INDEX {$db_prefix}topics_member_started ON {$db_prefix}topics (id_member_started, id_board);
CREATE INDEX {$db_prefix}topics_last_message_sticky ON {$db_prefix}topics (id_board, is_sticky, id_last_msg);
CREATE INDEX {$db_prefix}topics_board_news ON {$db_prefix}topics (id_board, id_first_msg);

#
# Dumping data for table `topics`
#

INSERT INTO {$db_prefix}topics
	(id_topic, id_board, id_first_msg, id_last_msg, id_member_started, id_member_updated)
VALUES (1, 1, 1, 1, 0, 0);
# --------------------------------------------------------


#
# Sequence for table `user_drafts`
#

CREATE SEQUENCE {$db_prefix}user_drafts_seq;

#
# Table structure for table `user_drafts`
#

CREATE TABLE {$db_prefix}user_drafts (
  id_draft int default nextval('{$db_prefix}user_drafts_seq'),
  id_topic int NOT NULL default '0',
  id_board smallint NOT NULL default '0',
  id_reply int NOT NULL default '0',
  type smallint NOT NULL default '0',
  poster_time int NOT NULL default '0',
  id_member int NOT NULL default '0',
  subject varchar(255) NOT NULL default '',
  smileys_enabled smallint NOT NULL default '1',
  body text NOT NULL,
  icon varchar(16) NOT NULL default 'xx',
  locked smallint NOT NULL default '0',
  is_sticky smallint NOT NULL default '0',
  to_list varchar(255) NOT NULL default '',
  PRIMARY KEY (id_draft)
);

#
# Indexes for table `user_drafts`
#

CREATE UNIQUE INDEX {$db_prefix}id_member ON {$db_prefix}user_drafts (id_member, id_draft, type);
