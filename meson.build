project('orafce', ['c'])

pg_config = find_program('pg_config')

bindir = run_command(pg_config, '--bindir', check: true).stdout().strip()
includedir_server = run_command(pg_config, '--includedir-server', check: true).stdout().strip()
pkglibdir = run_command(pg_config, '--pkglibdir', check: true).stdout().strip()
sharedir = run_command(pg_config, '--sharedir', check: true).stdout().strip()

orafce_sources = files(
  'aggregate.c',
  'alert.c',
  'assert.c',
  'convert.c',
  'datefce.c',
  'dbms_sql.c',
  'file.c',
  'charlen.c',
  'charpad.c',
  'magic.c',
  'math.c',
  'nvarchar2.c',
  'orafce.c',
  'others.c',
  'parse_keyword.c',
  'pipe.c',
  'plunit.c',
  'plvdate.c',
  'plvlex.c',
  'plvstr.c',
  'plvsubst.c',
  'putline.c',
  'random.c',
  'regexp.c',
  'replace_empty_string.c',
  'shmmc.c',
  'sqlparse.c',
  'utility.c',
  'varchar2.c',
)

shared_module(
  'orafce',
  orafce_sources,
  include_directories: [includedir_server],
  install: true,
  install_dir: pkglibdir,
  name_prefix: '',
)

install_data(
  'orafce.control',
  'orafce--3.2--3.3.sql',
  'orafce--3.3--3.4.sql',
  'orafce--3.4--3.5.sql',
  'orafce--3.5--3.6.sql',
  'orafce--3.6--3.7.sql',
  'orafce--3.7--3.8.sql',
  'orafce--3.8--3.9.sql',
  'orafce--3.9--3.10.sql',
  'orafce--3.10--3.11.sql',
  'orafce--3.11--3.12.sql',
  'orafce--3.12--3.13.sql',
  'orafce--3.13--3.14.sql',
  'orafce--3.14--3.15.sql',
  'orafce--3.15--3.16.sql',
  'orafce--3.16--3.17.sql',
  'orafce--3.17--3.18.sql',
  'orafce--3.18--3.19.sql',
  'orafce--3.19--3.20.sql',
  'orafce--3.20--3.21.sql',
  'orafce--3.21--3.22.sql',
  'orafce--3.22--3.23.sql',
  'orafce--3.23--3.24.sql',
  'orafce--3.24--3.25.sql',
  'orafce--3.25--4.0.sql',
  'orafce--4.0--4.1.sql',
  'orafce--4.1--4.2.sql',
  'orafce--4.2--4.3.sql',
  'orafce--4.3--4.4.sql',
  'orafce--4.4--4.5.sql',
  'orafce--4.5--4.6.sql',
  'orafce--4.6--4.7.sql',
  'orafce--4.7--4.8.sql',
  'orafce--4.8--4.9.sql',
  'orafce--4.9--4.10.sql',
  'orafce--4.10--4.11.sql',
  'orafce--4.11--4.12.sql',
  'orafce--4.12--4.13.sql',
  'orafce--4.13--4.14.sql',
  'orafce--4.14.sql',
  install_dir: sharedir / 'extension',
)

pg_regress = find_program(
  'pg_regress',
  dirs: [pkglibdir / 'pgxs/src/test/regress']
)

regress_tests = [
  'init',
  'orafce',
  'orafce2',
  'dbms_output',
  'dbms_utility',
  'files',
  'varchar2',
  'nvarchar2',
  'aggregates',
  'nlssort',
  'dbms_random',
  'regexp_func',
  'dbms_sql',
]

test('regress',
  pg_regress,
  args: ['--bindir', bindir,
         '--inputdir', meson.current_source_dir(),
         '--encoding', 'utf8',
         '--schedule', meson.current_source_dir() / 'parallel_schedule',
        ] + regress_tests,
)
