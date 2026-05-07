FROM python:3.11-slim

# Create non-root user
RUN groupadd -r flaskuser && useradd -r -g flaskuser flaskuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Change ownership to non-root user
RUN chown -R flaskuser:flaskuser /app

# Switch to non-root user
USER flaskuser

EXPOSE 5000

CMD ["python", "app.py"]