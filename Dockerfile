# Use the official vLLM image as base (it has python, torch, and vllm pre-installed)
FROM vllm/vllm-openai:latest

WORKDIR /app

# Install the RunPod SDK
RUN pip install runpod

# BAKE IN THE AWQ WEIGHTS (3.44GB)
RUN pip install huggingface_hub[cli] && \
    huggingface-cli download Qwen/Qwen3-4B-Thinking-2507-FP8 \
    --local-dir /app/model \
    --local-dir-use-symlinks False

# Copy your python script
COPY handler.py /app/handler.py

EXPOSE 8080

# ENVIRONMENT VARIABLES
ENV MODEL="/app/model"

# Run the handler (Not the web server!)
ENTRYPOINT []
CMD ["python3", "/app/handler.py"]
