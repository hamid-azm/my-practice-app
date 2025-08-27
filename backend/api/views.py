from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
from django.db import connection
from .serializers import HelloWorldSerializer
from .models import HelloWorld


@api_view(['GET'])
def hello_world(request):
    return Response({
        'message': 'Hello from Django in Docker!',
        'status': 'success'
    })

@api_view(['GET'])
def health_check(request):
    """Health check endpoint for Docker containers and load balancers"""
    try:
        # Check database connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        
        return JsonResponse({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': '2025-08-27T00:00:00Z'
        })
    except Exception as e:
        return JsonResponse({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'timestamp': '2025-08-27T00:00:00Z'
        }, status=500)

@api_view(['GET','POST'])
def hello_world_list(request):
    if request.method == 'GET':
        hellos = HelloWorld.objects.all()
        serializer = HelloWorldSerializer(hellos, many=True)
        return Response(serializer.data)
    
    if request.method == 'POST':
        serializer = HelloWorldSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)