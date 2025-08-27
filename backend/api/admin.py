from django.contrib import admin
from .models import HelloWorld

@admin.register(HelloWorld)
class HelloWorldAdmin(admin.ModelAdmin):
    list_display = ['message', 'created_at']
    list_filter = ['created_at']
    search_fields = ['message']
    readonly_fields = ['created_at']
