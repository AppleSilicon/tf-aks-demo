# Use the official Python image from Docker Hub
FROM python:3.13-alpine

WORKDIR /app

COPY index.html .

# Expose port 80
EXPOSE 80

# Run the HTTP server on startup
CMD ["python3", "-m", "http.server", "80"]