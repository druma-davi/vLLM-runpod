import runpod
from vllm import LLM, SamplingParams

# 1. GLOBAL INITIALIZATION
# We load the model once when the container starts, just like your sentiment code.
print("--- Loading Qwen Model ---")
llm = LLM(
    model="/app/model",
    trust_remote_code=True,
    dtype="half",
    max_model_len=8192,           # Fixes the memory crash
    gpu_memory_utilization=0.95,  # Maximizes GPU usage
    enforce_eager=True            # Fast boot
)
print("--- Model Loaded Successfully ---")

def handler(job):
    """
    This function runs every time you send a request.
    """
    job_input = job["input"]
    
    # Get the prompt from the user input
    # Supporting both "prompt" (standard) and "messages" (chat format)
    prompt = job_input.get("prompt")
    messages = job_input.get("messages")
    
    if messages and not prompt:
        # Simple chat formatting
        prompt = ""
        for msg in messages:
            prompt += f"<|im_start|>{msg['role']}\n{msg['content']}<|im_end|>\n"
        prompt += "<|im_start|>assistant\n"

    if not prompt:
        return {"error": "Please provide a 'prompt' or 'messages' in the input."}

    # Setup generation parameters
    sampling_params = SamplingParams(
        temperature=job_input.get("temperature", 0.7),
        top_p=0.95,
        max_tokens=job_input.get("max_tokens", 500)
    )

    # Run Inference (Fast vLLM engine)
    outputs = llm.generate([prompt], sampling_params)
    generated_text = outputs[0].outputs[0].text

    return {
        "text": generated_text,
        "usage": {
            "input_tokens": len(outputs[0].prompt_token_ids),
            "output_tokens": len(outputs[0].outputs[0].token_ids)
        }
    }

# Start the RunPod worker
runpod.serverless.start({"handler": handler})