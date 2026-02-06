import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0', // VITAL: Permite que Docker exponga el puerto al exterior
    port: 3000,      // Forzamos el puerto 3000 (el que espera nuestro docker-compose)
    watch: {
      usePolling: true, // Necesario para que la recarga automática funcione bien en Docker
    },
  },
})
