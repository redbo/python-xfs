import os
from setuptools import setup, find_packages
from setuptools.extension import Extension

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

try:
    from Cython.Distutils import build_ext
    cmdclass = {'build_ext': build_ext}
    xfs_ext = Extension('xfs', ['xfs.pyx'], libraries=['handle'])
except ImportError:
    cmdclass = {}
    xfs_ext = Extension('xfs', ['xfs.c'], libraries=['handle'])

setup(
    name='xfs',
    version='0.2',
    description='XFS filesystem API',
    long_description=read('README.rst'),
    url='https://github.com/redbo/python-xfs',
    author='Michael Barton',
    author_email='mike@weirdlooking.com',
    packages=find_packages(exclude=[]),
    install_requires=[],
    cmdclass=cmdclass,
    ext_modules=[xfs_ext],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Intended Audience :: Information Technology',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Environment :: No Input/Output (Daemon)',
    ]
)

