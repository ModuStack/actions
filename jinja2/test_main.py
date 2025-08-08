import os
from main import main

def test_renders_simple_template():
    os.environ['VARS'] = '{"name": "World"}'
    os.environ['TEMPLATE'] = 'Hello, {{ name }}!'

    assert main() == 'Hello, World!'


def test_lists_are_handled_gracefully():
    os.environ['VARS'] = '["Alice", "Bob", "Charlie"]'
    os.environ['TEMPLATE'] = '{% for name in all %}{{ name }}!{% endfor %}'

    assert main() == 'Alice!Bob!Charlie!'

def test_works_with_yaml():
    os.environ['VARS'] = '''
    user:
        name: "World"
    '''
    os.environ['TEMPLATE'] = 'Hello, {{ user.name }}!'

    assert main() == 'Hello, World!'