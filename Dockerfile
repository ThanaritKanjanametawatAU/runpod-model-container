FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS downloader

SHELL ["/bin/bash", "-c"]

# Install wget first
RUN apt-get update && apt-get install -y wget

WORKDIR /models

# Create directories with proper permissions
RUN mkdir -p checkpoints vae loras style_models clip_vision unet clip input sams grounding-dino diffusers diffusers/StableHair upscale_models

ARG HUGGINGFACE_ACCESS_TOKEN
RUN echo "Token prefix: ${HUGGINGFACE_ACCESS_TOKEN:0:8}..."

ARG CIVITAI_API_KEY
RUN echo "Civitai API Key prefix: ${CIVITAI_API_KEY:0:8}..."

# Download new models while preserving existing ones
# downloading https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth to /comfyui/models/sams/sam_vit_h_4b8939.pth
RUN wget -O /models/sams/sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth

# downloading https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/GroundingDINO_SwinT_OGC.cfg.py to /models/grounding-dino/GroundingDINO_SwinT_OGC.cfg.py
RUN wget -O /models/grounding-dino/GroundingDINO_SwinT_OGC.cfg.py https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/GroundingDINO_SwinT_OGC.cfg.py

# downloading https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/groundingdino_swint_ogc.pth to /models/grounding-dino/groundingdino_swint_ogc.pth
RUN wget -O /models/grounding-dino/groundingdino_swint_ogc.pth https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/groundingdino_swint_ogc.pth

# Download Hair Model
RUN wget --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -O /models/diffusers/StableHair/hair_adapter_model.bin https://huggingface.co/lldacing/StableHair/resolve/main/hair_adapter_model.bin

RUN wget --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -O /models/diffusers/StableHair/hair_bald_model.bin https://huggingface.co/lldacing/StableHair/resolve/main/hair_bald_model.bin

RUN wget --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -O /models/diffusers/StableHair/hair_controlnet_model.bin https://huggingface.co/lldacing/StableHair/resolve/main/hair_controlnet_model.bin

RUN wget --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -O /models/diffusers/StableHair/hair_encoder_model.bin https://huggingface.co/lldacing/StableHair/resolve/main/hair_encoder_model.bin


# Upscaler model 
RUN wget --header="Authorization: Bearer $HUGGINGFACE_ACCESS_TOKEN" -O /models/upscale_models/4x-UltraSharp.pth https://huggingface.co/datasets/Kizi-Art/Upscale/resolve/fa98e357882a23b8e7928957a39462fbfaee1af5/4x-UltraSharp.pth

# Install Python
RUN apt-get install -y python3

# Add Civit AI Downloader
RUN wget https://raw.githubusercontent.com/ashleykleynhans/civitai-downloader/main/download.py
RUN mv download.py /usr/local/bin/download-model
RUN chmod +x /usr/local/bin/download-model

# Create the config file
RUN mkdir -p /root/.civitai && echo -n "$CIVITAI_API_KEY" > /root/.civitai/config

# Download CivitAI Models
RUN download-model https://civitai.com/api/download/models/274039 /models/checkpoints/


FROM whitemoney293/comfyui-flux-models:v1.1.0
COPY --from=downloader /models /models

RUN echo "Verifying files in final image:" && \
    find /models -type f -name "*.safetensors" -exec ls -lh {} \;