FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS downloader

SHELL ["/bin/bash", "-c"]

# Install wget first
RUN apt-get update && apt-get install -y wget

WORKDIR /models

# Create directories with proper permissions
RUN mkdir -p checkpoints vae loras style_models clip_vision unet clip input

ARG HUGGINGFACE_ACCESS_TOKEN
RUN echo "Token prefix: ${HUGGINGFACE_ACCESS_TOKEN:0:8}..."

# Download new models while preserving existing ones
RUN wget -O /models/unet/flux1-fill-dev.safetensors --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors
RUN wget -O /models/clip_vision/siglip-so400m-patch14-384.safetensors https://huggingface.co/google/siglip-so400m-patch14-384/resolve/main/model.safetensors
RUN wget -O /models/clip/ViT-L-14-BEST-smooth-GmP-ft.safetensors https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-BEST-smooth-GmP-ft.safetensors
RUN wget -O /models/unet/flux1-canny-dev.safetensors --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" https://huggingface.co/black-forest-labs/FLUX.1-Canny-dev/resolve/main/flux1-canny-dev.safetensors

FROM whitemoney293/comfyui-flux-models:v1.0.0
COPY --from=downloader /models /models

RUN echo "Verifying files in final image:" && \
    find /models -type f -name "*.safetensors" -exec ls -lh {} \;