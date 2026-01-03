# 1. Base Image: Use the official vLLM image
FROM vllm/vllm-openai:latest

# 2. Setup Work Directory
WORKDIR /app

# 3. Install dependencies for faster downloading
RUN pip install uv && \
    uv pip install --system huggingface_hub[cli]

# 4. Download the Model (Qwen 4B)
# We exclude .bin files to ensure we use the faster safetensors
RUN huggingface-cli download Qwen/Qwen3-4B-Thinking-2507 \
    --local-dir /app/model \
    --local-dir-use-symlinks False \
    --exclude "*.bin" "*.pth"

# 5. Environment Variables
ENV MODEL="/app/model"
ENV SERVED_MODEL_NAME="qwen3"
ENV VLLM_ENFORCE_EAGER="true"
ENV VLLM_NO_USAGE_STATS="1"

# 6. Entrypoint
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]

# 7. COMMAND (THE FIX IS HERE)
# --max-model-len 8192:  Prevents the 36GB RAM crash.
# --dtype half:          Loads model instantly in FP16.
# --enforce-eager:       Skips slow startup checks.

CMD ["--model", "/app/model", \
     "--served-model-name", "qwen3", \
     "--trust-remote-code", \
     "--dtype", "half", \
     "--max-model-len", "16384", \
     "--gpu-memory-utilization", "0.95", \
     "--enforce-eager"]