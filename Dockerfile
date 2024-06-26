# Usa la imagen base adecuada para tu aplicación
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Actualiza el sistema e instala las dependencias necesarias
RUN apt-get update && apt-get install -y build-essential aria2 git python3 python3-pip

# Clona el repositorio y configura el directorio de trabajo
WORKDIR /app
RUN git clone -b v2.5 https://github.com/camenduru/text-generation-webui

# Instala las dependencias de Python
COPY requirements.txt .
RUN pip3 install -r requirements.txt

WORKDIR /app/text-generation-webui

# Descarga los modelos y archivos necesarios
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/resolve/main/model-00001-of-00002.safetensors -d models/Llama-2-7b-chat-hf -o model-00001-of-00002.safetensors \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/resolve/main/model-00002-of-00002.safetensors -d models/Llama-2-7b-chat-hf -o model-00002-of-00002.safetensors \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/raw/main/model.safetensors.index.json -d models/Llama-2-7b-chat-hf -o model.safetensors.index.json \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/raw/main/special_tokens_map.json -d models/Llama-2-7b-chat-hf -o special_tokens_map.json \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/resolve/main/tokenizer.model -d models/Llama-2-7b-chat-hf -o tokenizer.model \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/raw/main/tokenizer_config.json -d models/Llama-2-7b-chat-hf -o tokenizer_config.json \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/raw/main/config.json -d models/Llama-2-7b-chat-hf -o config.json \
    && aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/4bit/Llama-2-7b-chat-hf/raw/main/generation_config.json -d models/Llama-2-7b-chat-hf -o generation_config.json

# Crea el archivo de configuración
RUN echo "dark_theme: true" > /app/settings.yaml \
    && echo "chat_style: wpp" >> /app/settings.yaml

# Expón el puerto si es necesario
EXPOSE 80

# Ejecuta el servidor cuando se inicie el contenedor
CMD ["python3", "server.py", "--share", "--settings", "/app/settings.yaml", "--model", "/app/text-generation-webui/models/Llama-2-7b-chat-hf"]
