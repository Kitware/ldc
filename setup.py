from setuptools import setup


if __name__ == '__main__':
    setup(
        name='ldc',
        version='0.0.1',
        author='Kitware',
        scripts=['ldc.sh'],

        entry_points={
            'console_scripts': [
                # TODO: this is a better way of invoking executables
                'ldc=ldc.__main__:main',
            ],
        },
        packages=['ldc'],
    )
