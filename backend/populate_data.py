import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
django.setup()

from api.models import HelloWorld

def create_data():
    hello_list = [
        'Hello World 1',
        'Hello World 2',
        'Hello World 3',
        'Hello World 4',
    ]
    for hello in hello_list:
        obj, created = HelloWorld.objects.get_or_create(message=hello)
        if created:
            print(f'created: {obj.message}')
        else:
            print(f'found existing: {obj.message}')
if __name__ == '__main__':
    create_data()