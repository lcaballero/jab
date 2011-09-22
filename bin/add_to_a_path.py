'''Add a path to a list of paths, both of which come from command line

The list of paths is colon-separated, eg, $PATH or $PYTHONPATH
	Discard blanks and duplicates
'''

import os
import sys
import doctest

def add_path_to_paths(paths,path):
	'''Add a path to a list of paths

	Include no empties nor duplicates in the result

	>>> add_path_to_paths([0], 1)
	[1]

	>>> add_path_to_paths([1], 2)
	[1, 2]

	>>> add_path_to_paths([1, 2, 3], 1)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 3], 1)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 3], 2)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 3], 3)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 2, 3], 2)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 3, 2], 2)
	[1, 2, 3]

	>>> add_path_to_paths([1, 2, 3, 2], 0)
	[1, 2, 3]

	>>> add_path_to_paths([1, 0, 2, 3], 0)
	[1, 2, 3]

	>>> add_path_to_paths([0, 1, 2, 3, 2, 0], 0)
	[1, 2, 3]
	'''
	result = []
	for p in paths + [ path ]:
		if p and p not in result:
			result.append(p)
	return result

def add_path_to_path_string(path_string, path, separator=':'):
	'''Add the given path to a list of paths which are joined by the given separator
	
	>>> print add_path_to_path_string('/bin:/usr/bin','/usr/local/bin')
	/bin:/usr/bin:/usr/local/bin

	Ignore unreal directories
	>>> print add_path_to_path_string('/bin:/usr/bin', '/not/a/real/directory/at/all/AT/ALL')
	/bin:/usr/bin
	'''
	paths = []
	for p in path_string.split(separator):
		paths = add_path_to_paths(paths,p)
	if path and os.path.isdir(path):
		paths = add_path_to_paths(paths,os.path.realpath(path))
	return separator.join(paths)

def main(name_of_paths,new_path):
	path_string = os.environ.get(name_of_paths,'')
	print add_path_to_path_string(path_string,new_path)

if __name__ == '__main__':
	if sys.argv[1] == 'test':
		doctest.testmod()
	else:
		sys.exit(main(sys.argv[1],sys.argv[2]))
