# Dockerfile.models
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS downloader

SHELL ["/bin/bash", "-c"]

WORKDIR /models

# Create necessary directories
RUN mkdir -p checkpoints vae loras style_models clip_vision unet clip input

RUN apt-get update && apt-get install -y wget


ARG HUGGINGFACE_ACCESS_TOKEN
RUN echo "Token prefix: ${HUGGINGFACE_ACCESS_TOKEN:0:8}..."

# Download FLUX models (original set)
RUN wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" \
    -O /models/unet/flux1-dev.safetensors \
    https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors && \
    wget -O /models/clip/clip_l.safetensors \
    https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
    wget -O /models/clip/t5xxl_fp8_e4m3fn.safetensors \
    https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors && \
    wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" \
    -O /models/vae/ae.safetensors \
    https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors && \
    wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" \
    -O /models/clip_vision/sigclip_vision_patch14_384.safetensors \
    https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors && \
    wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" \
    -O /models/style_models/flux1-redux-dev.safetensors \
    https://huggingface.co/black-forest-labs/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors

# # Download SDXL models
# RUN wget -O checkpoints/sd_xl_base_1.0.safetensors \
#     https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
#     wget -O vae/sdxl_vae.safetensors \
#     https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors && \
#     wget -O vae/sdxl-vae-fp16-fix.safetensors \
#     https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

# # Download SD3 models
# RUN wget --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" \
#     -O checkpoints/sd3_medium_incl_clips_t5xxlfp8.safetensors \
#     https://huggingface.co/stabilityai/stable-diffusion-3-medium/resolve/main/sd3_medium_incl_clips_t5xxlfp8.safetensors

# # Download FLUX1-schnell models
# RUN wget -O unet/flux1-schnell.safetensors \
#     https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.safetensors && \
#     wget -O vae/ae_schnell.safetensors \
#     https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors

# Verify downloaded files
RUN echo "Listing all downloaded files:" && \
    find . -type f -name "*.safetensors" -exec ls -lh {} \;

# Use a small base image for the final stage
FROM alpine:latest
COPY --from=downloader /models /models

# Verify files in final image
RUN echo "Verifying files in final image:" && \
    find /models -type f -name "*.safetensors" -exec ls -lh {} \;