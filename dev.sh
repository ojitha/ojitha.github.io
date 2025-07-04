#!/bin/bash

# Jekyll Docker Development Helper Script

case "$1" in
    start)
        echo "🚀 Starting Jekyll development server with Docker..."
        docker-compose up --build
        ;;
    stop)
        echo "🛑 Stopping Jekyll development server..."
        docker-compose down
        ;;
    restart)
        echo "🔄 Restarting Jekyll development server..."
        docker-compose down
        docker-compose up --build
        ;;
    rebuild)
        echo "🔨 Rebuilding Docker image and starting server..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up
        ;;
    clean)
        echo "🧹 Clean rebuild - removing old images, volumes, and rebuilding..."
        docker-compose down
        docker rmi $(docker images | grep jekyll-site | awk '{print $3}') 2>/dev/null || true
        docker volume rm jekyll-site_bundle_cache 2>/dev/null || true
        docker system prune -f
        rm -f Gemfile.lock
        docker-compose build --no-cache
        docker-compose up
        ;;
    logs)
        echo "📋 Showing Jekyll logs..."
        docker-compose logs -f jekyll
        ;;
    shell)
        echo "🐚 Opening shell in Jekyll container..."
        docker-compose exec jekyll /bin/bash
        ;;
    debug)
        echo "🔍 Running diagnostics..."
        ./debug.sh
        ;;
    *)
        echo "🔧 Jekyll Docker Development Helper"
        echo ""
        echo "Usage: $0 {start|stop|restart|rebuild|clean|logs|shell|debug}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the Jekyll development server"
        echo "  stop    - Stop the Jekyll development server"
        echo "  restart - Restart the Jekyll development server"
        echo "  rebuild - Rebuild the Docker image and start server"
        echo "  clean   - Clean rebuild (removes old images, recommended for errors)"
        echo "  logs    - Show Jekyll server logs"
        echo "  shell   - Open a shell in the Jekyll container"
        echo "  debug   - Run diagnostic checks"
        echo ""
        echo "💡 If you're getting errors, try: $0 clean"
        exit 1
        ;;
esac
