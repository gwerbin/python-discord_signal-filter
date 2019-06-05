from setuptools import setup
from setuptools.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[
    Extension(_filter', ['filter/_filter.pyx']),
    ...
]

setup(
  name = 'diy-speaker-filter',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules
)