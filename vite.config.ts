import { defineConfig } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'

// eslint-disable-next-line import/no-default-export
export default defineConfig({
  plugins: [
    VitePWA({
      // includeAssets: [
      //   'apple-touch-icon.png',
      //   'browserconfig.xml',
      //   'favicon-16x16.png',
      //   'favicon-32x32',
      //   'favicon.ico',
      //   'mstile-150x150.png',
      // ],
      manifest: {
        name: 'Ticket to Ride',
        short_name: 'Ticket to Ride',
        description: 'Ticket to Ride',
        icons: [
          {
            src: '/android-chrome-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: '/android-chrome-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
        ],
        theme_color: '#0d0d0d',
        background_color: '#0d0d0d',
        display: 'standalone',
      },
    }),
  ],
})
