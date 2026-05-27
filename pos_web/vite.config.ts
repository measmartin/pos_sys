import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@PosApi': path.resolve(__dirname, '@PosApi'),
    },
  },
  server: {
    port: 5173,
  },
})
