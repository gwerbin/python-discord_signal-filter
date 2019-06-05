import numpy
from setuptools import setup
from setuptools.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[
    Extension('_filter', ['speaker_filter/_filter.pyx'], include_dirs=[numpy.get_include()]),
]

setup(
  name = 'diy-speaker-filter',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  install_requires=['numpy', 'cython']
)