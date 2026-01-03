# 1. Base Image
FROM vllm/vllm-openai:latest

WORKDIR /app

# 2. Install RunPod SDK
RUN pip install runpod

# 3. Download Model (Baking it in)
RUN pip install huggingface_hub[cli] && \
    huggingface-cli download Qwen/Qwen3-4B-Thinking-2507 \
    --local-dir /app/model \
    --local-dir-use-symlinks False \
    --exclude "*.bin" "*.pth"

# 4. Copy your script
COPY handler.py /app/handler.py

# 5. Environment Variables
ENV MODEL="/app/model"

# 6. CRITICAL FIX: Reset the Entrypoint
# We must override the base image's entrypoint so it runs OUR command, not vLLM's server.
ENTRYPOINT []

# 7. Run your handler
CMD ["python3", "/app/handler.py"]
