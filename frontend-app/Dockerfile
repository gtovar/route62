FROM node:20-alpine
WORKDIR /app

# Copiamos los archivos de dependencias
COPY package.json ./

# Instalamos las dependencias
RUN npm install

# Copiamos el código
COPY . .

EXPOSE 3000

# Comando para iniciar el servidor de desarrollo
CMD ["npm", "run","dev"]
