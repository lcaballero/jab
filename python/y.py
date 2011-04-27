import os
import argv
import paths

argv.add_options([
	('delete', 'delete python compiled files as well', False),
	('wipe', 'remove known garbage',False),
	('stat', 'run svn stat', False),
	('ptags', 'do not refresh the tags file', True),
	('verbose', 'run ptags verbosely', False),
])

from ls import ly

def remove_globs(globs):
	for glob in globs:
		#print glob, [ f for f in argv.first_directory.files(glob) ]
		for p in argv.first_directory.listdir(glob):
			if p.islink():
				p.unlink()
			elif p.isfile():
				p.rm()
			elif p.isdir():
				p.rmdir()
			else:
				raise ValueError( 'Do not know how to remove %s' % p )

def wipe():
	remove_globs([ '*~', '.*~', '*.orig', 'fred*', 'mary', '*.tmp', '*.bak', 'one', 'two' ])
	[ f.rm() for f in argv.first_directory.files('*.fail') if not f.size ]

def delete():
	remove_globs([ '*.pyc', '*.pyo' ] )

def svn_stat():
	if paths.path('.svn').isdir():
		os.system('svn stat ')

def ptags():
	import ptags
	ptags.read_write_dir(argv.first_directory)

def main():
	#print 'cd', argv.first_directory
	argv.first_directory.cd()
	print argv.first_directory
	for method in argv.methods:
		method()
	ly.show()
	if argv.options.stat:
		svn_stat()

if __name__ == '__main__':
	argv.main(main)
