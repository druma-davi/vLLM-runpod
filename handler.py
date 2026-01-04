import runpod
from vllm import LLM, SamplingParams

# INITIALIZE AWQ MODEL
print("--- Loading AWQ Model (Fast Boot) ---")
llm = LLM(
    model="/app/model",
    trust_remote_code=True,
    quantization="awq",           # CRITICAL: Native 4-bit support
    dtype="half",                 # Works best with AWQ on NVIDIA
    max_model_len=19384,          # 16k context window
    gpu_memory_utilization=0.9,   # Plenty of room for KV cache
    enforce_eager=True            # Skip warmup for instant boot
)
print("--- AWQ Model Ready ---")

def handler(job):
    job_input = job.get("input", {})
    prompt = job_input.get("prompt")
    messages = job_input.get("messages")

    # ChatML formatting for Qwen
    if messages and not prompt:
        prompt = "".join([f"<|im_start|>{m['role']}\n{m['content']}<|im_end|>\n" for m in messages])
        prompt += "<|im_start|>assistant\n"

    if not prompt: return {"error": "No input"}

    sampling_params = SamplingParams(
        temperature=job_input.get("temperature", 0.6),
        top_p=0.95,
        max_tokens=job_input.get("max_tokens", 1000),
        stop=["<|im_end|>"]
    )

    outputs = llm.generate([prompt], sampling_params)
    return {"text": outputs[0].outputs[0].text}

runpod.serverless.start({"handler": handler})