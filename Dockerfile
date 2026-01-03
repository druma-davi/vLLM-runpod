# 1. Use the official vLLM image (highly optimized for speed)
FROM vllm/vllm-openai:latest

# 2. Set the working directory
WORKDIR /app

# 3. Install Hugging Face CLI to download the model
RUN pip install --upgrade pip && \
    pip install huggingface_hub[cli]

# 4. Download the model weights inside the image
# This is the "Baking" step. The model becomes part of the file system.
# We download to /app/model
RUN huggingface-cli download Qwen/Qwen3-4B-Thinking-2507 \
    --local-dir /app/model \
    --local-dir-use-symlinks False

# 5. Set Environment Variables for vLLM
# These tell vLLM where the model is and how to treat it.
ENV MODEL="/app/model"
ENV SERVED_MODEL_NAME="qwen3"
ENV TRUST_REMOTE_CODE="True"

# 6. Define the start command
# We use the vLLM OpenAI compatible server
# We force float16 for speed (or use --quantization bitsandbytes if you strictly need 4bit to save RAM)
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--model", "/app/model", "--served-model-name", "qwen3", "--trust-remote-code", "--dtype", "half"]